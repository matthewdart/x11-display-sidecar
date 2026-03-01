#!/usr/bin/env bash
# wait-for-display.sh — poll until DISPLAY is available, then exec args
DISPLAY="${DISPLAY:-:99}"
until xdpyinfo -display "$DISPLAY" >/dev/null 2>&1; do
  sleep 0.5
done
exec "$@"
