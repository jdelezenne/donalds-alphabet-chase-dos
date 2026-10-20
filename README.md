# Donald’s Alphabet Chase (DOS)

Recovered C and assembly for both releases of Donald’s Alphabet Chase (1988).

## Build and verify

Requires Python 3, Bash, NASM, DOSBox-X and your separately installed Turbo C 2.0 compiler, headers and libraries. No original executable or game asset is used to build.

```sh
./setup.sh                         # install host prerequisites (Debian/Ubuntu)
tools/install_tc.sh /path/to/your/turbo-c /path/to/tc20
export TC_ROOT=/path/to/tc20
./build.sh all --check-hashes       # build both variants and check full hashes
./recomp.sh                        # fresh source-only exact build and evidence
make check-source                  # compiler-free source and NASM checks
./run.sh /path/to/game-data retail  # run rebuilt game with your own assets
```

Set DOSBOX to the DOSBox-X executable if it is not on PATH. The alternate target is `alt`; its output is `build/link-alt/DONALD`. Retail output is `build/link/DONALD.EXE`.

Expected complete outputs:
- Retail: 55,512 bytes, SHA-256 `c72ed19069a37fd5b8968a95d6413dba8044f21879651776c2bc2c89f4193aa8`
- Alternate: 55,432 bytes, SHA-256 `61d3bc8be22a17a7db59fc6ae044fdb2163c9b4ec3eb2e30dcc8e27d37b27f23`

## Layout

- `src/donald/`: executable sources, including both compile-time variants. Headers remain beside their owners; original translation-unit boundaries and DOS compiler stems are preserved.
- `tools/`: complete production build, verification and setup dependencies, including their manifests and configuration.
- `agents/`: recovery notes, research catalogs, diagnostics and provenance. This directory is not needed for setup, build, verification or run and may be removed.

The exact verifier copies only production sources and tooling, checks pinned compiler inputs, builds both complete executables and records hashes under `build/exact-*`. It needs no game files. No GitHub CI workflows are included; validation runs locally.

Supply legally obtained runtime game data to run. Game files and licensed compiler inputs are not distributed here and must not be committed. Complete binary identity does not imply a new interactive gameplay test.
