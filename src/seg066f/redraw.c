#include "donald.h"

/* FUNCTION: DONALD 066F:0008 */
void redraw_rect(void)
{
    redraw_rect_hw(g_win.x, g_win.y, g_win.w, g_win.h, g_win.bg);
    g_win.col = g_win.row = 0;
}
