#!/usr/bin/env bash
# PreToolUse (Edit|Write): blocca la modifica dei file generati.
# manifest.xml resta modificabile solo con ALLOW_MANIFEST_EDIT=1 (usato dalla skill add-device).
set -uo pipefail

path=$(jq -r '.tool_input.file_path // empty')
[[ -z "$path" ]] && exit 0

rel="${path#"${CLAUDE_PROJECT_DIR:-$PWD}"/}"

case "$rel" in
  bin/*|output/*|docs/public/*|*.iq|*.log)
    echo "Bloccato: '$rel' è un artefatto generato. Rigenerarlo con la build, non modificarlo a mano." >&2
    exit 2 ;;
  manifest.xml)
    if [[ "${ALLOW_MANIFEST_EDIT:-0}" != "1" && ! -f "${CLAUDE_PROJECT_DIR:-$PWD}/.claude/.allow-manifest-edit" ]]; then
      echo "Bloccato: manifest.xml è un file generato. Per aggiungere dispositivi usa la skill /add-device." >&2
      exit 2
    fi ;;
esac
exit 0
