/* Module 05ED: clipped lines / rectangles. */
#include "donald.h"

/* Module data: DGROUP 1E88-1EA1. */
int hline_masks[] = {3, 1, 7, 0, 508, 510, 504, 511};
int hline_shift[] = {2, 1, 3, 0, 0};

/* FUNCTION: DONALD 05ED:0007 */
void hline(register int y, register int x, int x2, int c)
{
    int n;
    int mask;

    mask = hline_masks[g_videoMode];
    while ((x & mask) && x <= x2)
        vline(x++, y, y, c);
    if (x < x2) {
        n = x2 - x;
        if (g_videoMode != VM_MODE3)
            n >>= hline_shift[g_videoMode];
        if (n)
            hspan(x, y, n, c);
        x = hline_masks[g_videoMode + 4] & x2;
    }
    while (x <= x2)
        vline(x++, y, y, c);
}

/* FUNCTION: DONALD 05ED:00A6 */
void draw_line(register int x1, register int y1, int x2, int y2, int c)
{
    int t;

    if (x2 < x1) { t = x1; x1 = x2; x2 = t; }
    if (y2 < y1) { t = y1; y1 = y2; y2 = t; }
    if (x1 < 0) x1 = 0;
    if (y1 < 0) y1 = 0;
    if (x2 < 0) x2 = 0;
    if (y2 < 0) y2 = 0;
    if (x1 > 319) x1 = 319;
    if (x2 > 319) x2 = 319;
    if (y1 > 199) y1 = 199;
    if (y2 > 199) y2 = 199;
    if (x1 == x2)
        vline(x1, y1, y2, c);
    else if (y1 == y2)
        hline(y1, x1, x2, c);
}

/* FUNCTION: DONALD 05ED:0157 */
void plot(int x, int y, int c)
{
    draw_line(x, y, x, y, c);
}
