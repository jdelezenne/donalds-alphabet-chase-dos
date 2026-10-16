#!/usr/bin/env python3
"""Generate the not-yet-decompiled game data as relocatable OMF objects build/gen/dNNNN.OBJ from the local
game/DONALD.EXE (so no game bytes are committed). Layout: config/retail/datalayout.txt; object order: link.txt.
Every DGROUP-relative symbol used by the sources (g_XXXX -> offset XXXX, plus named ones in data.csv) is defined
as a public at its offset. Far pointers inside the data become segment fixups (DGROUP, or the code segment of the
function they point to), written in descending order per LEDATA record like Turbo C, so TLINK reproduces the
original relocation table order.
Usage: mkdata.py"""
import csv, glob, re, struct, sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent)); import omf
ROOT = Path(__file__).resolve().parents[1]
exe = (ROOT / "game/DONALD.EXE").read_bytes(); hdr = struct.unpack_from("<14H", exe); img = exe[hdr[4] * 16:]
DG = 0x9470
rel = struct.unpack_from(f"<{2 * hdr[3]}H", exe, hdr[12]); relocs = {rel[i + 1] * 16 + rel[i] for i in range(0, len(rel), 2)}
lay = {}; chunks = []
for l in (ROOT / "config/retail/datalayout.txt").read_text().splitlines():
    l = l.split("#")[0].split()
    if not l: continue
    if l[0] == "chunk": chunks.append((l[1].upper(), int(l[2], 16)))
    else: lay[l[0]] = [int(x, 16) for x in l[1:]]
# symbols: g_XXXX from the sources + named data.csv entries
names = set()
for f in glob.glob(str(ROOT / "src/**/*.[ch]"), recursive=True): names |= set(re.findall(r"\bg_[0-9A-F]{4}\b", open(f).read()))
syms = {n: int(n[2:], 16) for n in names}
for r in csv.DictReader(open(ROOT / "config/retail/data.csv")): syms[r["name"]] = int(r["offset"], 16)
# function symbols for far code pointers
lin = lambda a: int(a[:4], 16) * 16 + int(a[5:], 16)
funcs = {}
for r in csv.DictReader(open(ROOT / "config/retail/symbols.csv")):
    if r["status"] != "lib": funcs[lin(r["addr"])] = r["name"]
# link order -> sizes of each C/asm module's own _DATA, so each chunk starts where the previous module ended
order = []
for l in (ROOT / "config/retail/link.txt").read_text().splitlines():
    if not l.strip() or l.startswith("#"): continue
    n, s = l.split()[:2]; order.append((n, s))
pos = lay["data_start"][0]; plan = {}; ck = dict(chunks)
for n, s in order:
    if n == "@data": plan[s.upper()] = (pos, ck[s.upper()]); pos = ck[s.upper()]; continue
    kind, nm = s.split(":")
    if kind == "lib": continue
    o = ROOT / ("build/obj" if kind == "obj" else "build/asm") / (nm + ".OBJ")
    segs, _, data, fixes = omf.read(o)
    if kind == "obj": pos += pos & 1             # TC _DATA is word aligned, even when empty
    for i, sg in enumerate(segs):
        if sg and sg["name"] == "_DATA" and sg["len"]:
            fx = fixes.get(i, set())
            bad = [k for k in range(sg["len"]) if k not in fx and data[i][k] != img[DG + pos + k]]
            if bad: sys.exit(f"{nm}: _DATA differs from the original at DGROUP:{pos + bad[0]:04X} ({len(bad)} bytes)")
            pos += sg["len"]

def rec(t, body):
    b = bytes([t]) + struct.pack("<H", len(body) + 1) + body
    return b + bytes([(-sum(b)) & 0xFF])
