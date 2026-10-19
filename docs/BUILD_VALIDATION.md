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
state and graphics data remain source initializers. The semantic follow-up partitions every assembly data initializer into 171 bounded storage objects (6,914 bytes) and catalogs all 81 callable assembly entries, including shared near-helper bodies; [ASM_DATA.md](ASM_DATA.md) records the recovered meanings and original quirks. The six earlier individual
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
  81 assembly callable entries, 171 assembly data objects and seven assembly
  modules, including the two data-only C units.
- Python syntax, shell syntax and `git diff --check`: passed.
- The semantic data-recovery follow-up passed independent source review: all
  81 assembly entries and 171 data objects accounted for; seven pixel lookup
  formulas checked; explicit original keyboard quirks and cross-segment
  graphics scratch alias retained. No mixed unnamed data run remained.
- Real NASM inventory checks passed for retail and alternate objects: every
  initializer and instruction emission accounted for, exact catalog symbol
  locations, no data/function overlap, two explicitly documented shared-helper
  spans, unchanged segment bytes/publics and complete relocation records.
- `funcs.py` regeneration from both the exact reference-equivalent TC2.0 output
  and the exploratory TC2.01 output preserves the reviewed function catalog.
  Newly inferred candidates are reported separately and cannot overwrite it.
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
- Repeated after semantic symbol/data recovery: both clean outputs again match
  the hashes below. A separate clean alternate-only build also matches without
  creating retail object/assembly/link directories.
- Initial follow-up builds using adaptive DOSBox `cycles=max` timed out on the
  headless SDL driver. The runner now uses normal-core `fixed 100000` cycles
  (overridable with `DOS_CYCLES`) and a five-second forced-kill grace after its
  timeout. The final two-target clean compile/link completed successfully in
  about ten seconds. This setting affects the build emulator, not the game.

| Target | Built bytes | Actual SHA-256 (matches recorded original) |
|---|---:|---|
| Retail | 55,512 | `c72ed19069a37fd5b8968a95d6413dba8044f21879651776c2bc2c89f4193aa8` |
| Alternate | 55,432 | `61d3bc8be22a17a7db59fc6ae044fdb2163c9b4ec3eb2e30dcc8e27d37b27f23` |

Both output digests matched. The expected digests above predate these changes in `config/originals.sha256`.
They are not generated from the rebuilt output. The exact-build result is
reported by `tools/check_build.py`; a nonzero status is a failure.

The earlier recovery checks did not include an interactive gameplay/audio/input
playthrough; separate `.CMP` runtime assets were unavailable then. Runtime assets
are now available locally, but this structure-only change did not add a new
interactive playthrough. Whole-file identity and source reconstruction are
distinct from a fresh interactive playtest.

## Purpose-based source reorganization (2026-10-19)

The source guide and complete old/new path map are in [SOURCE_LAYOUT.md](SOURCE_LAYOUT.md)
and `config/retail/modules.csv`. This change preserves all 27 C translation
units and seven original assembly modules, separates headers by role, introduces
16 evidence-backed API names, uses the existing `script_t` type, and names the
page-copy/drawing modes and fixed actor slots. It adds no synthetic tests.

Validation repeated after the reorganization:

- All four exact TC 2.0 toolchain fingerprints in `config/tc20.sha256`: passed.
- Clean `rm -rf build && tools/relink.sh all --check-hashes`: passed for both
  targets, with exactly the sizes and original hashes recorded above.
- A second build in a fresh source/config/tools copy with no pre-existing
  objects and only `game/README.md`: passed for both targets. Neither game
  executables nor `.CMP` assets were present in this clean workspace.
- Independent source review normalized only the documented identifier/type/
  constant changes and explicit `int main`: all 34 source units retained their
  prior token streams; all seven assembly bodies were text-identical.
- The review also checked every one of the 35 link inputs and all 27 C units:
  DOS link aliases, order, stable compiler stems and effective flags unchanged.
- Source consistency: 73 annotated C functions, 27 C units, seven ASM modules,
  81 ASM callable entries and 171 ASM data objects. NASM's real-object inventory
  and boundary checks passed for both retail and alternate variants.
- Python syntax, shell syntax and `git diff --check`: passed. `matchreport.py`
  regenerated the inventory with current source paths and API names.

The original executables were not available as separate comparison inputs for
this change, so `--verify` and the original-file function matcher were not rerun.
Recorded function statuses are retained from the prior recovery; the fresh
whole-file hashes independently prove the complete rebuilt files still equal
the recorded originals. No interactive gameplay result is claimed here.

## CI

Public CI checks source coverage, assembles both real variants, and verifies the assembly catalogs against actual NASM symbol/data bounds. The gated
self-hosted job requires a separately provisioned exact Turbo C 2.0 toolchain,
DOSBox-X and NASM; it builds from `git archive HEAD`, with no game files, and
checks both complete executable hashes. Public assembly-only CI is not
presented as a full compile/link or gameplay test.
