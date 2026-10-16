/* Shared declarations for Donald's Alphabet Chase (Turbo C 2.0, large model). */
#ifndef DONALD_H
#define DONALD_H

/* Uninitialised globals (_BSS), declared here first and in address order.
   Turbo C 2.0 allocates tentative definitions by walking its symbol hash table: buckets in hash order, each
   bucket in creation order. The link-visible names (g_XXXX_) share first char, last char and length, so they
   fall into one bucket and their order of first declaration (this list) reproduces the original layout.
   Sources keep the readable spellings. */
#define jump_right g_3868_
/* Actor slots (8): parallel arrays, see docs/SCRIPTS.md */
#define slot_x g_386A_
#define slot_y g_387A_
#define g_group g_388A_
#define slot_frame g_388C_
#define jump_x_major g_389C_
#define slot_shown g_389E_
#define jump_major g_38AE_
#define jump_minor g_38B0_
#define g_keysEnabled g_38B2_
#define g_packBuf g_38B4_
#define jump_steps g_38B8_
#define slot_pc g_38BA_
#define g_letterPicked g_38DA_
#define jump_err g_38DC_
#define g_idleTicks g_38DE_
#define g_pickedLetter g_38E0_
#define unused_38E2 g_38E2_
#define slot_delay g_390A_
#define g_gameWon g_391A_
#define slot_w g_391C_
#define slot_timer g_392C_
#define g_workBuf g_393C_
#define g_letterDone g_3940_
#define slot_flag g_3974_
#define g_sprites g_3984_
#define unused_3A9C g_3A9C_
#define slot_h g_3A9E_
#define g_letterScore g_3AAE_
#define g_jumping g_3AE2_
#define g_textWraps g_3AE4_
#define g_calibSlack g_3AE6_
#define unused_3AE8 g_3AE8_
#define g_initDone g_3AF0_
#define g_backBuf g_3AF2_
#define g_driveB g_3AF6_
#define g_videoMem g_3AF8_
#define g_fixedDrive g_3AFC_
#define unused_3AFE g_3AFE_
#define g_videoMode g_3B4E_
#define g_errMsg g_3B50_
#define g_diskNum g_3B54_
#define g_multiDisk g_3B56_
#define g_fileHandles g_3B58_
#define g_preload g_3B6C_

extern int jump_right;
extern int slot_x[8];
extern int slot_y[8];
extern int g_group;
extern int slot_frame[8];
extern int jump_x_major;
extern int slot_shown[8];
extern int jump_major;
extern int jump_minor;
extern int g_keysEnabled;
extern char far *g_packBuf;
extern int jump_steps;
extern char far *slot_pc[8];
extern int g_letterPicked;
extern int jump_err;
extern int g_idleTicks;
extern int g_pickedLetter;
extern char unused_38E2[40];
extern int slot_delay[8];
extern int g_gameWon;
extern int slot_w[8];
extern int slot_timer[8];
extern char far *g_workBuf;
extern int g_letterDone[26];
extern int slot_flag[8];
extern char far *g_sprites[70];
extern char unused_3A9C[2];
extern int slot_h[8];
extern int g_letterScore[26];
extern int g_jumping;
extern int g_textWraps;
extern int g_calibSlack;
extern char unused_3AE8[8];
extern int g_initDone;
extern char far *g_backBuf;
extern int g_driveB;
extern char far *g_videoMem;
extern int g_fixedDrive;
extern char unused_3AFE[80];
extern int g_videoMode;
extern char far *g_errMsg;
extern int g_diskNum;
extern int g_multiDisk;
extern int g_fileHandles[10];
extern int g_preload;

/* ---- basic types ---------------------------------------------------------------------------------------- */
typedef unsigned char uchar;
typedef unsigned int uint;
typedef char far *farptr;       /* every buffer, picture, sprite and string is reached through a far pointer */
typedef char script_t;          /* actor script byte: >= 0 operand/frame, < 0 opcode (see OP_*) */

