#include "donald.h"

/* FUNCTION: DONALD 0304:0383 */
void step(register int i)
{
    if (g_389C) {
        if (g_3868)
            g_386A[i] += 8;
        else
            g_386A[i] -= 8;
    } else
        g_387A[i] -= 8;
    g_38DC -= g_38B0;
    if (g_38DC < 0) {
        g_38DC += g_38AE;
        if (!g_389C) {
            if (g_3868)
                g_386A[i] += 8;
            else
                g_386A[i] -= 8;
        } else
            g_387A[i] -= 8;
    }
}
