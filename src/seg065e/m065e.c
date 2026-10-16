#include "donald.h"

/* FUNCTION: DONALD 065E:0008 */
void set_window(register int n)
{
    if (g_1EE8) {
        g_windows[g_1ED6].e = g_1EE0;
        g_windows[g_1ED6].f = g_1EE2;
        g_windows[g_1ED6].g = g_1EE4;
        g_windows[g_1ED6].u = g_1EE6;
    } else
        g_1EE8 = 1;
    g_1ED6 = n;
    win_x = g_windows[n].x;
    win_y = g_windows[n].y;
    win_w = g_windows[n].w;
    win_h = g_windows[n].h;
    g_1EE0 = g_windows[n].e;
    g_1EE2 = g_windows[n].f;
    g_1EE4 = g_windows[n].g;
    g_1EE6 = g_windows[n].u;
}
