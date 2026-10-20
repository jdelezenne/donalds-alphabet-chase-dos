#!/usr/bin/env python3
"""Bootstrap a NASM source for an assembly module from the local DONALD.EXE (one-shot helper; the output is
then hand-edited: names, comments, structure). Instructions NASM would encode differently are emitted as
`db` with the mnemonic in a comment, so the file always assembles byte-exactly.
Usage: asm2nasm.py SEG START END --code OFF[,OFF...] [--data OFF:END ...] > src/donald/engine/segXXXX.asm   (hex, seg-relative)
Code is traced (recursive descent) from the --code entry points; everything else becomes db."""
import sys, struct, subprocess, tempfile, os, re
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "tools"))
from capstone import Cs, CS_ARCH_X86, CS_MODE_16
ROOT = Path(__file__).resolve().parents[2]
d = (ROOT / "game/DONALD.EXE").read_bytes(); f = struct.unpack_from("<14H", d); img = d[f[4] * 16:]
rel = struct.unpack_from(f"<{2*f[3]}H", d, f[12]); relocs = {rel[i + 1] * 16 + rel[i] for i in range(0, len(rel), 2)}
seg, start, end = (int(x, 16) for x in sys.argv[1:4]); base = seg * 16
entries = [int(x, 16) for x in sys.argv[sys.argv.index("--code") + 1].split(",")]
md = Cs(CS_ARCH_X86, CS_MODE_16); md.skipdata = False
code = {}; todo = list(entries); targets = set(entries)
while todo:
    p = todo.pop()
    while start <= p < end and p not in code:
        ins = next(md.disasm(img[base + p:base + end], p), None)
        if ins is None: break
        code[p] = ins
        m = ins.mnemonic
        if (m.startswith("j") or m in ("call", "loop", "loope", "loopne", "jcxz")) and re.fullmatch(r"0x[0-9a-f]+", ins.op_str):
            t = int(ins.op_str, 16)
            if start <= t < end: targets.add(t); todo.append(t)
        if m in ("ret", "retf", "iret", "jmp", "ljmp") : break
        p += ins.size
INC = ROOT / "src/donald/engine/tasm.inc"
def nasm_bytes(line, org):
    with tempfile.TemporaryDirectory() as td:
        Path(td, "a.asm").write_text(f"bits 16\norg {org}\n%include \"{INC}\"\n{line}\n")
        r = subprocess.run(["nasm", "-f", "bin", "-o", f"{td}/a.bin", f"{td}/a.asm"], capture_output=True)
        return Path(td, "a.bin").read_bytes() if r.returncode == 0 else None
def conv(ins):
    m, o = ins.mnemonic, ins.op_str
    if re.fullmatch(r"(rep\w* )?(lods|stos|movs|scas|cmps)[bw]", m) and "cs:" not in o and not ("[si]" in o and "es:[si]" in o):
        return m                     # string ops: default segments, no operands
    o = o.replace(" ptr ", " ")
    o = re.sub(r"(byte|word|dword) (cs|ds|es|ss):\[", r"\1 [\2:", o)
    o = re.sub(r"\b(cs|ds|es|ss):\[", r"[\1:", o)
    if m == "lcall": m, o = "call", o.replace(", ", ":")
    if m == "ljmp": m, o = "jmp", o.replace(", ", ":")
    if m in ("call", "jmp") and re.fullmatch(r"0x[0-9a-f]+", o):
        t = int(o, 16); o = (f"L{t:04X}" if t in targets else o)
        if m == "jmp": o = ("short " if ins.size == 2 else "near ") + o
    elif m.startswith("j") or m.startswith("loop"):
        t = int(o, 16); o = f"L{t:04X}" if t in targets else o
        if m.startswith("j") and m != "jcxz" and ins.size == 2: o = "short " + o
    return f"{m} {o}".strip()
out = [f"; Module {seg:04X}: hand-written assembly (bootstrapped by tools/asm2nasm.py, then annotated).",
       f"; SEGMENT: DONALD {seg:04X} {start:04X}-{end:04X}", "bits 16", f"org 0x{start:04X}", '%include "tasm.inc"', ""]
p = start; data = []
def flush():
    global data
    for i in range(0, len(data), 16):
        out.append("    db " + ",".join(f"0x{b:02X}" for b in data[i:i + 16]))
    data = []
nb = 0
while p < end:
    if p in code:
        flush(); ins = code[p]
        if p in entries: out += ["", f"; FUNCTION: DONALD {seg:04X}:{p:04X}"]
        if p in targets: out.append(f"L{p:04X}:")
        line = conv(ins); raw = img[base + p:base + p + ins.size]
        # substitute label refs with numeric for the encoding check
        chk = re.sub(r"L([0-9A-F]{4})", lambda mm: "0x" + mm.group(1), line)
        cands = [line]
        mm = re.fullmatch(r"(\w+) (\w\w), (\w\w)", line)
        if mm and mm.group(1) in ("mov","add","or","adc","sbb","and","sub","xor","cmp"): cands.append(f"rr {mm.group(1)}, {mm.group(2)}, {mm.group(3)}")
        mi = re.fullmatch(r"(\w+) (.+), (-?0x[0-9a-f]+|-?\d+)", line)
        if mi: cands += [f"{mi.group(1)} {mi.group(2)}, strict word {mi.group(3)}", f"{mi.group(1)} {mi.group(2)}, strict byte {mi.group(3)}"]
        b = None
        for c in cands:
            cb = nasm_bytes(re.sub(r"L([0-9A-F]{4})", lambda q: "0x" + q.group(1), c), p)
            if cb == raw: line, b = c, cb; break
        rl = [x - base - p for x in relocs if base + p <= x < base + p + ins.size]
        cmt = "  ; reloc" if rl else ""
        if b == raw: out.append(f"    {line}{cmt}")
        else: out.append(f"    db {','.join(f'0x{x:02X}' for x in raw)}  ; {ins.mnemonic} {ins.op_str}{cmt}"); nb += 1
        p += ins.size
    else:
        if p in targets: flush(); out.append(f"L{p:04X}:")
        data.append(img[base + p]); p += 1
flush()
print("\n".join(out)); print(f"; {nb} instructions kept as db (NASM encodes them differently)", file=sys.stderr)
