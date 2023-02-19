#!/bin/bash
if [ ! -f "/var/www/html/cacti/cactid.php" ]; then
  exit 1
fi

if [ "$(/usr/bin/pgrep -a php | /bin/grep cactid.php | /usr/bin/wc -l)" -lt 2 ]; then
  echo "[INFO] Restart cactid." > /dev/stderr
  /app/start-cactid.sh || exit 1
fi

if [ ! -f /var/run/crond.pid ] || [ ! -e "/proc/$(cat /var/run/crond.pid)" ]; then
  exit 1
fi

exit 0
