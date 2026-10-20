#!/usr/bin/env python3
"""reccmp-style verifier for Turbo C 2.0 / DOS.
Every function in src/donald/**.c carries `/* FUNCTION: DONALD SSSS:OOOO */` on the line(s) before its definition.
verify.py builds everything (tools/build.sh), compares each annotated function against game/DONALD.EXE with
fixup bytes masked, updates agents/config/retail/symbols.csv (matched/nonmatching + %), and prints byte progress.
Usage: verify.py [--sources-only] [-n|--no-build] [-v] [paths...]
No paths checks the complete C source manifest. Explicit paths check only those units; a subset run never
refreshes the full-build coverage summary. Both modes check every linked assembly module.
--sources-only: check source annotations and link-manifest coverage, then exit without a compiler or original.
This mode does not compile, assemble, compare bytes, or update recorded match results.
This is a fixup-masked comparison, not a replacement for a whole-executable relink comparison."""
import csv, re, subprocess, sys, struct
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "tools"))
sys.path.insert(0, str(Path(__file__).parent)); import omf, asm_inventory, source_manifest
ROOT = Path(__file__).resolve().parents[2]
if "-h" in sys.argv or "--help" in sys.argv: print(__doc__); sys.exit(0)
args = [a for a in sys.argv[1:] if not a.startswith("-")]
srcs = [Path(a).resolve() for a in args] or sorted((ROOT / "src").rglob("*.c"))
full = not args
fn = list(csv.DictReader(open(ROOT / "agents/config/retail/functions.csv")))
expected = {r["addr"]: int(r["size"]) for r in fn if r["kind"] == "c"}
ANN = re.compile(r"/\*\s*FUNCTION:\s*DONALD\s+([0-9A-Fa-f]{4}):([0-9A-Fa-f]{4})\s*\*/")
DEF = re.compile(r"^(?:[A-Za-z_][\w \*]*?[\s\*])?(\w+)\s*\([^;]*$")
selected = {}; seen_addr = {}; seen_name = {}; stems = set()
errors = []
try:
    source_manifest.read_modules()
except (OSError, ValueError) as exc:
    errors.append(str(exc))
for src in srcs:
    if not src.is_file(): errors.append(f"missing source: {src}"); continue
    if src.stem in stems: errors.append(f"duplicate object stem: {src.stem}")
    stems.add(src.stem)
    lines = src.read_text().splitlines(); want = []
    for i, l in enumerate(lines):
        m = ANN.search(l)
        if not m: continue
        address = m.group(1).upper() + ":" + m.group(2).upper()
        definition = None
        for l2 in lines[i + 1:]:
            if ANN.search(l2): break
            definition = DEF.match(l2)
            if definition: break
        if not definition:
            errors.append(f"{src}:{i + 1}: annotation has no function definition"); continue
        name = definition.group(1)
        if address not in expected: errors.append(f"{src}:{i + 1}: {address} is not a manifest C function")
        if address in seen_addr: errors.append(f"duplicate C address: {address}")
        if name in seen_name: errors.append(f"duplicate C function: {name}")
        seen_addr[address] = src; seen_name[name] = src
        want.append((name, address))
    # All current game definitions use an opening brace on the following line. Detect accidentally dropped
    # annotations too, instead of letting an extra untracked definition escape verification.
    definitions = {m.group(1) for i, line in enumerate(lines[:-1])
                   if (m := DEF.match(line)) and lines[i + 1].strip() == "{"}
    unannotated = definitions - {name for name, _ in want}
    if unannotated: errors.append(f"{src}: unannotated functions: {', '.join(sorted(unannotated))}")
    selected[src] = want
if full:
    missing = set(expected) - set(seen_addr)
    if missing: errors.append("missing C sources/annotations: " + " ".join(sorted(missing)))
asm_sources = sorted((ROOT / "src").rglob("*.asm"))
link_inputs = [line.split()[1].split(":", 1)
               for line in (ROOT / "src/donald/link.txt").read_text().splitlines()
               if line.strip() and not line.lstrip().startswith("#")]
