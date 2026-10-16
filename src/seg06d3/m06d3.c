#include "donald.h"


/* FUNCTION: DONALD 06D3:000C */
void draw_sprite_masked(char far *dst, char far *src, register int x, register int y, int idx)
{
    g_2608 = g_23B2 = g_1AAA[idx].a;
    x += g_2608 * 8;
    g_260A = g_23B4 = g_1AAA[idx].c + g_2608;
    g_260C = g_23B6 = g_1AAA[idx].b * 8;
    y += g_260C;
    g_260E = g_23B8 = g_1AAA[idx].d * 8 + g_260C;
    if (g_3B4E != 2) {
        if (g_3B4E == 3)
            fn_0000_2BE0(dst, src, x, y);
        else
            fn_0000_1D16(dst, src, x, y);
    } else {
        if (dst == g_3AF2)
            dst = (char far *)0xA2000000L;
        fn_0000_11DC(dst, src, x, y);
    }
}
