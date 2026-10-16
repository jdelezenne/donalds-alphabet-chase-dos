#include "donald.h"

char far *xalloc();

/* FUNCTION: DONALD 04FC:00DF */
void init_game(void)
{
    fn_0512_0354();
    g_3AF0 = 1;
    g_3AFC = 0;
    install_harderr();
    fn_0000_2470();
    calibrate();
    g_3AF2 = xalloc(0x8000L);
    g_393C = g_38B4 = xalloc(0x8000L);
    g_1F3A = g_3AF2;
    load_resources();
}

/* FUNCTION: DONALD 04FC:0142 */
void shutdown(void)
{
    fn_0000_14DD(2);
    fn_0512_0398();
    fn_056A_0562();
    exit(g_3B4E);
}
