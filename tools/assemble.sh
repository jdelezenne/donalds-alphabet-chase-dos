#!/usr/bin/env bash
# Assemble all source modules into relocatable OMF objects, without a reference EXE.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
flags=()
case "${DAC_TARGET:-retail}" in
  retail) OUT="$ROOT/build/asm" ;;
  alt) OUT="$ROOT/build/alt/asm"; flags=(-DDONALD_ALT) ;;
  *) echo "DAC_TARGET must be retail or alt" >&2; exit 2 ;;
esac
command -v nasm >/dev/null || { echo "NASM is required (install nasm)." >&2; exit 1; }
rm -rf "$OUT"; mkdir -p "$OUT"
for src in "$ROOT"/src/asm/*.asm; do
  obj="$OUT/$(basename "$src" .asm).OBJ"
  rm -f "$obj"
  nasm -f obj "${flags[@]}" -i "$ROOT/src/asm/" -o "$obj" "$src"
  echo "assembled ${obj#"$ROOT/"}"
done
python3 "$ROOT/tools/asm_inventory.py" --objects "$OUT" --target "${DAC_TARGET:-retail}"
