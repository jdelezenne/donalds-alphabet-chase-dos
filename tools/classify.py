#!/usr/bin/env python3
"""Evidence-based source-language classification of every non-library function (config/retail/functions.csv
gains `lang` and `evidence` columns). Turbo C 2.0 traits vs hand-written assembly traits, from the original bytes.
Usage: classify.py [--write] [-v]"""
import csv, struct, sys, re
from pathlib import Path
from capstone import Cs, CS_ARCH_X86, CS_MODE_16
ROOT = Path(__file__).resolve().parents[1]
d = (ROOT / "game/DONALD.EXE").read_bytes(); img = d[struct.unpack_from("<H", d, 8)[0] * 16:]
md = Cs(CS_ARCH_X86, CS_MODE_16)
rows = list(csv.DictReader(open(ROOT / "config/retail/functions.csv")))
def feats(p, n):
    b = img[p:p + n]; ins = list(md.disasm(b, p)); txt = [f"{i.mnemonic} {i.op_str}" for i in ins]
    c, a = [], []
    if b[:3] == b"\x55\x8b\xec":
        c.append("bp-frame prologue")
        q = 3
        if b[q:q + 2] in (b"\x83\xec", b"\x81\xec"): c.append("sub sp,N locals"); q += 3 if b[q] == 0x83 else 4
        if b[q:q + 2] == b"\x56\x57" or b[q:q + 1] == b"\x56": c.append("push si[,di] (TC register vars)")
        if b[q:q + 3] == b"\x57\x56\x1e": a.append("push di,si,ds order (not TC)")
    elif b[:1] in (b"\x56",) : c.append("frameless push si (TC no-locals register var)")
    if re.search(rb"\x8b\xe5\x5d\xcb|\x5d\xcb|\x5e\x5d\xcb|\x5f\x5e\x5d\xcb", b): c.append("TC epilogue")
    j = " | ".join(txt)
    if re.search(r"jmp word ptr cs:\[bx \+ 0x[0-9a-f]+\]", j) and "shl bx, 1" in j: c.append("switch jump table (TC)")
    if re.search(r"pop cx|add sp, 0x[0-9a-f]+", j) and "lcall" in j: c.append("caller-cleans cdecl calls")
    if re.search(r"mov ax, 0x[0-9a-f]+ \| mov ds, ax", j) and "cs:" not in j: pass
    if re.search(r"mov (ax|bx), 0x[0-9a-f]{3} \| mov ds, ax", j): a.append("loads DS with own/far data segment")
    if re.search(r"\b(cs):\[", j): a.append("cs:-relative data")
    if re.search(r"mov (byte|word) ptr cs:\[", j): a.append("writes to code segment")
    if any(i.mnemonic == "iret" for i in ins): a.append("iret (interrupt handler)")
    if any(i.mnemonic in ("in", "out") for i in ins): a.append("port I/O")
    if any(i.mnemonic in ("stc", "clc", "cmc") for i in ins): a.append("carry-flag result")
    if any(i.mnemonic.startswith(("rep", "lods", "stos", "movs", "scas", "cmps")) for i in ins): a.append("string instructions")
    if any(i.mnemonic in ("cld", "std", "cli", "sti", "pushf", "popf", "xchg", "rcl", "rcr", "lahf", "sahf", "loop", "jcxz") for i in ins): a.append("non-TC idioms (cli/sti/xchg/rcl/loop/jcxz...)")
    if re.search(r"int 0x(10|16|21|33)", j): a.append("direct int")
    return c, a
out = []
for r in rows:
    if r["kind"] == "lib": r["lang"], r["evidence"] = "lib", "CL.LIB module match"; out.append(r); continue
    c, a = feats(int(r["linear"], 16), int(r["size"]))
    strong_c = "bp-frame prologue" in c and not any(x.startswith("push di,si,ds") for x in a)
    lang = "c" if (strong_c or "switch jump table (TC)" in c) and len(a) <= 1 else ("asm" if a or not c else "c?")
    if r["kind"] == "c":
        # byte-matched by TCC 2.0: compiler output by construction. Jump-table bytes disassemble as junk, so
        # hand-written traits only count when the function has no switch table.
        real_a = [x for x in a if "switch jump table (TC)" not in c]
        c.insert(0, "byte-matched by TCC 2.0")
        lang = "c" if not real_a else "c-flagged"
    r["lang"], r["evidence"] = lang, "; ".join(["C: " + ", ".join(c)] * bool(c) + ["ASM: " + ", ".join(a)] * bool(a))
    out.append(r)
if "--write" in sys.argv:
    w = csv.DictWriter(open(ROOT / "config/retail/functions.csv", "w", newline=""), fieldnames=["addr", "linear", "size", "kind", "lang", "evidence"])
    w.writeheader(); w.writerows(out)
for r in out:
    if r["lang"] != "lib" and ("-v" in sys.argv or r["lang"] != r["kind"].replace("c", "c")): print(r["addr"], r["kind"], r["lang"], r["size"], r["evidence"])
