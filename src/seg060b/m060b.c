#include "donald.h"

/* FUNCTION: DONALD 060B:000F */
void set_palette(char far *pal)
{
    register int i;
    register int v;

    fn_0000_2553(g_382D);
    if (g_3B4E == 1)
        fn_0000_24FB(pal);
    else if (g_3B4E == 2) {
        for (i = 0; i < 16; i++) {
            v = pal[i];
            if (v > 7)
                v += 8;
            fn_0000_1491(i, v);
        }
    } else if (g_3B4E == 3)
        fn_0000_271E(pal);
}