linked_asm = {name for kind, name in link_inputs if kind == "asm"}
if full and stems != {name for kind, name in link_inputs if kind == "obj"}:
    errors.append("C sources (including data-only units) do not equal the C objects in src/donald/link.txt")
if {a.stem for a in asm_sources} != linked_asm:
    errors.append("assembly sources do not equal the assembly objects in src/donald/link.txt")
for asm_src in asm_sources:
    if not re.search(r"SEGMENT:\s*DONALD\s+[0-9A-Fa-f]{4}\s+[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}", asm_src.read_text()):
        errors.append(f"{asm_src}: missing SEGMENT annotation")
inventory = asm_inventory.Inventory(ROOT)
errors.extend(inventory.check_sources())
if not expected or not srcs or not linked_asm: errors.append("empty source or function manifest")
if errors: sys.exit("source coverage check failed:\n" + "\n".join(errors))
if "--sources-only" in sys.argv:
    data_units = sum(not want for want in selected.values())
    print(f"{'Full' if full else 'Subset'} source coverage OK: {len(seen_addr)} annotated C functions, "
          f"{len(srcs)} C units ({data_units} data-only), {len(asm_sources)} linked assembly modules, "
          f"{len(inventory.functions)} ASM function entries and {len(inventory.data)} named ASM data objects. "
          "No build or byte comparison performed.")
    sys.exit(0)
if "-n" not in sys.argv and "--no-build" not in sys.argv:
    result = subprocess.run([str(ROOT / "tools/build.sh"), *map(str, srcs)])
    if result.returncode: sys.exit("C build failed; no objects were verified")
original = ROOT / "game/DONALD.EXE"
if not original.is_file(): sys.exit("comparison requires game/DONALD.EXE; use the source-only build to compile without it")
exe = original.read_bytes()
if len(exe) < 28 or exe[:2] != b"MZ": sys.exit("invalid MZ comparison executable")
header_size = struct.unpack_from("<H", exe, 8)[0] * 16
if header_size < 28 or header_size + 3 > len(exe): sys.exit("invalid MZ comparison header size")
img = exe[header_size:]
res = {}; details = {}
for src in srcs:
    want = selected[src]
    obj = ROOT / "build/obj" / (src.stem + ".OBJ")
    if not obj.exists():
        for n, a in want: res[n] = (a, expected[a], 0.0, "nobuild", src)
        if not want: errors.append(f"missing data-only object: {obj}")
        continue
    segs, pubs, data, fix = omf.read(obj)
    code = sorted((si, off, nm.lstrip("_")) for nm, si, off in pubs if segs[si]["class"].upper().endswith("CODE"))
    for n, a in want:
        hit = [(k, c) for k, c in enumerate(code) if c[2] == n]
        if not hit: res[n] = (a, expected[a], 0.0, "missing", src); continue
        k, (si, off, _) = hit[0]
        end = next((x[1] for x in code[k + 1:] if x[0] == si), segs[si]["len"])
        mine = data[si][off:end]
        # Ignore only alignment beyond the manifest boundary, never bytes inside the expected function.
        # Comparing a shorter matching prefix used to be enough to report a complete match.
        while len(mine) > expected[a] and mine[-1] == 0x90: mine = mine[:-1]
        if len(mine) != expected[a]:
            res[n] = (a, expected[a], 0.0, "nonmatching", src)
            details[n] = f"object size {len(mine)}, expected {expected[a]}"
            continue
        lin = int(a[:4], 16) * 16 + int(a[5:], 16); orig = img[lin:lin + len(mine)]
        if len(orig) != len(mine):
            res[n] = (a, expected[a], 0.0, "nonmatching", src)
            details[n] = "comparison executable ends before function boundary"
            continue
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
p = ROOT / "agents/config/retail/symbols.csv"; rows = list(csv.DictReader(open(p)))
byaddr = {r["addr"]: r for r in rows}
for n, (a, size, pct, st, src) in res.items():
    r = byaddr.get(a) or {}
    extra = f"; {details[n]}" if n in details else ""
    r.update(name=n, addr=a, size=str(size), status=st, notes=f"{pct:.1f}% {src.relative_to(ROOT)}{extra}")
    byaddr[a] = r
