#!/usr/bin/env python3
"""Disassemble original functions with relocation-aware far-call targets.
Usage: dumpfn.py SSSS:OOOO [...]  | dumpfn.py --list  (C functions with sizes, smallest first)"""
import csv, struct, sys
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "tools"))
from capstone import Cs, CS_ARCH_X86, CS_MODE_16
ROOT = Path(__file__).resolve().parents[2]
exe = (ROOT / "game/DONALD.EXE").read_bytes(); hdr = struct.unpack_from("<H", exe, 8)[0] * 16; img = exe[hdr:]
def funcs():
    rows = list(csv.DictReader(open(ROOT / "agents/config/retail/functions.csv")))
    out = []
    for i, r in enumerate(rows):
        out.append(dict(r, lin=int(r["linear"], 16), size=int(r["size"])))
    return out
def size_of(addr):
    for f in funcs():
        if f["addr"] == addr: return f["size"]
def dis(addr, n=None):
    s, o = (int(x, 16) for x in addr.split(":")); lin = s * 16 + o; n = n or size_of(addr) or 0x80
    md = Cs(CS_ARCH_X86, CS_MODE_16)
    for i in md.disasm(img[lin:lin + n], o):
        print(f"{s:04X}:{i.address:04X} {i.bytes.hex():<14} {i.mnemonic} {i.op_str}")
if __name__ == "__main__":
    if sys.argv[1] == "--list":
        done = {r["addr"] for r in csv.DictReader(open(ROOT / "agents/config/retail/symbols.csv")) if r["status"] == "matched"}
        for f in sorted(funcs(), key=lambda f: f["size"]):
            if f["kind"] == "c" and f["addr"] not in done: print(f["addr"], f["size"])
    else:
        for a in sys.argv[1:]: print("==", a); dis(a)
