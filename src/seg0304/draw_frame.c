#include "donald.h"

/* FUNCTION: DONALD 0304:03FC */
void draw_frame(int mode, register int i, register int x, int y)
{
    char far *p;

    p = g_3AF2;
    if (g_3B4E == 2)
        p = (char far *)0xA8000000L;
    g_1ABA = 0;
    g_1ABE = 40;
    g_1ABC = 0;
    g_1AC0 = 25;
    switch (mode) {
    case 0:
        draw_sprite(g_3AF8, g_3984[i], x, y, 0);
        break;
    case 1:
        draw_sprite(p, g_3984[i], x, y, 1);
        break;
    case 2:
        fn_06D3_000C(p, g_3984[i], x, y, 1);
        break;
    case 3:
        fn_06D3_000C(g_3AF8, g_3984[i], x, y, 1);
        break;
    }
}
