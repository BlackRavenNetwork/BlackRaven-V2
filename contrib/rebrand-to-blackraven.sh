#!/usr/bin/env bash
# Mechanical BlackRaven -> BlackRaven rebrand (run from repo root).
# Review `git diff` before committing. Does not change chainparams economics/genesis.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ ! -f configure.ac ]] || ! grep -q 'BlackRaven' configure.ac 2>/dev/null; then
  echo "This does not look like a fresh BlackRaven tree (already rebranded?)." >&2
  exit 1
fi

echo "Rebranding under $ROOT ..."

# File names containing neoxa (excluding .git)
while IFS= read -r -d '' f; do
  base="$(basename "$f")"
  dir="$(dirname "$f")"
  newbase="${base//neoxa/blackraven}"
  newbase="${newbase//BlackRaven/Blackraven}"
  newbase="${newbase//BLACKRAVEN/BLACKRAVEN}"
  if [[ "$base" != "$newbase" ]]; then
    git mv -f "$f" "$dir/$newbase" 2>/dev/null || mv "$f" "$dir/$newbase"
  fi
done < <(find . -name '*[Nn]eoxa*' -o -name '*BLKR*' 2>/dev/null | grep -v '.git' | sort -r | tr '\n' '\0' || true)

# Content replacements (order matters for some patterns)
export LC_ALL=C
find . -type f \( \
  -name '*.cpp' -o -name '*.h' -o -name '*.c' -o -name '*.md' -o -name '*.am' -o \
  -name '*.ac' -o -name '*.in' -o -name '*.py' -o -name '*.sh' -o -name '*.yml' -o \
  -name '*.json' -o -name '*.pc.in' -o -name '*.1' -o -name '*.qm' -o -name 'CMakeLists.txt' \
\) ! -path './.git/*' ! -path './depends/*' -print0 | \
  xargs -0 sed -i \
    -e 's/blackraven/blackraven/g' \
    -e 's/BlackRaven/BlackRaven/g' \
    -e 's/BlackRaven/BlackRaven/g' \
    -e 's/BlackRaven/BlackRaven/g' \
    -e 's/blackraven-/blackraven-/g' \
    -e 's/blackraven_/blackraven_/g' \
    -e 's/blackravend/blackravend/g' \
    -e 's/BLACKRAVEN/BLACKRAVEN/g' \
    -e 's/BLKR/BLKR/g' \
    -e 's/neoxa\.net/blackraven.network/g' \
    -e 's/neoxa\.gitbook/blackraven.network/g'

# Config header guard (sed may have over-replaced; fix common cases)
if [[ -f src/config/blackraven-config.h.in ]]; then
  sed -i 's/BLACKRAVEN_CONFIG_H/BLACKRAVEN_CONFIG_H/g' src/config/blackraven-config.h.in 2>/dev/null || true
fi

echo "Done. Next: edit src/chainparams.cpp (genesis, ports, rewards), then ./autogen.sh && ./configure"
echo "Run: git status && git diff --stat"
