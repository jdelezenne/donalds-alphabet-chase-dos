/* Shared types, constants and script opcodes. Include through donald.h. */
#ifndef DONALD_COMMON_H
#define DONALD_COMMON_H

/* Original Turbo C 2.0 large-model types: int=16, long=32, far pointer=32 bits. */
typedef unsigned char uchar;
typedef unsigned int uint;
typedef char far *farptr;       /* every buffer, picture, sprite and string is reached through a far pointer */
typedef char script_t;          /* signed script byte: negative opcodes and context-dependent operands (see OP_*) */

/* Video, file and application constants. */
/* g_videoMode (asm: GV_MODE): index into g_biosVideoMode[] and the per-mode tables */
#define VM_CGA    0             /* BIOS mode 4, 320x200x4 */
#define VM_TANDY  1             /* BIOS mode 9, 320x200x16 */
#define VM_EGA    2             /* BIOS mode 0Dh, 320x200x16 planar */
#define VM_MODE3  3             /* 4th driver set (sprite_put_m3, 2x save size in show_error); no menu entry */
#define NUM_GROUPS   6          /* letter groups / screens: ABCD EFG HIJK LMNOP QRSTU VWXYZ */
#define NUM_LETTERS 26
#define NUM_SLOTS    8          /* actor slots: 0-4 letters, 5 bubble, 6 helper, 7 Donald */
/* Actor slot roles (the remaining slots hold the current group's letters). */
#define SLOT_BUBBLE  5
#define SLOT_HELPER  6
#define SLOT_DONALD  7
/* copy_page_rect modes: direction between screen, background and work page. */
#define PAGE_SCREEN_TO_BACK 0
#define PAGE_BACK_TO_SCREEN 1
#define PAGE_BACK_TO_WORK   2
#define PAGE_WORK_TO_BACK   3
#define PAGE_SCREEN_TO_WORK 4
#define PAGE_WORK_TO_SCREEN 5
/* draw_actor_frame modes: destination page and optional horizontal mirror. */
#define DRAW_SCREEN          0
#define DRAW_BACK            1
#define DRAW_BACK_MIRRORED   2
#define DRAW_SCREEN_MIRRORED 3
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
/* actor script opcodes: negative script bytes, the cases of step_actor_script (docs/SCRIPTS.md) */
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

#endif
