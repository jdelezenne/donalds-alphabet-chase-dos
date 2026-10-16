#include "donald.h"

/* FUNCTION: DONALD 0304:08B1 */
void setup_level(int lv)
{
    char i;

    for (i = 0; i < 8; i++)
        g_392C[i] = 0;
    for (i = 0; i < 5; i++) {
        g_38BA[i] = g_145A;
        g_3A9E[i] = 3;
    }
    g_3A9E[5] = 3;
    g_3A9E[6] = 3;
    g_021D = g_021E = g_1493[lv];
    g_38D2 = g_1452;
    init_slots();
}
