#include "donald.h"


/* FUNCTION: DONALD 06C3:000F */
void draw_sprite(char far *dst, char far *src, register int x, register int y, int idx)
{
    g_2608 = g_23B2 = g_1AAA[idx].a;
    x += g_2608 * 8;
    g_260A = g_23B4 = g_1AAA[idx].c + g_2608;
    g_260C = g_23B6 = g_1AAA[idx].b * 8;
    y += g_260C;
    g_260E = g_23B8 = g_1AAA[idx].d * 8 + g_260C;
    if (g_videoMode != 2) {
        if (g_videoMode == 3)
            fn_0000_2A15(dst, src, x, y);
        else
            fn_0000_16FA(dst, src, x, y);
    } else {
        if (dst == g_3AF2)
            dst = (char far *)0xA2000000L;
        fn_0000_0B2E(dst, src, x, y);
    }
}
