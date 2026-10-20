#!/usr/bin/env python3
"""Check complete linked executables against recorded original hashes, without game files."""
import argparse
import hashlib
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
OUTPUTS = {"retail": "build/link/DONALD.EXE", "alt": "build/link-alt/DONALD"}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("target", choices=["retail", "alt", "all"], nargs="?", default="all")
    args = parser.parse_args()
    expected = {}
    for line in (ROOT / "src/donald/outputs.sha256").read_text().splitlines():
        digest, size, filename = line.split()
        expected[filename] = (int(size), digest)
    targets = OUTPUTS if args.target == "all" else [args.target]
    passed = True
    for target in targets:
        path = ROOT / OUTPUTS[target]
        if not path.is_file():
            print(f"MISSING {OUTPUTS[target]}", file=sys.stderr)
            passed = False
            continue
        data = path.read_bytes()
        actual = (len(data), hashlib.sha256(data).hexdigest())
        match = actual == expected[path.name]
        print(f"{'MATCH' if match else 'MISMATCH'} {OUTPUTS[target]}: {actual[0]} bytes, sha256 {actual[1]}")
        if not match:
            print(f"  expected {expected[path.name][0]} bytes, sha256 {expected[path.name][1]}")
        passed &= match
    return 0 if passed else 1


if __name__ == "__main__":
    sys.exit(main())
