#include "donald.h"

/* FUNCTION: DONALD 0304:0776 */
void aim(int i)
{
    register int d;
    register int target;
    int x, y, t;

    target = *g_38BA[i];
    x = g_386A[i] >> 3;
    y = g_387A[i] >> 3;
    if (x >= target) {
        d = x - target;
        g_3868 = 0;
    } else {
        d = target - x;
        g_3868 = 1;
    }
    t = y;
    if (d >= t) {
        g_38AE = d;
        g_38B0 = t;
        g_389C = 1;
    } else {
        g_38AE = t;
        g_38B0 = d;
        g_389C = 0;
    }
    g_38DC = g_38AE >> 1;
    g_38B8 = g_38AE;
}
