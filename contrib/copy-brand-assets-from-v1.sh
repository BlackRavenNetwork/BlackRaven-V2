#!/usr/bin/env bash
# Copy BlackRaven V1 Qt branding into this tree (run from BlackRaven-V2 root).
# Requires: V1 checkout at ../BlackRaven (or set BLACKRAVEN_V1_ROOT).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
V1="${BLACKRAVEN_V1_ROOT:-$(dirname "$ROOT")/BlackRaven}"
ICONS_V1="$V1/src/qt/res/icons"
ICONS_V2="$ROOT/src/qt/res/icons"
IMAGES_V2="$ROOT/src/qt/res/images"

if [[ ! -f "$ICONS_V1/blkr-512x512.png" ]]; then
  echo "V1 icons not found at $ICONS_V1 (set BLACKRAVEN_V1_ROOT)" >&2
  exit 1
fi

mkdir -p "$ICONS_V2" "$IMAGES_V2"

cp -f "$ICONS_V1/blkr-512x512.png" "$ICONS_V2/bitcoin.png"
cp -f "$ICONS_V1/blkr-512x512.png" "$ICONS_V2/blkr-512x512.png"
cp -f "$ICONS_V1/blkrtext.png" "$ICONS_V2/blkrtext.png"
cp -f "$ICONS_V1/blkrtext.png" "$IMAGES_V2/blackraven_logo_toolbar.png"
cp -f "$ICONS_V1/blkrcointext.png" "$IMAGES_V2/blackraven_logo_horizontal.png"
cp -f "$ICONS_V1/blkr.ico" "$ICONS_V2/blackraven.ico"
cp -f "$ICONS_V1/raven_testnet.ico" "$ICONS_V2/blackraven_testnet.ico"

python3 - "$ICONS_V1" "$IMAGES_V2" <<'PY'
import sys
from PIL import Image

v1, images_v2 = sys.argv[1], sys.argv[2]
icon512 = Image.open(f"{v1}/blkr-512x512.png").convert("RGBA")
w, h = 480, 540
splash = Image.new("RGB", (w, h), (15, 23, 42))
icon = icon512.resize((280, 280), Image.LANCZOS)
splash.paste(icon, (30, 90), icon)
splash.save(f"{images_v2}/splash_blackraven.png")
print("Updated splash_blackraven.png")
PY

echo "Brand assets copied from $V1"
