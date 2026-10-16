#!/usr/bin/env bash
# Full relink check: compile C, assemble asm, TLINK, whole-EXE compare. Every byte comes from src/ (the original
# EXEs are only read for the comparison).
# Usage: tools/relink.sh [retail|alt|all]   (default all; alt is skipped when game/DONALD is absent)
#   retail: build/link/DONALD.EXE     vs game/DONALD.EXE (sha256 c72ed190...)
#   alt:    build/link-alt/DONALD     vs game/DONALD     (sha256 61d3bc8b...), the same sources with DONALD_ALT
set -euo pipefail
cd "$(dirname "$0")/.."
T=${1:-all}
python3 tools/verify.py >/dev/null || { echo "verify.py failed (function mismatch)"; exit 1; }
rc=0
if [ "$T" != alt ]; then python3 tools/relink.py || rc=1; fi
if [ "$T" != retail ]; then
  if [ -f game/DONALD ]; then
    # only the units that have DONALD_ALT variants are rebuilt; everything else is shared with retail
    mapfile -t C < <(grep -l DONALD_ALT $(find src -name '*.c' | sort))
    DAC_TARGET=alt tools/build.sh "${C[@]}" >/dev/null
    mkdir -p build/alt/asm
    for a in $(grep -l DONALD_ALT src/asm/*.asm); do
      nasm -f obj -DDONALD_ALT -i src/asm/ -o "build/alt/asm/$(basename "$a" .asm).OBJ" "$a"
    done
    python3 tools/relink.py --alt || rc=1
  else echo "game/DONALD not present: alt target skipped"; fi
fi
exit $rc
