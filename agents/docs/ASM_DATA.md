# Assembly functions and data

The original hand-written drivers stay assembly. Descriptive names are recovered
from accesses and control flow, not claimed to be the original authors' spelling.
The source now declares bounded objects and their actual uses, rather than giving
a large mixed byte run the name of its first scalar.

## Inventories and checks

- `agents/config/retail/asm_functions.csv`: 81 callable entries, their source, body
  bounds, calling role and evidence. Interrupt handlers and near helpers are
  included. A bounding body can contain a shared helper; those overlaps are
  explicit and are counted once in `tools/matchreport.py`.
- `agents/config/retail/asm_data.csv`: 171 owned storage objects or explicitly split
  object contributions, totaling 6,914 initialized bytes. Each row gives a real
  source label, address space, size, type and access evidence. Pointer members
  can be separate leaf objects; aliases do not allocate or count storage twice.
- `functions.csv` and `symbols.csv` carry the same assembly routine boundaries.
  `tools/funcs.py` preserves the reviewed catalog rather than replacing it with
  a far-call/prologue heuristic that misses interrupts and absorbs data.
- Source-only checks verify catalog/marker/definition consistency. The assembly
  inventory check uses real NASM output to verify symbol addresses, initializer
  intervals and coverage. It does not prove the semantic interpretation by
  itself; the access evidence and independent review address that question.

Address spaces `0000`, `0512` and `056A` mean the retail CODE frames. `GFX_DATA`
uses offsets relative to graphics frame `0B7F`; `KBD_DATA` uses its own frame,
`0CCD`. In the alternate executable the graphics frame is `0B7A`, keyboard
far-data frame `0CC8`, and sound/keyboard CODE paragraph biases increase by
8 bytes. Label-difference expressions preserve those literal CS displacements
without introducing offset relocations absent from the original objects.

## Graphics

`gfx_data.inc` defines all graphics-frame members and the shared 19-byte
`SPRITE_WORK` layout. Each physical initializer has a size/offset assertion.
The three physical GFX_DATA contributions remain 24, 5,264 and 42 bytes.

The former long `_gfx_clip_y2` and `_clip_y2` runs contain these separate objects:

- Clip coordinates, source/destination segments, widths, row counts, bank
  phases and clipping scratch are individually typed bytes/words. The random
  seed is four bytes, matching the C `long`, not the following nine bytes too.
- Two 256-byte CGA paired-pixel conversion maps and two 16-byte phase palettes.
  `set_palette16` computes the maps; the converters alternate them by scanline.
- Two 256-byte pixel-reversal tables: high/low nibble exchange and reversal of
  four two-bit CGA pixels. The DS nibble table is an unreferenced duplicate of
  the used CS table; its contents and boundaries are nevertheless identified.
- A 4,096-byte font workspace: 128 eight-row monochrome glyphs occupy its first
  1,024 bytes; `gfx_init` expands backward to 2,048 CGA bytes or 4,096 Tandy bytes.
  The remaining 3,072 initial zero bytes are actual expansion space.
- Foreground/background pixels, text row groups, retrace and vertical-line
  scratch, and an eight-entry six-bit DAC intensity ramp. The ramp starts at
  GFX:14B5; the OMF link order splits its first byte from the final seven bytes.
  The two source contributions are named as parts of the same array.

CODE-resident storage is also explicit: EGA clipping scratch, two 256-byte
transparent-pixel preservation-mask tables, packed clipping state, the used
256-byte Tandy nibble exchange table, source segment scratch and the two
three-word VGA RLE clipping workspaces. These bytes are data, not instructions.
Only actual unreferenced slots are called reserved; no algorithmic table or
font buffer is hidden under that designation.

### Cross-segment sprite state

The final mirrored-VGA `SPRITE_WORK` instance extends beyond GFX_DATA's last
allocated byte at 14DF. Its last byte/word are physically the first three bytes
of KBD_DATA:

- GFX:14E0 = KBD_DATA:0000: `m3_mirror_subpixel_shift`, written zero and not read
  in mode 3
- GFX:14E1 = KBD_DATA:0001: `m3_mirror_clip_columns`, an unaligned word storing
  the horizontal clip span before conversion to pixel width

The exact Turbo C 2.0 link maps verify the frame arithmetic for both variants.
No bytes are appended to GFX_DATA. Keyboard byte 0003 is an unreferenced
alignment byte before its word fields; its alignment purpose is inferred.

### Function boundaries and names

The two copy-rectangle near entries share code; the EGA latch entry's local
span branches to the dispatcher's common return. A mirrored-Tandy edge helper
is physically embedded in its caller's bounding body. These are explicit
shared-code cases, not extra disjoint code coverage. Other helpers, including
`take_nibble`, `merge_mirrored_cga_edge` and `expand_bits4`, have their own ranges.
Embedded tables and trailing scratch are excluded from routine bounds.

Access analysis also corrected misleading earlier names: the old C `cga` and
`tandy` glyph names were reversed, `clear_buffer` converts pixels and masks,
and `sprite_mask_*` mirrors sprites. C callers now use the semantic assembly
names through documented compatibility aliases in `donald.h`; the assembly
linker names remain stable. The C wrapper is named `draw_sprite_mirrored`.

## Sound

All 237 leading data bytes are 24 bounded objects: saved INT 08h/23h/09h far
vectors, current and pending tune far pointers, stream position, byte flags,
loop and duration counters, option/tick words and 96 PIT channel-2 divisors.
The parser's accepted note range is 0..95 and the lookup is word-indexed. The
only unexplained storage is a two-byte zero reservation at CS:0020 with no
read, write, public symbol or constructed pointer in this driver. Its original
purpose is unknown, and the source does not invent one.

All 18 callable bodies are catalogued separately, including the timer ISR,
music-tick interpreter, three speaker/PIT helpers and Ctrl-C/keyboard ISRs.
The option setter and interrupt installers no longer absorb those bodies in
the function-size metadata.

## Keyboard

The keyboard module has 531 CODE-resident data bytes, eight far-data bytes,
and 888 instruction bytes in eight callable routines. Named objects include:

- 13 policy key words with 13 corresponding masks
- Three 16-byte E0 scan/translation arrays
- A 64-word ring queue, with one empty slot and thus 63 usable entries; each
  word packs a key number in AL and Shift/Ctrl/Alt bits in AH
- An 89-byte normal scan map, three 128-bit bitmaps, two 62-byte ASCII tables
- A null Escape callback, saved vectors, queue indices, prefix/lock/policy
  state and three bytes of ISR scratch

Original quirks are preserved rather than silently repaired: the policy/E0
searches make one rejected probe into the adjacent array; normal scan indexing
is not bounded above 58h; lock tests use inherited CH on normal scans; and E0
compatibility compares an absolute cursor against 21h. Initial IRQ policy
0110h is replaced by far-data policy 0010h on the first IRQ. The Ctrl-S toggle
has no game consumer. These observations limit behavioral claims; they do not
leave mixed data runs unresolved.

## Evidence limits

All seven recovered objects retain their exact pre-change segment bytes and full OMF
fixup records; both target builds are checked against the pre-existing complete
executable SHA-256 values. This proves source-built binary identity, not recovery
of original source spelling or an interactive playthrough. Separate `.CMP`
assets remain necessary for gameplay and were unavailable for a playtest.
