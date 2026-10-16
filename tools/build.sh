#!/usr/bin/env bash
# Compile src/*.c (or the given files) with Turbo C 2.0 inside headless DOSBox-X into build/obj/<name>.OBJ.
# DOS needs 8.3 names: a longer name is compiled as Cnnn.C in build/dos and the object renamed back.
# Flags: config/retail/cflags.txt line 1 (default) + optional per-file override "name.c: flags".
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; OUT="$ROOT/build/obj"; DOS="$ROOT/build/dos"
mkdir -p "$OUT"; rm -rf "$DOS"; mkdir -p "$DOS"
FLAGS=$(head -1 "$ROOT/config/retail/cflags.txt")
FILES=("$@"); [ ${#FILES[@]} -gt 0 ] || mapfile -t FILES < <(find "$ROOT/src" -name '*.c' | sort)
for h in "$ROOT"/src/include/*.h; do [ -f "$h" ] && sed "s/\r*$/\r/" "$h" > "$DOS/$(basename "$h" | tr a-z A-Z)"; done
cmds=(); names=(); i=0
for f in "${FILES[@]}"; do
  [ -f "$f" ] || continue
  base=$(basename "$f" .c); short=$(printf 'C%03d' $i); i=$((i+1))
  # 8.3-safe names compile under their own name: TCC names the code segment NAME_TEXT after the file, and TLINK
  # combines equal segment names (seg06e3/harderr.c shares HARDERR_TEXT with CL.LIB's HARDERR module)
  [[ "$base" =~ ^[A-Za-z0-9_]{1,8}$ ]] && short=$(echo "$base" | tr a-z A-Z)
  sed "s/\r*$/\r/" "$f" > "$DOS/$short.C"; names+=("$short:$base")
  rel=${f#"$ROOT/src/"}; over=""
  # override lines: "<glob relative to src/>: flags" (last match wins), e.g. "seg06f0/*: -ml -Z"
  while IFS= read -r line; do g=${line%%:*}; [[ "$line" == *:* && "$line" != \#* ]] || continue
    [[ "$rel" == $g ]] && over=${line#*:}; done < <(tail -n +2 "$ROOT/config/retail/cflags.txt")
  cmds+=("TCC -c -IC:\\INCLUDE ${over:-$FLAGS} $short.C")
done
"$ROOT/tools/dosrun.sh" "$DOS" "${cmds[@]}" | grep -vE "^(Turbo C|$|.*Available memory)" || true
rc=0
for p in "${names[@]}"; do
  s=${p%%:*}; b=${p#*:}
  if [ -f "$DOS/$s.OBJ" ]; then mv "$DOS/$s.OBJ" "$OUT/$b.OBJ"; echo "built build/obj/$b.OBJ"; else echo "FAILED $b"; rc=1; fi
done
exit $rc
