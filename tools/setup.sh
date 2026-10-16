#!/usr/bin/env bash
# Toolchain setup (Debian/Ubuntu box). Idempotent.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
sudo apt-get update -qq
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq dosbox-x python3-venv git nasm mtools unzip || \
  echo "note: dosbox-x not in apt here; install it from flatpak/source"
python3 -m venv "$HERE/.venv"
"$HERE/.venv/bin/pip" install -q capstone==5.0.6
"$HERE/.venv/bin/python" "$HERE/verify_originals.py" && "$HERE/.venv/bin/python" "$HERE/mzinfo.py" "$HERE/../game/DONALD.EXE"
