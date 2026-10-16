#include "donald.h"

void far about();
char far *xalloc();
void init_game(void);
void shutdown(void);

/* Module data: DGROUP 1AAA-1ADF (text windows for set_window; BIOS video mode per g_videoMode). */
struct sprite_rect g_1AAA[] = {{0, 0, 40, 25, 15, 0, 0, 0}, {0, 8, 30, 10, 15, 0, 0, 0}, {5, 10, 30, 4, 15, 0, 0, 0}};
int g_biosVideoMode[] = {4, 9, 13};

/* FUNCTION: DONALD 04FC:0009 */
main(int argc, char far **argv)
{
#ifdef DONALD_ALT
    /* alternate build (game/DONALD): no command-line parameters, video always auto-detected */
    if (argc < 2)
        fn_0512_0102(-1);
    else
        fn_0512_0102(60);
    g_1F3E = 1;
    g_1F2E = about;
    g_3B6C = 1;
    fn_056A_029A();
    detect_video();
#else
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
#endif
    fn_0000_14DD(g_biosVideoMode[g_videoMode]);
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
#ifndef DONALD_ALT
    exit(g_videoMode);
#endif
}
