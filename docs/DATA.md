# Data structures

What the original program's data looked like. Each item comes with the evidence for it. The test for every change:
both relinks stay IDENTICAL and verify.py reports 73/73. Turbo C 2.0 large model gives these address patterns:
- **Array of structs** `t[i].f`: the index is multiplied by the struct size (`imul`/shift-and-add), and the field is a
  constant displacement on one base.
- **Struct of arrays** `f[i]`: `shl bx,1` (or `shl ×2` for far pointers), and each field has its own base address.
- **Data layout**: an initialised array of structs interleaves its fields in DGROUP; parallel arrays keep each field
  contiguous.

Declarations: `src/include/donald.h` (types, constants, structs, data) and `src/include/proto.h` (prototypes of all
72 C functions and all asm publics). Asm offsets: `src/asm/tasm.inc`.

## Recovered

| structure | where | evidence |
|---|---|---|
| `struct file_entry {char far *name; long size; char far *data; int disk; long pos;}` (18 bytes), `g_cmpFiles[]` | tables.c 1772 | Accesses use stride 18, with fields at +0/+4/+8/+12/+14 as dword/dword/dword/word/dword. The initialiser interleaves name and size per file. The messages name the Westwood file library ("Open_File", "Seek_File", "Find_Disk_Number", "Get_Resident_Index"). `disk` is what Find_Disk_Number returns; it is ORed into `g_multiDisk` and printed as the disk number. |
| `struct window {int x, y, w, h, fg, bg, col, row;}` (16 bytes), `g_windows[3]` | m04fc.c 1AAA | Stride 16. Rows of 8 interleaved words in the data. set_window copies 8 fields. |
| `struct window g_win` (the active window) | m06f0.c 1ED8-1EE7 | Was 8 loose ints (`win_x..win_h`, `g_textFg/Bg/Col/Row`). They sit at 1ED8+0..+14 in exactly the `struct window` order, set_window moves exactly those 8 fields to and from `g_windows[n]`, and the initial values `{0,0,40,25,15,0,0,0}` are a full-screen window like `g_windows[0]`. Field accesses compile to the same direct addresses: IDENTICAL. |
| `g_scriptTable[127]` (`script_t far *`) | scripts.c 1262 | One table (batch 6); fixed entries via `SCR_*` indices. |
| Sprite header: offsets `SPR_HM1`=1, `SPR_W`=2, `SPR_HDR`=4; asm `STRUC SPRITE` | grab/grab_vga, sprite_* asm | grab writes bytes 1 and 2 of a `char far *` and puts the data at +4. The asm walks the header with `inc si`. Kept as offsets on a char pointer (see Rejected). |
| `.CMP` header: asm `STRUC CMPHDR` (len word, layout byte, RLE) | load_file, cmp_unpack_* | docs/CMP.md. |
| Script opcodes `OP_*` (-1..-48) | run_script cases | One `case` per opcode; meanings in docs/SCRIPTS.md. |
| Constants: `VM_CGA/TANDY/EGA/MODE3`, `KEY_ESC`, `KEY_SOUND`, `READ/WRITE/READWRITE`, `FH_FREE` 0x7fff, `FH_RESIDENT` 0x8000, `NUM_FILES` | everywhere | The values come from the code: `g_biosVideoMode` {4,9,13}, Open_File's switch, the handle-slot sentinels. |
| Typedefs `uchar`, `uint`, `farptr`, `script_t` | donald.h | `rand8` returns `unsigned char`. Everything else is char/int/far pointer, which matches the access widths. |
| Prototypes for every function | proto.h | Adding them leaves every function unchanged. Codegen fixes two types: `dos_putc` takes an int (a `char` prototype changes detect_video), and `pack_rect` returns an int (grab uses the count). |

## Rejected, with evidence

| candidate | why not |
|---|---|
| Actor slots as `struct slot[8]` | **Struct of arrays is proven.** Every field is addressed as `[bx+base]` with `bx = i*2` (×4 for `slot_pc`), and the bases are separate. `g_group` (388A) sits between `slot_y` and `slot_frame`, and the jump counters sit between the other arrays, so no struct layout can produce these addresses. The arrays are 8 long (batch 6 found slots 5-7 under separate names). |
| Per-group tables as `struct group[6]` | **Struct of arrays is proven by the data layout.** `group_scene_pic` 0162, `group_letters_pic` 016E and `group_donald_pic` 017A each hold 6 contiguous ints ({15,13,12,14,17,16}, ...), not interleaved. Likewise `g_groupFirst` (7 entries), `group_letter_count`, `group_roll_base`, `group_intro_script`. A `[3][6]` 2-D array would give the same code and the same bytes, so it can't be ruled out, but nothing hints at it. |
| `struct letter {done, score}` | `g_letterDone` (3940) and `g_letterScore` (3AAE) are far apart in BSS and each indexed `key*2` from its own base. |
| Sprite header as a C struct | The C code only ever indexes a `char far *` (`res[1]`, `res[2]`, `res + 4`), and there is no struct-typed access anywhere. A struct would need casts that the original very likely didn't have. |
| `hline_masks[2][4]` (left/right masks) | `hline_masks[mode]` and `hline_masks[mode + 4]` compile the same as `[0][mode]` and `[1][mode]`, so codegen can't decide. Kept flat. |
| Error-box state as a struct (`g_errShowHook`, `g_errMsgHook`, `g_diskRetries`, `g_memReserve`, `g_errSaveBuf`, `g_errWindow`) | Each one is set on its own by other modules (main sets the hook, window and reserve). Their types are mixed and nothing accesses them as a group. They look like the Westwood library's separate globals. |
| GFX clip rectangle (`clip_x1..y2`, `gfx_clip_*`) as a struct | Asm-owned words. The C code writes them one by one, and no struct access exists in the asm. |
| File handle slots as structs | `g_fileHandles[10]` holds plain ints (DOS handle, `FH_RESIDENT\|index`, or `FH_FREE`). No other per-slot data exists. |
| `<io.h>`/`<fcntl.h>` | Including them changes Read_File, Write_File, Seek_File and load_resources (`read(fd, buf, long)` would truncate the long, and the `open`/`lseek` prototypes differ). seg06f0 was compiled without them. `<stdlib.h> <string.h> <alloc.h> <time.h>` are fine. |

## Names fixed in this batch (evidence)

- `music_toggle` → **`select_drive(disk)`**: it only calls `dos_set_drive(0)` (A:), then `dos_set_drive(1)` (B:)
  when `g_driveB` is set and `disk > 0`. Open_File calls it with `Find_Disk_Number(name)` before opening a file
  that is not resident.
- `g_multiDisk` (3AF6) → **`g_driveB`**: used as the drive for disks above 0 and as the letter `'A' + g_driveB` in
  "Insert disk _ in drive _:".
- `g_noDiskCheck` (3AFC) → **`g_fixedDrive`**: when set, `select_drive` and the drive letter in the message are skipped.
- `g_diskSwapOn` (3B56) → **`g_multiDisk`**: load_resources ORs every file's disk number into it, and Open_File only
  switches drives when it is nonzero.
- `g_errHooked` (3B6C) → **`g_preload`**: main sets it to 1, and load_resources only reads files into memory when it is set.
- File functions take the Westwood names from the messages (`Open_File`, `Seek_File`, `Find_Disk_Number`,
  `Get_Resident_Index`). The rest of the family is named to match: `Close_File`, `Read_File`, `Write_File`,
  `File_Exists`, `Delete_File`, `Create_File`, `Read_Resident`, `free_resident`.
