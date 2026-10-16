#!/usr/bin/env bash
# Full relink check: compile C, assemble asm, generate data modules from the local EXE, TLINK, whole-EXE compare.
set -euo pipefail
cd "$(dirname "$0")/.."
python3 tools/verify.py >/dev/null || { echo "verify.py failed (function mismatch)"; exit 1; }
python3 tools/mkdata.py
python3 tools/relink.py "$@"
