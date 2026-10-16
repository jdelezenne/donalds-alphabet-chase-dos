#include "donald.h"

void far about();

/* FUNCTION: DONALD 04FC:0009 */
main(int argc, char far **argv)
{
    g_3B4E = -1;
    if (argc < 2)
        fn_0512_0102(-1);
    else {
        fn_0512_0102(atoi(argv[1]));
        if (argc >= 3)
            fn_0000_14C7(g_3B4E = atoi(argv[2]));
    }
    g_1F3E = 1;
    g_1F2E = about;
    g_3B6C = 1;
    fn_056A_029A();
    if (g_3B4E == -1)
        detect_video();
    fn_0000_14DD(g_1ADA[g_3B4E]);
    g_3AF8 = (char far *)0xB8000000L;
    if (g_3B4E == 2)
        g_3AF8 = (char far *)0xA0000000L;
    g_1F38 = 0x39;
    if (g_3B4E == 1)
        g_1F38 += 0x10;
    init_game();
    game();
    free_all();
    shutdown();
}