/* ---- magic constants -------------------------------------------------------------------------------------- */
/* g_videoMode (asm: GV_MODE): index into g_biosVideoMode[] and the per-mode tables */
#define VM_CGA    0             /* BIOS mode 4, 320x200x4 */
#define VM_TANDY  1             /* BIOS mode 9, 320x200x16 */
#define VM_EGA    2             /* BIOS mode 0Dh, 320x200x16 planar */
#define VM_MODE3  3             /* 4th driver set (sprite_put_m3, 2x save size in show_error); no menu entry */
#define NUM_GROUPS   6          /* letter groups / screens: ABCD EFG HIJK LMNOP QRSTU VWXYZ */
#define NUM_LETTERS 26
#define NUM_SLOTS    8          /* actor slots: 0-4 letters, 5 bubble, 6 helper, 7 Donald */
#define NUM_FILES   10          /* Open_File handle slots */
#define NUM_SPRITES 70
#define FH_FREE     0x7fff      /* g_fileHandles[]: unused slot */
#define FH_RESIDENT 0x8000      /* g_fileHandles[]: index into g_cmpFiles (file preloaded in memory) */
#define KEY_ESC     27
#define KEY_SOUND   '1'         /* toggles g_soundOn */
/* Open_File modes (see the "Illegal MODE in Open_File" message) */
#define READ        1
#define WRITE       2
#define READWRITE   3
/* actor script opcodes: negative script bytes, the cases of run_script (docs/SCRIPTS.md) */
#define OP_WALK           (-1)
#define OP_END            (-2)
#define OP_POS            (-3)
#define OP_DELAY          (-4)
#define OP_NEXT           (-5)
#define OP_WAIT_DONALD_X  (-6)
#define OP_JMP_IF_LEFT    (-7)
#define OP_JMP_UNTIL_AT   (-8)
#define OP_TALLER         (-9)
#define OP_SHORTER        (-10)
#define OP_RANDOM         (-11)
#define OP_FACE_LEFT      (-12)
#define OP_SKIP_50        (-13)
#define OP_LOOP_75        (-14)
#define OP_NEXT_LEVEL     (-15)
#define OP_WAIT_DONALD_Y  (-16)
#define OP_WAIT_DONALD_DX (-17)
#define OP_IF_FOUND       (-18)
#define OP_BUBBLE_X       (-19)
#define OP_JUMP_CATCH     (-20)
#define OP_SKIP           (-21)
#define OP_INIT_SLOTS     (-22)
#define OP_GROUP_INTRO    (-23)
#define OP_IF_GROUP       (-24)
#define OP_START          (-25)
#define OP_MOVE_E         (-26)
#define OP_MOVE_S         (-27)
#define OP_MOVE_W         (-28)
#define OP_MOVE_N         (-29)
#define OP_MOVE_SE        (-30)
#define OP_MOVE_NE        (-31)
#define OP_MOVE_SW        (-32)
#define OP_MOVE_NW        (-33)
#define OP_SHOW_E         (-34)
#define OP_SHOW_S         (-35)
#define OP_SHOW_W         (-36)
#define OP_SHOW_N         (-37)
#define OP_SHOW_SE        (-38)
#define OP_SHOW_NE        (-39)
#define OP_SHOW_SW        (-40)
#define OP_SHOW_NW        (-41)
#define OP_RESET_BUBBLE   (-42)
#define OP_IF_PICKED      (-43)
#define OP_BESIDE_DONALD  (-44)
#define OP_CLEAR_LETTER   (-45)
#define OP_SOUND          (-46)
#define OP_KEYS_ON        (-47)
#define OP_KEYS_OFF       (-48)
/* Indices into g_scriptTable (0-25: one script per letter; the rest are shared scripts). */
#define SCR_IDLE         52  /* parked actor */
#define SCR_BUBBLE       53  /* Donald's speech bubble (patched in place by handle_key) */
#define SCR_LEVEL_DONE   96
#define SCR_IDLE_TIMEOUT 97
#define SCR_DONALD       98  /* Donald, slot 7 */
#define SCR_PICK_HELPER 124  /* slot 6 after a letter is picked */
#define SCR_PICK_LETTER 126  /* slots 0-4 after a letter is picked */

