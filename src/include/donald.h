/* Shared declarations for Donald's Alphabet Chase (Turbo C 2.0, large model). */
#ifndef DONALD_H
#define DONALD_H

extern int g_videoMode;      /* DGROUP:3B4E, 2 = EGA path (TBD) */

void far blit_generic(int x, int y, int w, int h8, char far *src);                   /* 0000:28B3 asm */


extern int g_386A[8];     /* DGROUP:386A */
extern int g_387A[8];     /* DGROUP:387A */
extern int g_389E[8];     /* DGROUP:389E, -1 = unused slot */
extern int g_391C[8];     /* DGROUP:391C */
extern int g_3A9E[8];     /* DGROUP:3A9E */

void far draw_item(int p, int x, int y, int a, int b);          /* 0304:0221 */

/* placeholder globals, named by DGROUP offset */
extern char g_1460;
extern long g_1E22[];
extern int g_1ED8, g_1EDA, g_1EDC, g_1EDE;
extern void (far *g_1F2E)(void);
extern void (far *g_1F32)(void);
extern int g_382D;
extern int g_3AF6, g_3AFC;
extern char far *g_3B50;
extern int g_3B58[];
extern char far *g_1F02;
extern int g_1EE2, g_1EE4, g_1EE6;
extern int g_388A;
extern char g_0094[], g_009E[], g_00A9[], g_00B5[], g_014F, g_0150, g_0152[];
extern int g_0162[], g_016E[], g_017A[];
extern long g_25FB;
extern int g_38B2, g_38DA, g_38DE, g_38E0, g_145E, g_3940[];
extern char g_0210, g_0211, g_020C;
extern long g_1E32;
struct name_entry { char far *name; long size; char far *data; int value; long pos; };
extern struct name_entry g_1772[];
extern int g_173C[];
extern char far *g_16D0[];
extern int g_1E86, g_3AE4;
struct sprite_rect { int a, b, c, d, e, f, g, h; };
extern struct sprite_rect g_1AAA[];
extern int g_1ED6, g_1EE0, g_1EE8;
extern char far *g_3984[];
extern int g_1ABA, g_1ABC, g_1ABE, g_1AC0;
extern int g_23B2, g_23B4, g_23B6, g_23B8, g_2608, g_260A, g_260C, g_260E;
extern int g_3AE6;
extern char far *g_1F06;
extern int g_391A, g_1F3E, g_3B6C, g_1F38, g_1ADA[];
extern char far *g_3AF8;
extern char far *g_1F0A, far *g_1F16;
extern char far *g_145A, far *g_1452, far *g_1332, far *g_13EA, far *g_1336;
extern char far *g_38D2, far *g_38D6, far *g_38CE;
extern char g_021D, g_021E;
extern int g_38B8, g_390A[], g_392A, g_3AAC, g_3874, g_3884, g_3896, g_3914, g_3936;
extern char far *g_1F22;
extern int g_388C[], g_392C[];
extern char g_1493[];
extern char g_14AD[];
extern char far *g_38BA[];
extern int g_1ECE;
extern char far *g_1F1A;
extern int g_389C, g_3868, g_38B0, g_38AE, g_38DC;
extern int g_3AF0;
extern char far *g_3AF2;
extern char far *g_38B4;
extern char far *g_393C;
extern char far *g_1F3A;
extern char far *g_1F1E;
extern int g_3B4E;
extern int g_1E88[];
extern int g_1E98[];
extern int g_1485[], g_146D[], g_3AAE[];

void far quit(int code);
extern char g_0186[], g_0196[], g_01A6[];
extern int g_3974[], g_3AE2, g_390A[], g_1479[], g_1461[];
extern char far *g_13E2, far *g_13E6, far *g_1262[];
extern int g_3B54, g_3B56, g_1F36;
extern char far *g_1EF2, far *g_1EF6, far *g_1EFA, far *g_1EFE;
void far print_word(char far *s, int nl);

#endif
