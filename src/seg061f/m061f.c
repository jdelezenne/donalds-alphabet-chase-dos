#include "donald.h"

/* FUNCTION: DONALD 061F:0007 */
void calibrate(void)
{
    register int count;
    register int d;
    unsigned long far *ticks;
    unsigned long t;
    int b, a, i;

    ticks = (unsigned long far *)0x0000046CL;
    count = 0;
    g_382D = count;
    fn_0000_0FF0();
    t = *ticks;
    fn_0000_0FEE();
    while (*ticks == t)
        ;
    fn_0000_0FF0();
    t = *ticks + 4;
    fn_0000_0FEE();
    while (*ticks < t) {
        count++;
        for (d = 200; d; d--)
            ;
    }
    g_3AE6 = count - 400;
    if (g_3AE6 < 0)
        g_3AE6 = 0;
    b = a = 0;
    for (i = 0; i < 10000; i++)
        if (fn_0000_253B())
            a++;
        else
            b++;
    if (a > b)
        g_382D = 1;
}
