#!/usr/bin/env bash
set -euo pipefail

sysctl -w net.ipv4.conf.all.arp_ignore=1  >/dev/null 2>&1 || true
sysctl -w net.ipv4.conf.all.arp_announce=2 >/dev/null 2>&1 || true

: "${ONVIF_CONFIG:=/onvif.yaml}"
if [ ! -f "$ONVIF_CONFIG" ]; then
  echo "onvif: []" > "$ONVIF_CONFIG"
fi

exec /usr/bin/tini -- node /app/manager/server.js