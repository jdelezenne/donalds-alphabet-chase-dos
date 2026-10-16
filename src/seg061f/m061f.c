#include "donald.h"

/* Uninitialised data (_BSS): DGROUP 3AE6-3AEF (ownership inferred, see docs/MATCHING.md). */
int g_calibSlack;
char unused_3AE8[8];

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
    g_retraceWait = count;
    disable_ints();
    t = *ticks;
    enable_ints();
    while (*ticks == t)
        ;
    disable_ints();
    t = *ticks + 4;
    enable_ints();
    while (*ticks < t) {
        count++;
        for (d = 200; d; d--)
            ;
    }
    g_calibSlack = count - 400;
    if (g_calibSlack < 0)
        g_calibSlack = 0;
    b = a = 0;
    for (i = 0; i < 10000; i++)
        if (in_vretrace())
            a++;
        else
            b++;
    if (a > b)
        g_retraceWait = 1;
}
