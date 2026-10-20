# Source guide and provenance

Donald uses the same purpose-based source organization as the recovered Goofy
project: application code, shared engine services, audio and data. Handwritten
assembly lives beside the C code for its subsystem. These are descriptive
reconstruction names, not a claim that the original source filenames have been
recovered.

The layout remains 27 C translation units (two data-only) and seven assembly
modules. No functions were moved between translation units, no code/data was
reordered, and no original assembly was replaced with C. Retail addresses in
annotations and catalogs remain the primary identity of each recovered item.

## Finding code

- `src/donald/game.c`: dirty-region rendering, letter-group progression, letter
  selection, actor scripts, jump paths, title/ending flow and disk prompt.
- `src/donald/main.c`: command-line handling, initialization and shutdown; the
  `DONALD_ALT` differences remain here.
- `src/donald/audio/`: `music.c` tune streams and high-level sound playback,
  `sound.asm` sound interrupt driver, and their `sound.h` interface.
- `src/donald/engine/`: independent rendering, input, timing, memory, resource-file and
  text-window services. `drive.c` contains disk selection; the previous
  `src/donald/seg065b/music.c` filename incorrectly suggested an audio service.
  This directory also owns the five graphics assembly objects, keyboard
  interrupt driver and `engine.h`. `tasm.inc` and `gfx_data.inc` describe
  assembly encodings/layouts; the sound driver shares `tasm.inc`.
- `src/donald/data/`: script bytes and resource/scene tables. Numeric script operands
  remain intact: negative bytes can be operands as well as opcodes, so a blind
  replacement with `OP_*` names would mislabel the program.
- `src/donald/`: the ordered `donald.h` umbrella plus `bss.h`, `common.h` and
  `game.h`. Subsystem headers sit with their sources: `data/gamedata.h`,
  `audio/sound.h` and `engine/engine.h`.

The complete machine-readable map is [modules.csv](../src/donald/modules.csv).
Each row records the current source, language, retail code segment (or DGROUP
for data-only C), stable compiler stem, previous repository path and purpose.
Rows follow the exact non-runtime object order in [link.txt](../src/donald/link.txt).
The previous paths and compiler stems document this reconstruction's history;
they are not historical source-file evidence.

| Retail segment | C source | Responsibility |
|---|---|---|
| 0304 | `game.c` | Game and actor/script flow |
| DGROUP | `data/scripts.c`, `data/tables.c` | Initialized game data |
| 04FC | `main.c` | Program lifecycle |
| 0567 | `audio/music.c` | Music streams and playback |
| 05C2 | `engine/input.c` | Keyboard wrappers |
| 05C5 | `engine/egablit.c` | Clipped rectangle blit |
| 05D4 | `engine/retrace.c` | Frame waits |
| 05D5 | `engine/text.c` | Text glyphs |
| 05E7 | `engine/fillrect.c` | Filled rectangles |
| 05ED | `engine/lines.c` | Lines and points |
| 0604 | `engine/picture.c` | CMP pictures |
| 060B | `engine/palette.c` | Palette dispatch |
| 0612 | `engine/xalloc.c` | Allocation wrapper |
| 061A | `engine/loadfile.c` | Resource loading |
| 061F | `engine/calibrat.c` | Timer/retrace calibration |
| 062D | `engine/capture.c` | Sprite capture |
| 065B | `engine/drive.c` | Disk selection |
| 065E | `engine/setwin.c` | Window state switching |
| 066F | `engine/redraw.c` | Clear active window |
| 0671 | `engine/wraptext.c` | Word wrapping |
| 06AD | `engine/wordtext.c` | Window text and scrolling |
| 06C3 | `engine/sprite.c` | Sprite dispatch |
| 06D3 | `engine/mirror.c` | Mirrored sprite dispatch |
| 06E3 | `engine/harderr.c` | DOS critical errors |
| 06EF | `engine/window.c` | Select/clear window |
| 06F0 | `engine/files.c` | File/resident I/O and error dialogs |

Assembly module address ranges and every callable/data boundary are retained
in [ASM_DATA.md](ASM_DATA.md), [asm_functions.csv](../agents/config/retail/asm_functions.csv)
and [asm_data.csv](../agents/config/retail/asm_data.csv). All catalogs use the current
semantic paths.

## Interfaces and storage

Include `donald.h` as the supported umbrella. Its order is intentional:

1. `bss.h`: first declarations and link aliases for all uninitialized globals.
2. `common.h`: original-width types, video/file/script constants, named
   page-copy directions, drawing destinations and fixed actor slots.
3. `gamedata.h`: typed resource/window structures and initialized data.
4. The existing selected Turbo C library headers.
5. Compatibility aliases for assembly entry points, then `game.h`, `sound.h`
   and `engine.h` function interfaces.

The build and permuter stage these headers together under their unchanged DOS
basenames, so the umbrella include order and source text stay intact. NASM uses
the owning directory and `src/donald/engine/` as include search paths.

