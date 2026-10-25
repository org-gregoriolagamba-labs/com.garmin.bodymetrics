#!/usr/bin/env bash
# Build and launch BodyMetrics in the simulator for a given device.
# Usage: bash .vscode/run-sim.sh [DEVICE_ID]
# Default device: fr265
# Example: bash .vscode/run-sim.sh fenix7

set -euo pipefail

SIM="/home/gregorio/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-9.1.0-2026-03-09-6a872a80b/bin/simulator"
MONKEYC="/home/gregorio/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-9.1.0-2026-03-09-6a872a80b/bin/monkeyc"
MONKEYDO="/home/gregorio/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-9.1.0-2026-03-09-6a872a80b/bin/monkeydo"
KEY="/home/gregorio/.Garmin/ConnectIQ/Keys/bodymetrics-dev-key.pk8.der"
LOG="${PWD}/.vscode/bodymetrics-simulator.log"

DEVICE="${1:-fr265}"

# Verify the device is listed in the manifest
if ! grep -q "\"${DEVICE}\"" manifest.xml; then
  echo "ERROR: '${DEVICE}' is not listed in manifest.xml."
  echo ""
  echo "Available devices:"
  grep -oP '(?<=id=")[^"]+' manifest.xml | sort | sed 's/^/  /'
  exit 1
fi

echo "Building for: ${DEVICE}"

: > "$LOG"
pkill -f "connectiq-sdk-lin.*/bin/simulator" >/dev/null 2>&1 || true
nohup "$SIM" >> "$LOG" 2>&1 &
sim_pid=$!

sleep 2
if ! kill -0 "$sim_pid" 2>/dev/null; then
  echo "Simulator exited immediately. Check GUI session/display configuration."
  echo "Log: $LOG"
  tail -n 80 "$LOG" || true
  exit 1
fi

"$MONKEYC" -f monkey.jungle -d "$DEVICE" -o bin/BodyMetrics.prg -y "$KEY"

for attempt in $(seq 1 60); do
  if "$MONKEYDO" bin/BodyMetrics.prg "$DEVICE"; then
    exit 0
  fi
  sleep 1
done

echo "Unable to connect to simulator after 60 attempts."
echo "Log: $LOG"
tail -n 80 "$LOG" || true
exit 1
