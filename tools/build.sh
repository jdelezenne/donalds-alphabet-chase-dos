#!/usr/bin/env bash
# Compile cataloged C units (or the given subset) with Turbo C 2.0 into build/obj/<semantic-name>.OBJ.
# config/retail/modules.csv preserves the pre-refactor 8.3 compiler filename and CODE segment identity.
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
python3 "$ROOT/tools/source_manifest.py" --compile-list "$@" > "$DOS/SOURCES.TSV"
if [ "$#" -eq 0 ]; then
  # A removed/renamed source must never be satisfied by an object from a previous build.
  rm -rf "$OUT"; mkdir -p "$OUT"
fi
# Flatten subsystem headers to their unchanged DOS basenames; preserve source include order.
for h in "$ROOT"/src/*.h "$ROOT"/src/{audio,data,engine}/*.h; do [ -f "$h" ] && sed "s/\r*$/\r/" "$h" > "$DOS/$(basename "$h" | tr a-z A-Z)"; done
cmds=(); names=()
while IFS=$'\t' read -r f short; do
  [ -f "$f" ] || { echo "Missing source: $f" >&2; exit 1; }
  f=$(realpath "$f")
  base=$(basename "$f" .c)
  # Stable compiler names preserve TC segment identity even when source paths change.
  # HARDERR_TEXT must continue sharing the runtime's HARDERR segment.
  sed "s/\r*$/\r/" "$f" > "$DOS/$short.C"; names+=("$short:$base")
  rm -f "$OUT/$base.OBJ"
  rel=${f#"$ROOT/src/"}; over=""
  # override lines: "<glob relative to src/>: flags" (last match wins), e.g. "engine/files.c: -ml"
  while IFS= read -r line; do g=${line%%:*}; [[ "$line" == *:* && "$line" != \#* ]] || continue
    [[ "$rel" == $g ]] && over=${line#*:}; done < <(tail -n +2 "$ROOT/config/retail/cflags.txt")
  cmds+=("TCC -c -IC:\\INCLUDE ${DEF}${over:-$FLAGS} $short.C")
done < "$DOS/SOURCES.TSV"
"$ROOT/tools/dosrun.sh" "$DOS" "${cmds[@]}"
rc=0
for p in "${names[@]}"; do
  s=${p%%:*}; b=${p#*:}
  if [ -f "$DOS/$s.OBJ" ]; then mv "$DOS/$s.OBJ" "$OUT/$b.OBJ"; echo "built ${OUT#"$ROOT/"}/$b.OBJ"; else echo "FAILED $b"; rc=1; fi
done
exit $rc
