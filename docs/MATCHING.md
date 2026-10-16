# Matching workflow

## Loop
1. Pick a function from `config/retail/functions.csv` (start with small leaf functions in the game segments, not segment 0000 = startup/CRT).
2. Write `src/<name>.c`, add `name,SSSS:OOOO,size,todo,` to `config/retail/symbols.csv`.
3. `tools/build.sh src/<name>.c` then `tools/.venv/bin/python tools/cmpobj.py build/obj/<NAME>.OBJ`.
4. Iterate until `MATCH`; set `status=matched`, run `tools/matchreport.py`, commit.

`cmpobj.py` masks every byte covered by an OMF fixup (far call targets, segment bases, DGROUP offsets), so a
function can match before the whole program links in original order. The final milestone (as in maniac-mansion-dos)
is a full-layout TLINK rebuild compared with `cmp`.

## Toolchain (settled)
**Turbo C 2.0, large model, `TCC -c -ml -O -Z`.** Install with `tools/install_tc.sh <your TC 2.0 floppy archive> /opt/tc20`.

| | TC 2.0 (1988) | TC 2.01 (1989) |
|---|---|---|
| `TCC.EXE` sha256 | `24535a9a…dbaad6c1e` | `19650666…8d1127047eecbfe8d1b6eb82830cd8f493c140` |
| `TLINK.EXE` | `997fcac6…bd4f8f7` | `821a862e…93c140` |
| `C0L.OBJ` | `cc2555af…26e2b8` (identical in both) | same |
| `CL.LIB` | `8acad064…eb8` | `53946486…432` |
| unique CL modules found in DONALD.EXE | **45 segs / 7,276 bytes** | 43 / 6,134 |

- `U001` closed: **2.0**. `FBRK` (`__brk/__sbrk`) and `FFREE` (`free/farfree`) match only the 2.0 `CL.LIB`; every 2.01 hit is also a 2.0 hit. The startup object is identical in both versions so it cannot discriminate.
- `U002` closed: **large**. `C0L.OBJ` matches at 0000:0000 (457 bytes) and 44 `CL.LIB` modules match; `C0H`/`CH.LIB` give only 7 generic hits (the `push ds; mov ds` sequences are the hand-written asm module in segment 0000, which loads its own data segment `0B7Fh`).
- `U003` flags: `-Z` (register-load suppression) is required (`blit_dispatch` reuses `AX=0` for the second far pointer); `-O` (jump optimisation) is required (`rom_check` has no `jmp $+2` before the epilogue). Default register variables (`-r`) on: `SI` then `DI` in declaration order. `-G` makes no difference on the 3 matched functions (open). No stack check (`-N` off).
- `U004` linker and link order: open. Layout seen so far: segment 0000 = `C0L` + hand-written asm (0x01C9–0x2DAA, video/BIOS helpers, `push di/si/ds; mov ds,0B7Fh`) + `CL` helper modules (`SETARGV` … `LLSH`); 0304.. = C game modules (each `X_TEXT` segment); 06E3.. = remaining `CL.LIB` in library order (`HARDERR`, `IOERROR`, `EXIT` … `BDOS`).
- `U005` open: alt `DONALD` build matches the same 45 modules (`config/alt/crt_matches.csv`).

## Compiler quirks learned
- Locals take stack slots in declaration order (`int a, b;` gives `a` = `[bp-2]`... check against original) and register variables are assigned SI, DI in declaration order.
- Far-pointer constants: write `(char far *)0xA8000000L`; with `-Z` the zero offset is shared between consecutive constants.
- `register int r = 0; ... return r;` reproduces the `mov ax,si` epilogue pattern.

## Matched (proof of pipeline)
| Function | Address | Size |
|---|---|---|
| blit_dispatch | 0304:000C | 90 |
| draw_items | 0304:0187 | 154 |
| rom_check | 0304:05C0 | 43 |

