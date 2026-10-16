#include "donald.h"

/* FUNCTION: DONALD 065E:0008 */
void set_window(register int n)
{
    if (g_windowSet) {
        g_windows[g_curWindow].fg = g_textFg;
        g_windows[g_curWindow].bg = g_textBg;
        g_windows[g_curWindow].col = g_textCol;
        g_windows[g_curWindow].row = g_textRow;
    } else
        g_windowSet = 1;
    g_curWindow = n;
    win_x = g_windows[n].x;
    win_y = g_windows[n].y;
    win_w = g_windows[n].w;
    win_h = g_windows[n].h;
    g_textFg = g_windows[n].fg;
    g_textBg = g_windows[n].bg;
    g_textCol = g_windows[n].col;
    g_textRow = g_windows[n].row;
}
