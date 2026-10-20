#include "donald.h"

/* FUNCTION: DONALD 0604:0001 */
void draw_pic(char far *p, char far *dst)
{
    register int n;

    if (*p++ == 1)
        cmp_unpack_planar(p, dst);
    else
        cmp_unpack_cga(p, dst);
    if (g_videoMode == VM_CGA) {
        n = 80;
        if (g_cgaSmallWin)
            n = 4;
        cga_convert(dst, dst, n, 16000);
        if (g_cgaSmallWin)
            cga_shift_rows(dst);
    }
}
