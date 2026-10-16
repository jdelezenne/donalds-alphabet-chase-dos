#include "donald.h"

/* FUNCTION: DONALD 0304:093C */
void show_picture(register int n)
{
    char c;

    load_file(g_1772[n].name, g_393C);
    if (g_173C[n]) {
        c = 0;
        if (g_3B4E == 0) {
            fn_0000_0FF2(g_16D0[n]);
            c = g_3B4E = 1;
            fn_0000_14C7(g_3B4E);
        }
        draw_pic(g_393C, g_3AF2);
        if (c) {
            g_3B4E = 0;
            fn_0000_14C7(0);
            fn_0000_10D2(g_3AF2, 0);
        }
    } else {
        if (g_3B4E == 0)
            fn_0000_0FF2(g_16D0[n]);
        draw_pic(g_393C, g_3AF2);
        if (g_3B4E == 2)
            fn_0000_0A6B(g_3AF2, 0xA800);
    }
    if (g_3B4E == 0)
        fn_0000_1478(1);
}
