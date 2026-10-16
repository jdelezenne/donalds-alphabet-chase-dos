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
Every C function in the game (73 functions, 16,709 bytes) byte-matches with Turbo C 2.0 (`-ml`, plus `-O -Z` on some modules; see `config/retail/cflags.txt`).
The three assembly modules (segments 0000, 0512, 056A; 14,021 bytes) reassemble byte-exactly with NASM. The 71 Turbo C library modules are identified against the real `CL.LIB`.
That covers 99.97% of the 38,000 code bytes; the rest is 12 bytes of zero padding.
`tools/splice.py` builds `build/DONALD.EXE` the full-layout way and reproduces the original SHA-256. A real TLINK relink is not done yet (see docs/MATCHING.md).
See [docs/STATUS.md](docs/STATUS.md), [docs/BINARY.md](docs/BINARY.md) and [docs/MATCHING.md](docs/MATCHING.md).

## Layout
- `src/segXXXX/` one C file per original code segment (= one Turbo C translation unit, functions in address order); `src/include/` headers; `src/asm/` NASM sources of the assembly modules (`tasm.inc` holds the TASM-style encodings).
- `config/retail/` `symbols.csv` (name, seg:off, size, status), `functions.csv` (seeded starts), `cflags.txt`.
- `config/alt/` same for the alternate `DONALD` build.
- `tools/` workflow scripts (below). `build/` and `game/` are git-ignored.

## Tooling
| Script | Purpose |
|---|---|
| `tools/setup.sh` | apt packages (DOSBox-X, nasm, mtools), Python venv with Capstone, verifies originals |
| `tools/install_tc.sh` | installs **your own** Turbo C 2.0 to `/opt/tc20` (never into the repo) |
| `tools/dosrun.sh` | runs DOS commands headless in DOSBox-X (C: = compiler, D: = work dir) |
| `tools/build.sh` | compiles `src/**/*.c` with `TCC` into `build/obj/` (per-module flags in `config/retail/cflags.txt`) |
| `tools/verify.py` | **the checker**: builds, compares every `/* FUNCTION: DONALD SSSS:OOOO */` function (fixups masked) and every `src/asm` module, updates `symbols.csv`, prints byte progress |
| `tools/fndiff.py` | instruction-level diff of one function with operands normalised (handles jump tables with `--skip`) |
| `tools/permute.py` | permuter: tries `@P{a\|b}` source alternatives times a flag list and writes the first 100% match |
| `tools/dumpfn.py` | `--list` unmatched C functions by size; `SSSS:OOOO` disassembles one |
| `tools/asm2nasm.py` | bootstraps a NASM source for an asm module from your local EXE (then hand-annotated) |
| `tools/splice.py` | full-layout build `build/DONALD.EXE` from our bytes plus the local original, and compares it |
| `tools/cmpobj.py` | per-function compare of an `.OBJ` against the original image, fixup bytes masked, side-by-side diff |
| `tools/libmatch.py` | finds Turbo C startup/library modules in the image (relocation-masked) |
| `tools/omf.py` | minimal OMF reader (segments, publics, LEDATA, fixups) |
| `tools/mzinfo.py` | MZ header, packer/banner detection, relocation segment histogram |
| `tools/funcs.py` | function starts, sizes (C sizes exclude trailing data) and kind lib/asm/c → `functions.csv` |
| `tools/matchreport.py` | regenerates `docs/STATUS.md` from `symbols.csv` |

## Reproducing
1. `tools/setup.sh`
2. `tools/install_tc.sh /path/to/your/TC20-floppies.7z /opt/tc20`
3. Copy your game files into `game/`, run `python3 tools/verify_originals.py`.
4. `rm -rf build && python3 tools/verify.py && python3 tools/splice.py` (needs `nasm`)
