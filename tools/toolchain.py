#!/usr/bin/env python3
"""Check or stage only declared Turbo C inputs, never ambient TCC.CFG files.

Default staging permits exploratory compiler versions; --exact checks the
recorded TC 2.0 fingerprints, including every header used by this recovery.
The manifest contains hashes only, not licensed compiler or header contents.
"""
import argparse
import hashlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def inventory():
    files = {}
    for line in (ROOT / "config/tc20.sha256").read_text().splitlines():
        digest, name = line.split()
        if name in files or Path(name).is_absolute() or ".." in Path(name).parts:
            raise ValueError(f"Invalid/duplicate toolchain input: {name}")
        files[name] = digest
    return files


def prepare(root, destination=None, exact=False):
    result = {}
    for name, expected in inventory().items():
        path = Path(root) / name
        if not path.is_file():
            raise ValueError(f"Missing Turbo C input: {path} (set TC_ROOT)")
        data = path.read_bytes()
        actual = hashlib.sha256(data).hexdigest()
        if exact and actual != expected:
            raise ValueError(f"Exact Turbo C 2.0 fingerprint mismatch: {name}")
        result[name] = actual
        if destination is not None:
            target = Path(destination) / name
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(data)
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("root", type=Path)
    parser.add_argument("--stage", type=Path)
    parser.add_argument("--exact", action="store_true")
    args = parser.parse_args()
    if args.stage is not None and args.stage.exists():
        parser.error("Staging destination must be a new directory")
    try:
        result = prepare(args.root, args.stage, args.exact)
    except (OSError, ValueError) as exc:
        parser.exit(1, str(exc) + "\n")
    print(f"{'Exact TC 2.0 inputs verified' if args.exact else 'Toolchain inputs staged/checked'}: {len(result)} files")


if __name__ == "__main__":
    main()