## Library identification
`tools/libmatch.py /opt/tc20/LIB -m l --csv ...` does a relocation-masked search of every code segment of `C0L.OBJ`, `CL.LIB`, `MATHL.LIB`, `EMU.LIB`, `FP87.LIB`, `GRAPHICS.LIB`. Results are merged into `config/retail/symbols.csv` with `status=lib`; `functions.csv` has `kind` = `lib` / `asm?` / `c`.
(`GFREEMEM`, 18 bytes, overlaps `FFREE` and was dropped as a false hit.)

## Batch-1 workflow additions
- Annotate every function: `/* FUNCTION: DONALD SSSS:OOOO */` right before the definition (TC 2.0 has no `//`).
- `python3 tools/verify.py` (clean: `rm -rf build` first) builds, checks all annotated functions with fixups masked, updates `config/retail/symbols.csv` and prints byte progress (`build/progress.txt`).
- `tools/permute.py file.perm target.c --flags "-ml|-ml -O -Z"` brute-forces `@P{a|b}` source alternatives × flags.
- `tools/dumpfn.py --list` lists unmatched C functions; `tools/cmpobj.py OBJ name=SSSS:OOOO` shows a side-by-side diff.
- Per-module flags live in `config/retail/cflags.txt` (glob relative to src/, last match wins).
- One source file per original code segment (calls to earlier functions in the same TU become `push cs; call near`).
- TC quirks: first local = lowest address; `a=b=0` stores b first; -O reorders if/else and tail-merges; branch polarity follows source (`if (x != 3) {...} else` vs `if (x == 3)`).

## Batch-2 findings
- **Gotos are real.** `run_script` (0304:11AA, a 48-opcode actor script VM) only matched once shared tails were written as `goto` to labels in the earlier case. Plain duplicate code made TC's cross-jump merge keep the *later* copy, the opposite of the original. For a jump whose target is a jump, write `if (a != b) goto back; else goto inc;`. TC canonicalises `if (x) A; else goto L;`, so swapping the condition alone does not change the branch polarity.
- **Branch polarity follows source.** `if (g != 3) {...} else ...` vs `if (g == 3)` decides layout. Early `return` without `else` avoids an extra `jmp`.
- **unsigned vs int and chained assignment.** `x = y = reg` stores through `ax`; separate statements store the register directly. `print_wrapped` needed the odd but byte-exact `idx = wlen = wlen;`, which permute.py found.
- `draw_frame` was never a codegen puzzle: case 0 passes `1` (`b8 01 00`). Read the raw bytes before theorising.
- `-G` is still unresolved: no function so far shows a size/speed choice that depends on it.

## Assembly modules
There is no TASM in the TC 2.0 archives, and TC's inline `asm` needs TASM. So, as in time-commando-dos (MASM sources checked byte-for-byte), the asm modules are NASM sources under `src/asm/`:
- `seg0000.asm` (0000:01C9-2DAB, graphics/blit/decompression helpers between C0L and the runtime), `seg0512.asm` (0512:0000-0558, timer and music), and `seg056a.asm` (056A:0000-058B, keyboard ISR and scancode tables).
- Each has a `; SEGMENT: DONALD SSSS AAAA-BBBB` header. `verify.py` assembles each one (`nasm -f bin`) and requires identical bytes. Relocated words appear as literal segment values marked `; reloc`.
- `tasm.inc` provides `rr op, dst, src` for TASM's `reg, r/m` encodings (8B/33/03...). Six instructions remain as `db` (cs:-override and `rcl m8,1` forms) with the mnemonic in a comment.
- They were bootstrapped by `tools/asm2nasm.py` (recursive descent from the known entry points, data as `db`) and are meant to be annotated further (names, comments, `%define`s for the tables).
- Making them relocatable OMF (externs, `SEG` fixups) is needed for a real link.

## Full relink: status
`tools/splice.py` gives the full-layout build: it writes `build/DONALD.EXE` with every non-fixup byte of matched code taken from our objects/asm and the rest from your local original. It reproduces the original SHA-256 (27,223 code bytes come from our sources). A TLINK relink still needs:
1. Definitions for all DGROUP data. Today the globals are `extern g_XXXX` placeholders.
2. The asm modules as relocatable OMF.
3. The module link order recovered from the segment map.
