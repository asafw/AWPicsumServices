#!/usr/bin/env zsh
# ios_screenshots.sh — Run iOS screenshot UITests and extract PNGs.
#
# Usage (from repo root):
#   bash scripts/ios_screenshots.sh
#
# Output: screenshots/ios/*.png
#
# No API key required — Lorem Picsum is a free, open API.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
IOS_DIR="$REPO_ROOT/Examples/PicsumDemoApp-iOS"
OUT_DIR="$REPO_ROOT/screenshots/ios"
BUNDLE="/tmp/picsumdemo_screenshots.xcresult"

mkdir -p "$OUT_DIR"
cd "$IOS_DIR"

echo "▶ Generating Xcode project…"
xcodegen generate --quiet

rm -rf "$BUNDLE"
echo "▶ Running screenshot tests (real network — picsum.photos)…"
set +e
xcodebuild test \
  -scheme PicsumDemoApp-iOS \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:PicsumDemoScreenshots \
  -resultBundlePath "$BUNDLE" \
  2>&1 | grep -E '(📸|error:|Test Case.*passed|Test Case.*failed|Executed)'
set -e

echo "▶ Extracting PNGs…"
python3 "$REPO_ROOT/scripts/extract_ios_screenshots.py" "$BUNDLE" "$OUT_DIR"

echo "▶ Done. Screenshots written to $OUT_DIR"
ls "$OUT_DIR"
