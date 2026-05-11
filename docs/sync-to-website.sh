#!/usr/bin/env bash
# sync-to-website.sh
#
# Builds the BodyMetrics docs Hugo site and syncs the output into
# the personal GitHub Pages website under static/bodymetrics/.
#
# Usage:
#   ./docs/sync-to-website.sh
#
# Requirements:
#   - hugo installed (https://gohugo.io)
#   - The personal website repo checked out at WEBSITE_DIR
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCS_DIR="$SCRIPT_DIR"
WEBSITE_DIR="/home/gregorio/Software/myProjects/gregoriolagamba.github.io"
DEST_DIR="$WEBSITE_DIR/static/bodymetrics"

echo "==> Building BodyMetrics docs (Hugo)..."
cd "$DOCS_DIR"
hugo --minify --destination "$DOCS_DIR/public"

echo "==> Syncing to $DEST_DIR ..."
mkdir -p "$DEST_DIR"
rsync -av --delete "$DOCS_DIR/public/" "$DEST_DIR/"

echo ""
echo "✅ Done. Docs available at: $DEST_DIR"
echo "   Will be served at: https://gregoriolagamba.github.io/bodymetrics/"
echo ""
echo "Next steps:"
echo "  1. cd $WEBSITE_DIR"
echo "  2. git add static/bodymetrics"
echo "  3. git commit -m 'docs: sync BodyMetrics documentation'"
echo "  4. git push"
