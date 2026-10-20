#!/usr/bin/env python3
"""Build both complete executables in a fresh original-free source snapshot.

No reference-game input is accepted. Expected hashes were recorded independently
in src/donald/outputs.sha256. Python audit logs supplement the input inventory;
they are not an OS-level sandbox or a trace of native emulator file reads.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

from check_build import OUTPUTS
from check_source import check_paths
from toolchain import prepare

ROOT = Path(__file__).resolve().parents[1]
DIRECTORIES = ("src", "tools")


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--tc-root", type=Path, default=os.environ.get("TC_ROOT", "/opt/tc20"))
    parser.add_argument("--output", type=Path, help="New evidence directory; defaults to build/exact-*")
    args = parser.parse_args()
    tc_root = args.tc_root.resolve()
    fingerprints = prepare(tc_root, exact=True)
    candidates = [path for directory in DIRECTORIES for path in (ROOT / directory).rglob("*")]
    if any(path.is_symlink() for path in candidates):
        parser.error("Source snapshot contains a symlink; inspect it before building")
    check_paths(path.relative_to(ROOT) for path in candidates if path.is_file())
    if args.output is None:
        (ROOT / "build").mkdir(exist_ok=True)
        out = Path(tempfile.mkdtemp(prefix="exact-", dir=ROOT / "build"))
    else:
        out = args.output.resolve()
        if any(out.is_relative_to(ROOT / directory) for directory in (*DIRECTORIES, "game", "docs", ".git")):
            parser.error("Output must not be inside a source, reference or metadata directory")
        if out.exists():
            parser.error("Output directory already exists; choose a fresh destination")
        out.mkdir(parents=True)
    copy = out / "source"
    copy.mkdir()
    print("Original-free exact-build evidence: " + str(out), flush=True)
    for directory in DIRECTORIES:
        shutil.copytree(ROOT / directory, copy / directory,
                        ignore=shutil.ignore_patterns("__pycache__", "*.pyc"))
    for name in ("Makefile", "README.md", ".gitignore", "setup.sh", "build.sh", "recomp.sh", "run.sh"):
        shutil.copy2(ROOT / name, copy / name)
    inputs = {str(path.relative_to(copy)): sha(path)
              for path in sorted(copy.rglob("*")) if path.is_file()}
    (out / "inputs.json").write_text(json.dumps(inputs, indent=2, sort_keys=True) + "\n")
    audit = out / "audit"
    audit.mkdir()
    # Every child Python process loads this through PYTHONPATH. It cannot read
    # the parent checkout (including game/) or copied game assets. This is
    # instrumentation only; native DOSBox mounts are separately constrained.
    hook = '''import os, sys
from pathlib import Path
root = Path(os.environ["DONALD_AUDIT_ROOT"])
allowed = Path(os.environ["DONALD_AUDIT_OUTPUT"])
copy = allowed / "source"
log = os.open(str(allowed / "audit" / ("opens.%d.log" % os.getpid())), os.O_WRONLY | os.O_CREAT | os.O_APPEND, 0o600)
def audit(event, args):
    if event == "open" and isinstance(args[0], (str, bytes)):
        path = Path(os.fsdecode(args[0])).resolve()
        os.write(log, (repr(args) + "\\n").encode())
        if (path.is_relative_to(root) and not path.is_relative_to(allowed)) or (path.is_relative_to(copy / "game") and path.name != "README.md"):
            raise RuntimeError("Reference/parent-checkout read prohibited: " + str(path))
sys.addaudithook(audit)
'''
    (audit / "sitecustomize.py").write_text(hook)
    env = dict(os.environ, TC_ROOT=str(tc_root), DONALD_AUDIT_ROOT=str(ROOT),
               DONALD_AUDIT_OUTPUT=str(out),
               PYTHONPATH=str(audit) + os.pathsep + os.environ.get("PYTHONPATH", ""))
    with (out / "build.log").open("w") as log:
        result = subprocess.run([str(copy / "tools/relink.sh"), "all", "--check-hashes"],
                                cwd=copy, env=env, stdout=log, stderr=subprocess.STDOUT)
    expected = {}
    for line in (copy / "src/donald/outputs.sha256").read_text().splitlines():
        digest, size, name = line.split()
        expected[name] = (int(size), digest)
    artifacts = []
    for target, filename in OUTPUTS.items():
        path = copy / filename
        size, digest = expected[path.name]
        actual = sha(path) if path.is_file() else None
        actual_size = path.stat().st_size if path.is_file() else None
        artifacts.append(dict(target=target, file=filename, bytes=actual_size,
                              sha256=actual, expected_bytes=size, expected_sha256=digest,
                              exact=(actual_size, actual) == (size, digest)))
    unchanged = all((copy / name).is_file() and sha(copy / name) == digest for name, digest in inputs.items())
    logs = sorted(audit.glob("opens.*.log"))
    events = sum(len(path.read_text().splitlines()) for path in logs)
    audit_ok = bool(logs) and all(path.stat().st_size for path in logs)
    audit_ok &= "Error in sitecustomize" not in (out / "build.log").read_text(errors="replace")
    toolchain_unchanged = prepare(tc_root, exact=True) == fingerprints
    exact = result.returncode == 0 and unchanged and audit_ok and toolchain_unchanged and all(item["exact"] for item in artifacts)
    report = dict(status="passed" if exact else "failed",
                  method="Fresh source-only copy; both targets; no original input or argument; Python audit blocks parent-checkout/reference reads.",
                  input_file_count=len(inputs),
                  input_manifest_sha256=hashlib.sha256(json.dumps(inputs, sort_keys=True).encode()).hexdigest(),
                  source_inputs_unchanged=unchanged, toolchain_inputs=fingerprints,
                  toolchain_inputs_unchanged=toolchain_unchanged,
                  build_exit_code=result.returncode, python_audit_processes=len(logs),
                  python_open_events=events, python_audit_ok=audit_ok, artifacts=artifacts,
                  limitations=["Python audit is not an OS-level native file-read trace or an isolation boundary.",
                               "No new interactive gameplay, audio or input test is implied by complete file identity."])
    (out / "verification.json").write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps(report, indent=2))
    if not exact:
        print("Build failed; inspect " + str(out / "build.log"), file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