This separation preserves the original declaration stream. TC 2.0 allocates
_BSS by symbol-hash bucket and first-declaration order; regrouping globals by
subsystem can silently change the executable. The address-based `g_XXXX_`
link aliases are intentionally isolated in `bss.h`. Unknown reserved storage
remains explicitly unidentified instead of receiving an invented meaning.

Actor arrays remain parallel arrays, consistent with indexed-access evidence.
Script storage and its pointer table now use `script_t` (exactly `char`),
including the `slot_pc` definition. Its first extern declaration in `bss.h`
still spells `char far *`, before the typedef exists. Resource and window
initializers are formatted one record per line without changing their order.
`main` explicitly spells its existing implicit `int` return type.

Do not add `<io.h>` or `<fcntl.h>` globally: the original unprototyped DOS calls
have stack-width quirks documented in [DATA.md](DATA.md). This is recovered
16-bit code, not a modernization of its ABI or original bugs.

## Semantic API changes

Names are supported by the existing bodies and call sites. Addresses retain
traceability to the earlier names in git history.

| Address | Current name | Previous name / evidence |
|---|---|---|
| 0304:000C | `present_rect` | `blit_dispatch`; present a source rectangle by video mode |
| 0304:0066 | `propagate_dirty_overlap` | `check_collisions`; propagate redraw flags through overlapping actor bounds, not gameplay collision response |
| 0304:0187 | `copy_dirty_actor_rects` | `draw_items`; copy padded dirty regions |
| 0304:0221 | `copy_page_rect` | `draw_item`; six source/destination page combinations |
| 0304:0383 | `step_jump_path` | `step`; integer major/minor-axis jump step |
| 0304:03FC | `draw_actor_frame` | `draw_frame`; sprite frame/destination/mirroring dispatch |
| 0304:05C0 | `detect_tandy_signature` | `rom_check`; ROM byte probe selecting Tandy mode |
| 0304:0737 | `completed_group_score` | `level_sum`; group score, zero until the group is complete |
| 0304:0776 | `initialize_jump_path` | `aim`; initialize major/minor axes and jump error accumulator |
| 0304:08B1 | `prepare_letter_selection` | `setup_level`; install picked-letter/helper scripts and patch frames |
| 0304:0C0D | `run_game` | `game`; main game flow |
| 0304:11AA | `step_actor_script` | `run_script`; interpret actor script until yielding |
| 0304:1A71 | `roll_bounded_random_sum` | `roll`; sum bounded random rolls plus an addend |
| 0304:1E5B | `prompt_insert_game_disk` | `about`; draw insertion prompt and wait for a key |
| 05D4:0002 | `wait_frame_intervals` | `repeat_call`; repeat calibrated retrace waits |
| 06EF:000B | `select_and_clear_window` | `set_and_redraw`; select window then clear it/reset cursor |

The `PAGE_*`, `DRAW_*` and `SLOT_*` constants replace only established literal
meanings. They are integer preprocessor constants, preserving call widths and
all original branch values.

## Build invariants and checking changes

`build.sh` reads the module catalog rather than deriving compiler identity from
a semantic filename. For example, `game.c` is still staged as `M0304.C`, and
`engine/harderr.c` as `HARDERR.C`. The latter must emit `HARDERR_TEXT`, shared
with the real Turbo C runtime's HARDERR module. Semantic object filenames are
mapped to the unchanged DOS link aliases in `link.txt`.

`source_manifest.py` checks current source coverage, unique object/compiler
stems, annotated segments, per-file compiler overrides and exact link order.
`verify.py --sources-only` includes this check. It is a source consistency
check, not a binary test. The separate full original SHA-256 check covers code,
data, relocations, call targets, header and padding:

```sh
python3 tools/verify.py --sources-only
rm -rf build
tools/relink.sh all --check-hashes
python3 tools/matchreport.py
```

See [BUILD_VALIDATION.md](BUILD_VALIDATION.md) for actual build evidence and
which checks require original game files. No compiler binaries, original game
files, synthetic tests or generated data are added by this reorganization.

## Maintenance constants and checks

`src/donald/data/gamedata.h` names resource indices 18-26 (`PIC_*`) from the actual
`g_cmpFiles` entries and their matching palette table in `src/donald/data/tables.c`.
`run_game` and `ending` use these names at the load/draw callers. The single
`0DONALD.CMP` sprite and `0DONALD0.CMP` sheet names describe their existing grab
calls; they do not claim recovered historical identifiers. Actor/letter/sprite
array extents and their loops in `game.c` reuse the existing `NUM_*` macros.
Every substitution expands to exactly the same literal token, preserving type
and width. The preamble's eight printed lines and coordinate/frame literals
remain separate because they have different meanings.

`make check-source` checks the flat DOS header namespace, include resolution,
original C function order and module/link provenance, then assembles and checks
both real NASM variants. `make check-exact` rebuilds both complete executables
in a fresh original-free source snapshot with pinned Turbo C inputs. See
[BUILD_VALIDATION.md](BUILD_VALIDATION.md) for current evidence and limits.
