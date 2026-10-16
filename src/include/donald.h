/* Shared declarations for Donald's Alphabet Chase (Turbo C 2.0, large model). */
#ifndef DONALD_H
#define DONALD_H

/* Uninitialised globals (_BSS), declared here first and in address order.
   Turbo C 2.0 allocates tentative definitions by walking its symbol hash table: buckets in hash order, each
   bucket in creation order. The link-visible names (g_XXXX_) share first char, last char and length, so they
   fall into one bucket and their order of first declaration (this list) reproduces the original layout.
   Sources keep the readable spellings. */
#define g_3868 g_3868_
/* Actor slots (8): parallel arrays, see docs/SCRIPTS.md */
#define slot_x g_386A_
#define slot_y g_387A_
#define g_group g_388A_
#define slot_frame g_388C_
#define g_3896 g_3896_
#define g_3898 g_3898_
#define g_389C g_389C_
#define slot_shown g_389E_
#define g_38AE g_38AE_
#define g_38B0 g_38B0_
#define g_38B2 g_38B2_
#define g_packBuf g_38B4_
#define g_38B8 g_38B8_
#define slot_pc g_38BA_
#define g_38CE g_38CE_
#define g_38D2 g_38D2_
#define g_38D6 g_38D6_
#define g_38DA g_38DA_
#define g_38DC g_38DC_
#define g_38DE g_38DE_
#define g_38E0 g_38E0_
#define g_38E2 g_38E2_
#define slot_delay g_390A_
#define g_3914 g_3914_
#define g_3916 g_3916_
#define g_391A g_391A_
#define slot_w g_391C_
#define slot_timer g_392C_
#define g_3936 g_3936_
#define g_3938 g_3938_
#define g_workBuf g_393C_
#define g_letterDone g_3940_
#define slot_flag g_3974_
#define g_sprites g_3984_
#define g_3A9C g_3A9C_
#define slot_h g_3A9E_
#define g_letterScore g_3AAE_
#define g_3AE2 g_3AE2_
#define g_3AE4 g_3AE4_
#define g_3AE6 g_3AE6_
#define g_3AE8 g_3AE8_
#define g_3AF0 g_3AF0_
#define g_backBuf g_3AF2_
#define g_3AF6 g_3AF6_
#define g_videoMem g_3AF8_
#define g_3AFC g_3AFC_
#define g_3AFE g_3AFE_
#define g_videoMode g_3B4E_
#define g_3B50 g_3B50_
#define g_3B54 g_3B54_
#define g_3B56 g_3B56_
#define g_3B58 g_3B58_
#define g_3B6C g_3B6C_

extern int g_3868;
extern int slot_x[8];
extern int slot_y[8];
extern int g_group;
extern int slot_frame[5];
extern int g_3896;
extern char g_3898[4];
extern int g_389C;
extern int slot_shown[8];
extern int g_38AE;
extern int g_38B0;
extern int g_38B2;
extern char far *g_packBuf;
extern int g_38B8;
extern char far *slot_pc[5];
extern char far *g_38CE;
extern char far *g_38D2;
extern char far *g_38D6;
extern int g_38DA;
extern int g_38DC;
extern int g_38DE;
extern int g_38E0;
extern char g_38E2[40];
extern int slot_delay[5];
extern int g_3914;
extern char g_3916[4];
extern int g_391A;
extern int slot_w[8];
extern int slot_timer[5];
extern int g_3936;
extern char g_3938[4];
extern char far *g_workBuf;
extern int g_letterDone[26];
extern int slot_flag[8];
extern char far *g_sprites[70];
extern char g_3A9C[2];
extern int slot_h[8];
extern int g_letterScore[26];
extern int g_3AE2;
extern int g_3AE4;
extern int g_3AE6;
extern char g_3AE8[8];
extern int g_3AF0;
extern char far *g_backBuf;
extern int g_3AF6;
extern char far *g_videoMem;
extern int g_3AFC;
extern char g_3AFE[80];
extern int g_videoMode;
extern char far *g_3B50;
extern int g_3B54;
extern int g_3B56;
extern int g_3B58[10];
extern int g_3B6C;

