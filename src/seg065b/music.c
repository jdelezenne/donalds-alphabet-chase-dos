#include "donald.h"

/* Uninitialised data (_BSS): DGROUP 3AF0-3B4D (ownership inferred, see docs/MATCHING.md). */
int g_initDone;
char far *g_backBuf;
int g_driveB;
char far *g_videoMem;
int g_fixedDrive;
char unused_3AFE[80];

/* FUNCTION: DONALD 065B:000C */
/* Before opening a file of disk `disk`: go to drive A:, or B: when disks >0 live in a second drive. */
void select_drive(int disk)
{
    if (!g_fixedDrive) {
        dos_set_drive(0);
        if (g_driveB && disk > 0)
            dos_set_drive(1);
    }
}
