#!/usr/bin/env bash
# Build complete DOS executables from source and the Turbo C 2.0 runtime.
# No game files are read unless --verify is explicitly requested.
set -euo pipefail
cd "$(dirname "$0")/.."
target=all; verify=(); check_hashes=false
for arg in "$@"; do
  case "$arg" in
    retail|alt|all) target=$arg ;;
    --verify) verify=(--verify) ;;
    --check-hashes) check_hashes=true ;;
    -h|--help)
      echo "Usage: tools/relink.sh [retail|alt|all] [--check-hashes] [--verify]"
      echo "Default: build both targets without reading game/."
      echo "--check-hashes checks the built files against config/originals.sha256 (no originals needed)."
      echo "--verify also compares with the selected original executable(s) in game/."
      exit 0 ;;
    *) echo "Unknown argument: $arg" >&2; exit 2 ;;
  esac
done
python3 tools/verify.py --sources-only
if [ ${#verify[@]} -gt 0 ]; then
  if [ "$target" != alt ] && [ ! -f game/DONALD.EXE ]; then
    echo "--verify requires game/DONALD.EXE; omit --verify for a source-only build." >&2; exit 1
  fi
  if [ "$target" != retail ] && [ ! -f game/DONALD ]; then
    echo "--verify requires game/DONALD; omit --verify for a source-only build." >&2; exit 1
  fi
fi
if [ "$target" != alt ]; then
  DAC_TARGET=retail tools/build.sh
  DAC_TARGET=retail tools/assemble.sh
  python3 tools/relink.py "${verify[@]}"
  if [ ${#verify[@]} -gt 0 ]; then python3 tools/verify.py --no-build; fi
fi
if [ "$target" != retail ]; then
  DAC_TARGET=alt tools/build.sh
  DAC_TARGET=alt tools/assemble.sh
  python3 tools/relink.py --alt "${verify[@]}"
fi
if "$check_hashes"; then python3 tools/check_build.py "$target"; fi