def nm(s): return bytes([len(s)]) + s.encode()
def write(path, modname, dchunk, gfx=None, bss=None):
    lnames = ["DGROUP", "_DATA", "DATA", "_BSS", "BSS", "GFX_DATA"]
    out = rec(0x80, nm(modname)) + rec(0x96, b"".join(nm(x) for x in lnames))
    segdefs = [(0x28, dchunk[1] - dchunk[0], 2, 3)]               # _DATA byte-aligned public
    segdefs.append((0x28, (bss[1] - bss[0]) if bss else 0, 4, 5))   # _BSS
    segdefs.append((0x48, (gfx[1] - gfx[0]) if gfx else 0, 6, 3))   # GFX_DATA word-aligned public, class DATA
    for acbp, ln, n_, c_ in segdefs: out += rec(0x98, bytes([acbp]) + struct.pack("<H", ln) + bytes([n_, c_, 1]))
    out += rec(0x9A, bytes([1, 0xFF, 1, 0xFF, 2]))                   # DGROUP = _DATA, _BSS
    # externals: functions referenced by far code pointers in this chunk
    ext = []
    a0, a1 = dchunk
    for p in range(a0, a1 - 1):
        if DG + p in relocs:
            v = struct.unpack_from("<H", img, DG + p)[0]
            if v != DG >> 4:
                f = funcs.get(v * 16 + struct.unpack_from("<H", img, DG + p - 2)[0])
                if not f: sys.exit(f"far pointer at DGROUP:{p:04X} -> {v:04X}: no symbol")
                if f not in ext: ext.append(f)
    if ext: out += rec(0x8C, b"".join(nm("_" + f) + b"\0" for f in ext))
    pubs = {1: [], 2: [], 3: []}
    for s, off in sorted(syms.items(), key=lambda x: x[1]):
        if a0 <= off < a1: pubs[1].append((s, off - a0))
        elif gfx and gfx[0] <= off < gfx[1]: pubs[3].append((s, off - gfx[0]))
        elif bss and bss[0] <= off < bss[1]: pubs[2].append((s, off - bss[0]))
    for si, lst in pubs.items():
        for k in range(0, len(lst), 20):
            body = bytes([1 if si != 3 else 0, si]) + b"".join(nm("_" + s) + struct.pack("<H", o) + b"\0" for s, o in lst[k:k + 20])
            out += rec(0x90, body)
    # LEDATA records split at chunk edges and at offsets == record_mod (mod 0x400); fixups descending per record
    rm = lay["record_mod"][0]; cuts = sorted({a0, a1} | {x for x in range(rm, a1, 0x400) if a0 < x < a1})
    for s, e in zip(cuts, cuts[1:]):
        body = bytearray(img[DG + s:DG + e])
        for p in range(s, e - 1):
            if DG + p in relocs: body[p - s:p - s + 2] = b"\0\0"   # TLINK adds the frame to the stored value
        out += rec(0xA0, bytes([1]) + struct.pack("<H", s - a0) + bytes(body))
        fx = b""
        for p in sorted((p for p in range(s, e - 1) if DG + p in relocs), reverse=True):
            v = struct.unpack_from("<H", img, DG + p)[0]; lo = p - s
            loc = bytes([0xC0 | (2 << 2) | (lo >> 8), lo & 0xFF])     # segment-relative, 16-bit base
            if v == DG >> 4: fx += loc + bytes([0x15, 1, 1])            # frame GRP DGROUP, target GRP DGROUP
            else:
                f = funcs[v * 16 + struct.unpack_from("<H", img, DG + p - 2)[0]]
                fx += loc + bytes([0x56, ext.index(f) + 1])             # frame = target, target EXTDEF
        if fx: out += rec(0x9C, fx)
    if gfx:
        g0, g1 = gfx
        for s in range(g0, g1, 1024):
            out += rec(0xA0, bytes([3]) + struct.pack("<H", s - g0) + img[DG + s:DG + min(s + 1024, g1)])
    path.write_bytes(out + rec(0x8A, b"\0"))
gen = ROOT / "build/gen"; gen.mkdir(parents=True, exist_ok=True)
for f in gen.glob("*"): f.unlink()
for k, (a0, a1) in plan.items():
    if a1 < a0: sys.exit(f"chunk {k}: end {a1:#x} before start {a0:#x}")
    first = k == chunks[0][0]
    write(gen / f"d{k.lower()}.OBJ", f"d{k.lower()}", (a0, a1), lay["gfx"] if first else None, lay["bss"] if first else None)
    print(f"build/gen/d{k.lower()}.OBJ  _DATA {a0:04X}-{a1:04X}" + ("  + GFX_DATA, _BSS" if first else ""))
