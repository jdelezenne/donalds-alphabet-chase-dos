# Agent rules

1. **Never commit game files** (`*.EXE`, `DONALD`, `*.CMP`, disk images) or compiler binaries/libraries. They live in `game/` and `/opt/tc20`.
2. Work on a branch and open a PR; never push to `main`.
3. A function is `matched` only when `tools/cmpobj.py` prints `MATCH` (only relocation/fixup bytes may differ). Anything else is `nonmatching` with the best % in `notes`.
4. One function per file in `src/`, named after the function; record every function in `config/retail/symbols.csv` and rerun `tools/matchreport.py`.
5. Evidence over guesses: Ghidra/decompiler pseudocode is a lead, never evidence. Record compiler quirks and every closed or open question in `docs/MATCHING.md`.
6. Prefer C. Use asm only when Turbo C 2.0 provably cannot emit the bytes, and document why.
7. Library (Turbo C runtime) code is identified by matching against the real `CL.LIB`/`C0L.OBJ`, not rewritten.
8. Keep `DONALD.EXE` (retail) as the base; the alt `DONALD` build is tracked as differences in `config/alt/`.
