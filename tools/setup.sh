#!/usr/bin/env bash
# Toolchain setup (Debian/Ubuntu box). Idempotent.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
sudo apt-get update -qq
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq python3-venv git nasm mtools unzip
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq dosbox-x || \
  echo "note: dosbox-x not in apt here; install it from the official DOSBox-X packages/source"
python3 -m venv "$HERE/.venv"
"$HERE/.venv/bin/pip" install -q capstone==5.0.6
echo "Install your Turbo C 2.0 toolchain with tools/install_tc.sh, then run tools/relink.sh all --check-hashes."
echo "Game files are not needed to build. Reference verification is optional."
