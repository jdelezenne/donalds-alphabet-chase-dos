#include "donald.h"

/* FUNCTION: DONALD 05D5:000D */
void print_text(char far *s, register int col, int y, int fg, int bg)
{
    register int off;
    char far *p;
    int ch;
    unsigned cur;
    int x0;

    fn_0000_2298(fg, bg);
    p = s;
    off = y * 320;
    if (g_videoMode == 3)
        off = y * 0xa00;
    x0 = col;
    while (*p) {
        if (*p == '\r') {
            col = x0;
            off += 320;
            if (g_videoMode == 3)
                off += 0x8c0;
            p++;
        } else {
            ch = (*p & 0x7f) << 3;
            p++;
            if (col > g_1E86 - 1) {
                col = x0;
                g_3AE4++;
                off += 320;
                if (g_videoMode == 3)
                    off += 0x8c0;
            }
            cur = col++;
            if (g_videoMode == 0)
                fn_0000_237A(ch << 1, off, cur << 1);
            else if (g_videoMode == 1)
                fn_0000_2319(ch << 2, off, cur << 2);
            else if (g_videoMode == 2)
                fn_0000_23C2(ch, off, cur);
            else
                fn_0000_241D(ch, off, cur << 3);
        }
    }
}
