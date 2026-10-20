# .CMP picture format

All 27 `.CMP` files are full-screen pictures (320x200, 16 colours), including the `*DON`/`*PET` sprite
sheets that the game cuts sprites out of (`g_sprites`). `tools/cmp_extract.py game/*.CMP` decodes every file to
`build/cmp/NAME.png` and uses each file to its last byte.

| offset | size | meaning |
|---|---|---|
| 0 | u16 | payload length (= file size - 2). `load_file` (061A:0005) reads this word, then the payload |
| 2 | u8  | layout: `1` = row-major (decoded by `cmp_unpack_planar`, 0000:0F2C); anything else = column-major (`cmp_unpack_cga`, 0000:0F83): the stream fills 200 bytes of column 0, then column 1, ... |
| 3 | ... | RLE stream that expands to exactly 32000 bytes = 200 rows x 160 bytes, two 4-bit pixels per byte (high nibble left) |

RLE control byte `c`:
- `01..7F`: `c` literal bytes follow.
- `80..FF`: repeat the next byte `256 - c` times.
- `00 lo hi v`: repeat `v` `hi:lo` times.

`draw_pic` (0604:0001) decodes into the off-screen buffer. In CGA mode (`g_videoMode` 0) `cga_convert` then maps
each 4-bit pixel to 2 bits through a table, and `cga_shift_rows` moves the rows into place in the small-window layout.
The colours come from the 16-entry table `g_palettes[n]` (`set_palette16`), one per `g_cmpFiles` entry. The
extractor uses the default EGA palette instead. Files 18-21 (`WIN1`-`WIN4`) are loaded back to back into
`g_workBuf` (+0, +1B8A, +3714, +5910) for the end-of-game animation.