rows = sorted(byaddr.values(), key=lambda r: int(r["addr"][:4], 16) * 16 + int(r["addr"][5:], 16))
w = csv.DictWriter(open(p, "w"), fieldnames=["name", "addr", "size", "status", "notes"], lineterminator="\n"); w.writeheader(); w.writerows(rows)
for n, (a, size, pct, st, src) in sorted(res.items(), key=lambda x: x[1][0]):
    if st != "matched" or "-v" in sys.argv: print(f"{a} {n:<28} {size:5} {pct:6.1f}% {st} {details.get(n, '')}".rstrip())
# assembly modules: src/donald/**/*.asm (NASM -f obj, `; SEGMENT: DONALD SSSS AAAA-BBBB` header). The module's first CODE
# segment must equal the original bytes with fixup (relocation) bytes masked; build/asm/<name>.OBJ feeds tools/relink.sh
# and build/asm/<name>.bin (fixup bytes taken from the original) feeds tools/splice.py.
asm_ok = 0; asm_bad = []
for a in asm_sources:
    m = re.search(r"SEGMENT:\s*DONALD\s+([0-9A-Fa-f]{4})\s+([0-9A-Fa-f]{4})-([0-9A-Fa-f]{4})", a.read_text())
    if not m:
        asm_bad.append(a.name); print(f"{a.name}: missing SEGMENT annotation"); continue
    out = ROOT / "build/asm" / (a.stem + ".OBJ"); out.parent.mkdir(parents=True, exist_ok=True)
    r = subprocess.run(["nasm", "-f", "obj", "-i", str(a.parent) + "/", "-i", str(ROOT / "src/donald/engine") + "/", "-o", str(out), str(a)], capture_output=True, text=True)
    sg, s0, s1 = (int(x, 16) for x in m.groups()); want = img[sg * 16 + s0: sg * 16 + s1]
    got, fx = b"", set()
    if r.returncode == 0:
        segs, _, data, fix = omf.read(out)
        si = next(i for i, s in enumerate(segs) if s and s["class"].upper() == "CODE")
        got, fx = bytes(data[si]), fix.get(si, set())
    got = bytes(want[i] if i in fx and i < len(want) else c for i, c in enumerate(got))
    (ROOT / "build/asm" / (a.stem + ".bin")).write_bytes(got)
    if got == want: asm_ok += len(want)
    else:
        asm_bad.append(a.name)
        k = next((i for i in range(min(len(got), len(want))) if got[i] != want[i]), min(len(got), len(want)))
        print(f"{a.name}: MISMATCH at {sg:04X}:{s0 + k:04X} (got {len(got)} bytes, want {len(want)}) {r.stderr.strip()}")
errors.extend(inventory.check_objects(ROOT / "build/asm"))
ctot = sum(expected[a] for a in seen_addr)
code_end = struct.unpack_from("<H", img, 1)[0] * 16       # DGROUP start = end of code
matched = {v[0] for v in res.values() if v[3] == "matched"}
mc = sum(expected[a] for a in matched)
lib = sum(int(r["size"]) for r in rows if r["status"] == "lib")
nm = len(matched)
unc = sorted(set(seen_addr) - matched)
if unc: print("unmatched C:", " ".join(unc))
for error in errors: print(error)
summary = (f"{'Full' if full else 'Subset'} fixup-masked comparison: checked {len(res)} C functions, matched {nm}; "
           f"C {mc}/{ctot} bytes; assembly modules matched {len(asm_sources) - len(asm_bad)}/{len(asm_sources)} "
           f"({asm_ok} bytes).")
if full:
    summary += (f" Recorded CRT coverage: {lib} bytes; C + assembly + recorded CRT: "
                f"{mc+lib+asm_ok}/{code_end} image bytes before DGROUP. Whole-EXE comparison is separate.")
print(summary)
if full:
    (ROOT / "build").mkdir(exist_ok=True)
    (ROOT / "build/progress.txt").write_text(f"{100*mc/ctot:.2f}\n")
    (ROOT / "build/summary.txt").write_text(summary + "\n")
sys.exit(0 if not unc and not errors and not asm_bad else 1)
