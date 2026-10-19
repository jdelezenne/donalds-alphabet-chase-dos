/* Recovered application/resource data and record layouts. Use donald.h. */
#ifndef DONALD_GAMEDATA_H
#define DONALD_GAMEDATA_H

/* Shared record layouts (docs/DATA.md). */
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

/* Initialized data and shared engine state. Keep declaration order stable:
   this is the original stream after bss.h and common.h. Declarations from
   different subsystems intentionally remain together here. */
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

#endif
