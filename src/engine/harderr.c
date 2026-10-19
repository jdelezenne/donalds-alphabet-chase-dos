#include <dos.h>

/* FUNCTION: DONALD 06E3:0009 */
int harderr_handler(int errval, int ax, int bp, int si)
{
    hardretn(0);
}

/* FUNCTION: DONALD 06E3:0017 */
void install_harderr(void)
{
    harderr(harderr_handler);
}