/* sprite made by grab()/grab_vga(): 4-byte header, then the packed pixels (asm: STRUC SPRITE in tasm.inc).
   Accessed as bytes of a char far *, so the header stays a set of offsets rather than a C struct. */
#define SPR_HM1 1               /* height - 1 (rows; 8-pixel rows in grab_vga) */
#define SPR_W   2               /* width in bytes / cells */
#define SPR_HDR 4               /* header size: bytes 0 and 3 are never written */

/* ---- structures (docs/DATA.md) ----------------------------------------------------------------------------- */
/* Westwood file-library entry: one per game file (tables.c, 18 bytes, accessed as g_cmpFiles[i].field) */
struct file_entry {
    char far *name;             /* +0  "ABCDPET.CMP"; list ends with an empty name */
    long size;                  /* +4  file size; Seek_File clamps to it */
    char far *data;             /* +8  resident copy loaded by load_resources, or 0 */
    int disk;                   /* +12 disk number (Find_Disk_Number), ORed into g_multiDisk */
    long pos;                   /* +14 read position of the resident copy (Read_Resident/Seek_File) */
};
/* text window in 8x8 cells (16 bytes). g_windows[] holds the saved windows, g_win the active one: set_window
   stores g_win's colours/cursor into the old entry and loads x..row of the new one. */
struct window {
    int x, y, w, h;             /* origin (bytes, text rows) and size */
    int fg, bg, col, row;       /* text colours and cursor */
};

/* ---- data ------------------------------------------------------------------------------------------------ */
extern struct file_entry g_cmpFiles[];
extern struct window g_windows[], g_win;
extern int g_curWindow, g_windowSet, g_cgaSmallWin, g_textCols, g_textWraps;
extern int g_biosVideoMode[], g_groupFirst[], group_letter_count[], group_roll_base[], group_intro_script[];
extern int group_scene_pic[], group_letters_pic[], group_donald_pic[], pic_needs_ega[];
extern int hline_masks[], hline_shift[];
extern char letter_frame[];
extern script_t scr_letter_wait[], bubble_arg1, bubble_arg2, bubble_frame, pick_frame1, pick_frame2;
extern script_t far *g_scriptTable[];
extern char far *g_tunes[];
extern char far *g_palettes[];
extern char msg_cga[], msg_ega[], msg_tandy[], msg_detected[], str_lf, str_cr, msg_insert_disk[];
extern char pal_level[], pal_title[], pal_ending[];
extern int g_curLetter;
extern char g_soundOn;
extern long g_randSeed;
extern int g_retraceWait;
extern int gfx_clip_x1, gfx_clip_x2, gfx_clip_y1, gfx_clip_y2, clip_x1, clip_x2, clip_y1, clip_y2;
extern void (far *g_errShowHook)(void);
extern void (far *g_errMsgHook)(void);
extern int g_errWindow, g_memReserve, g_diskRetries;
extern char far *g_errSaveBuf;
extern char far *msg_err_create, far *msg_err_mode, far *msg_insert_disk_n, far *msg_err_too_many;
extern char far *msg_err_close, far *msg_err_read, far *msg_err_write, far *msg_err_write_res;
extern char far *msg_err_disk_num, far *msg_err_res_index, far *msg_err_open_files;

/* Turbo C headers whose prototypes match the original calls. <io.h>/<fcntl.h> are left out on purpose:
   their prototypes of open/read/write/lseek change the code of Read_File, Write_File, Seek_File and
   load_resources (e.g. read(fd, buf, long) would truncate the long), so seg06f0 was built without them. */
#include <stdlib.h>
#include <string.h>
#include <alloc.h>
#include <time.h>
#include "proto.h"

#endif
