#include "donald.h"

void far about();
char far *xalloc();
void init_game(void);
void shutdown(void);

/* FUNCTION: DONALD 04FC:0009 */
main(int argc, char far **argv)
{
    g_videoMode = -1;
    if (argc < 2)
        fn_0512_0102(-1);
    else {
        fn_0512_0102((int)atol(argv[1]));
        if (argc >= 3)
            fn_0000_14C7(g_videoMode = (int)atol(argv[2]));
    }
    g_1F3E = 1;
    g_1F2E = about;
    g_3B6C = 1;
    fn_056A_029A();
    if (g_videoMode == -1)
        detect_video();
    fn_0000_14DD(g_1ADA[g_videoMode]);
    g_3AF8 = (char far *)0xB8000000L;
    if (g_videoMode == 2)
        g_3AF8 = (char far *)0xA0000000L;
    g_1F38 = 0x39;
    if (g_videoMode == 1)
        g_1F38 += 0x10;
    init_game();
    game();
    free_all();
    shutdown();
}

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
    exit(g_videoMode);
}
