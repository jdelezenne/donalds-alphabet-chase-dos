Game files are optional for building. `tools/relink.sh all --check-hashes`
builds and checks both executables using source plus the Turbo C 2.0 toolchain.

For direct reference comparison, put your own legally obtained originals here
(git-ignored): `DONALD.EXE` (retail), optionally `DONALD` (alternate).
Use `python3 tools/verify_originals.py` and `tools/relink.sh retail --verify`
(or `all --verify` when both references are present).

The game still needs its `.CMP` data files at runtime, beside the executable.
No game or compiler binaries should be committed to this repository.
