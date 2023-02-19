#!/bin/bash
if [ -f "/app/spine.conf" ]; then
  /app/spine -C /app/spine.conf > /dev/null 2>&1
else
  echo "[ERROR] spine.conf not found." > /dev/stderr
  exit 1
fi
