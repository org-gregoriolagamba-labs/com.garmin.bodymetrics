#!/usr/bin/env bash
# PostToolUse (Edit|Write): compila per fr265 dopo una modifica a source/*.mc.
# Esce con 2 (e mostra l'errore a Claude) se la build fallisce.
set -uo pipefail

path=$(jq -r '.tool_input.file_path // empty')
[[ "$path" == *.mc ]] || exit 0

cd "${CLAUDE_PROJECT_DIR:-$PWD}" || exit 0

SDK="/home/gregorio/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-9.1.0-2026-03-09-6a872a80b"
KEY="/home/gregorio/.Garmin/ConnectIQ/Keys/bodymetrics-dev-key.pk8.der"
OUT="${TMPDIR:-/tmp}/bodymetrics-quick.prg"

[[ -x "$SDK/bin/monkeyc" && -f "$KEY" ]] || exit 0

result=$("$SDK/bin/monkeyc" -f monkey.jungle -d fr265 -o "$OUT" -y "$KEY" 2>&1)
if ! grep -q "BUILD SUCCESSFUL" <<<"$result"; then
  echo "Build fr265 fallita dopo la modifica di $path:" >&2
  echo "$result" | head -30 >&2
  exit 2
fi
if grep -qi "warning" <<<"$result"; then
  echo "Build fr265 riuscita con warning:" >&2
  grep -i "warning" <<<"$result" | head -10 >&2
fi
exit 0
