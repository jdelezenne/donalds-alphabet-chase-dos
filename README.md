# donalds-alphabet-chase-dos

A matching decompilation of *Donald's Alphabet Chase* (Disney Software, 1988) for IBM PC DOS.
The goal is C (and, only where unavoidable, asm) source that rebuilds a **byte-identical** `DONALD.EXE`.

## No game files in this repo
Do **not** commit copyrighted game files: no executables, `*.CMP` data or disk images.
Originals are optional for reference comparisons: put a legally obtained copy in `game/` (git-ignored) and run `python3 tools/verify_originals.py`. Building does not require them.
Expected hashes are in [config/originals.sha256](config/originals.sha256).

| Target | File | Size | SHA-256 |
|---|---|---|---|
| retail (primary) | `DONALD.EXE` | 55,512 | `c72ed19069a37fd5b8968a95d6413dba8044f21879651776c2bc2c89f4193aa8` |
| alt build | `DONALD` (no extension) | 55,432 | `61d3bc8be22a17a7db59fc6ae044fdb2163c9b4ec3eb2e30dcc8e27d37b27f23` |

## Status
Both complete source-only builds were verified with Turbo C 2.0 against the original SHA-256 hashes, with no game files present. See [validation evidence](docs/BUILD_VALIDATION.md).

The recorded reference results cover all 73 C functions (16,710 bytes), byte-matching with Turbo C 2.0 (`-ml`, plus `-O -Z` on some modules; see `config/retail/cflags.txt`).
The seven assembly modules (5 graphics objects in segment 0000, plus 0512 and 056A; 14,020 bytes including embedded data) are readable NASM sources, with all executable byte blobs recovered as instructions. Every function is classified C/asm/lib with evidence in `config/retail/functions.csv` (`tools/classify.py`). The 71 recorded runtime symbol spans are identified against the real `CL.LIB`/`C0L.OBJ` (they are not 71 separate library modules).
That covers 99.97% of the 38,000 code bytes; the rest is 12 bytes of zero padding.
**`tools/relink.sh` builds both complete executables from C/assembly source plus the separately installed Turbo C runtime, without reading `game/`.** All game code, initialised data, `GFX_DATA` and `_BSS` are source definitions. `--check-hashes` checks each complete output against the recorded original SHA-256 without needing the original file; `--verify` explicitly enables comparison with local original executable(s). See [docs/BUILD_VALIDATION.md](docs/BUILD_VALIDATION.md) for the current validation evidence and limitations.
The recorded alternate-build match is **`DONALD` (sha256 61d3bc8b…) from the same sources** with `DONALD_ALT` defined: a shorter `main()` with no command-line options, `shutdown()` without `exit()`, and the two driver modules 8 bytes further into their paragraph (`CSO()` offsets).
See [docs/STATUS.md](docs/STATUS.md), [docs/BINARY.md](docs/BINARY.md), [docs/MATCHING.md](docs/MATCHING.md), [docs/CMP.md](docs/CMP.md) (picture format) and [docs/SCRIPTS.md](docs/SCRIPTS.md) (actor script opcodes) and [docs/DATA.md](docs/DATA.md) (data structures and the evidence for them).

## Layout
- `src/segXXXX/` one C file per original code segment (= one Turbo C translation unit, functions in address order); `src/include/` headers; `src/asm/` NASM sources of the assembly modules (`tasm.inc` holds the TASM-style encodings).
- `src/data/` data-only C units (`scripts.c`, `tables.c`: DGROUP 020A-1AA9, linked after seg0304).
- `config/retail/` `symbols.csv` (name, seg:off, size, status), `functions.csv` (starts, kind, `lang` + `evidence`), `cflags.txt`, `link.txt` (TLINK object order), `data.csv` (named globals).
- `config/alt/` same for the alternate `DONALD` build.
- `tools/` workflow scripts (below). `build/` and `game/` are git-ignored.

