/* Module 05ED: clipped lines / rectangles. */
#include "donald.h"

/* FUNCTION: DONALD 05ED:0007 */
void hline(register int y, register int x, int x2, int c)
{
    int n;
    int mask;

    mask = g_1E88[g_3B4E];
    while ((mask & x) != 0 && x <= x2)
        fn_0000_2584(x++, y, y, c);
    if (x < x2) {
        n = x2 - x;
        if (g_3B4E != 3)
            n >>= g_1E98[g_3B4E];
        if (n)
            fn_0000_0217(x, y, n, c);
        x = g_1E88[g_3B4E + 4] & x2;
    }
    while (x <= x2)
        fn_0000_2584(x++, y, y, c);
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
        fn_0000_2584(x1, y1, y2, c);
    else if (y1 == y2)
        hline(y1, x1, x2, c);
}

/* FUNCTION: DONALD 05ED:0157 */
void plot(int x, int y, int c)
{
    draw_line(x, y, x, y, c);
}
