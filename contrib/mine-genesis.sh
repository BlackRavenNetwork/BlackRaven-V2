#!/usr/bin/env bash
# Mine BlackRaven v2 mainnet and/or testnet genesis (KawPoW). Run from repo root.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/src"

NETWORK="${1:-all}"
HOST_PREFIX="${HOST_PREFIX:-$ROOT/depends/x86_64-pc-linux-gnu}"
DEPFLAGS=(
  -m64 -std=c++14 -DHAVE_CONFIG_H
  -I. -I../src/config -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=2 -I./obj
  -DBOOST_SP_USE_STD_ATOMIC -DBOOST_AC_USE_STD_ATOMIC -pthread
  -I"$HOST_PREFIX/include"
  -I./leveldb/include -I./leveldb/helpers/memenv
  -I./secp256k1/include -I./univalue/include
  -DHAVE_BUILD_INFO -D__STDC_FORMAT_MACROS
  -fPIE -pipe -static-libstdc++ -O2 -g1 -fno-omit-frame-pointer
)

compile_mine_o() {
  local net="$1"
  local defs=(-DBLKR_MINE_GENESIS)
  [[ "$net" == "test" ]] && defs+=(-DBLKR_MINE_TESTNET)
  rm -f libblackraven_common_a-chainparams.o
  g++ "${DEPFLAGS[@]}" "${defs[@]}" -c -o libblackraven_common_a-chainparams.o chainparams.cpp
  ar rs libblackraven_common.a libblackraven_common_a-chainparams.o >/dev/null
  make blackravend >/dev/null
}

mine_one() {
  local net="$1"
  local datadir="/tmp/blk-genesis-mine-$net-$$"
  local log="/tmp/blk-genesis-mine-$net.log"
  mkdir -p "$datadir"
  echo "=== Mining $net genesis (see $log) ==="
  compile_mine_o "$net"
  local args=(-datadir="$datadir")
  [[ "$net" == "test" ]] && args+=(-testnet)
  stdbuf -oL ./blackravend "${args[@]}" 2>&1 | tee "$log"
  rm -rf "$datadir"
}

case "$NETWORK" in
  main) mine_one main ;;
  test) mine_one test ;;
  all) mine_one main; mine_one test ;;
  *) echo "Usage: $0 [main|test|all]" >&2; exit 1 ;;
esac

echo ""
echo "Paste values from /tmp/blk-genesis-mine-*.log into contrib/genesis-values.h"
echo "Set BLKR_*_GENESIS_MINED to 1, rebuild without BLKR_MINE_GENESIS."
