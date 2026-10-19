#!/usr/bin/env bash
# Run DOS commands headless in DOSBox-X. C: = Turbo C root, D: = work directory.
# Propagate emulator failures, timeouts and DOS command ERRORLEVEL to the caller.
set -euo pipefail
if [ "$#" -lt 2 ]; then echo "Usage: dosrun.sh WORKDIR DOS_COMMAND..." >&2; exit 2; fi
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TC=${TC_ROOT:-/opt/tc20}; WORK="$(realpath "$1")"; shift
DOSBOX=${DOSBOX:-dosbox-x}
command -v "$DOSBOX" >/dev/null || { echo "DOSBox-X is required (set DOSBOX to its executable)." >&2; exit 1; }
[ -d "$TC" ] || { echo "Turbo C directory not found: $TC (set TC_ROOT)." >&2; exit 1; }
DOSBOX=$(command -v "$DOSBOX")
DOSBOX=$(realpath "$DOSBOX")
STAGE=$(mktemp -d)
BAT="$WORK/_RUN.BAT"
trap 'rm -f "$BAT"; rm -rf "$STAGE"' EXIT
python3 "$ROOT/tools/toolchain.py" "$TC" --stage "$STAGE/compiler"
mkdir "$STAGE/home"
cp "$ROOT/config/compiler-dosbox.conf" "$STAGE/compiler.conf"
{
  echo "@echo off"
  echo "set PATH=C:\\"
  echo "set TMP=D:\\"
  for c in "$@"; do
    echo "$c >> D:\\_OUT.TXT"
    if [ "${DOS_CONTINUE_ON_ERROR:-0}" = 1 ]; then
      # The permuter compiles independent candidates, some intentionally invalid.
      # Attempt every candidate but still return failure for the overall batch.
      echo "if errorlevel 1 echo failed>> D:\\_FAIL.TXT"
    else
      echo "if errorlevel 1 goto failed"
    fi
  done
  echo "echo complete> D:\\_DONE.TXT"
  echo "goto end"
  echo ":failed"
  echo "echo failed> D:\\_FAIL.TXT"
  echo ":end"
} | sed 's/$/\r/' > "$BAT"
rm -f "$WORK/_OUT.TXT" "$WORK/_DONE.TXT" "$WORK/_FAIL.TXT"
rc=0
# Only this invocation's compiler snapshot and caller-supplied work directory
# are mounted. Ignore host DOSBox config, mapper and autoexec files explicitly.
# Serialize the real emulator process across the related DOS recoveries.
(
  cd "$STAGE"
  export HOME="$STAGE/home" XDG_CONFIG_HOME="$STAGE/home"
  export SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy
  flock /tmp/disney-dosbox.lock timeout --kill-after=5 "${DOS_TIMEOUT:-300}" "$DOSBOX" \
    -conf "$STAGE/compiler.conf" -noautoexec -noconfig -defaultmapper \
    -silent -nogui -nomenu -fastlaunch -set "cpu cycles=${DOS_CYCLES:-fixed 100000}" \
    -c "mount c \"$STAGE/compiler\"" -c "mount d \"$WORK\"" \
    -c "d:" -c "call _RUN.BAT" -c "exit"
) >"$WORK/_EMU.LOG" 2>&1 || rc=$?
if [ -f "$WORK/_OUT.TXT" ]; then tr -d '\r' < "$WORK/_OUT.TXT"; fi
if [ "$rc" -ne 0 ]; then
  cat "$WORK/_EMU.LOG" >&2
  echo "DOSBox-X failed with status $rc (124 means timeout)." >&2
  exit "$rc"
fi
if [ -f "$WORK/_FAIL.TXT" ] || [ ! -f "$WORK/_DONE.TXT" ]; then
  echo "DOS command failed or did not finish; see $WORK/_OUT.TXT and _EMU.LOG." >&2
  exit 1
fi
