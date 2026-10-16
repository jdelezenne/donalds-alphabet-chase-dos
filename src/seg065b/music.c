#include "donald.h"

/* Uninitialised data (_BSS): DGROUP 3AF0-3B4D (ownership inferred, see docs/MATCHING.md). */
int g_initDone;
char far *g_backBuf;
int g_multiDisk;
char far *g_videoMem;
int g_noDiskCheck;
char unused_3AFE[80];

/* FUNCTION: DONALD 065B:000C */
void music_toggle(int x)
{
    if (!g_noDiskCheck) {
        dos_set_drive(0);
        if (g_multiDisk && x > 0)
            dos_set_drive(1);
    }
}
