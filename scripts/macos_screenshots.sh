#!/usr/bin/env zsh
# macos_screenshots.sh — Capture macOS demo app screenshots using real live data.
#
# Usage (from repo root):
#   bash scripts/macos_screenshots.sh
#
# Output: screenshots/macos/*.png
#
# No API key required — Lorem Picsum is a free, open API.
# Requires: cliclick (brew install cliclick)

set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$REPO/screenshots/macos"
APP="$REPO/.build/debug/PicsumDemoApp"

mkdir -p "$OUT"

screenshot() {
  local name="$1"
  local pid="$2"
  python3 "$REPO/scripts/capture_macos_window.py" PicsumDemoApp "$OUT/${name}.png" "$pid"
  echo "📸 ${name}.png"
}

echo "▶ Building PicsumDemoApp…"
cd "$REPO"
swift build --product PicsumDemoApp 2>&1 | tail -2

# ── 1. Photo grid (real network load, no env vars) ──────────────────────────
echo "▶ Launching — photo grid…"
"$APP" &
APP_PID=$!
trap 'kill $APP_PID 2>/dev/null; true' EXIT
echo "  Waiting 16 s for photos + thumbnails to load from picsum.photos…"
sleep 16
screenshot "macos_photo_grid" "$APP_PID"
kill $APP_PID 2>/dev/null; trap - EXIT; sleep 1

# ── 2. Photo detail sheet (MOCK_DETAIL fires at t=14 s, after photos loaded) ─
echo "▶ Launching — photo detail…"
MOCK_DETAIL=1 "$APP" &
APP_PID=$!
trap 'kill $APP_PID 2>/dev/null; true' EXIT
echo "  Waiting 26 s for photos to load then detail sheet to open…"
sleep 26
screenshot "macos_photo_detail" "$APP_PID"
kill $APP_PID 2>/dev/null; trap - EXIT; sleep 1

echo "▶ Done."
ls "$OUT"
