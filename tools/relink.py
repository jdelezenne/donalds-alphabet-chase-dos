#!/usr/bin/env python3
"""Relink DONALD.EXE with the Turbo C 2.0 TLINK from build objects and compare the whole EXE with the original.
Inputs: build/obj/*.OBJ (tools/build.sh), build/asm/*.OBJ (tools/verify.py),
C:\\LIB\\C0L.OBJ + C:\\LIB\\CL.LIB from $TC_ROOT, object order from config/retail/link.txt.
Output: build/link/DONALD.EXE (+ DONALD.MAP); prints the first differences. Exit 0 only if byte-identical.
Usage: relink.py [-q]"""
import hashlib, shutil, struct, subprocess, sys
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]; L = ROOT / "build/link"
if L.exists(): shutil.rmtree(L)
L.mkdir(parents=True)
objs = []
for line in (ROOT / "config/retail/link.txt").read_text().splitlines():
    if not line.strip() or line.startswith("#"): continue
    n, s = line.split()[:2]
    kind, name = s.split(":")
    if kind == "lib": objs.append("C:\\LIB\\" + name); continue
    src = ROOT / {"obj": "build/obj", "asm": "build/asm"}[kind] / (name + ".OBJ")
    if not src.exists(): sys.exit(f"missing {src} (run tools/build.sh, tools/verify.py)")
    shutil.copy(src, L / (n + ".OBJ")); objs.append(n)
rsp = "/m /s /l /c " + " +\r\n".join(objs) + "\r\nDONALD\r\nDONALD\r\nC:\\LIB\\CL\r\n"
(L / "LINK.RSP").write_bytes(rsp.encode())
out = subprocess.run([str(ROOT / "tools/dosrun.sh"), str(L), "TLINK @LINK.RSP"], capture_output=True, text=True).stdout
msgs = [l for l in out.splitlines() if l.strip() and not l.startswith("Turbo Link")]
for m in msgs: print("tlink:", m)
exe = L / "DONALD.EXE"
if not exe.exists(): sys.exit("link failed")
a, b = exe.read_bytes(), (ROOT / "game/DONALD.EXE").read_bytes()
print(f"build/link/DONALD.EXE {len(a)} bytes sha256 {hashlib.sha256(a).hexdigest()[:16]}; original {len(b)} bytes")
if a == b: print("IDENTICAL to original"); sys.exit(0)
ha, hb = struct.unpack_from("<14H", a), struct.unpack_from("<14H", b)
print("header mine", ha); print("header orig", hb)
hs = hb[4] * 16
diffs = [i for i in range(min(len(a), len(b))) if a[i] != b[i]]
print(f"{len(diffs)} differing bytes in common length")
def where(i): return f"hdr+{i:#x}" if i < hs else f"img {i - hs:#07x}"
shown, last = 0, -99
for i in diffs:
    if i > last + 16 and shown < 25: print("  diff at", where(i), a[i:i + 8].hex(" "), "| orig", b[i:i + 8].hex(" ")); shown += 1
    last = i
sys.exit(1)
