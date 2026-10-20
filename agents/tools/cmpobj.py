#!/usr/bin/env python3
"""Compare public functions of a Turbo C .OBJ against the original image, fixup bytes wildcarded.
Usage: cmpobj.py build/obj/X.OBJ name=SSSS:OOOO [name=...]   (load-image segment:offset, hex)
       cmpobj.py build/obj/X.OBJ            -> uses addresses from agents/config/retail/symbols.csv
Env: TARGET=game/DONALD.EXE  FULL=1 (full side-by-side on mismatch)"""
import os, sys, csv
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "tools"))
sys.path.insert(0, str(Path(__file__).parent))
import omf
from capstone import Cs, CS_ARCH_X86, CS_MODE_16
ROOT = Path(__file__).resolve().parents[2]
exe = (ROOT / os.environ.get("TARGET", "game/DONALD.EXE")).read_bytes()
img = exe[int.from_bytes(exe[8:10], "little") * 16:]
segs, pubs, data, fix = omf.read(sys.argv[1])
want = dict(a.split("=") for a in sys.argv[2:])
if not want:
    for row in csv.DictReader(open(ROOT / "agents/config/retail/symbols.csv")): want[row["name"]] = row["addr"]
code = sorted((si, off, nm) for nm, si, off in pubs if segs[si]["class"].upper().endswith("CODE"))
md = Cs(CS_ARCH_X86, CS_MODE_16); rc = 0
for k, (si, off, nm) in enumerate(code):
    key = nm.lstrip("_")
    if key not in want and nm not in want: continue
    seg, o = (int(x, 16) for x in want.get(key, want.get(nm)).split(":")); lin = seg * 16 + o
    end = next((x[1] for x in code[k + 1:] if x[0] == si), segs[si]["len"])
    mine, orig = data[si][off:end], img[lin:lin + end - off]
    fx = {p - off for p in fix.get(si, ()) if off <= p < end}
    bad = [i for i in range(len(mine)) if i not in fx and mine[i] != orig[i]]
    print(f"{key:<28} {seg:04X}:{o:04X} len {len(mine):5}  {'MATCH' if not bad else f'DIFF {len(bad)} bytes, first +{bad[0]:X}'}")
    if bad:
        rc = 1
        a = list(md.disasm(bytes(mine), 0)); b = list(md.disasm(bytes(orig), 0))
        for x, y in list(zip(a, b))[(0 if os.environ.get("FULL") else max(0, next(i for i, z in enumerate(a) if z.address + z.size > bad[0]) - 3)):][:None if os.environ.get("FULL") else 14]:
            m = "*" if any(x.address <= q < x.address + x.size for q in bad) else " "
            print(f"  {m}{x.address:4X} {x.mnemonic} {x.op_str:<30} | {y.address:4X} {y.mnemonic} {y.op_str}")
sys.exit(rc)
