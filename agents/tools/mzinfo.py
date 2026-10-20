#!/usr/bin/env python3
"""Print MZ header, packer signatures, compiler banner and relocation segment histogram."""
import struct, sys, collections, hashlib
d = open(sys.argv[1], "rb").read()
f = struct.unpack_from("<14H", d)
assert f[0] in (0x5A4D, 0x4D5A), "not MZ"
size = (f[2] - 1) * 512 + (f[1] or 512); hdr = f[4] * 16
print(f"sha256   {hashlib.sha256(d).hexdigest()}")
print(f"file     {len(d)}  image(end) {size}  header {hdr}  overlay {len(d)-size}")
print(f"relocs   {f[3]} at {f[12]:#x}  min/max {f[5]:#x}/{f[6]:#x}")
print(f"CS:IP    {f[11]:04X}:{f[10]:04X}  SS:SP {f[7]:04X}:{f[8]:04X}")
for sig in (b"LZ91", b"LZ09", b"PKLITE", b"RNC", b"EXEPACK", b"Packed file is corrupt"):
    if sig in d: print("packer?  ", sig.decode())
img = d[hdr:size]
for b in (b"Turbo-C", b"Turbo C++", b"Borland C++", b"MS Run-Time", b"Microsoft", b"WATCOM"):
    i = img.find(b)
    if i >= 0: print(f"banner   {img[i:img.index(b'\0', i)].decode(errors='replace')!r} at image {i:#x}")
print("null-ptr check msg:", b"Null pointer assignment" in img, "(absent => far-data model)")
rel = struct.unpack_from(f"<{2*f[3]}H", d, f[12])
c = collections.Counter(rel[1::2])
print(f"reloc target segments ({len(c)}):", " ".join(f"{s:04X}x{n}" for s, n in sorted(c.items())))
