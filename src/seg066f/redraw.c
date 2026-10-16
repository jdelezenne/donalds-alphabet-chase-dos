#include "donald.h"

/* FUNCTION: DONALD 066F:0008 */
void redraw_rect(void)
{
    redraw_rect_hw(win_x, win_y, win_w, win_h, g_textBg);
    g_textCol = g_textRow = 0;
}
