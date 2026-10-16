#include "donald.h"

char far *fn_0612_0009();

/* FUNCTION: DONALD 04FC:00DF */
void init_game(void)
{
    fn_0512_0354();
    g_3AF0 = 1;
    g_3AFC = 0;
    install_harderr();
    fn_0000_2470();
    fn_061F_0007();
    g_3AF2 = fn_0612_0009(0x8000L);
    g_393C = g_38B4 = fn_0612_0009(0x8000L);
    g_1F3A = g_3AF2;
    fn_06F0_0A23();
}
