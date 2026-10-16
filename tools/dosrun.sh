#!/usr/bin/env bash
# Run DOS commands headless in DOSBox-X. C: = Turbo C root ($TC_ROOT, default /opt/tc20), D: = work dir ($1).
# Remaining args are DOS command lines; their output is captured to D:\_OUT.TXT and printed.
set -euo pipefail
TC=${TC_ROOT:-/opt/tc20}; WORK="$(realpath "$1")"; shift
BAT="$WORK/_RUN.BAT"
{ echo "@echo off"; echo "set PATH=C:\\"; echo "set TMP=D:\\"
  for c in "$@"; do echo "$c >> D:\\_OUT.TXT"; done; } | sed 's/$/\r/' > "$BAT"
rm -f "$WORK/_OUT.TXT"
SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy timeout "${DOS_TIMEOUT:-300}" dosbox-x -silent -nogui -nomenu -fastlaunch \
  -set "cpu cycles=max" -set "dos ver=3.3" -set "dosbox memsize=16" \
  -c "mount c $TC" -c "mount d $WORK" -c "d:" -c "call _RUN.BAT" -c "exit" >/dev/null 2>&1 || true
[ -f "$WORK/_OUT.TXT" ] && tr -d '\r' < "$WORK/_OUT.TXT"
rm -f "$BAT"
