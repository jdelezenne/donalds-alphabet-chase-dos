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
- `U003` flags: `-Z` (register-load suppression) is required (`blit_dispatch` reuses `AX=0` for the second far pointer); `-O` (jump optimisation) is required (`rom_check` has no `jmp $+2` before the epilogue). Default register variables (`-r`) on: `SI` then `DI` in declaration order. `-G` is **not** used (closed in batch 3: adding it breaks 49 of 73 functions; dropping `-O` from the default line breaks 16 functions, dropping `-Z` breaks 9). No stack check (`-N` off).
- `U004` closed in batch 3: TLINK 2.0 (TC 2.0), order in `config/retail/link.txt` (see Relink below). Original note: Layout seen so far: segment 0000 = `C0L` + hand-written asm (0x01C9–0x2DAA, video/BIOS helpers, `push di/si/ds; mov ds,0B7Fh`) + `CL` helper modules (`SETARGV` … `LLSH`); 0304.. = C game modules (each `X_TEXT` segment); 06E3.. = remaining `CL.LIB` in library order (`HARDERR`, `IOERROR`, `EXIT` … `BDOS`).
- `U005` assessed in batch 3: the alt `DONALD` (55,432 bytes, 698 relocations) is the same link with a shorter `main()` (no `argv[2]` video-mode override / `g_videoMode = -1` / `detect_video()` path, -0x48 bytes) and two small asm edits (0512:0199, 056A:03F6); everything else differs only by the resulting segment shift. It matches the same 45 library modules (`config/alt/crt_matches.csv`).

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
- `-G`: resolved in batch 3, not used.

## Language classification (batch 3)
Requirement: code written in asm stays asm, code written in C is C. `tools/classify.py --write` records the verdict
per function in `config/retail/functions.csv` (`lang`, `evidence`):
- **c** (73): byte-matched by TCC 2.0 from C source, which is itself the proof. Traits listed too (bp frame, `sub sp`, `push si/di`
  register variables, TC epilogue, switch tables, caller-cleans cdecl calls). A C function is flagged `c-flagged` if
  it shows hand-written traits without a switch table: **none are**.
- **asm** (66): every routine in the 3 NASM modules shows hand-written traits that TCC never emits: `push di; push si;
  push ds; mov ax,SEG; mov ds,ax` (TC pushes `si` first and never reloads DS from a far data segment), `cs:` data and
  self-modifying stores, `iret` ISRs, port I/O, carry-flag results, string instructions, `cli/sti/xchg/rcl/loop`, register
  parameter passing. The audit found **no compiler-generated routine** inside them, so none had to move to C.
- **lib** (70): Turbo C runtime, matched against `CL.LIB`/`C0L.OBJ`.

## Assembly modules
Sources are NASM `-f obj` (relocatable OMF), so they link with TLINK:
- `seg0000_01c9/0217/08b9/277e/2a15.asm`: 5 graphics modules in `_TEXT`. The relocation table shows they are 5
  separate objects interleaved with the C modules in link order. They share the far data segment `GFX_DATA`
  (class DATA, word aligned, frame 0B7F because it starts at 0B7F:000E right after `_CRTSEG`).
- `seg0512.asm`: `SND_TEXT`, timer and music; starts at 0512:0001, right after `shutdown()`'s `retf`.
- `seg056a.asm`: `KBD_TEXT`, the keyboard ISR, plus its 8-byte `KBD_DATA` (frame 0CCD).
- Segment values are symbolic (`mov ax, GFX_DATA`, `dw KBD_DATA`, `call (seg L01A9):L01A9`). `verify.py` compares each
  module's code segment with fixup bytes masked. `tasm.inc` provides `rr op, dst, src` for TASM's `reg, r/m` encodings.
  Six instructions remain as `db`, with the mnemonic in a comment.

## Relink (batch 3): byte-identical
`tools/relink.sh` runs verify.py, then mkdata.py, then relink.py (TLINK `/m /s /l /c` C0L + objects + CL.LIB). The result is
`build/link/DONALD.EXE`, **identical to DONALD.EXE (sha256 c72ed190...)**: header, all 702 relocations in order, code and data.
How the pieces were recovered:
- **Link order from the relocation table.** TLINK writes relocations object by object in link order. Within an
  object they follow its FIXUPP records: TC writes them in descending order per LEDATA record, TASM in ascending order. So the order in which
  each module's relocations first appear gives `config/retail/link.txt`.
- **Segment names matter.** TCC names the code segment after the file. `seg06e3/harderr.c` produces `HARDERR_TEXT`, which
  CL.LIB's `HARDERR` module joins: that is why the library's `harderr()` sits at 06E3:0024 inside the game code.
  `build.sh` now compiles 8.3-safe files under their own name. `main()` and `m04fc.c` were one file (one segment).
- **Data.** The C modules' `_DATA` is word aligned, even when empty. 06F0's data (DGROUP 1ECE-2193: error-box variables,
  the far-pointer table of disk error messages, the `show_error`/`error_msg` hooks, then TC's literal pool) is now
  real C initialisers in `m06f0.c`. TC emitted those relocations before the code ones, exactly as in the original.
  seg0612's two string literals were already C. The rest is generated at build time from your EXE by `tools/mkdata.py`
  (layout in `config/retail/datalayout.txt`; no game bytes in git): DGROUP 0094-1EA1 (0304's strings, palette tables,
  actor scripts, the `.CMP` name table...), `GFX_DATA`, and the game `_BSS` extent.
  Each `g_XXXX` (and each `data.csv` name) becomes a public at its offset. Far pointers become DGROUP or code-segment fixups, emitted
  in TC order (descending per LEDATA record, records cut at offsets congruent to 0x5E mod 0x400).
- **Bugs the fixup-masked matcher could not see**, all found by the whole-EXE compare: `write_file` called `read`
  instead of `write`; `free_all` called `free` instead of `farfree`; `main` calls `atol`, not `atoi`.
  These calls differ only in fixup bytes, so **the relink is now the real proof for calls and data references**.
- Next: move the remaining generated data into its owning sources. 0304 owns 0094-~1AA9: relocations 127-308, then its literal
  pool of `.CMP` names. 1AAA-1EA1 belongs to modules between 04FC and 0612 (0512/0567 own the far pointers at 1E24-1E84).
  `GFX_DATA` belongs to the asm modules. Then the BSS globals become definitions too.

## Full-layout splice
`tools/splice.py` still writes `build/DONALD.EXE` from our bytes plus the local original (for byte-level checks
while editing). The relink above supersedes it as the proof.
