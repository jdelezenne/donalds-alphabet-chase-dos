# Matching workflow

## Loop
1. Pick a function from `config/retail/functions.csv` (start with small leaf functions in the game segments, not segment 0000 = startup/CRT).
2. Write `src/<name>.c`, add `name,SSSS:OOOO,size,todo,` to `config/retail/symbols.csv`.
3. `tools/build.sh src/<name>.c` then `tools/.venv/bin/python tools/cmpobj.py build/obj/<NAME>.OBJ`.
4. Iterate until `MATCH`; set `status=matched`, run `tools/matchreport.py`, commit.

`cmpobj.py` masks every byte covered by an OMF fixup (far call targets, segment bases, DGROUP offsets), so a
function can match before the whole program links in original order. The final milestone (as in maniac-mansion-dos)
is a full-layout TLINK rebuild compared with `cmp`.

## Compiler: Turbo C 2.0 (to confirm vs 2.01)
Open questions:
- `U001` exact version (2.0 vs 2.01): match startup `C0L.OBJ` and CRT modules of each against the image.
- `U002` memory model large vs huge.
- `U003` flags. Turbo C 2.0 defaults: register variables on (`-r`), no jump optimisation (`-O` off), no `-Z`/`-G`.
  Signals to look for in the original: `push si/push di` usage (register vars), jump chains (`-O`), `-k` standard stack frame, `-a` word alignment, `-N` stack checks (look for calls to `STKOVER`).
- `U004` linker version (TLINK 2.0 from TC 2.0) and link order (use the code-segment order in `mzinfo.py` + string offsets in DGROUP).
- `U005` alt build `DONALD` vs `DONALD.EXE`: which is the later revision.

## Library identification (next tool to add)
Port `libmatch.py` from dangerous-dave-dos: relocation-masked compare of every `CL.LIB`/`CH.LIB` OMF module against the
image, writing `config/retail/crt_matches.csv` with `status=lib`.
