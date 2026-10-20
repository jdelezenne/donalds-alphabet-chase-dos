#include "donald.h"

/* Module data: DGROUP 1E86. */
int g_textCols = 40;

/* Uninitialised data (_BSS): DGROUP 3AE4-3AE5 (ownership inferred, see docs/MATCHING.md). */
int g_textWraps;

/* FUNCTION: DONALD 05D5:000D */
void print_text(char far *s, register int col, int y, int fg, int bg)
{
    register int off;
    char far *p;
    int ch;
    unsigned cur;
    int x0;

    set_text_colours(fg, bg);
    p = s;
    off = y * 320;
    if (g_videoMode == VM_MODE3)
        off = y * 0xa00;
    x0 = col;
    while (*p) {
        if (*p == '\r') {
            col = x0;
            off += 320;
            if (g_videoMode == VM_MODE3)
                off += 0x8c0;
            p++;
        } else {
            ch = (*p & 0x7f) << 3;
            p++;
            if (col > g_textCols - 1) {
                col = x0;
                g_textWraps++;
                off += 320;
                if (g_videoMode == VM_MODE3)
                    off += 0x8c0;
            }
            cur = col++;
            if (g_videoMode == VM_CGA)
                draw_char_cga2bpp(ch << 1, off, cur << 1);
            else if (g_videoMode == VM_TANDY)
                draw_char_tandy4bpp(ch << 2, off, cur << 2);
            else if (g_videoMode == VM_EGA)
                draw_char_ega(ch, off, cur);
            else
                draw_char_vga8bpp(ch, off, cur << 3);
        }
    }
}
