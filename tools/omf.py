#!/usr/bin/env python3
"""Minimal OMF (Intel/Borland .OBJ) reader: segments, publics, LEDATA bytes and fixup positions.
Usage: omf.py FILE.OBJ  -> prints segments and publics."""
import struct, sys

def _idx(b, p):
    v = b[p]
    return (((v & 0x7F) << 8) | b[p + 1], p + 2) if v & 0x80 else (v, p + 1)

def read(path):
    return parse(open(path, "rb").read())[:4]

def parse(b, p=0):
    """Parse one module starting at b[p]; returns (segs, pubs, data, fix, end_pos, module_name)."""
    modname = ""
    names, segs, pubs = [""], [None], []
    data = {}           # seg index -> bytearray
    fix = {}            # seg index -> set(offsets that are fixup bytes)
    last = None         # (seg, offset) of last LEDATA
    while p < len(b):
        t, n = b[p], struct.unpack_from("<H", b, p + 1)[0]; r = b[p + 3:p + 3 + n - 1]; p += 3 + n
        if t == 0x80: modname = r[1:1 + r[0]].decode("latin1")
        elif t in (0x8A, 0x8B): break
        elif t == 0x96:  # LNAMES
            q = 0
            while q < len(r): l = r[q]; names.append(r[q + 1:q + 1 + l].decode("latin1")); q += 1 + l
        elif t in (0x98, 0x99):
            a = r[0]; q = 1 + (3 if a >> 5 == 0 else 0)
            ln = struct.unpack_from("<H" if t == 0x98 else "<I", r, q)[0]; q += 2 if t == 0x98 else 4
            ni, q = _idx(r, q); ci, q = _idx(r, q)
            segs.append({"name": names[ni], "class": names[ci], "len": ln}); data[len(segs) - 1] = bytearray(ln)
        elif t in (0x90, 0x91):
            q = 0; _, q = _idx(r, q); si, q = _idx(r, q)
            if si == 0: q += 2
            while q < len(r):
                l = r[q]; nm = r[q + 1:q + 1 + l].decode("latin1"); q += 1 + l
                off = struct.unpack_from("<H" if t == 0x90 else "<I", r, q)[0]; q += 2 if t == 0x90 else 4
                _, q = _idx(r, q); pubs.append((nm, si, off))
        elif t in (0xA0, 0xA1):
            si, q = _idx(r, 0); off = struct.unpack_from("<H" if t == 0xA0 else "<I", r, q)[0]; q += 2 if t == 0xA0 else 4
            chunk = r[q:]; data[si][off:off + len(chunk)] = chunk; last = (si, off)
        elif t in (0x9C, 0x9D) and last:
            q = 0
            while q < len(r):
                if r[q] & 0x80:
                    loc = ((r[q] & 3) << 8) | r[q + 1]; typ = (r[q] >> 2) & 0xF; q += 2
                    fd = r[q]; q += 1
                    if not fd & 0x80 and (fd >> 4) & 7 < 3: _, q = _idx(r, q)
                    if not fd & 0x08 and (fd & 3) < 3: _, q = _idx(r, q)
                    if not fd & 0x04: q += 2 if t == 0x9C else 4
                    width = {0: 1, 1: 2, 2: 2, 3: 4, 4: 1, 5: 2, 9: 2, 11: 4, 13: 4}.get(typ, 2)
                    s = fix.setdefault(last[0], set())
                    s.update(range(last[1] + loc, last[1] + loc + width))
                else:  # THREAD subrecord
                    d = r[q]; q += 1
                    if not d & 0x40 or (d >> 2) & 7 < 3: _, q = _idx(r, q)
    return segs, pubs, data, fix, p, modname

def library(path):
    """Yield (segs, pubs, data, fix, name) for each module of an OMF .LIB."""
    b = open(path, "rb").read()
    page = 16
    if b[0] == 0xF0: page = struct.unpack_from("<H", b, 1)[0] + 3
    p = page if b[0] == 0xF0 else 0
    while p < len(b) and b[p] == 0x80:
        segs, pubs, data, fix, end, name = parse(b, p)
        yield segs, pubs, data, fix, name
        p = (end + page - 1) // page * page

if __name__ == "__main__":
    segs, pubs, data, fix = read(sys.argv[1])
    for i, s in enumerate(segs[1:], 1): print(f"seg {i} {s['name']:<16} {s['class']:<8} {s['len']:#06x} fixups {len(fix.get(i, ()))}")
    for nm, si, off in pubs: print(f"pub {nm:<24} seg {si} +{off:#06x}")
