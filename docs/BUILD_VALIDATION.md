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

## Current maintenance checks (2026-10-19)

`make check-source` checks the actual source/header/link inventories, address
order, Python/shell syntax, forbidden binary inputs, and the real NASM object
inventories for both variants. It needs no Turbo C, DOSBox, originals or assets.
Assembly runs in temporary copies and leaves any existing exact build intact.

`make check-exact` creates a fresh source-only copy, verifies all nine declared
Turbo C 2.0 inputs (compiler, linker, runtime/startup and five used headers),
builds both targets, and checks their full sizes and independently recorded
SHA-256 hashes. Its evidence directory retains an input manifest, toolchain
fingerprints, logs and a machine-readable result. Python file-open auditing
rejects parent-checkout/reference reads in build subprocesses; it is additional
instrumentation, not an OS sandbox or a native DOSBox file-access trace.

The current receipt is [verification/maintenance-pass.json](verification/maintenance-pass.json).
It records identical preprocessed tokens in all 27 C units for both variants,
real-source compiler staging/negative checks, and complete file identity.
The semantic changes only name proven resource-table indices at callers and
use the existing actor/letter/sprite/group counts. Header ownership, include
order, C types, original translation units, function order, flags, assembly,
data initializer values and link order are unchanged. No historical names or
new structure layouts are inferred.

The supported C builder uses a new staging directory on every invocation,
ignores old output and ambient `TCC.CFG`/headers, and retains diagnostic logs.
`dosrun.sh` stages only the manifest's compiler inputs and runs from an isolated
cwd/HOME with explicit DOSBox settings, disabling ambient config/autoexec/mapper
loading. The shared emulator lock serializes actual DOSBox commands. The
low-level runner still mounts its supplied work directory, so callers other
than the supported build/relink scripts are responsible for that directory's
contents. This is reproducible input staging, not a security sandbox.

No new interactive gameplay/audio/input playthrough was added. Exact executable
identity does not establish a fresh runtime test or recover unknown original
identifiers, historical type names, or development-tool provenance.

## Reproducing the complete build

Use NASM, DOSBox-X, Python 3 and the exact Turbo C 2.0 distribution. The nine
compiler/linker/runtime/header fingerprints are recorded in `config/tc20.sha256`.
Verify them from the installed toolchain directory with `sha256sum -c` and an
absolute path to that manifest. Compiler binaries are not distributed here.

From a clean checkout:

```sh
export TC_ROOT=/path/to/tc20
make check-source
make check-exact
```

`make check-exact` never copies local originals or prior output. Its new
`build/exact-*/source/game/` contains only the README. Both targets are built;
`alt` also builds independently, rather than borrowing retail objects. Full
builds discard their target's old objects so removed sources cannot be hidden
by stale output. No comparison or splice helper participates in the build.

For optional direct reference comparisons, supply legally obtained originals
in `game/` and run `tools/relink.sh all --check-hashes --verify`. An explicitly requested comparison fails if a
reference is absent. `tools/verify.py`'s function checks mask relocations; the
complete-file hashes/comparison are the proof of call targets, data references,
MZ header, relocation table, layout and padding.

## Historical recovery checks (2026-10-19)

The sections below preserve earlier validation snapshots. Statements about local
asset availability, tool versions or test timing apply to those runs only; the
current maintenance result is linked above.

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

## Historical purpose-based source reorganization (2026-10-19)

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

## Historical shallow subsystem layout follow-up (2026-10-19)

Headers now live beside their owning sources, with the ordered umbrella and
shared/game declarations directly in `src/`. Sound assembly is in `src/audio/`;
graphics and keyboard assembly, plus the shared TASM encoding and graphics
layout includes, are in `src/engine/`. The empty include/assembly directories
and header placeholder are gone. All active build, checker, research-tool,
catalog and documentation paths use this layout; historical `previous_source`
values in `modules.csv` are unchanged.

Validation repeated for this path-only cleanup:

- All 27 C files, seven assembly files and two assembly includes retain their
  exact bytes. All seven headers retain their declaration text and ordering;
  only the directory name in one `engine.h` comment changed.
- All 34 source module rows retain their order, compiler stems, segment
  identities, purpose and historical provenance. Compiler flags and the entire
  `link.txt` are byte-identical to the previous layout.
- All four exact TC 2.0 toolchain fingerprints passed.
- Clean `tools/relink.sh all --check-hashes --verify` passed: both complete
  output files match the sizes and SHA-256 digests above and compare directly
  byte-for-byte with originals extracted from the user-supplied archive.
- The fresh retail function verifier matched all 73 C functions (16,710 bytes)
  and all seven assembly modules (14,020 bytes). Real NASM object inventories
  passed for both variants: 81 callable entries and 171 data objects.
- A second clean source/config/tools copy with no existing build and only
  `game/README.md` passed `tools/relink.sh all --check-hashes` for both targets.
- Source-only coverage, Python syntax, shell syntax and `git diff --check`
  passed. `matchreport.py` regenerated the status with current paths and the
  fresh verifier summary.

Original files remain local and ignored. No game binaries, compiler files or
runtime assets are committed. No new interactive gameplay test is claimed.

## CI

Public CI checks source coverage, assembles both real variants, and verifies the assembly catalogs against actual NASM symbol/data bounds. The gated
self-hosted job requires a separately provisioned exact Turbo C 2.0 toolchain,
DOSBox-X and NASM; it runs `make check-exact` from a fresh source-only snapshot, with no game
files or existing objects, and checks both complete executable hashes. Public assembly-only CI is not
presented as a full compile/link or gameplay test.
