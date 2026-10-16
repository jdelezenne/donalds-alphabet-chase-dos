#include "donald.h"

/* FUNCTION: DONALD 0304:080E */
void reset_actors(void)
{
    register int i;

    for (i = 0; i < 8; i++) {
        g_391C[i] = g_3A9E[i] = 3;
        g_38BA[i] = g_1332;
        g_386A[i] = -160;
        g_387A[i] = 0;
        g_392C[i] = g_390A[i] = 10;
        g_388C[i] = -1;
    }
    g_392A = g_3AAC = 8;
    g_38D6 = g_13EA;
    g_38CE = g_1336;
    g_3874 = 0x128;
    g_3884 = g_3896 = 0;
    g_3936 = g_3914 = 20;
    init_slots();
}
