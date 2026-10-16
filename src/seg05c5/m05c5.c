#include "donald.h"

/* FUNCTION: DONALD 05C5:0008 */
void blit_ega(register int x, register int y, int sx, int sy, int w, int h, char far *p1, char far *p2)
{
    if (w > 40)
        w = 40;
    if (h > 25)
        h = 25;
    if (x < 0) {
        sx -= x;
        w += x;
        x = 0;
    }
    if (sx < 0) {
        x -= sx;
        w += sx;
        sx = 0;
    }
    if (y < 0) {
        sy -= y;
        h += y;
        y = 0;
    }
    if (sy < 0) {
        y -= sy;
        h += sy;
        sy = 0;
    }
    if (g_videoMode != VM_EGA)
        blit_ega_core(x, y, sx, sy, w, h, p1, p2);
    else {
        if (p1 == g_backBuf)
            p1 = (char far *)0xA2000000L;
        if (p2 == g_backBuf)
            p2 = (char far *)0xA2000000L;
        blit_ega_core(x, y, sx, sy, w, h, p1, p2);
    }
}
