/* Module 062D: sprite grabbing (compiled with -ml). */
#include "donald.h"

char far *xalloc();
char far *grab_vga();

/* FUNCTION: DONALD 062D:0005 */
char far *grab(int x, register int y, int w, register int h)
{
    int stride;
    int n2;
    unsigned size;
    char far *res;

    if (g_videoMode != 3) {
        size = (w * h) << 2;
        if (g_videoMode != 2) {
            res = xalloc((long)(size + 4));
            if (res) {
                res[1] = h - 1;
                res[2] = w;
                x <<= 2;
                y *= 160;
                w <<= 1;
                stride = 160;
                fn_0000_0D56(g_3AF2 + y + x, res + 4, w, h, stride - w * 2);
                if (g_videoMode == 0)
                    fn_0000_0D56(g_3AF2 + y + x + 1, res + (size >> 1) + 4, w, h, stride - w * 2);
            }
        } else {
            x <<= 2;
            y *= 160;
            n2 = fn_0000_0D56(g_3AF2 + y + x, g_38B4, w, h, 160 - w * 4);
            res = xalloc((long)(n2 + 4));
            res[1] = h - 1;
            res[2] = w;
            fn_0000_0A2E(g_38B4, res + 4, (long)n2);
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
    dst = g_38B4;
    dst[1] = h - 1;
    dst[2] = w;
    dst += 4;
    p = g_3AF2;
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
        fn_0000_0A2E(g_38B4, row, size);
    return row;
}
