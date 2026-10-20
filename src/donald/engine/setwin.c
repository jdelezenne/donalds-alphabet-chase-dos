#include "donald.h"

/* FUNCTION: DONALD 065E:0008 */
void set_window(register int n)
{
    if (g_windowSet) {
        g_windows[g_curWindow].fg = g_win.fg;
        g_windows[g_curWindow].bg = g_win.bg;
        g_windows[g_curWindow].col = g_win.col;
        g_windows[g_curWindow].row = g_win.row;
    } else
        g_windowSet = 1;
    g_curWindow = n;
    g_win.x = g_windows[n].x;
    g_win.y = g_windows[n].y;
    g_win.w = g_windows[n].w;
    g_win.h = g_windows[n].h;
    g_win.fg = g_windows[n].fg;
    g_win.bg = g_windows[n].bg;
    g_win.col = g_windows[n].col;
    g_win.row = g_windows[n].row;
}
