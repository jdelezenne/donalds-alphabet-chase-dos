#!/usr/bin/env python3
"""Check game/ against config/originals.sha256. Exit 1 if a required file is missing or differs."""
import hashlib, sys
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
REQUIRED = {"DONALD.EXE"}
bad = 0
for line in (ROOT / "config/originals.sha256").read_text().splitlines():
    h, size, name = line.split(None, 2)
    p = ROOT / "game" / name
    if not p.exists():
        if name in REQUIRED: print(f"MISSING {name}"); bad = 1
        continue
    got = hashlib.sha256(p.read_bytes()).hexdigest()
    ok = got == h
    bad |= (not ok) and name in REQUIRED
    print(f"{'OK  ' if ok else 'BAD '} {name} ({size} bytes)")
sys.exit(bad)
