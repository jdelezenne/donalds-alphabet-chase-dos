#include "donald.h"

/* FUNCTION: DONALD 05E7:000A */
void fill_rect(register int x1, register int y, int x2, int y2, int c)
{
    if ((x1 & 1) || !(x2 & 1) || g_videoMode != VM_TANDY) {
        while (y2 >= y)
            hline(y++, x1, x2, c);
    } else
        gfx_fill_rect(x1, y, ((x2 - x1) >> 1) + 1, y2 - y, c);
}
