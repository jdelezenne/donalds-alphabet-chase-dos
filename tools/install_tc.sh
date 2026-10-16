#!/usr/bin/env bash
# Install YOUR OWN Turbo C 2.0 (or 2.01) files into $TC_ROOT (default /opt/tc20), never into the repo.
# Usage: tools/install_tc.sh <dir-or-zip-with-TCC.EXE, TLINK.EXE, LIB\*.LIB, INCLUDE\*>
set -euo pipefail
SRC="$1"; DST=${TC_ROOT:-/opt/tc20}
sudo mkdir -p "$DST" && sudo chown "$USER" "$DST"
if [ -f "$SRC" ]; then T=$(mktemp -d); unzip -qo "$SRC" -d "$T"; SRC="$T"; fi
TCC=$(find "$SRC" -iname TCC.EXE | head -1); [ -n "$TCC" ] || { echo "TCC.EXE not found"; exit 1; }
BASE=$(dirname "$TCC")
cp -r "$BASE"/. "$DST"/
# Flatten: tcc expects -I / -L paths; keep LIB and INCLUDE under root.
for d in LIB INCLUDE; do [ -d "$DST/$d" ] || echo "warning: $DST/$d missing"; done
sha256sum "$DST"/TCC.EXE "$DST"/TLINK.EXE "$DST"/LIB/C0*.OBJ 2>/dev/null | tee "$DST/MANIFEST.sha256"
echo "Installed to $DST. Record the hashes in docs/TOOLCHAIN.md."
