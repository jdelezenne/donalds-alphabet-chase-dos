#include "donald.h"

void far about();
char far *xalloc();
void init_game(void);
void shutdown(void);

/* Module data: DGROUP 1AAA-1ADF (text windows for set_window; BIOS video mode per g_videoMode). */
struct window g_windows[] = {{0, 0, 40, 25, 15, 0, 0, 0}, {0, 8, 30, 10, 15, 0, 0, 0}, {5, 10, 30, 4, 15, 0, 0, 0}};
int g_biosVideoMode[] = {4, 9, 13};

/* FUNCTION: DONALD 04FC:0009 */
main(int argc, char far **argv)
{
#ifdef DONALD_ALT
    /* alternate build (game/DONALD): no command-line parameters, video always auto-detected */
    if (argc < 2)
        snd_set_option(-1);
    else
        snd_set_option(60);
    g_errWindow = 1;
    g_errShowHook = about;
    g_errHooked = 1;
    kbd_install();
    detect_video();
#else
    g_videoMode = -1;
    if (argc < 2)
        snd_set_option(-1);
    else {
        snd_set_option((int)atol(argv[1]));
        if (argc >= 3)
            set_video_type(g_videoMode = (int)atol(argv[2]));
    }
    g_errWindow = 1;
    g_errShowHook = about;
    g_errHooked = 1;
    kbd_install();
    if (g_videoMode == -1)
        detect_video();
#endif
    set_bios_mode(g_biosVideoMode[g_videoMode]);
    g_videoMem = (char far *)0xB8000000L;
    if (g_videoMode == 2)
        g_videoMem = (char far *)0xA0000000L;
    g_memReserve = 0x39;
    if (g_videoMode == 1)
        g_memReserve += 0x10;
    init_game();
    game();
    free_all();
    shutdown();
}

/* FUNCTION: DONALD 04FC:00DF */
void init_game(void)
{
    snd_init();
    g_initDone = 1;
    g_noDiskCheck = 0;
    install_harderr();
    gfx_init();
    calibrate();
    g_backBuf = xalloc(0x8000L);
    g_workBuf = g_packBuf = xalloc(0x8000L);
    g_errSaveBuf = g_backBuf;
    load_resources();
}

/* FUNCTION: DONALD 04FC:0142 */
void shutdown(void)
{
    set_bios_mode(2);
    snd_shutdown();
    kbd_remove();
#ifndef DONALD_ALT
    exit(g_videoMode);
#endif
}
