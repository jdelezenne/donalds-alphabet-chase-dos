# Agent rules

1. **Never commit game files** (`*.EXE`, `DONALD`, `*.CMP`, disk images) or compiler binaries/libraries. They live in `game/` and `/opt/tc20`.
2. Work on a branch and open a PR; never push to `main`, never merge.
3. Every function carries `/* FUNCTION: DONALD SSSS:OOOO */` on the line before its definition (no `//`: TC 2.0 rejects it). A function is `matched` only when `tools/verify.py` (clean build: `rm -rf build` first) reports it matched; anything else stays `nonmatching` with its %.
4. Preserve each original C translation unit and its functions in address order; organize files by purpose (see `docs/SOURCE_LAYOUT.md`): TC emits `push cs; call near` only for functions defined earlier in the same file. Per-module flags go in `config/retail/cflags.txt`; source moves must update `config/retail/modules.csv`, `link.txt` and catalogs. Keep the stable DOS compiler stems: filenames affect emitted CODE segment names.
5. Evidence over guesses: decompiler output is a lead, never evidence. Record compiler quirks and every open question in `docs/MATCHING.md`.
6. Recover the original language: C stays C, hand-written asm stays asm (evidence in `functions.csv`, `tools/classify.py`). The asm modules (`src/asm/*.asm`, NASM) must assemble byte-exactly; keep `db` only for instructions NASM cannot encode the TASM way, with the mnemonic in a comment.
7. Library (Turbo C runtime) code is identified by matching against the real `CL.LIB`/`C0L.OBJ`, not rewritten.
8. After changes: `rm -rf build && tools/relink.sh all --check-hashes && python3 tools/matchreport.py`. The complete executable hashes must match the recorded originals; this check needs no game files. When originals are available, `tools/relink.sh all --verify` also performs direct comparison. These whole-file checks see call targets and data references, which verify.py masks.
10. Never commit generated data (`build/gen`): game data enters git only as decompiled C/asm initialisers.
9. Keep `DONALD.EXE` (retail) as the base; the alt `DONALD` build is tracked as differences in `config/alt/`.
