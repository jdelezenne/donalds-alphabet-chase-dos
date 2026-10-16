#!/usr/bin/env python3
"""Find Turbo C startup/library modules in the original image (relocation-masked code compare).
Usage: libmatch.py LIBDIR [-m l|h] [--target game/DONALD.EXE] [--csv out.csv]
Each code segment of each module (C0x.OBJ + Cx.LIB [+ MATHx.LIB, EMU.LIB, GRAPHICS.LIB]) is searched in the image;
fixup bytes are wildcards. A hit is reported unique when the pattern occurs exactly once."""
import argparse, re, struct, sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent)); import omf
ROOT = Path(__file__).resolve().parents[1]
ap = argparse.ArgumentParser(); ap.add_argument("libdir"); ap.add_argument("-m", default="l")
ap.add_argument("--target", default=str(ROOT / "game/DONALD.EXE")); ap.add_argument("--csv"); ap.add_argument("--min", type=int, default=8)
a = ap.parse_args(); L = Path(a.libdir); m = a.m.upper()
exe = Path(a.target).read_bytes(); hdr = struct.unpack_from("<H", exe, 8)[0] * 16; img = exe[hdr:]
rel = struct.unpack_from(f"<{2*struct.unpack_from('<H', exe, 6)[0]}H", exe, struct.unpack_from("<H", exe, 0x18)[0])
segbases = sorted(set(rel[1::2]) | {0})
def segoff(lin):
    s = max(x for x in segbases if x * 16 <= lin); return f"{s:04X}:{lin - s*16:04X}"
mods = []
s, pu, d, f = omf.read(L / f"C0{m}.OBJ"); mods.append((s, pu, d, f, f"C0{m}"))
for lib in (f"C{m}.LIB", f"MATH{m}.LIB", "EMU.LIB", "FP87.LIB", "GRAPHICS.LIB"):
    if (L / lib).exists(): mods += [(s, pu, d, f, f"{lib}:{n}") for s, pu, d, f, n in omf.library(L / lib)]
hits, total = [], 0
for segs, pubs, data, fix, name in mods:
    for si in range(1, len(segs)):
        if not segs[si]["class"].upper().endswith("CODE") or segs[si]["len"] < a.min: continue
        code, fx = bytes(data[si]), fix.get(si, set())
        pat = b"".join(b"." if i in fx else re.escape(code[i:i+1]) for i in range(len(code)))
        found = [x.start() for x in re.finditer(pat, img, re.S)]
        if len(found) == 1:
            lin = found[0]; total += len(code)
            ps = sorted((o, n) for n, s2, o in pubs if s2 == si)
            hits.append((lin, len(code), name, ps))
hits.sort()
for lin, n, name, ps in hits:
    print(f"{segoff(lin)} {lin:05X} {n:5} {name:<24} {' '.join(p for _, p in ps)}")
print(f"# {len(hits)} unique module code segments, {total} bytes", file=sys.stderr)
if a.csv:
    with open(a.csv, "w") as o:
        o.write("name,addr,size,status,notes\n")
        for lin, n, name, ps in hits:
            ps = ps or [(0, name.split(':')[-1])]
            if ps[0][0] > 0: ps = [(0, name.split(':')[-1].lower() + '_local')] + ps
            for k, (off, p) in enumerate(ps):
                end = ps[k + 1][0] if k + 1 < len(ps) else n
                o.write(f"{p.lstrip('_') if p.startswith('_') else p},{segoff(lin+off)},{end-off},lib,{name}\n")
