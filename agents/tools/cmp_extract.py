#!/usr/bin/env python3
"""Decode Donald's Alphabet Chase .CMP pictures (format in docs/CMP.md) to PNG.
Usage: cmp_extract.py FILE.CMP... [-o OUTDIR]     (default OUTDIR: build/cmp)
Writes OUTDIR/NAME.png (320x200, default EGA palette) and prints how much of each file the decoder consumed.
Files that are not a single full-screen picture (sprite sheets) are reported and their payload is dumped raw."""
import struct, sys, zlib
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "tools"))

W, H, SIZE = 320, 200, 0x7D00          # 160 bytes per row (two 4-bit pixels per byte) x 200 rows
EGA = [(0,0,0),(0,0,170),(0,170,0),(0,170,170),(170,0,0),(170,0,170),(170,85,0),(170,170,170),
       (85,85,85),(85,85,255),(85,255,85),(85,255,255),(255,85,85),(255,85,255),(255,255,85),(255,255,255)]

def unrle(b, pos, n=SIZE):
    """The RLE of cmp_unpack_planar / cmp_unpack_cga (seg0000 0F2C / 0F83). Returns (bytes, end position)."""
    out = bytearray()
    while len(out) < n:
        c = b[pos]
        if c == 0:                      # 00 lo hi value: long repeat
            cnt = b[pos + 1] | b[pos + 2] << 8; pos += 3; out += bytes([b[pos]]) * cnt; pos += 1
        elif c >= 0x80:                 # -n value: repeat
            out += bytes([b[pos + 1]]) * (256 - c); pos += 2
        else:                           # n bytes: literal
            out += b[pos + 1:pos + 1 + c]; pos += 1 + c
    return bytes(out[:n]), pos

def decode(b):
    """u16 payload length, then layout byte (1 = row-major, else column-major: 200 bytes per column of 160), RLE."""
    assert (b[0] | b[1] << 8) == len(b) - 2, "length word"
    data, end = unrle(b, 3)
    if b[2] != 1:
        rows = bytearray(SIZE)
        for i, v in enumerate(data): rows[(i % 200) * 160 + i // 200] = v
        data = bytes(rows)
    return data, end

def png(path, pix):
    raw = b"".join(b"\0" + bytes(c for p in pix[y * W:(y + 1) * W] for c in EGA[p]) for y in range(H))
    def chunk(t, d): return struct.pack(">I", len(d)) + t + d + struct.pack(">I", zlib.crc32(t + d) & 0xFFFFFFFF)
    path.write_bytes(b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", W, H, 8, 2, 0, 0, 0))
                     + chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b""))

def main(argv):
    out = Path("build/cmp")
    if "-o" in argv: i = argv.index("-o"); out = Path(argv[i + 1]); del argv[i:i + 2]
    out.mkdir(parents=True, exist_ok=True); rc = 0
    for f in map(Path, argv):
        b = f.read_bytes()
        try:
            data, end = decode(b)
        except (IndexError, AssertionError):
            print(f"{f.name}: not a full-screen picture ({len(b)} bytes); raw copy written"); (out / (f.stem + ".bin")).write_bytes(b); continue
        pix = [v >> 4 if x % 2 == 0 else v & 15 for v in data for x in (0, 1)]
        png(out / (f.stem + ".png"), pix)
        print(f"{f.name}: layout {b[2]}, {end}/{len(b)} bytes used -> {out / (f.stem + '.png')}")
        if end != len(b): rc = 1
    return rc

if __name__ == "__main__": sys.exit(main(sys.argv[1:]))
