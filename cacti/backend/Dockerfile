FROM docker.io/php:8.3-fpm-bookworm

ENV CACTI_URL="https://files.cacti.net/cacti/linux/cacti-1.2.27.tar.gz"
ENV SPINE_URL="https://files.cacti.net/spine/cacti-spine-1.2.27.tar.gz"

# persistent / runtime deps
RUN set -eux; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      snmp \
      rrdtool \
      busybox-static \
      procps \
      sudo \
      libmariadb3 \
    ; \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    \
    savedAptMark="$(apt-mark showmanual)"; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      zlib1g-dev \
      libpng-dev \
      libgmp-dev \
      libldap2-dev \
    ; \
    rm -rf /var/lib/apt/lists/*; \
    \
    docker-php-ext-install gettext gd gmp ldap pdo_mysql sockets pcntl; \
    \
    apt-mark auto '.*' > /dev/null; \
    [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
    find /usr/local -type f -executable -exec ldd '{}' ';' \
      | awk '/=>/ { print $(NF-1) }' \
      | sort -u \
      | xargs -r dpkg-query --search \
      | cut -d: -f1 \
      | sort -u \
      | xargs -r apt-mark manual \
    ; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false;

RUN set -eux; \
    \
    savedAptMark="$(apt-mark showmanual)"; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      autoconf \
      automake \
      dos2unix \
      g++ \
      gcc \
      libtool \
      m4 \
      make \
      help2man \
      libsnmp-dev \
      libssl-dev \
      libmariadb-dev-compat \
      libmariadb-dev \
    ; \
    rm -rf /var/lib/apt/lists/*; \
    \
    mkdir -p /usr/src; \
    cd /usr/src; \
    curl -fsSL -o /usr/local/share/ca-certificates/lets-encrypt-r3.crt https://letsencrypt.org/certs/lets-encrypt-r3.pem; \
    update-ca-certificates --fresh; \
    curl -fsSL -o cacti-spine.tar.gz "$SPINE_URL"; \
    mkdir -p cacti-spine; \
    tar zxf cacti-spine.tar.gz -C cacti-spine --strip-components=1; \
    \
    cd cacti-spine; \
    gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
    ./bootstrap; \
    ./configure \
      --build="$gnuArch"; \
    make -j "$(nproc)"; \
    mkdir -p /app; \
    cp -p spine /app; \
    strip --strip-all /app/spine; \
    chown root:root /app/spine; \
    chmod u+s /app/spine; \
    \
    rm -rf /usr/src/cacti-spine; \
    cd /; \
    \
    apt-mark auto '.*' > /dev/null; \
    [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
    find /usr/local -type f -executable -exec ldd '{}' ';' \
      | awk '/=>/ { print $(NF-1) }' \
      | sort -u \
      | xargs -r dpkg-query --search \
      | cut -d: -f1 \
      | sort -u \
      | xargs -r apt-mark manual \
    ; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false;

RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini

COPY --chown=root:root crontab /var/spool/cron/crontabs/www-data
COPY --chown=root:root www.conf /usr/local/etc/php-fpm.d/
COPY *.sh /app/

VOLUME [ "/var/www/html/cacti" ]

CMD ["/app/start.sh"]

HEALTHCHECK --start-period=3s CMD /app/healthcheck.sh
