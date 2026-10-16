#!/usr/bin/env bash
# Install YOUR OWN Turbo C into /opt (never into the repo). Accepts a .7z/.zip of the floppy images
# (WinWorld "Borland Turbo C 2.0 (1988) (3.5-720k)" / "2.01 (1989)") or a directory of .img files or an installed tree.
# Usage: tools/install_tc.sh <archive|dir> [dest, default /opt/tc20]
# Needs: p7zip-full (FAT images are extracted with 7z). Result: DEST/{TCC.EXE,TLINK.EXE,...,LIB/,INCLUDE/}
set -euo pipefail
SRC="$1"; DST=${2:-${TC_ROOT:-/opt/tc20}}; T=$(mktemp -d)
command -v 7z >/dev/null || sudo apt-get install -y -qq p7zip-full
if [ -f "$SRC" ]; then 7z x -y -o"$T/a" "$SRC" >/dev/null; else cp -r "$SRC" "$T/a"; fi
i=0; find "$T/a" -iname '*.img' -o -iname '*.ima' | while read -r img; do 7z x -y -o"$T/x/$i" "$img" >/dev/null; i=$((i+1)); done
sudo mkdir -p "$DST/LIB" "$DST/INCLUDE/SYS" && sudo chown -R "$USER" "$DST"
find "$T" -type f | while read -r f; do
  b=$(basename "$f"); case "$f" in */SYS/*.H|*/sys/*.h) cp "$f" "$DST/INCLUDE/SYS/"; continue;; esac
  case "${b^^}" in *.H) cp "$f" "$DST/INCLUDE/${b^^}";; *.OBJ|*.LIB) cp "$f" "$DST/LIB/${b^^}";; *.EXE|*.COM) cp "$f" "$DST/${b^^}";; esac
done
rm -rf "$T"
( cd "$DST" && sha256sum TCC.EXE TLINK.EXE LIB/C0L.OBJ LIB/CL.LIB > MANIFEST.sha256 && cat MANIFEST.sha256 )
SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy TC_ROOT="$DST" "$(dirname "$0")/dosrun.sh" "$(mktemp -d)" "TCC" | head -1
