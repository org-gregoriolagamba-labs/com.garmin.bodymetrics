#!/usr/bin/env bash
# Build BodyMetrics for every device listed in manifest.xml and report results.
# Usage: bash .vscode/build-all-devices.sh [--fail-fast]

set -uo pipefail

MONKEYC="/home/gregorio/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-9.1.0-2026-03-09-6a872a80b/bin/monkeyc"
KEY="/home/gregorio/.Garmin/ConnectIQ/Keys/bodymetrics-dev-key.pk8.der"
OUT_DIR="/tmp/bodymetrics-builds"
FAIL_FAST=false

for arg in "$@"; do
  [[ "$arg" == "--fail-fast" ]] && FAIL_FAST=true
done

mkdir -p "$OUT_DIR"

# Extract product ids from <iq:product id="..."/> lines only (skip application UUID)
DEVICES=$(grep -oP '(?<=<iq:product id=")[^"]+' manifest.xml | sort)

PASS=()
FAIL=()

echo "========================================="
echo "BodyMetrics — multi-device build report"
echo "========================================="
echo ""

for dev in $DEVICES; do
  printf "  %-28s ... " "$dev"
  result=$("$MONKEYC" -f monkey.jungle -d "$dev" -o "$OUT_DIR/BodyMetrics_${dev}.prg" -y "$KEY" 2>&1)
  if echo "$result" | grep -q "BUILD SUCCESSFUL"; then
    echo "OK"
    PASS+=("$dev")
  else
    echo "FAIL"
    echo "    $result"
    FAIL+=("$dev")
    if $FAIL_FAST; then
      echo ""
      echo "Stopped at first failure (--fail-fast)."
      exit 1
    fi
  fi
done

echo ""
echo "========================================="
echo "PASS: ${#PASS[@]}   FAIL: ${#FAIL[@]}"
echo "========================================="

if [[ ${#FAIL[@]} -gt 0 ]]; then
  echo ""
  echo "Failed devices:"
  for dev in "${FAIL[@]}"; do
    echo "  - $dev"
  done
  exit 1
fi

echo ""
echo "All devices built successfully."
