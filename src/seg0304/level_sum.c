#include "donald.h"

/* FUNCTION: DONALD 0304:0737 */
int level_sum(void)
{
    register int sum = 0;
    register int i;

    for (i = g_1485[g_388A]; i < g_1485[g_388A + 1]; i++)
        sum += g_3AAE[i];
    if (g_146D[g_388A] > sum)
        sum = 0;
    return sum;
}
