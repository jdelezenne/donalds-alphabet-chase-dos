#!/usr/bin/env python3
"""Link source-built OMF objects with Turbo C 2.0; optionally compare an original.

Usage: relink.py [--alt] [--verify]
Run tools/relink.sh to compile and assemble first. Without --verify, no game files
are read. The startup object and C library come from the installed toolchain.
"""
import argparse
import hashlib
from pathlib import Path
import shutil
import struct
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--alt", action="store_true", help="link the alternate DONALD build")
    parser.add_argument("--verify", action="store_true", help="compare with the original in game/")
    args = parser.parse_args()
    link_dir = ROOT / ("build/link-alt" if args.alt else "build/link")
    object_root = ROOT / ("build/alt" if args.alt else "build")
    target = "DONALD" if args.alt else "DONALD.EXE"
    original = ROOT / "game" / target
    if args.verify and not original.is_file():
        parser.error(f"--verify requires {original}; omit --verify to link without it")

    # Check every input before discarding a previous successful link.
    inputs = []
    for line in (ROOT / "src/donald/link.txt").read_text().splitlines():
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        name, source = line.split()
        kind, stem = source.split(":")
        if kind == "lib":
            inputs.append((name, "C:\\LIB\\" + stem))
            continue
        path = object_root / {"obj": "obj", "asm": "asm"}[kind] / (stem + ".OBJ")
        if not path.is_file():
            sys.exit(f"Missing {path}; run tools/relink.sh {'alt' if args.alt else 'retail'}")
        inputs.append((name, path))
    if link_dir.exists():
        shutil.rmtree(link_dir)
    link_dir.mkdir(parents=True)
    objects = []
    for name, source in inputs:
        if isinstance(source, Path):
            shutil.copyfile(source, link_dir / (name + ".OBJ"))
            objects.append(name)
        else:
            objects.append(source)
    response = "/m /s /l /c " + " +\r\n".join(objects) + "\r\nDONALD\r\nDONALD\r\nC:\\LIB\\CL\r\n"
    (link_dir / "LINK.RSP").write_bytes(response.encode("ascii"))
    subprocess.run([str(ROOT / "tools/dosrun.sh"), str(link_dir), "TLINK @LINK.RSP"], check=True)
    executable = link_dir / "DONALD.EXE"
    if not executable.is_file():
        sys.exit("TLINK did not produce DONALD.EXE")
    built = executable.read_bytes()
    if len(built) < 28 or built[:2] != b"MZ":
        sys.exit("TLINK output is not a DOS MZ executable")
    if args.alt:
        executable.rename(link_dir / target)
    print(f"{link_dir.relative_to(ROOT)}/{target}: {len(built)} bytes, sha256 {hashlib.sha256(built).hexdigest()}")
    if not args.verify:
        return 0

    reference = original.read_bytes()
    if built == reference:
        print(f"IDENTICAL to game/{target}")
        return 0
    print(f"MISMATCH against game/{target}: built {len(built)}, original {len(reference)} bytes")
    if len(reference) >= 28:
        print("header mine", struct.unpack_from("<14H", built))
        print("header orig", struct.unpack_from("<14H", reference))
    differences = [i for i in range(min(len(built), len(reference))) if built[i] != reference[i]]
    print(f"{len(differences)} differing bytes in common length")
    shown, last = 0, -99
    for offset in differences:
        if offset > last + 16 and shown < 25:
            print(f"  file+{offset:#x}: {built[offset:offset + 8].hex(' ')} | orig {reference[offset:offset + 8].hex(' ')}")
            shown += 1
        last = offset
    return 1


if __name__ == "__main__":
    sys.exit(main())
