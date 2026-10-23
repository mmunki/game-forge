#!/usr/bin/env bash
# Builds the Linux and Web exports, runs a headless project smoke test, and
# writes the SHA-256 checksums.  Safe to rerun: Godot's import cache and the
# build directory are incremental.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [ -z "${GODOT:-}" ]; then
  GODOT="$(bash tools/fetch_godot.sh | tail -1)"
fi
[ -x "$GODOT" ] || { echo "Godot not executable: $GODOT" >&2; exit 1; }

mkdir -p build/linux build/web

echo "==> importing resources"
"$GODOT" --headless --path . --import

echo "==> exporting Linux"
"$GODOT" --headless --path . --export-release "Linux" build/linux/game-forge.x86_64

echo "==> exporting Web"
"$GODOT" --headless --path . --export-release "Web" build/web/index.html

echo "==> loading the main scene headless"
"$GODOT" --headless --path . --quit-after 3

echo "==> packaging"
(
  cd build/linux
  rm -f ../game-forge-linux.zip
  zip -X -q -9 ../game-forge-linux.zip game-forge.x86_64
)
(
  cd build/web
  rm -f ../game-forge-web.zip
  zip -X -q -9 -r ../game-forge-web.zip .
)
sha256sum build/game-forge-linux.zip build/game-forge-web.zip > build/SHA256SUMS

echo "==> done"
cat build/SHA256SUMS
