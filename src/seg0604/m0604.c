#include "donald.h"

/* FUNCTION: DONALD 0604:0001 */
void draw_pic(char far *p, char far *dst)
{
    register int n;

    if (*p++ == 1)
        fn_0000_0F2C(p, dst);
    else
        fn_0000_0F83(p, dst);
    if (g_3B4E == 0) {
        n = 80;
        if (g_1ECE)
            n = 4;
        fn_0000_106B(dst, dst, n, 16000);
        if (g_1ECE)
            fn_0000_0D1C(dst);
    }
}