## Tooling
| Script | Purpose |
|---|---|
| `tools/setup.sh` | apt packages (DOSBox-X, nasm, mtools), Python venv with Capstone; no game files needed |
| `tools/install_tc.sh` | installs **your own** Turbo C 2.0 to `/opt/tc20` (never into the repo) |
| `tools/dosrun.sh` | runs DOS commands headless in DOSBox-X (C: = compiler, D: = work dir) |
| `tools/build.sh` | compiles `src/**/*.c` with `TCC` into `build/obj/` (per-module flags in `config/retail/cflags.txt`) |
| `tools/verify.py` | **the checker**: builds, compares every `/* FUNCTION: DONALD SSSS:OOOO */` function (fixups masked) and every `src/asm` module, updates `symbols.csv`, prints byte progress |
| `tools/fndiff.py` | instruction-level diff of one function with operands normalised (handles jump tables with `--skip`) |
| `tools/permute.py` | permuter: tries `@P{a\|b}` source alternatives times a flag list and writes the first 100% match |
| `tools/dumpfn.py` | `--list` unmatched C functions by size; `SSSS:OOOO` disassembles one |
| `tools/asm2nasm.py` | bootstraps a NASM source for an asm module from your local EXE (then hand-annotated) |
| `tools/assemble.sh` | assembles all NASM sources to OMF without original files (`DAC_TARGET=alt` for alternate build) |
| `tools/relink.sh` | source-only compile, assemble and link `[retail\|alt\|all]`; optional `--check-hashes` or `--verify` |
| `tools/check_build.py` | compares built executable sizes and SHA-256 hashes with the recorded originals; reads no game files |
| `tools/cmp_extract.py` | decodes `.CMP` pictures to PNG (`build/cmp/`) |
| `tools/classify.py` | per-function C/asm/lib verdict with evidence → `functions.csv` `lang`/`evidence` |
| `tools/splice.py` | full-layout build `build/DONALD.EXE` from our bytes plus the local original, and compares it |
| `tools/cmpobj.py` | per-function compare of an `.OBJ` against the original image, fixup bytes masked, side-by-side diff |
| `tools/libmatch.py` | finds Turbo C startup/library modules in the image (relocation-masked) |
| `tools/omf.py` | minimal OMF reader (segments, publics, LEDATA, fixups) |
| `tools/mzinfo.py` | MZ header, packer/banner detection, relocation segment histogram |
| `tools/funcs.py` | function starts, sizes (C sizes exclude trailing data) and kind lib/asm/c → `functions.csv` |
| `tools/matchreport.py` | regenerates `docs/STATUS.md` from `symbols.csv` |

## Building without the retail binary
Requirements: Linux with DOSBox-X, `nasm`, Python 3, and your own **Turbo C 2.0** toolchain (compiler, linker, headers, `C0L.OBJ`, `CL.LIB`). Game executables, `.CMP` files and disk images are not build inputs.

1. `tools/setup.sh`
2. `tools/install_tc.sh /path/to/your/TC20-floppies.7z /opt/tc20` (or set `TC_ROOT` to an installed toolchain).
3. `rm -rf build && tools/relink.sh all --check-hashes`

The outputs are `build/link/DONALD.EXE` and `build/link-alt/DONALD`. Both targets build even when `game/` contains only its README. Use `retail` or `alt` to build one target. Each variant has its own complete objects; alternate builds never reuse stale retail objects. Omit `--check-hashes` for an exploratory build whose output may not yet match.

The hash check covers the entire executable, including the MZ header, relocation table, code, data and padding. It uses the hashes already recorded in `config/originals.sha256`, not bytes extracted from a retail executable. Turbo C 2.01 can compile the sources, but its different runtime library is **not** a substitute for the exact Turbo C 2.0 matching toolchain.

## Optional reference verification and running
To compare directly against legally obtained original files, copy them into `game/`, run `python3 tools/verify_originals.py`, then `tools/relink.sh all --verify`. Select `retail --verify` if only `game/DONALD.EXE` is available. Explicit verification fails if a requested reference is absent; it never silently skips a target.

While editing a C function, use `python3 tools/verify.py` and `python3 tools/fndiff.py SSSS:OOOO` with the retail reference present. The full-executable comparison or hash check is the final proof, because per-function checks mask relocations.

Playing the rebuilt game still requires its separately obtained `.CMP` picture/sprite data. Put the rebuilt executable beside those files and run it in DOS/DOSBox-X. These assets are runtime data, not source-build inputs. `python3 tools/cmp_extract.py game/*.CMP` optionally decodes the pictures to PNG.
