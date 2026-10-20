#!/usr/bin/env python3
"""Compiler-free source/catalog checks and real NASM assembly for both builds.

Requires Python 3, Bash and NASM; no Turbo C, DOSBox or original game files.
This checks consistency and assembled bounds, not executable/gameplay identity.
"""
import ast
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
FORBIDDEN = {".exe", ".cmp", ".com", ".obj", ".lib", ".img", ".ima", ".bin", ".zip", ".7z"}


def check_paths(paths):
    for path in paths:
        if path.suffix.lower() in FORBIDDEN or path.as_posix().lower() == "game/donald":
            raise ValueError(f"Forbidden game/compiler/binary source input: {path}")


def main():
    python_files = sorted((ROOT / "tools").glob("*.py"))
    for path in python_files:
        ast.parse(path.read_text(), filename=str(path.relative_to(ROOT)))
    for path in sorted((ROOT / "tools").glob("*.sh")):
        subprocess.run(["bash", "-n", str(path)], check=True)
    for directory in ("tools/config",):
        for path in (ROOT / directory).rglob("*.json"):
            json.loads(path.read_text())
    # A checkout scans tracked files, so legitimate ignored local game files
    # do not make public source checks fail. Source-only exports scan their files.
    if (ROOT / ".git").exists():
        names = subprocess.check_output(["git", "ls-files", "-z"], cwd=ROOT).decode().split("\0")
        check_paths(Path(name) for name in names if name)
    else:
        check_paths(path.relative_to(ROOT) for directory in ("src", "tools")
                    for path in (ROOT / directory).rglob("*") if path.is_file())
    # Check working-tree source inputs too, including newly added/untracked files.
    check_paths(path.relative_to(ROOT) for directory in ("src", "tools")
                for path in (ROOT / directory).rglob("*") if path.is_file())
    for source in (ROOT / "src").rglob("*.asm"):
        if re.search(r"^\s*incbin\b", source.read_text(), re.I | re.M):
            raise ValueError(f"Binary include is not recovered source: {source}")
    subprocess.run([sys.executable, str(ROOT / "tools/source_manifest.py")], check=True)
    # Assemble copies of the actual source; don't disturb a local exact build.
    with tempfile.TemporaryDirectory(prefix="donald-source-") as temporary:
        copy = Path(temporary)
        for directory in ("src", "tools"):
            shutil.copytree(ROOT / directory, copy / directory,
                            ignore=shutil.ignore_patterns("__pycache__", "*.pyc"))
        for target in ("retail", "alt"):
            env = dict(os.environ, DAC_TARGET=target)
            subprocess.run([str(copy / "tools/assemble.sh")], cwd=copy, env=env, check=True)
    print(f"Passed: {len(python_files)} Python sources, shell syntax, source/header/link manifests, both NASM variants.")
    print("Scope: compiler-free consistency checks. Use make check-exact for complete executable identity.")


if __name__ == "__main__":
    main()
