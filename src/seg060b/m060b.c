#include "donald.h"

/* FUNCTION: DONALD 060B:000F */
void set_palette(char far *pal)
{
    register int i;
    register int v;

    wait_vretrace(g_382D);
    if (g_videoMode == 1)
        set_palette_regs(pal);
    else if (g_videoMode == 2) {
        for (i = 0; i < 16; i++) {
            v = pal[i];
            if (v > 7)
                v += 8;
            set_palette_reg(i, v);
        }
    } else if (g_videoMode == 3)
        set_dac_regs(pal);
}
