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
#define g_multiDisk g_3AF6_
#define g_videoMem g_3AF8_
#define g_noDiskCheck g_3AFC_
#define unused_3AFE g_3AFE_
#define g_videoMode g_3B4E_
#define g_errMsg g_3B50_
#define g_diskNum g_3B54_
#define g_diskSwapOn g_3B56_
#define g_fileHandles g_3B58_
#define g_errHooked g_3B6C_

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
extern int g_multiDisk;
extern char far *g_videoMem;
extern int g_noDiskCheck;
extern char unused_3AFE[80];
extern int g_videoMode;
extern char far *g_errMsg;
extern int g_diskNum;
extern int g_diskSwapOn;
extern int g_fileHandles[10];
extern int g_errHooked;

extern int g_videoMode;      /* DGROUP:3B4E, 2 = EGA path (TBD) */

void far blit_generic(int x, int y, int w, int h8, char far *src);                   /* 0000:28B3 asm */


extern int slot_x[8];     /* DGROUP:386A */
extern int slot_y[8];     /* DGROUP:387A */
extern int slot_shown[8];     /* DGROUP:389E, -1 = unused slot */
extern int slot_w[8];     /* DGROUP:391C */
extern int slot_h[8];     /* DGROUP:3A9E */

void far draw_item(int p, int x, int y, int a, int b);          /* 0304:0221 */

/* placeholder globals, named by DGROUP offset */
extern char g_soundOn;
extern char far *g_tunes[];  /* tune table (sound.c) */
extern int win_x, win_y, win_w, win_h;
extern void (far *g_errShowHook)(void);
extern void (far *g_errMsgHook)(void);
extern int g_retraceWait;
extern int g_multiDisk, g_noDiskCheck;
extern char far *g_errMsg;
extern int g_fileHandles[];
extern char far *msg_err_close;
extern int g_textBg, g_textCol, g_textRow;
extern int g_group;
extern char msg_cga[], msg_ega[], msg_tandy[], msg_detected[], str_lf, str_cr, pal_level[];
extern int group_scene_pic[], group_letters_pic[], group_donald_pic[];
extern long g_randSeed;
extern int g_keysEnabled, g_letterPicked, g_idleTicks, g_pickedLetter, g_curLetter, g_letterDone[];
extern char bubble_arg1, bubble_arg2, bubble_frame;
struct name_entry { char far *name; long size; char far *data; int value; long pos; };
extern struct name_entry g_cmpFiles[];
extern int pic_needs_ega[];
extern char far *g_palettes[];
extern int g_textCols, g_textWraps;
/* text window in 8x8 cells: set_window copies x,y,w,h to win_* and swaps the text colours/cursor in and out of fg..row */
struct window { int x, y, w, h;          /* origin (bytes, text rows) and size */
                int fg, bg, col, row; };  /* saved text colours and cursor */
extern struct window g_windows[];
extern int g_curWindow, g_textFg, g_windowSet;
extern char far *g_sprites[];

extern int gfx_clip_x1, gfx_clip_x2, gfx_clip_y1, gfx_clip_y2, clip_x1, clip_x2, clip_y1, clip_y2;
extern int g_calibSlack;
extern char far *msg_err_read;
extern int g_gameWon, g_errWindow, g_errHooked, g_memReserve, g_biosVideoMode[];
extern char far *g_videoMem;
extern char far *msg_err_write, far *msg_err_write_res;
extern char pick_frame1, pick_frame2;
extern int jump_steps, slot_delay[];
extern char far *msg_err_open_files;
extern int slot_frame[], slot_timer[];
extern char letter_frame[];
extern char scr_letter_wait[];
extern char far *slot_pc[];
extern int g_cgaSmallWin;
extern char far *msg_err_disk_num;
extern int jump_x_major, jump_right, jump_minor, jump_major, jump_err;
extern int g_initDone;
extern char far *g_backBuf;
extern char far *g_packBuf;
extern char far *g_workBuf;
extern char far *g_errSaveBuf;
extern char far *msg_err_res_index;
extern int hline_masks[];
extern int hline_shift[];
extern int g_groupFirst[], group_letter_count[], g_letterScore[];

void far quit(int code);
extern char pal_title[], pal_ending[], msg_insert_disk[];
extern int slot_flag[], g_jumping, slot_delay[], group_roll_base[], group_intro_script[];
/* Indices into g_scriptTable (0-25: one script per letter; the rest are shared scripts). */
#define SCR_IDLE         52  /* parked actor */
#define SCR_BUBBLE       53  /* Donald's speech bubble (patched in place by handle_key) */
#define SCR_LEVEL_DONE   96
#define SCR_IDLE_TIMEOUT 97
#define SCR_DONALD       98  /* Donald, slot 7 */
#define SCR_PICK_HELPER 124  /* slot 6 after a letter is picked */
#define SCR_PICK_LETTER 126  /* slots 0-4 after a letter is picked */
extern char far *g_scriptTable[];
extern int g_diskNum, g_diskSwapOn, g_diskRetries;
extern char far *msg_err_create, far *msg_err_mode, far *msg_insert_disk_n, far *msg_err_too_many;
void far print_word(char far *s, int nl);

#endif
