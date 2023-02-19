#!/bin/bash
CACTI_DIR=/var/www/html/cacti

if [ ! -f "$CACTI_DIR/cactid.php" ]; then
  echo "Extract cacti files"
  mkdir -p /usr/src
  pushd /usr/src
    curl -fsSL -o cacti.tar.gz "$CACTI_URL"
    tar zxf cacti.tar.gz -C "$CACTI_DIR" --strip-components=1
  popd
fi
chown -R www-data:www-data "$CACTI_DIR"

sleep 1
/app/start-crond.sh
/app/start-cactid.sh
exec php-fpm "$@"
