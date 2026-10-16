#include "donald.h"

/* FUNCTION: DONALD 0304:1ABA */
void init_slots(void)
{
    register int i;

    for (i = 0; i < g_146D[g_388A]; i++)
        if (g_3AAE[g_1485[g_388A] + i]) {
            g_386A[i] = (i * 4 + 1) * 8;
            g_387A[i] = 0;
            g_388C[i] = g_1493[g_1485[g_388A] + i];
            g_38BA[i] = g_14AD;
            g_392C[i] = 0;
        }
}
