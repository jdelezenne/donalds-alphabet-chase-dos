/* 0304:000C */
#include "donald.h"

void blit_dispatch(char far *src, register int x, register int y, int w, int h)
{
    if (g_videoMode != 2)
        blit_generic(x, y, w, h >> 3, src);
    else
        blit_ega(x, y, x, y, w, h >> 3, (char far *)0xA8000000L, (char far *)0xA0000000L);
}
