#include "donald.h"


/* FUNCTION: DONALD 06D3:000C */
void draw_sprite_masked(char far *dst, char far *src, register int x, register int y, int idx)
{
    clip_x1 = gfx_clip_x1 = g_windows[idx].x;
    x += clip_x1 * 8;
    clip_x2 = gfx_clip_x2 = g_windows[idx].w + clip_x1;
    clip_y1 = gfx_clip_y1 = g_windows[idx].y * 8;
    y += clip_y1;
    clip_y2 = gfx_clip_y2 = g_windows[idx].h * 8 + clip_y1;
    if (g_videoMode != VM_EGA) {
        if (g_videoMode == VM_MODE3)
            sprite_mask_m3(dst, src, x, y);
        else
            sprite_mask_cga(dst, src, x, y);
    } else {
        if (dst == g_backBuf)
            dst = (char far *)0xA2000000L;
        sprite_mask_ega(dst, src, x, y);
    }
}
