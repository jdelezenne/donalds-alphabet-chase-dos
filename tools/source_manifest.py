#!/usr/bin/env python3
"""Validate source provenance and list C units with their stable Turbo C filenames.

modules.csv follows link.txt's non-runtime object order. Semantic source/object
names are deliberately independent of the DOS compiler filenames: Turbo C uses
the latter for CODE segment names, including HARDERR_TEXT's runtime sharing.
This checks real source/configuration consistency; it does not compare game bytes.
"""
import argparse
import csv
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
FIELDS = ["source", "kind", "segment", "compiler_stem", "previous_source", "purpose"]


def read_headers():
    """Validate the flattened DOS header namespace and every actual C include."""
    headers = sorted((ROOT / "src").rglob("*.h"))
    by_name = {}
    for path in headers:
        name = path.name.upper()
        if not re.fullmatch(r"[A-Z0-9_]{1,8}\.H", name) or name in by_name:
            raise ValueError(f"Invalid or duplicate DOS header basename: {path}")
        if path.is_symlink():
            raise ValueError(f"Source header must not be a symlink: {path}")
        by_name[name] = path
    declared_system = {line.split()[1] for line in
                       (ROOT / "config/tc20.sha256").read_text().splitlines()}
    referenced = set()
    for source in sorted((ROOT / "src").rglob("*.c")) + headers:
        for delimiter, name in re.findall(r'^\s*#\s*include\s*([<"])([^>"\n]+)[>"]',
                                          source.read_text(), re.M):
            if delimiter == '"':
                if "/" in name or "\\" in name or name.upper() not in by_name:
                    raise ValueError(f"Missing/non-basename source include: {source}: {name}")
                referenced.add(name.upper())
            elif "INCLUDE/" + name.upper() not in declared_system:
                raise ValueError(f"Undeclared toolchain header: {source}: {name}")
    if referenced != set(by_name):
        raise ValueError(f"Unreferenced source headers: {sorted(set(by_name) - referenced)}")
    return headers


def read_modules():
    with (ROOT / "config/retail/modules.csv").open(newline="") as handle:
        reader = csv.DictReader(handle)
        if reader.fieldnames != FIELDS:
            raise ValueError("modules.csv has unexpected columns")
        rows = list(reader)
    read_headers()
    errors = []
    sources, objects, compiler_stems = set(), set(), set()
    for row in rows:
        if None in row or any(not row.get(key) for key in FIELDS if key != "compiler_stem"):
            errors.append("modules.csv contains a blank or malformed field")
            continue
        source = row["source"]
        path = ROOT / source
        kind = row["kind"]
        if kind not in {"c", "asm"}:
            errors.append(f"{source}: unknown source kind {kind}")
            continue
        if not source.startswith("src/") or ".." in Path(source).parts or path.suffix != "." + kind:
            errors.append(f"{source}: invalid source path")
            continue
        obj = (kind, path.stem.lower())
        if source in sources or obj in objects:
            errors.append(f"{source}: duplicate source or object stem")
        sources.add(source)
        objects.add(obj)
        if kind == "c":
            stem = row["compiler_stem"] or ""
            if not re.fullmatch(r"[A-Z0-9_]{1,8}", stem) or stem in compiler_stems:
                errors.append(f"{source}: invalid or duplicate DOS compiler stem {stem}")
            compiler_stems.add(stem)
        elif row["compiler_stem"]:
            errors.append(f"{source}: NASM does not use a Turbo C compiler stem")
        if path.is_symlink():
            errors.append(f"source must not be a symlink: {source}")
        if not path.is_file():
            errors.append(f"missing source {source}")
            continue
        text = path.read_text()
        annotation = r"(?:FUNCTION|SEGMENT):\s*DONALD\s+([0-9A-Fa-f]{4})"
        segments = {s.upper() for s in re.findall(annotation, text)}
        addresses = re.findall(r"FUNCTION:\s*DONALD\s+([0-9A-Fa-f]{4}):([0-9A-Fa-f]{4})", text)
        if kind == "c" and addresses != sorted(addresses, key=lambda pair: tuple(int(x, 16) for x in pair)):
            errors.append(f"{source}: C function annotations are not in original address order")
        expected = set() if row["segment"] == "DGROUP" else {row["segment"]}
        if segments != expected:
            errors.append(f"{source}: segment annotations {sorted(segments)} disagree with {row['segment']}")
    if errors:
        raise ValueError("source manifest check failed:\n" + "\n".join(errors))
    actual = {str(p.relative_to(ROOT)) for p in (ROOT / "src").rglob("*") if p.suffix in {".c", ".asm"}}
    if actual != sources:
        errors.append(f"source manifest differs from src/: missing {sorted(actual - sources)}, stale {sorted(sources - actual)}")
    link = []
    for line in (ROOT / "config/retail/link.txt").read_text().splitlines():
        if line.strip() and not line.lstrip().startswith("#"):
            _, spec = line.split()
            kind, stem = spec.split(":", 1)
            if kind != "lib":
                link.append(({"obj": "c", "asm": "asm"}.get(kind, kind), stem))
    declared = [(row["kind"], Path(row["source"]).stem) for row in rows]
    if link != declared:
        errors.append("modules.csv must follow the exact non-runtime object order in link.txt")
    # Every per-file override must still select a real source after a rename.
    c_sources = [Path(row["source"]).relative_to("src") for row in rows if row["kind"] == "c"]
    for line in (ROOT / "config/retail/cflags.txt").read_text().splitlines()[1:]:
        if line.strip() and not line.lstrip().startswith("#"):
            pattern, separator, flags = line.partition(":")
            if not separator or not flags.strip() or not any(p.match(pattern) for p in c_sources):
                errors.append(f"unmatched or malformed compiler override: {line}")
    if errors:
        raise ValueError("source manifest check failed:\n" + "\n".join(errors))
    return rows


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--headers", action="store_true", help="print validated source header paths")
    parser.add_argument("--compile-list", action="store_true", help="print source path and stable DOS stem, tab-separated")
    parser.add_argument("paths", nargs="*", help="optional C source subset")
    args = parser.parse_args()
    try:
        rows = read_modules()
        c_rows = [row for row in rows if row["kind"] == "c"]
        if args.paths:
            by_path = {(ROOT / row["source"]).resolve(): row for row in c_rows}
            requested = [Path(path).resolve() for path in args.paths]
            if len(requested) != len(set(requested)):
                raise ValueError("Duplicate C source in requested subset")
            unknown = [str(path) for path in requested if path not in by_path]
            if unknown:
                raise ValueError("Unknown C source subset: " + ", ".join(unknown))
            c_rows = [by_path[path] for path in requested]
        if args.headers:
            for path in read_headers():
                print(path)
        elif args.compile_list:
            for row in c_rows:
                print(f"{ROOT / row['source']}\t{row['compiler_stem']}")
        else:
            print(f"Source provenance OK: {len(c_rows)} C units, {len(rows) - sum(r['kind'] == 'c' for r in rows)} assembly modules; exact link order and compiler overrides accounted for.")
    except (OSError, ValueError, KeyError) as exc:
        sys.exit(str(exc))


if __name__ == "__main__":
    main()
