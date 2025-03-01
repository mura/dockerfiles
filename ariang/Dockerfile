# syntax=docker/dockerfile:1.4
FROM golang:1.23-bookworm as build

RUN <<EOF
set -eux
apt-get update
apt-get install -y --no-install-recommends \
  git \
  curl
rm -rf /var/lib/apt/lists/*
EOF

# goreman supervisor build latest
WORKDIR /work
RUN <<EOF
set -eux
export GOPATH=/work
export CGO_ENABLED=0
go install github.com/mattn/goreman@latest
EOF

FROM debian:bookworm-slim

# customizable values
ENV RPC_PORT 6800
ENV HTTPD_PORT 8080
ENV USE_HTTPD true

# persistent / runtime deps
RUN <<EOF
set -eux
apt-get update
apt-get install -y --no-install-recommends \
  busybox-static \
  ca-certificates \
  curl
rm -rf /var/lib/apt/lists/*
EOF

# build aria2
ENV ARIA2_URL=https://github.com/aria2/aria2/releases/download/release-1.37.0/aria2-1.37.0.tar.xz
RUN <<EOF
set -eux

savedAptMark="$(apt-mark showmanual)"
apt-get update
apt-get install -y --no-install-recommends \
  build-essential \
  gnutls-dev \
  nettle-dev \
  libgmp-dev \
  libssh2-1-dev \
  libc-ares-dev \
  libxml2-dev \
  zlib1g-dev \
  libsqlite3-dev \
  pkg-config \
  libcppunit-dev \
  autoconf \
  automake \
  autotools-dev \
  autopoint \
  libtool

mkdir -p /usr/src
cd /usr/src

curl -fsSL -o aria2.tar.xz "$ARIA2_URL"
mkdir -p /usr/src/aria2
tar -Jxf aria2.tar.xz -C aria2 --strip-components=1
cd /usr/src/aria2
gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"
autoreconf -i
./configure \
  --build="$gnuArch" \
  --with-ca-bundle='/etc/ssl/certs/ca-certificates.crt'
make -j "$(nproc)"
make install
find /usr/local/bin /usr/local/sbin -type f -executable -exec strip --strip-all '{}' + || true

cd /
rm -rf /usr/src/aria2

# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
apt-mark auto '.*' > /dev/null
[ -z "$savedAptMark" ] || apt-mark manual $savedAptMark
find /usr/local -type f -executable -exec ldd '{}' ';' \
  | awk '/=>/ { print $(NF-1) }' \
  | sort -u \
  | sed 's,\(.*\),\1\n/usr\1,g' \
  | xargs -r dpkg-query --search \
  | cut -d: -f1 \
  | sort -u \
  | xargs -r apt-mark manual

apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false

# smoke test
aria2c --version
EOF

# AriaNg install latest
RUN <<EOF
set -eux
savedAptMark="$(apt-mark showmanual)"
apt-get update
apt-get install -y --no-install-recommends \
  unzip \
  jq
rm -rf /var/lib/apt/lists/*
mkdir -p /usr/src
cd /usr/src
GITHUB_API="https://api.github.com/repos/mayswind/AriaNg"
DOWNLOAD_URL=$(curl -s "${GITHUB_API}/releases/latest" | jq -r '.assets[].browser_download_url | select(. | contains("AllInOne.zip"))')
curl -fsSL -o ariang.zip "$DOWNLOAD_URL"
unzip ariang.zip -d ariang
mkdir -p /app/www
mkdir -p /app/cache
cp -p /usr/src/ariang/index.html /app/www/index.html
cd /
rm -rf /usr/src/ariang
apt-mark auto '.*' > /dev/null
apt-mark manual $savedAptMark > /dev/null
apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false
EOF

# copy built goreman
COPY --from=build /work/bin/goreman /usr/local/bin/goreman

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod 755 /docker-entrypoint.sh

# aria2 downloads directory
VOLUME [ "/data" ]

ENTRYPOINT ["/docker-entrypoint.sh"]
WORKDIR /app

RUN <<EOF
set -eux
tee /app/aria2.conf <<EOC
enable-rpc
rpc-listen-all
rpc-allow-origin-all
rpc-listen-port=${RPC_PORT}
dir=/data
dht-file-path=/app/cache/dht.dat
dht-file-path6=/app/cache/dht6.dat
EOC
EOF

EXPOSE ${RPC_PORT}/tcp ${HTTPD_PORT}/tcp
CMD ["aria2c", "--conf-path=/app/aria2.conf"]
