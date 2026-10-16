#!/usr/bin/env bash
# Compile src/*.c (or the given files) with Turbo C 2.0 inside headless DOSBox-X into build/obj/*.OBJ.
# Flags: config/retail/cflags.txt (global, first line) + optional per-file override "FILE.C: flags".
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; OUT="$ROOT/build/obj"; mkdir -p "$OUT"
FLAGS=$(head -1 "$ROOT/config/retail/cflags.txt")
FILES=("$@"); [ ${#FILES[@]} -gt 0 ] || FILES=("$ROOT"/src/*.c)
cmds=()
for f in "${FILES[@]}"; do
  [ -f "$f" ] || continue
  b=$(basename "$f" | tr a-z A-Z); cp "$f" "$OUT/$b"
  over=$(grep -i "^$b:" "$ROOT/config/retail/cflags.txt" | cut -d: -f2- || true)
  cmds+=("TCC -c -IC:\\INCLUDE ${over:-$FLAGS} $b")
done
cp "$ROOT"/src/include/*.h "$OUT"/ 2>/dev/null || true
"$ROOT/tools/dosrun.sh" "$OUT" "${cmds[@]}"
