#!/usr/bin/env python3
"""Full-layout splice build (the maniac-mansion-dos / tintin-tibet-dos convention): start from the local
game/DONALD.EXE, overwrite every byte we can produce ourselves (compiled C functions at non-fixup positions,
assembled src/donald/engine and src/donald/audio modules), write build/DONALD.EXE and byte-compare it with the original.
Fixup bytes (segment/offset values TLINK would write) and everything outside matched code (header, DGROUP data,
library code) come from the local original; they are never stored in git. A real TLINK relink is the next step.
Usage: splice.py   (run tools/verify.py first so build/obj and build/asm exist)"""
import csv, re, struct, sys
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "tools"))
sys.path.insert(0, str(Path(__file__).parent)); import omf
ROOT = Path(__file__).resolve().parents[2]
exe = bytearray((ROOT / "game/DONALD.EXE").read_bytes()); hdr = struct.unpack_from("<H", exe, 8)[0] * 16
out = bytearray(exe); ours = 0; differ = 0
ANN = re.compile(r"/\*\s*FUNCTION:\s*DONALD\s+([0-9A-Fa-f]{4}):([0-9A-Fa-f]{4})\s*\*/")
DEF = re.compile(r"^(?:[A-Za-z_][\w \*]*?[\s\*])?(\w+)\s*\([^;]*$")
for src in sorted((ROOT / "src").rglob("*.c")):
    lines = src.read_text().splitlines(); want = {}
    for i, l in enumerate(lines):
        m = ANN.search(l)
        if m:
            for l2 in lines[i + 1:]:
                d = DEF.match(l2)
                if d: want[d.group(1)] = int(m.group(1), 16) * 16 + int(m.group(2), 16); break
    obj = ROOT / "build/obj" / (src.stem + ".OBJ")
    if not want or not obj.exists(): continue
    segs, pubs, data, fix = omf.read(obj)
    code = sorted((si, off, nm.lstrip("_")) for nm, si, off in pubs if segs[si]["class"].upper().endswith("CODE"))
    for k, (si, off, nm) in enumerate(code):
        if nm not in want: continue
        end = next((x[1] for x in code[k + 1:] if x[0] == si), segs[si]["len"])
        fx = set(fix.get(si, ()))
        mine = data[si][off:end]
        while len(mine) > 1 and mine[-1] == 0x90: mine = mine[:-1]
        for i, b in enumerate(mine):
            if off + i in fx: continue
            p = hdr + want[nm] + i
            # near calls inside a module are relocated by layout; keep the original rel16 there
            if i >= 2 and mine[i - 2] == 0x0E and mine[i - 1] == 0xE8: continue
            if i >= 3 and mine[i - 3] == 0x0E and mine[i - 2] == 0xE8: continue
            if out[p] != b: differ += 1
            out[p] = b; ours += 1
for a in sorted((ROOT / "src").rglob("*.asm")):
    m = re.search(r"SEGMENT:\s*DONALD\s+(\w{4})\s+(\w{4})-(\w{4})", a.read_text())
    sg, a0, a1 = (int(x, 16) for x in m.groups()); b = (ROOT / "build/asm" / (a.stem + ".bin")).read_bytes()
    for i, x in enumerate(b):
        p = hdr + sg * 16 + a0 + i
        if out[p] != x: differ += 1
        out[p] = x; ours += 1
(ROOT / "build").mkdir(exist_ok=True); (ROOT / "build/DONALD.EXE").write_bytes(out)
code_end = struct.unpack_from("<H", exe, hdr + 1)[0] * 16
same = out == exe
print(f"build/DONALD.EXE: {len(out)} bytes, identical to original: {same}; "
      f"{ours} bytes produced by our sources ({100*ours/code_end:.2f}% of {code_end} code bytes), {differ} differing")
sys.exit(0 if same else 1)
