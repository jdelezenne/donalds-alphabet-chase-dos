# Executable analysis

Both files are plain, **unpacked** MZ executables (no LZEXE/PKLITE/EXEPACK signature, image size == file size, no overlay, no DOS extender).

| | DONALD.EXE (retail) | DONALD (alt) |
|---|---|---|
| size | 55,512 | 55,432 |
| header | 3,072 bytes (0xC0 paras) | 3,072 |
| relocations | 702 | 698 |
| CS:IP | 0000:0000 | 0000:0000 |
| SS:SP | 0D07:00E6 | 0D02:00E6 |
| min/max alloc | 0x49 / 0xFFFF | 0x49 / 0xFFFF |
| DGROUP (`mov dx,imm` at entry) | 0947 | 0942 |
| banner | `Turbo-C - Copyright (c) 1988 Borland Intl.` at image 0x9474 | at 0x9424 |

The two builds differ by 80 bytes / 4 relocations: a slightly different code build, same toolchain.

## Compiler
**Borland Turbo C 2.0** — confirmed against 2.01 by library matching (see MATCHING.md).
Entry code is the Turbo C `C0.ASM` startup (`mov dx,DGROUP; mov cs:[DGROUP@],dx; mov ah,30h; int 21h; mov bp,[2]; mov bx,[2Ch]` ...).
Runtime strings: `Divide error`, `Abnormal program termination`.

## Memory model: large (confirmed by C0L.OBJ/CL.LIB match, see MATCHING.md)
- **Far code**: ~47 distinct code segments in the relocation table (one per module, Borland style), 462 `9A` far-call bytes vs 204 `E8`, 249 `RETF` (`CB`).
- **Far data**: no `Null pointer assignment` message (Turbo C only emits that check in tiny/small/medium), 440 `LES` bytes.
- 58 `push ds; mov ax,seg; mov ds,ax` sequences: could be huge-model prologues or library code; **large vs huge is open** (match `C0L.OBJ` vs `C0H.OBJ` startup with `libmatch`).

## Data files
`*.CMP` (30 files): compressed pictures/animations (title, credits, per-letter-group `*DON`/`*PET`/`*SCR`, `WIN1-4`, `LIGHTBLB`). Format not yet analysed.
Video: CGA, EGA and Tandy are detected (`A CGA / An EGA / A TANDY graphic card has been detected`).
