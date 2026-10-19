#!/usr/bin/env python3
"""Discover function candidates: far-call targets (9A with relocation) + near calls
preceded by PUSH CS + `push bp; mov bp,sp` prologues. size = distance to next start (or DGROUP).
kind: lib (libmatch spans in symbols.csv), asm (segment 0000 after C0L, segments 0512/056A, or self-loading
DS prologue), c (size trimmed to the last RET, so trailing data is not counted). Annotated starts are included;
sizes never cross the next segment base. This heuristic is NOT an authoritative assembly boundary finder:
embedded data, interrupt handlers and overlapping near helpers require the reviewed asm_functions.csv.
Existing reviewed C/library records and all their metadata are preserved when writing; new heuristic
candidates are reported but never promoted into the reviewed catalog. Assembly entries come exclusively
from that catalog, rather than the heuristic's next-entry spans.
Usage: funcs.py [--write] [--exe path/to/reference.exe]"""
import csv, struct, sys
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
reference = Path(sys.argv[sys.argv.index("--exe") + 1]) if "--exe" in sys.argv else ROOT / "game/DONALD.EXE"
d = reference.read_bytes()
f = struct.unpack_from("<14H", d); hdr = f[4] * 16; img = d[hdr:]
rel = struct.unpack_from(f"<{2*f[3]}H", d, f[12]); relocs = {rel[i + 1] * 16 + rel[i] for i in range(0, len(rel), 2)}
dgroup = struct.unpack_from("<H", img, 1)[0]; end = dgroup * 16
starts = {}
for p in range(end - 5):
    if img[p] == 0x9A and p + 3 in relocs:
        off, seg = struct.unpack_from("<HH", img, p + 1)
        if seg * 16 + off < end: starts[seg * 16 + off] = (seg, off)
    if img[p] == 0x0E and img[p + 1] == 0xE8:        # push cs; call near
        t = (p + 4 + struct.unpack_from("<h", img, p + 2)[0]) & 0xFFFF
        seg = next((s for s, o in starts.values() if False), None)
for p in range(end - 3):
    if img[p:p + 3] == b"\x55\x8b\xec" and p not in starts:
        # attach to the closest known segment base below
        bases = sorted({s for s, _ in starts.values() if s * 16 <= p})
        s = bases[-1] if bases else 0
        starts[p] = (s, p - s * 16)
# near targets of push cs; call
for p in range(end - 4):
    if img[p] == 0x0E and img[p + 1] == 0xE8:
        bases = sorted({s for s, _ in starts.values() if s * 16 <= p}); s = bases[-1] if bases else 0
        t = s * 16 + ((p - s * 16 + 4 + struct.unpack_from("<h", img, p + 2)[0]) & 0xFFFF)
        if t < end and t not in starts: starts[t] = (s, t - s * 16)
# annotated functions (src/**/*.c `/* FUNCTION: DONALD SSSS:OOOO */`) are authoritative starts
import re
for src in (ROOT / "src").rglob("*.c"):
    for m in re.finditer(r"FUNCTION:\s*DONALD\s+([0-9A-Fa-f]{4}):([0-9A-Fa-f]{4})", src.read_text()):
        sg, of = int(m.group(1), 16), int(m.group(2), 16); starts[sg * 16 + of] = (sg, of)
ASM_SEGS = {0x0512, 0x056A}                     # hand-written asm modules (cs:-relative data, DS reloads)
# asm module spans (src/asm/*.asm headers) bound the neighbouring functions; a TLINK segment base is only the
# paragraph below a module's first byte, so sizes are NOT capped at segment bases in general
asm_spans = []
for a in (ROOT / "src/asm").glob("*.asm"):
    m = re.search(r"SEGMENT:\s*DONALD\s+(\w{4})\s+(\w{4})-(\w{4})", a.read_text())
    if m: sg, a0, a1 = (int(x, 16) for x in m.groups()); asm_spans.append((sg * 16 + a0, sg * 16 + a1))
segbases = sorted({a for a, _ in asm_spans} | {end})
lib = [r for r in csv.DictReader(open(ROOT / "config/retail/symbols.csv")) if r["status"] == "lib"]
sp = [(int(r["addr"][:4], 16) * 16 + int(r["addr"][5:], 16), int(r["size"])) for r in lib]
ks = sorted(starts); rows = []
for i, p in enumerate(ks):
    s, o = starts[p]
    nb = next(b for b in segbases if b > p)       # never run past the next segment base
    n = min(ks[i + 1] if i + 1 < len(ks) else end, nb) - p
    if any(a <= p < a + m for a, m in sp): kind = "lib"
    elif p < 0x2DAB or s in ASM_SEGS or any(a <= p < b for a, b in asm_spans) or img[p + 3:p + 7] == b"\x57\x56\x1e\xb8": kind = "asm"
    else:
        kind = "c"
        # C size excludes trailing data/padding: cut after the last RET/RETF in the span
        body = img[p:p + n]; r = max(body.rfind(b"\xcb"), body.rfind(b"\xc3"))
        if r >= 0: n = r + 1
    rows.append(dict(addr=f"{s:04X}:{o:04X}", linear=f"{p:05X}", size=n, kind=kind,
                     lang=kind, evidence="Heuristic candidate; needs source/boundary review"))
# Do not erase recovered types/evidence or re-absorb data/helper bodies into a public function.
reviewed = list(csv.DictReader(open(ROOT / "config/retail/functions.csv")))
byaddr = {r["addr"]: r for r in reviewed if r["kind"] != "asm"}
candidates = [r for r in rows if r["kind"] != "asm" and r["addr"] not in byaddr]
for r in csv.DictReader(open(ROOT / "config/retail/asm_functions.csv")):
    p = int(r["addr"][:4], 16) * 16 + int(r["addr"][5:], 16)
    byaddr[r["addr"]] = dict(addr=r["addr"], linear=f"{p:05X}", size=r["size"], kind="asm", lang="asm",
                             evidence=f"{r['role']}: {r['evidence']}")
rows = sorted(byaddr.values(), key=lambda r: int(r["linear"], 16))
if "--write" in sys.argv:
    w = csv.DictWriter(open(ROOT / "config/retail/functions.csv", "w"), fieldnames=["addr", "linear", "size", "kind", "lang", "evidence"], lineterminator="\n"); w.writeheader(); w.writerows(rows)
import collections
c = collections.Counter(r["kind"] for r in rows); b = collections.Counter()
for r in rows: b[r["kind"]] += int(r["size"])
print("records:", dict(c), "listed body bytes (overlapping helpers are not additive coverage):", dict(b))
if candidates:
    print(f"Unreviewed non-ASM candidates: {len(candidates)} (not written):", " ".join(r["addr"] for r in candidates))
