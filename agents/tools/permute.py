#!/usr/bin/env python3
"""Brute-force source variants (decomp-permuter-lite for Turbo C under DOSBox).
Write alternatives inline as  @P{alt1|alt2|...}  in a copy of the source, then:
  permute.py src/donald/game.c.perm src/donald/game.c [--flags "-ml|-ml -O|-ml -O -Z"]
Every combination (x every flag set) is compiled in one DOSBox batch per 40 variants and scored with
the verify masker; best scores are printed and the first full match is written to the target file."""
import itertools, os, re, subprocess, sys, shutil, struct
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "tools"))
sys.path.insert(0, str(Path(__file__).parent)); import omf
ROOT = Path(__file__).resolve().parents[2]
perm, target = Path(sys.argv[1]), Path(sys.argv[2])
flags = (sys.argv[sys.argv.index("--flags") + 1].split("|") if "--flags" in sys.argv
         else [open(ROOT / "src/donald/cflags.txt").readline().strip()])
text = perm.read_text(); slots = re.findall(r"@P\{([^}]*)\}", text)
combos = list(itertools.product(*[s.split("|") for s in slots]))
ann = re.findall(r"/\*\s*FUNCTION:\s*DONALD\s+(\w{4}):(\w{4})\s*\*/\s*\n(?:.*\n)*?\S[^\n(]*?(\w+)\s*\(", text)
exe = (ROOT / "game/DONALD.EXE").read_bytes(); img = exe[struct.unpack_from("<H", exe, 8)[0] * 16:]
def score(obj):
    segs, pubs, data, fix = omf.read(obj); tot = bad = 0
    code = sorted((si, off, nm.lstrip("_")) for nm, si, off in pubs if segs[si]["class"].upper().endswith("CODE"))
    for s, o, name in ann:
        hit = [(k, c) for k, c in enumerate(code) if c[2] == name]
        if not hit: return 0.0
        k, (si, off, _) = hit[0]; end = next((x[1] for x in code[k + 1:] if x[0] == si), segs[si]["len"])
        mine = data[si][off:end]; lin = int(s, 16) * 16 + int(o, 16); orig = img[lin:lin + len(mine)]
        fx = {p - off for p in fix.get(si, ()) if off <= p < end}
        bad += sum(1 for i in range(len(mine)) if i not in fx and mine[i] != orig[i]); tot += len(mine)
    return 100.0 * (tot - bad) / max(tot, 1)
work = ROOT / "build/perm"; shutil.rmtree(work, ignore_errors=True); work.mkdir(parents=True)
for h in (ROOT / "src").rglob("*.h"): (work / h.name.upper()).write_text(h.read_text().replace("\n", "\r\n"))
jobs = []
for fi, fl in enumerate(flags):
    for ci, c in enumerate(combos):
        it = iter(c); src = re.sub(r"@P\{[^}]*\}", lambda m: next(it), text)
        name = f"P{fi:01d}{ci:05d}"; (work / f"{name}.C").write_text(src.replace("\n", "\r\n")); jobs.append((name, fl, c, src))
results = []
for i in range(0, len(jobs), 40):
    batch = jobs[i:i + 40]
    subprocess.run([str(ROOT / "tools/dosrun.sh"), str(work)] + [f"TCC -c -IC:\\INCLUDE {fl} {n}.C" for n, fl, _, _ in batch],
                   stdout=subprocess.DEVNULL, env={**os.environ, "DOS_CONTINUE_ON_ERROR": "1"})
    for n, fl, c, src in batch:
        o = work / f"{n}.OBJ"; results.append((score(o) if o.exists() else 0.0, fl, c, src))
results.sort(key=lambda r: -r[0])
for sc, fl, c, _ in results[:10]: print(f"{sc:6.2f}%  [{fl}]  {c}")
if results and results[0][0] == 100.0:
    target.write_text(results[0][3]); print(f"MATCH written to {target} (flags {results[0][1]})")
