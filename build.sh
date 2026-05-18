#!/usr/bin/env bash
# Build BlackRaven Core (depends toolchain recommended). Run from repo root.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

HOST_PREFIX="${HOST_PREFIX:-$ROOT/depends/x86_64-pc-linux-gnu}"
JOBS="${JOBS:-$(nproc)}"
WITH_GUI="${WITH_GUI:-yes}"
RUN_TESTS="${RUN_TESTS:-no}"

if [[ ! -d "$HOST_PREFIX" ]]; then
  echo "Building depends (first time; can take 30+ minutes)..."
  make -C depends -j"$JOBS" HOST=x86_64-pc-linux-gnu
  make -C depends install HOST=x86_64-pc-linux-gnu
fi

if [[ ! -f ./configure ]]; then
  ./autogen.sh
fi

if [[ ! -f Makefile ]]; then
  CONFIG_SITE="$HOST_PREFIX/share/config.site"
  export CONFIG_SITE
  EXTRA=(--prefix="$HOST_PREFIX")
  if [[ "$WITH_GUI" == "yes" ]]; then
    EXTRA+=(--with-gui)
  else
    EXTRA+=(--without-gui)
  fi
  if [[ "$RUN_TESTS" == "no" ]]; then
    EXTRA+=(--disable-tests --disable-bench)
  fi
  ./configure "${EXTRA[@]}"
fi

make -j"$JOBS" -C src blackravend blackraven-cli blackraven-tx
if [[ "$WITH_GUI" == "yes" ]]; then
  make -j"$JOBS" -C src qt/blackraven-qt
fi

echo ""
echo "Built:"
echo "  src/blackravend"
echo "  src/blackraven-cli"
echo "  src/blackraven-tx"
[[ "$WITH_GUI" == "yes" ]] && echo "  src/qt/blackraven-qt"
