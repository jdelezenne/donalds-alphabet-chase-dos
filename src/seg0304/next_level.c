#include "donald.h"

/* FUNCTION: DONALD 0304:04F9 */
void next_level(void)
{
    char i, sum;

    for (i = sum = 0; i < 26; i++)
        sum += g_3AAE[i];
    if (sum < 26) {
        do {
            g_388A++;
            if (g_388A >= 6)
                g_388A = 0;
            sum = 0;
            for (i = g_1485[g_388A]; i < g_1485[g_388A + 1]; i++)
                sum += g_3AAE[i];
        } while (sum == g_146D[g_388A]);
        i = 0;
        if (key_ready())
            i = fn_0304_1061();
        if (i == 0 || i == 27) {
            fn_0304_0A4E();
            reset_actors();
        }
    } else
        g_391A = 1;
}
