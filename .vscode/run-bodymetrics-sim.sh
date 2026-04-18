#!/usr/bin/env bash
set -euo pipefail

SIM="/home/gregorio/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-9.1.0-2026-03-09-6a872a80b/bin/simulator"
MONKEYC="/home/gregorio/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-9.1.0-2026-03-09-6a872a80b/bin/monkeyc"
MONKEYDO="/home/gregorio/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-9.1.0-2026-03-09-6a872a80b/bin/monkeydo"
KEY="/home/gregorio/.Garmin/ConnectIQ/Keys/bodymetrics-dev-key.pk8.der"
LOG="${PWD}/.vscode/bodymetrics-simulator.log"

: > "$LOG"
pkill -f "connectiq-sdk-lin.*/bin/simulator" >/dev/null 2>&1 || true
nohup "$SIM" >> "$LOG" 2>&1 &
sim_pid=$!

sleep 2
if ! kill -0 "$sim_pid" 2>/dev/null; then
  echo "Simulator exited immediately. Check GUI session/display configuration."
  echo "Log file: $LOG"
  ls -l "$LOG"
  tail -n 80 "$LOG" || true
  exit 1
fi

"$MONKEYC" -f monkey.jungle -d fr265 -o bin/BodyMetrics.prg -y "$KEY"

for attempt in $(seq 1 60); do
  if "$MONKEYDO" bin/BodyMetrics.prg fr265; then
    exit 0
  fi
  sleep 1
done

echo "Unable to connect to simulator after 60 attempts."
echo "Log file: $LOG"
ls -l "$LOG"
tail -n 80 "$LOG" || true
exit 1
