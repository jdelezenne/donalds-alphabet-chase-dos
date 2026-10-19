/* Layout-sensitive uninitialised storage. Include through donald.h only. */
#ifndef DONALD_BSS_H
#define DONALD_BSS_H

/* These are the first declarations in donald.h, in original address order.
   Turbo C 2.0 emits tentative definitions by walking its symbol hash table:
   buckets in hash order, then each bucket in creation order. All g_XXXX_
   linker names share first character, last character and length, placing
   them in one bucket. Their first-declaration order reproduces the original
   _BSS layout. Keep both these aliases and this declaration order intact.
   Readable source names do not change the link-visible names. */
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
/* Unidentified storage at DGROUP:38E2; no recovered semantic use. */
extern char unused_38E2[40];
extern int slot_delay[8];
extern int g_gameWon;
extern int slot_w[8];
extern int slot_timer[8];
extern char far *g_workBuf;
extern int g_letterDone[26];
extern int slot_flag[8];
extern char far *g_sprites[70];
/* Unidentified storage at DGROUP:3A9C; no recovered semantic use. */
extern char unused_3A9C[2];
extern int slot_h[8];
extern int g_letterScore[26];
extern int g_jumping;
extern int g_textWraps;
extern int g_calibSlack;
/* Unidentified storage at DGROUP:3AE8; no recovered semantic use. */
extern char unused_3AE8[8];
extern int g_initDone;
extern char far *g_backBuf;
extern int g_driveB;
extern char far *g_videoMem;
extern int g_fixedDrive;
/* Unidentified storage at DGROUP:3AFE; no recovered semantic use. */
extern char unused_3AFE[80];
extern int g_videoMode;
extern char far *g_errMsg;
extern int g_diskNum;
extern int g_multiDisk;
extern int g_fileHandles[10];
extern int g_preload;

#endif
