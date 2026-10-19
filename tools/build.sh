#!/usr/bin/env bash
# Compile src/*.c (or the given files) with Turbo C 2.0 inside headless DOSBox-X into build/obj/<name>.OBJ.
# DOS needs 8.3 names: a longer name is compiled as Cnnn.C in build/dos and the object renamed back.
# Flags: config/retail/cflags.txt line 1 (default) + optional per-file override "name.c: flags".
# DAC_TARGET=alt builds the alternate DONALD variant (-DDONALD_ALT) into build/alt/obj.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; DEF=""
case "${DAC_TARGET:-retail}" in
  retail) OUT="$ROOT/build/obj"; DOS="$ROOT/build/dos" ;;
  alt) OUT="$ROOT/build/alt/obj"; DOS="$ROOT/build/alt/dos"; DEF="-DDONALD_ALT " ;;
  *) echo "DAC_TARGET must be retail or alt" >&2; exit 2 ;;
esac
TC=${TC_ROOT:-/opt/tc20}
for required in TCC.EXE TLINK.EXE LIB/C0L.OBJ LIB/CL.LIB INCLUDE/DOS.H; do
  [ -f "$TC/$required" ] || { echo "Missing Turbo C 2.0 toolchain file: $TC/$required (set TC_ROOT)." >&2; exit 1; }
done
mkdir -p "$OUT"; rm -rf "$DOS"; mkdir -p "$DOS"
FLAGS=$(head -1 "$ROOT/config/retail/cflags.txt")
FILES=("$@"); [ ${#FILES[@]} -gt 0 ] || mapfile -t FILES < <(find "$ROOT/src" -name '*.c' | sort)
if [ "$#" -eq 0 ]; then
  # A removed/renamed source must never be satisfied by an object from a previous build.
  rm -rf "$OUT"; mkdir -p "$OUT"
fi
for h in "$ROOT"/src/include/*.h; do [ -f "$h" ] && sed "s/\r*$/\r/" "$h" > "$DOS/$(basename "$h" | tr a-z A-Z)"; done
cmds=(); names=(); i=0
for f in "${FILES[@]}"; do
  [ -f "$f" ] || { echo "Missing source: $f" >&2; exit 1; }
  f=$(realpath "$f")
  base=$(basename "$f" .c); short=$(printf 'C%03d' $i); i=$((i+1))
  # 8.3-safe names compile under their own name: TCC names the code segment NAME_TEXT after the file, and TLINK
  # combines equal segment names (seg06e3/harderr.c shares HARDERR_TEXT with CL.LIB's HARDERR module)
  [[ "$base" =~ ^[A-Za-z0-9_]{1,8}$ ]] && short=$(echo "$base" | tr a-z A-Z)
  sed "s/\r*$/\r/" "$f" > "$DOS/$short.C"; names+=("$short:$base")
  rm -f "$OUT/$base.OBJ"
  rel=${f#"$ROOT/src/"}; over=""
  # override lines: "<glob relative to src/>: flags" (last match wins), e.g. "seg06f0/*: -ml -Z"
  while IFS= read -r line; do g=${line%%:*}; [[ "$line" == *:* && "$line" != \#* ]] || continue
    [[ "$rel" == $g ]] && over=${line#*:}; done < <(tail -n +2 "$ROOT/config/retail/cflags.txt")
  cmds+=("TCC -c -IC:\\INCLUDE ${DEF}${over:-$FLAGS} $short.C")
done
"$ROOT/tools/dosrun.sh" "$DOS" "${cmds[@]}"
rc=0
for p in "${names[@]}"; do
  s=${p%%:*}; b=${p#*:}
  if [ -f "$DOS/$s.OBJ" ]; then mv "$DOS/$s.OBJ" "$OUT/$b.OBJ"; echo "built ${OUT#"$ROOT/"}/$b.OBJ"; else echo "FAILED $b"; rc=1; fi
done
exit $rc
