/* Shared declarations for Donald's Alphabet Chase (Turbo C 2.0, large model). */
#ifndef DONALD_H
#define DONALD_H

extern int g_videoMode;      /* DGROUP:3B4E, 2 = EGA path (TBD) */

void far blit_generic(int x, int y, int w, int h8, char far *src);                   /* 0000:28B3 asm */
void far blit_ega(int x, int y, int x2, int y2, int w, int h8, char far *p1, char far *p0); /* 05C5:0008 */

extern int g_arr386A[8];     /* DGROUP:386A */
extern int g_arr387A[8];     /* DGROUP:387A */
extern int g_arr389E[8];     /* DGROUP:389E, -1 = unused slot */
extern int g_arr391C[8];     /* DGROUP:391C */
extern int g_arr3A9E[8];     /* DGROUP:3A9E */

void far draw_item(int p, int x, int y, int a, int b);          /* 0304:0221 */

#endif
