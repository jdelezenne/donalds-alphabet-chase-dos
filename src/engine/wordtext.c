/* Module 06AD: text output into the current window (compiled with -ml). */
#include "donald.h"

/* FUNCTION: DONALD 06AD:0002 */
void print_word(char far *s, int nl)
{
    register int i;
    register int n;

    if (g_win.row >= g_win.h) {
        n = i = strlen(s);
        for (; i < g_win.w; i++)
            s[i] = ' ';
        s[g_win.w] = 0;
        blit_ega(g_win.x, g_win.y + 1, g_win.x, g_win.y, g_win.w, g_win.h - 1, g_videoMem, g_videoMem);
        fill_rect(g_win.x << 3, (g_win.y + g_win.h - 1) << 3, (g_win.x + g_win.w - 1) << 3,
                  ((g_win.y + g_win.h) << 3) - 1, 0);
        print_text(s, g_win.x, g_win.y + g_win.h - 1, g_win.fg, g_win.bg);
        if (nl) {
            g_win.col = 0;
            g_win.row++;
        } else {
            g_win.col += n;
            g_win.row = g_win.h - 1;
            if (g_win.col >= g_win.w) {
                g_win.col = 0;
                g_win.row++;
            }
        }
    } else {
        print_text(s, g_win.col + g_win.x, g_win.row + g_win.y, g_win.fg, g_win.bg);
        if (nl) {
            g_win.col = 0;
            g_win.row++;
        } else {
            g_win.col += strlen(s);
            if (g_win.col >= g_win.w) {
                g_win.col = 0;
                g_win.row++;
            }
        }
    }
    *s = 0;
}
