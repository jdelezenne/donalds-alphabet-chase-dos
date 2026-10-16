#include "donald.h"

/* FUNCTION: DONALD 065E:0008 */
void set_window(register int n)
{
    if (g_1EE8) {
        g_1AAA[g_1ED6].e = g_1EE0;
        g_1AAA[g_1ED6].f = g_1EE2;
        g_1AAA[g_1ED6].g = g_1EE4;
        g_1AAA[g_1ED6].h = g_1EE6;
    } else
        g_1EE8 = 1;
    g_1ED6 = n;
    g_1ED8 = g_1AAA[n].a;
    g_1EDA = g_1AAA[n].b;
    g_1EDC = g_1AAA[n].c;
    g_1EDE = g_1AAA[n].d;
    g_1EE0 = g_1AAA[n].e;
    g_1EE2 = g_1AAA[n].f;
    g_1EE4 = g_1AAA[n].g;
    g_1EE6 = g_1AAA[n].h;
}
