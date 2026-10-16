#!/usr/bin/env python3
"""Seed a function list: code segments from relocation targets, functions from Turbo C prologues.
Usage: funcs.py [game/DONALD.EXE] > config/retail/functions.csv
Heuristic only: a start is `push bp; mov bp,sp` (55 8B EC) or the byte after a RETF/RET in a segment."""
import struct, sys
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
d = (Path(sys.argv[1]) if len(sys.argv) > 1 else ROOT / "game/DONALD.EXE").read_bytes()
f = struct.unpack_from("<14H", d); hdr = f[4] * 16; img = d[hdr:(f[2] - 1) * 512 + (f[1] or 512)]
rel = struct.unpack_from(f"<{2*f[3]}H", d, f[12])
dgroup = struct.unpack_from("<H", img, 1)[0]          # C0x: mov dx, DGROUP
segs = sorted({s for s in rel[1::2] if s < dgroup} | {0})
print("addr,linear,segment_end,kind")
for i, s in enumerate(segs):
    lo, hi = s * 16, (segs[i + 1] * 16 if i + 1 < len(segs) else dgroup * 16)
    p = lo
    while True:
        p = img.find(b"\x55\x8b\xec", p, hi)
        if p < 0: break
        print(f"{s:04X}:{p-lo:04X},{p:05X},{hi:05X},prologue"); p += 3
