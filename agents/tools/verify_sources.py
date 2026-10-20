#!/usr/bin/env python3
"""Validate source annotations, link manifests and assembly catalogs without game files."""
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
if True:
    data_units = sum(not want for want in selected.values())
    print(f"{'Full' if full else 'Subset'} source coverage OK: {len(seen_addr)} annotated C functions, "
          f"{len(srcs)} C units ({data_units} data-only), {len(asm_sources)} linked assembly modules, "
          f"{len(inventory.functions)} ASM function entries and {len(inventory.data)} named ASM data objects. "
          "No build or byte comparison performed.")
    sys.exit(0)
