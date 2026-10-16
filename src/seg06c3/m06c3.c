#include "donald.h"


/* FUNCTION: DONALD 06C3:000F */
void draw_sprite(char far *dst, char far *src, register int x, register int y, int idx)
{
    clip_x1 = g_23B2 = g_windows[idx].x;
    x += clip_x1 * 8;
    clip_x2 = g_23B4 = g_windows[idx].w + clip_x1;
    clip_y1 = g_23B6 = g_windows[idx].y * 8;
    y += clip_y1;
    clip_y2 = g_23B8 = g_windows[idx].h * 8 + clip_y1;
    if (g_videoMode != 2) {
        if (g_videoMode == 3)
            sprite_put_m3(dst, src, x, y);
        else
            sprite_put_cga(dst, src, x, y);
    } else {
        if (dst == g_backBuf)
            dst = (char far *)0xA2000000L;
        sprite_put_ega(dst, src, x, y);
    }
}
