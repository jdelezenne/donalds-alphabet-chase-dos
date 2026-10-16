/* Module 062D: sprite grabbing (compiled with -ml). */
#include "donald.h"


/* FUNCTION: DONALD 062D:0005 */
char far *grab(int x, register int y, int w, register int h)
{
    int stride;
    int n2;
    unsigned size;
    char far *res;

    if (g_videoMode != VM_MODE3) {
        size = (w * h) << 2;
        if (g_videoMode != VM_EGA) {
            res = xalloc((long)(size + SPR_HDR));
            if (res) {
                res[SPR_HM1] = h - 1;
                res[SPR_W] = w;
                x <<= 2;
                y *= 160;
                w <<= 1;
                stride = 160;
                pack_rect(g_backBuf + y + x, res + SPR_HDR, w, h, stride - w * 2);
                if (g_videoMode == VM_CGA)
                    pack_rect(g_backBuf + y + x + 1, res + (size >> 1) + SPR_HDR, w, h, stride - w * 2);
            }
        } else {
            x <<= 2;
            y *= 160;
            n2 = pack_rect(g_backBuf + y + x, g_packBuf, w, h, 160 - w * 4);
            res = xalloc((long)(n2 + SPR_HDR));
            res[SPR_HM1] = h - 1;
            res[SPR_W] = w;
            far_copy(g_packBuf, res + SPR_HDR, (long)n2);
        }
    } else
        res = grab_vga(x, y, w, h);
    return res;
}

/* FUNCTION: DONALD 062D:01A6 */
char far *grab_vga(int x, int y, int w, int h)
{
    register int n;
    char far *p;
    char far *dst;
    char far *row;
    int run;
    long size;

    size = 4;
    dst = g_packBuf;
    dst[SPR_HM1] = h - 1;
    dst[SPR_W] = w;
    dst += SPR_HDR;
    p = g_backBuf;
    p += y * 320 + x;
    row = p;
    while (h--) {
        n = w << 3;
        while (n) {
            if (*p) {
                *dst++ = *p++;
                size++;
                n--;
            } else {
                *dst++ = 0;
                size++;
                for (run = 1; run < 255 && n - run > 0; run++)
                    if (p[run])
                        break;
                p += run;
                *dst++ = run;
                size++;
                n -= run;
            }
        }
        row += 320;
        p = row;
    }
    row = xalloc(size);
    if (row)
        far_copy(g_packBuf, row, size);
    return row;
}
