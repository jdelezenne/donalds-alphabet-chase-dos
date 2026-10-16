#include "donald.h"

/* FUNCTION: DONALD 065B:000C */
void music_toggle(int x)
{
    if (!g_3AFC) {
        fn_0000_1461(0);
        if (g_3AF6 && x > 0)
            fn_0000_1461(1);
    }
}
