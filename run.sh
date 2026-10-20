#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
DATA="${1:-$ROOT/game}"
TARGET="${2:-retail}"
case "$TARGET" in
 retail) EXE="$ROOT/build/link/DONALD.EXE" ;;
 alt) EXE="$ROOT/build/link-alt/DONALD" ;;
 *) echo "Usage: ./run.sh [game-data-directory] [retail|alt]" >&2; exit 2 ;;
esac
[ -f "$EXE" ] || { echo "Run ./build.sh first." >&2; exit 1; }
[ -d "$DATA" ] || { echo "Supply your legally obtained game-data directory." >&2; exit 1; }
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
cp -R "$DATA"/. "$STAGE"/
cp "$EXE" "$STAGE/DONALD.EXE"
"${DOSBOX:-dosbox-x}" -noautoexec -noconfig -c "mount c \"$STAGE\"" -c "c:" -c "DONALD.EXE" -c "exit"
