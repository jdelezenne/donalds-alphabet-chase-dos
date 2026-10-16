/* FUNCTION: DONALD 0304:0187 */
#include "donald.h"

void draw_items(int p)
{
    register int i;
    register int d;
    int a, b;

    for (i = 0; i < 8; i++) {
        a = 1;
        b = 8;
        d = 2;
        if (g_arr3A9E[i] != 3 && g_arr3A9E[i] != 8) {
            a = d;
            b = 16;
            d = 4;
        }
        if (g_arr389E[i] != -1)
            draw_item(p, (g_arr386A[i] >> 3) - a, g_arr387A[i] - b, g_arr391C[i] + d, (g_arr3A9E[i] + d) << 3);
    }
}
