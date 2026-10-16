#include "donald.h"

/* Uninitialised data (_BSS): DGROUP 3AF0-3B4D (ownership inferred, see docs/MATCHING.md). */
int g_3AF0;
char far *g_3AF2;
int g_3AF6;
char far *g_3AF8;
int g_3AFC;
char g_3AFE[80];

/* FUNCTION: DONALD 065B:000C */
void music_toggle(int x)
{
    if (!g_3AFC) {
        dos_set_drive(0);
        if (g_3AF6 && x > 0)
            dos_set_drive(1);
    }
}
