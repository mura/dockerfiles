# syntax=docker/dockerfile:1.4
FROM debian:bookworm as builder

RUN <<EOF
set -eux
apt-get update
apt-get install -y --no-install-recommends \
    wget \
    ca-certificates \
    build-essential
rm -rf /var/lib/apt/lists/*
EOF

WORKDIR /build
RUN <<EOF
set -eux
wget -L -O ethersrv-linux.tar.gz 'https://sourceforge.net/projects/etherdfs/files/ethersrv-linux/ethersrv-linux-20180203.tar.xz/download'
mkdir ethersrv-linux
tar -xf ethersrv-linux.tar.gz -C ethersrv-linux --strip-components=1
cd ethersrv-linux
make
EOF

FROM debian:bookworm-slim

WORKDIR /app
VOLUME [ "/data" ]

COPY --from=builder /build/ethersrv-linux/ethersrv-linux /app/ethersrv-linux

ENTRYPOINT [ "/app/ethersrv-linux" ]
CMD [ "-f", "eth0", "/data" ]
