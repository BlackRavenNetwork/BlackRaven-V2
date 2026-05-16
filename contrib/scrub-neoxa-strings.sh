#!/usr/bin/env bash
# Second-pass scrub of leftover Neoxa strings (run from repo root).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

export LC_ALL=C

mapfile -d '' FILES < <(
  find . -type f \( \
    -name '*.cpp' -o -name '*.h' -o -name '*.c' -o -name '*.md' -o -name '*.am' -o \
    -name '*.ac' -o -name '*.in' -o -name '*.py' -o -name '*.sh' -o -name '*.yml' -o \
    -name '*.json' -o -name '*.pc.in' -o -name '*.1' -o -name '*.ts' -o -name '*.ui' -o \
    -name '*.css' -o -name '*.svg' -o -name '*.plist' -o -name '*.service' -o -name '*.openrc' \
    -o -name '*.include' -o -name '*.rc' -o -name '*.qrc' -o -name '*.mm' -o -name '*.pro' \
    -o -name 'CMakeLists.txt' -o -name 'Dockerfile' -o -name 'Jenkinsfile' -o -name '.travis.yml' \
    -o -name '.gitignore' \) \
    ! -path './.git/*' ! -path './depends/*' \
    ! -path './contrib/scrub-neoxa-strings.sh' \
    -print0
)

for f in "${FILES[@]}"; do
  sed -i \
    -e 's/neoxaconsensus/blackravenconsensus/g' \
    -e 's/neoxacoin_kawpow/blackraven_kawpow/g' \
    -e 's/neoxaqt/blackraven-qt/g' \
    -e 's/test_neoxa/test_blackraven/g' \
    -e 's/neoxa\.conf/blackraven.conf/g' \
    -e 's/neoxahash/blackravenhash/g' \
    -e 's/neoxagaming\.com/blackraven.network/g' \
    -e 's/neoxa\.exchange\/swap/blackraven.network/g' \
    -e 's/neoxa\.exchange/blackraven.network/g' \
    -e 's/neoxaevo\.org/blackraven.network/g' \
    -e 's/The-BlackRaven-Endeavor\/neoxa/BlackRavenNetwork\/BlackRaven-V2/g' \
    -e 's/BlackRavenChain\/BlackRaven/BlackRavenNetwork\/BlackRaven-V2/g' \
    -e 's/less neoxa /less BLKR /g' \
    -e 's/sending neoxas/sending BLKR/g' \
    -e 's/neoxas/BLKR/g' \
    -e 's/neoxa address/blackraven address/g' \
    -e 's/neoxa asset/blackraven asset/g' \
    -e 's/\"neoxa\"/\"blackraven\"/g' \
    -e 's/PACKAGE_NAME="neoxa"/PACKAGE_NAME="blackraven"/g' \
    -e 's/NEOXA/BLKR/g' \
    -e 's/Neoxa/BlackRaven/g' \
    -e 's/neoxa/blackraven/g' \
    "$f"
done

echo "Scrub complete. Review: git diff --stat"
