#include "donald.h"

/* FUNCTION: DONALD 05D4:0002 */
void repeat_call(int n)
{
    while (n--)
        wait_vretrace(g_382D);
}
