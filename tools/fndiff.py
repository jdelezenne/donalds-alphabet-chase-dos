#!/usr/bin/env python3
"""Instruction-level diff of one function (build obj vs original), operands normalised so that
relocated offsets and branch targets don't create noise. Handles a jump table by --skip START:END (hex, rel).
Usage: fndiff.py OBJ name SSSS:OOOO [--skip 9D:FD] [--ctx N]"""
import sys, re, difflib
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent)); import omf
from capstone import Cs, CS_ARCH_X86, CS_MODE_16
ROOT = Path(__file__).resolve().parents[1]
obj, name, addr = sys.argv[1:4]
skip = None
if "--skip" in sys.argv: a, b = sys.argv[sys.argv.index("--skip") + 1].split(":"); skip = (int(a, 16), int(b, 16))
ctx = int(sys.argv[sys.argv.index("--ctx") + 1]) if "--ctx" in sys.argv else 3
segs, pubs, data, fix = omf.read(obj)
exe = (ROOT / "game/DONALD.EXE").read_bytes(); img = exe[int.from_bytes(exe[8:10], "little") * 16:]
sg, of = (int(x, 16) for x in addr.split(":"))
si, off = [(s, o) for n, s, o in pubs if n.lstrip("_") == name][0]
nxt = sorted(o for n, s, o in pubs if s == si and o > off); end = nxt[0] if nxt else segs[si]["len"]
mine = bytes(data[si][off:end]); orig = img[sg * 16 + of: sg * 16 + of + len(mine) + 64]
md = Cs(CS_ARCH_X86, CS_MODE_16)
def norm(i):
    s = f"{i.mnemonic} {i.op_str}"
    if i.mnemonic.startswith("j") or i.mnemonic in ("call", "lcall"): return i.mnemonic
    s = re.sub(r"\[(bx|si|di)( \+ (?:si|di))?(?: [+-] (?:0x)?[0-9a-f]+)?\]", r"[\1\2 + X]", s)
    return re.sub(r"\[(?:0x)?[0-9a-f]+\]", "[X]", s)
def lst(buf, n):
    out = []
    parts = [(0, skip[0]), (skip[1], n)] if skip else [(0, n)]
    for a, b in parts:
        for i in md.disasm(buf[a:b], a): out.append((i.address, norm(i), f"{i.mnemonic} {i.op_str}"))
    return out
A = lst(mine, len(mine)); B = lst(orig, len(mine) + 64)
sm = difflib.SequenceMatcher(None, [x[1] for x in A], [x[1] for x in B], autojunk=False)
print(f"{name}: ratio {sm.ratio()*100:.1f}%")
for op, a1, a2, b1, b2 in sm.get_opcodes():
    if op == "equal": continue
    print(f"--- {op} mine {A[a1][0] if a1 < len(A) else -1:X} orig {B[b1][0] if b1 < len(B) else -1:X}")
    for x in A[max(0,a1-ctx):a2][:12]: print("  M", f"{x[0]:4X}", x[2])
    for x in B[max(0,b1-ctx):b2][:12]: print("  O", f"{x[0]:4X}", x[2])
