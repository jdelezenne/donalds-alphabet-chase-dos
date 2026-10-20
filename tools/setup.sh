#!/usr/bin/env bash
# Host prerequisites; licensed Turbo C inputs are installed separately.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
if [ "${1:-}" = --check ]; then
  for tool in python3 bash nasm "${DOSBOX:-dosbox-x}" flock timeout; do
    command -v "$tool" >/dev/null || { echo "Missing host prerequisite: $tool" >&2; exit 1; }
  done
  exec python3 "$ROOT/tools/toolchain.py" "${TC_ROOT:-/opt/tc20}" --exact
fi
sudo apt-get update -qq
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq python3 nasm p7zip-full
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq dosbox-x || \
  echo "Install DOSBox-X from its official packages/source."
echo "Install your Turbo C 2.0 with tools/install_tc.sh, set TC_ROOT, then run ./setup.sh --check."
