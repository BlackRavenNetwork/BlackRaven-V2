#!/usr/bin/env bash
# Mine BlackRaven v2 mainnet and/or testnet genesis (KawPoW). Run from repo root.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

NETWORK="${1:-all}"
JOBS="${JOBS:-$(nproc)}"
HOST_PREFIX="${HOST_PREFIX:-$ROOT/depends/x86_64-pc-linux-gnu}"

if [[ ! -f ./configure ]]; then
  ./autogen.sh
fi

if [[ ! -f Makefile ]]; then
  if [[ -d "$HOST_PREFIX" ]]; then
    ./configure --prefix="$HOST_PREFIX" --without-gui --disable-wallet
  else
    echo "Run: cd depends && make -j\$(nproc)   OR install system deps and ./configure" >&2
    ./configure --without-gui --disable-wallet
  fi
fi

mine_one() {
  local net="$1"
  local extra_cflags
  if [[ "$net" == "test" ]]; then
    extra_cflags="-DBLKR_MINE_GENESIS -DBLKR_MINE_TESTNET"
  else
    extra_cflags="-DBLKR_MINE_GENESIS"
  fi
  echo "=== Mining $net genesis (KawPoW; may take several minutes) ==="
  rm -f src/chainparams.o
  make -j"$JOBS" AM_CXXFLAGS="$extra_cflags" CXXFLAGS="$extra_cflags" src/blackravend
  ./src/blackravend -version 2>&1 | tee "/tmp/blk-genesis-mine-$net.log"
}

case "$NETWORK" in
  main) mine_one main ;;
  test) mine_one test ;;
  all)
    mine_one main
    mine_one test
    ;;
  *)
    echo "Usage: $0 [main|test|all]" >&2
    exit 1
    ;;
esac

echo ""
echo "See /tmp/blk-genesis-mine-*.log for values to paste into contrib/genesis-values.h"
echo "Set BLKR_*_GENESIS_MINED to 1 and rebuild."