extern int g_videoMode;      /* DGROUP:3B4E, 2 = EGA path (TBD) */

void far blit_generic(int x, int y, int w, int h8, char far *src);                   /* 0000:28B3 asm */


extern int slot_x[8];     /* DGROUP:386A */
extern int slot_y[8];     /* DGROUP:387A */
extern int slot_shown[8];     /* DGROUP:389E, -1 = unused slot */
extern int slot_w[8];     /* DGROUP:391C */
extern int slot_h[8];     /* DGROUP:3A9E */

void far draw_item(int p, int x, int y, int a, int b);          /* 0304:0221 */

/* placeholder globals, named by DGROUP offset */
extern char g_1460;
extern char far *g_tunes[];  /* tune table (sound.c) */
extern int win_x, win_y, win_w, win_h;
extern void (far *g_1F2E)(void);
extern void (far *g_1F32)(void);
extern int g_382D;
extern int g_3AF6, g_3AFC;
extern char far *g_3B50;
extern int g_3B58[];
extern char far *g_1F02;
extern int g_1EE2, g_1EE4, g_1EE6;
extern int g_group;
extern char g_0094[], g_009E[], g_00A9[], g_00B5[], g_014F, g_0150, g_0152[];
extern int g_0162[], g_016E[], g_017A[];
extern long g_25FB;
extern int g_38B2, g_38DA, g_38DE, g_38E0, g_145E, g_letterDone[];
extern char g_0210, g_0211, g_020C;
struct name_entry { char far *name; long size; char far *data; int value; long pos; };
extern struct name_entry g_cmpFiles[];
extern int g_173C[];
extern char far *g_palettes[];
extern int g_1E86, g_3AE4;
/* text window in 8x8 cells (set_window copies x,y,w,h to win_*; e,f,g take the current colours) */
struct window { int x, y, w, h, e, f, g, u; };
extern struct window g_windows[];
extern int g_1ED6, g_1EE0, g_1EE8;
extern char far *g_sprites[];

extern int g_23B2, g_23B4, g_23B6, g_23B8, clip_x1, clip_x2, clip_y1, clip_y2;
extern int g_3AE6;
extern char far *g_1F06;
extern int g_391A, g_1F3E, g_3B6C, g_1F38, g_biosVideoMode[];
extern char far *g_videoMem;
extern char far *g_1F0A, far *g_1F16;
extern char far *g_145A, far *g_1452, far *g_1332, far *g_13EA, far *g_1336;
extern char far *g_38D2, far *g_38D6, far *g_38CE;
extern char g_021D, g_021E;
extern int g_38B8, slot_delay[], g_3896, g_3914, g_3936;
extern char far *g_1F22;
extern int slot_frame[], slot_timer[];
extern char g_1493[];
extern char g_14AD[];
extern char far *slot_pc[];
extern int g_1ECE;
extern char far *g_1F1A;
extern int g_389C, g_3868, g_38B0, g_38AE, g_38DC;
extern int g_3AF0;
extern char far *g_backBuf;
extern char far *g_packBuf;
extern char far *g_workBuf;
extern char far *g_1F3A;
extern char far *g_1F1E;
extern int g_1E88[];
extern int g_1E98[];
extern int g_groupFirst[], g_146D[], g_letterScore[];

void far quit(int code);
extern char g_0186[], g_0196[], g_01A6[];
extern int slot_flag[], g_3AE2, slot_delay[], g_1479[], g_1461[];
extern char far *g_13E2, far *g_13E6, far *g_scriptTable[];
extern int g_3B54, g_3B56, g_1F36;
extern char far *g_1EF2, far *g_1EF6, far *g_1EFA, far *g_1EFE;
void far print_word(char far *s, int nl);

#endif
