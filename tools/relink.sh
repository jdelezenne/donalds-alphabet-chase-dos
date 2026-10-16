#!/usr/bin/env bash
# Full relink check: compile C, assemble asm, TLINK, whole-EXE compare. Every byte comes from src/ (the original
# EXE is only read for the comparison).
set -euo pipefail
cd "$(dirname "$0")/.."
python3 tools/verify.py >/dev/null || { echo "verify.py failed (function mismatch)"; exit 1; }
python3 tools/relink.py "$@"
