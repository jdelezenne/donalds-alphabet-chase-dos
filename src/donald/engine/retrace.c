#include "donald.h"

/* FUNCTION: DONALD 05D4:0002 */
void wait_frame_intervals(int n)
{
    while (n--)
        wait_vretrace(g_retraceWait);
}
