# Standalone source build validation

## Scope

The build inputs are the checked-in C, NASM, headers and link configuration,
plus a separately installed Turbo C 2.0 compiler, linker, headers, startup
object and runtime library. Neither original game executable nor `.CMP` data
is a build input. The original picture/sprite files remain necessary to play.

The source inventory is 73 annotated C functions in 27 C translation units
(including two data-only units), plus seven NASM modules. There are no C stubs
or binary includes. The four previously opaque executable blocks in the sound
and keyboard drivers (1,279 bytes including the one-byte Ctrl-C handler) are
now mnemonic assembly with labeled control flow. Embedded tables, scripts,
state and graphics data remain source initializers. The six earlier individual
instruction `db` exceptions and executable NOP bytes are also mnemonics.
`tasm.inc`'s `rr` macro selects TASM's register-register instruction encoding
from mnemonic/register operands; it is not a stored game-code blob.

## Reproducing the complete build

Use NASM, DOSBox-X, Python 3 and the exact Turbo C 2.0 distribution. The four
compiler/linker/runtime fingerprints are recorded in `config/tc20.sha256`.
Verify them from the installed toolchain directory with `sha256sum -c` and an
absolute path to that manifest. Compiler binaries are not distributed here.

From a clean checkout:

```sh
export TC_ROOT=/path/to/tc20
python3 tools/verify.py --sources-only
rm -rf build
tools/relink.sh all --check-hashes
```

`game/` may contain only its README. Both targets are built unconditionally;
`alt` also builds independently, rather than borrowing retail objects. Full
builds discard their target's old objects so removed sources cannot be hidden
by stale output. No comparison or splice helper participates in the build.

For optional direct reference comparisons, supply legally obtained originals
in `game/` and add `--verify`. An explicitly requested comparison fails if a
reference is absent. `tools/verify.py`'s function checks mask relocations; the
complete-file hashes/comparison are the proof of call targets, data references,
MZ header, relocation table, layout and padding.

## Checks performed on 2026-10-19

- Source manifest and annotation coverage: passed, 73 C functions, 27 units,
  seven assembly modules, including the two data-only C units.
- Python syntax, shell syntax and `git diff --check`: passed.
- Fresh NASM assembly of the previous committed and recovered sources: every
  non-source-filename OMF record is identical, including complete LEDATA,
  FIXUPP targets/order, segment definitions and public symbols. Both retail and
  alternate sound/keyboard variants were compared independently. Graphics
  mnemonic cleanup produces byte-identical complete OMF files.
- Real Turbo C 2.01 exploratory compile/link: passed for both targets with no
  game files. Its complete-file hash checks correctly failed. This is a
  different compiler/runtime and is not matching evidence.
- Real Turbo C 2.0 source-only clean build: **passed for both targets**, exit 0. The build ran in a
  fresh copy of tracked/source files with no pre-existing objects and only
  `game/README.md`; no original game binaries were supplied to the workspace.

| Target | Built bytes | Actual SHA-256 (matches recorded original) |
|---|---:|---|
| Retail | 55,512 | `c72ed19069a37fd5b8968a95d6413dba8044f21879651776c2bc2c89f4193aa8` |
| Alternate | 55,432 | `61d3bc8be22a17a7db59fc6ae044fdb2163c9b4ec3eb2e30dcc8e27d37b27f23` |

Both output digests matched. The expected digests above predate these changes in `config/originals.sha256`.
They are not generated from the rebuilt output. The exact-build result is
reported by `tools/check_build.py`; a nonzero status is a failure.

No interactive gameplay/audio/input playthrough was performed, because the
separate `.CMP` runtime assets were not available. Whole-file identity and
source reconstruction are distinct from a fresh interactive playtest.

## CI

Public CI checks source coverage and assembles both real variants. The gated
self-hosted job requires a separately provisioned exact Turbo C 2.0 toolchain,
DOSBox-X and NASM; it builds from `git archive HEAD`, with no game files, and
checks both complete executable hashes. Public assembly-only CI is not
presented as a full compile/link or gameplay test.
