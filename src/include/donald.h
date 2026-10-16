/* Shared declarations for Donald's Alphabet Chase (Turbo C 2.0, large model). */
#ifndef DONALD_H
#define DONALD_H

extern int g_videoMode;      /* DGROUP:3B4E, 2 = EGA path (TBD) */

void far blit_generic(int x, int y, int w, int h8, char far *src);                   /* 0000:28B3 asm */
void far blit_ega(int x, int y, int x2, int y2, int w, int h8, char far *p1, char far *p0); /* 05C5:0008 */

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

#endif
