#include "donald.h"

/* FUNCTION: DONALD 0567:0008 */
void play_sound(int i)
{
    if (g_1460)
        fn_0512_03CD(g_1E22[i]);
}

/* FUNCTION: DONALD 0567:002A */
void stop_sound(void)
{
    fn_0512_03F1();
}
