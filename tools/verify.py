#!/usr/bin/env python3
"""reccmp-style verifier for Turbo C 2.0 / DOS.
Every function in src/**.c carries `/* FUNCTION: DONALD SSSS:OOOO */` on the line(s) before its definition.
verify.py builds everything (tools/build.sh), compares each annotated function against game/DONALD.EXE with
fixup bytes masked, updates config/retail/symbols.csv (matched/nonmatching + %), and prints byte progress.
Usage: verify.py [-n|--no-build] [-v] [paths...]   exit 1 if any annotated function does not match."""
import csv, re, subprocess, sys, struct
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent)); import omf
ROOT = Path(__file__).resolve().parents[1]
args = [a for a in sys.argv[1:] if not a.startswith("-")]
srcs = [Path(a) for a in args] or sorted((ROOT / "src").rglob("*.c"))
if "-n" not in sys.argv and "--no-build" not in sys.argv:
    subprocess.run([str(ROOT / "tools/build.sh"), *map(str, srcs)], check=False, stdout=subprocess.DEVNULL)
exe = (ROOT / "game/DONALD.EXE").read_bytes(); img = exe[struct.unpack_from("<H", exe, 8)[0] * 16:]
ANN = re.compile(r"/\*\s*FUNCTION:\s*DONALD\s+([0-9A-Fa-f]{4}):([0-9A-Fa-f]{4})\s*\*/")
DEF = re.compile(r"^[A-Za-z_][\w \*]*?\b(\w+)\s*\([^;]*$")
res = {}
for src in srcs:
    lines = src.read_text().splitlines(); want = []
    for i, l in enumerate(lines):
        m = ANN.search(l)
        if m:
            for l2 in lines[i + 1:]:
                d = DEF.match(l2)
                if d: want.append((d.group(1), m.group(1).upper() + ":" + m.group(2).upper())); break
    obj = ROOT / "build/obj" / (src.stem + ".OBJ")
    if not obj.exists():
        for n, a in want: res[n] = (a, 0, 0.0, "nobuild", src)
        continue
    segs, pubs, data, fix = omf.read(obj)
    code = sorted((si, off, nm.lstrip("_")) for nm, si, off in pubs if segs[si]["class"].upper().endswith("CODE"))
    for n, a in want:
        hit = [(k, c) for k, c in enumerate(code) if c[2] == n]
        if not hit: res[n] = (a, 0, 0.0, "missing", src); continue
        k, (si, off, _) = hit[0]
        end = next((x[1] for x in code[k + 1:] if x[0] == si), segs[si]["len"])
        mine = data[si][off:end]
        while len(mine) > 1 and mine[-1] == 0x90: mine = mine[:-1]
        lin = int(a[:4], 16) * 16 + int(a[5:], 16); orig = img[lin:lin + len(mine)]
        fx = {p - off for p in fix.get(si, ()) if off <= p < end}
        # near calls (push cs; call rel16) inside the module: compare resolved targets via annotations,
        # because the intra-segment layout is incomplete until every function of the module is placed
        ann = {nm: ad for nm, ad in want}
        offs = {o: nm for s2, o, nm in code if s2 == si}
        for i in range(len(mine) - 3):
            if mine[i] == 0x0E and mine[i + 1] == 0xE8 and orig[i + 1] == 0xE8:
                t_mine = (off + i + 4 + int.from_bytes(mine[i + 2:i + 4], "little", signed=True)) & 0xFFFF
                t_orig = (lin + i + 4 + int.from_bytes(orig[i + 2:i + 4], "little", signed=True)) & 0xFFFF
                tn = offs.get(t_mine); ta = ann.get(tn)
                if ta and (int(ta[:4], 16) * 16 + int(ta[5:], 16)) & 0xFFFF == t_orig & 0xFFFF:
                    fx |= {i + 2, i + 3}
        bad = sum(1 for i in range(len(mine)) if i not in fx and mine[i] != orig[i])
        res[n] = (a, len(mine), 100.0 * (len(mine) - bad) / max(1, len(mine)), "matched" if bad == 0 else "nonmatching", src)
# update symbols.csv
p = ROOT / "config/retail/symbols.csv"; rows = list(csv.DictReader(open(p)))
byaddr = {r["addr"]: r for r in rows}
for n, (a, size, pct, st, src) in res.items():
    r = byaddr.get(a) or {}
    r.update(name=n, addr=a, size=str(size), status=st, notes=f"{pct:.1f}% {src.relative_to(ROOT)}")
    byaddr[a] = r
rows = sorted(byaddr.values(), key=lambda r: int(r["addr"][:4], 16) * 16 + int(r["addr"][5:], 16))
w = csv.DictWriter(open(p, "w"), fieldnames=["name", "addr", "size", "status", "notes"]); w.writeheader(); w.writerows(rows)
for n, (a, size, pct, st, src) in sorted(res.items(), key=lambda x: x[1][0]):
    if st != "matched" or "-v" in sys.argv: print(f"{a} {n:<28} {size:5} {pct:6.1f}% {st}")
fn = list(csv.DictReader(open(ROOT / "config/retail/functions.csv")))
ctot = sum(int(r["size"]) for r in fn if r["kind"] == "c")
code_end = struct.unpack_from("<H", img, 1)[0] * 16       # DGROUP start = end of code
mc = sum(v[1] for v in res.values() if v[3] == "matched")
lib = sum(int(r["size"]) for r in rows if r["status"] == "lib")
nm = sum(1 for v in res.values() if v[3] == "matched")
print(f"matched {nm}/{len(res)} annotated; C {mc}/{ctot} bytes = {100*mc/ctot:.2f}%; "
      f"code {mc+lib}/{code_end} bytes = {100*(mc+lib)/code_end:.2f}% (incl. {lib} lib)")
(ROOT / "build").mkdir(exist_ok=True)
(ROOT / "build/progress.txt").write_text(f"{100*mc/ctot:.2f}\n")
sys.exit(0 if all(v[3] == "matched" for v in res.values()) else 1)
