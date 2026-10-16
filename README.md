# donalds-alphabet-chase-dos

A matching decompilation of *Donald's Alphabet Chase* (Disney Software, 1988) for IBM PC DOS.
The goal is C (and, only where unavoidable, asm) source that rebuilds a **byte-identical** `DONALD.EXE`.

## No game files in this repo
Do **not** commit copyrighted game files: no executables, `*.CMP` data or disk images.
Put your own legally obtained copy in `game/` (git-ignored) and run `python3 tools/verify_originals.py`.
Expected hashes are in [config/originals.sha256](config/originals.sha256).

| Target | File | Size | SHA-256 |
|---|---|---|---|
| retail (primary) | `DONALD.EXE` | 55,512 | `c72ed19069a37fd5b8968a95d6413dba8044f21879651776c2bc2c89f4193aa8` |
| alt build | `DONALD` (no extension) | 55,432 | `61d3bc8be22a17a7db59fc6ae044fdb2163c9b4ec3eb2e30dcc8e27d37b27f23` |

## Status
Scaffolding only. 0 functions matched. See [docs/STATUS.md](docs/STATUS.md), [docs/BINARY.md](docs/BINARY.md)
(executable analysis) and [docs/MATCHING.md](docs/MATCHING.md) (workflow and compiler notes).

## Layout
- `src/` one C file per function (`src/include/` headers); `asm/` hand-written asm only when Turbo C cannot reproduce the bytes.
- `config/retail/` `symbols.csv` (name, seg:off, size, status), `functions.csv` (seeded starts), `cflags.txt`.
- `config/alt/` same for the alternate `DONALD` build.
- `tools/` workflow scripts (below). `build/` and `game/` are git-ignored.

## Tooling
| Script | Purpose |
|---|---|
| `tools/setup.sh` | apt packages (DOSBox-X, nasm, mtools), Python venv with Capstone, verifies originals |
| `tools/install_tc.sh` | installs **your own** Turbo C 2.0 to `/opt/tc20` (never into the repo) |
| `tools/dosrun.sh` | runs DOS commands headless in DOSBox-X (C: = compiler, D: = work dir) |
| `tools/build.sh` | compiles `src/*.c` with `TCC` into `build/obj/` |
| `tools/cmpobj.py` | per-function compare of an `.OBJ` against the original image, fixup bytes masked, side-by-side diff |
| `tools/omf.py` | minimal OMF reader (segments, publics, LEDATA, fixups) |
| `tools/mzinfo.py` | MZ header, packer/banner detection, relocation segment histogram |
| `tools/funcs.py` | seeds function starts per code segment |
| `tools/matchreport.py` | regenerates `docs/STATUS.md` from `symbols.csv` |

## Reproducing
1. `tools/setup.sh`
2. `tools/install_tc.sh /path/to/your/TC20` 
3. Copy your game files into `game/`, run `python3 tools/verify_originals.py`.
4. `tools/build.sh && tools/.venv/bin/python tools/cmpobj.py build/obj/FOO.OBJ`
