/* Data-only translation unit linked after scripts.c: DGROUP 145E-1AA9 (records from 145E reproduce the
   relocation runs 16D2-184C / 185E-195A). Sprite/animation tables and the resource file table g_cmpFiles;
   TC places the literal pool (the .CMP file names) at its end, 196A-1AA9. */
#include "donald.h"

int g_curLetter = -1;
char g_soundOn = 1;
int group_intro_script[] = {26, 30, 33, 37, 42, 47};
int group_letter_count[] = {4, 3, 4, 5, 5, 5};
int group_roll_base[] = {-1, 3, 6, 10, 15, 20};
int g_groupFirst[] = {0, 4, 7, 11, 16, 21, 26};
char letter_frame[26] = {4, 8, 18, 23, 4, 12, 19, 4, 10, 16, 23, 4, 11, 14, 19, 24, 4, 9, 14, 18, 22, 4, 10, 13, 19, 23};
script_t scr_letter_wait[3] = {-27, -37, -2};
char pal_abcdscr[32] = {0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 0, 0, 0, 1, 1, 3, 0, 0, 3, 1, 3, 3, 2, 2, 2, 2, 1, 1, 0, 1, 1, 3};
char pal_abcdpet[32] = {0, 1, 1, 2, 1, 1, 2, 2, 2, 2, 1, 3, 0, 1, 1, 3, 0, 1, 3, 1, 1, 3, 2, 2, 2, 2, 1, 3, 0, 1, 1, 3};
char pal_hijkdon[32] = {0, 3, 0, 0, 0, 3, 2, 0, 2, 1, 1, 1, 0, 3, 0, 3, 0, 3, 0, 0, 0, 3, 2, 0, 2, 1, 1, 1, 0, 3, 0, 3};
char pal_efgscr[32] = {0, 1, 3, 1, 1, 1, 2, 2, 0, 1, 1, 1, 0, 0, 2, 3, 0, 1, 3, 3, 2, 2, 2, 2, 2, 1, 1, 1, 0, 0, 2, 3};
char pal_efgpet[32] = {0, 3, 3, 3, 2, 3, 2, 0, 2, 1, 1, 1, 0, 0, 2, 3, 0, 3, 3, 1, 2, 3, 2, 0, 2, 1, 1, 1, 0, 0, 2, 3};
char pal_hijkscr[32] = {0, 2, 1, 1, 1, 1, 2, 2, 0, 1, 1, 2, 0, 0, 2, 3, 0, 2, 1, 2, 1, 1, 3, 2, 2, 1, 1, 2, 0, 0, 2, 3};
char pal_hijkpet[32] = {0, 2, 1, 1, 1, 1, 2, 2, 0, 1, 2, 3, 0, 0, 2, 3, 0, 2, 1, 2, 1, 1, 3, 2, 2, 1, 3, 3, 0, 0, 2, 3};
char pal_lmnopscr[32] = {0, 1, 1, 1, 1, 3, 2, 2, 2, 1, 1, 1, 0, 0, 1, 3, 0, 1, 1, 0, 0, 3, 2, 2, 0, 1, 0, 2, 0, 0, 1, 3};
char pal_lmnoppet[32] = {0, 1, 1, 2, 2, 3, 2, 2, 2, 1, 2, 1, 0, 0, 1, 3, 0, 1, 3, 2, 3, 3, 2, 2, 0, 1, 2, 2, 0, 0, 1, 3};
char pal_qrstuscr[32] = {0, 3, 3, 0, 1, 3, 2, 0, 2, 1, 2, 2, 0, 0, 3, 3, 0, 3, 1, 1, 1, 3, 2, 2, 2, 1, 2, 0, 0, 0, 0, 3};
char pal_qrstupet[32] = {0, 2, 0, 0, 1, 1, 2, 0, 2, 3, 2, 2, 0, 0, 3, 3, 0, 2, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3, 0, 0, 0, 3};
char pal_vwxyzscr[32] = {0, 2, 1, 1, 0, 3, 2, 2, 2, 1, 3, 1, 0, 0, 3, 3, 0, 0, 2, 1, 0, 3, 2, 2, 0, 1, 3, 2, 0, 0, 2, 3};
char pal_vwxyzpet[32] = {0, 2, 1, 1, 0, 1, 2, 2, 2, 1, 3, 1, 0, 0, 3, 3, 0, 0, 2, 1, 0, 1, 2, 3, 2, 1, 3, 2, 0, 0, 2, 3};
char pal_lightblb[32] = {0, 0, 0, 0, 3, 3, 1, 0, 0, 1, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 3, 3, 1, 0, 0, 2, 0, 0, 0, 0, 0, 3};
char pal_dtitle[32] = {1, 0, 2, 3, 3, 3, 2, 2, 2, 1, 1, 1, 0, 2, 0, 3, 2, 0, 2, 3, 0, 3, 2, 2, 0, 1, 1, 0, 0, 2, 0, 3};
char pal_dcredit[32] = {1, 1, 3, 1, 3, 3, 2, 2, 2, 3, 3, 0, 0, 2, 1, 3, 2, 1, 3, 1, 3, 3, 2, 2, 2, 3, 3, 0, 0, 2, 1, 3};
char pal_win1[32] = {0, 0, 2, 2, 2, 1, 2, 0, 2, 1, 2, 1, 0, 0, 2, 3, 0, 0, 3, 3, 3, 2, 2, 0, 2, 3, 3, 1, 0, 0, 0, 3};
char far *g_palettes[] = {pal_vwxyzpet, pal_hijkpet, pal_qrstupet, pal_efgpet, pal_hijkdon, pal_abcdpet, pal_hijkdon, pal_lmnoppet, pal_hijkdon, pal_hijkdon, pal_hijkdon, pal_hijkdon, pal_hijkscr, pal_efgscr, pal_lmnopscr, pal_abcdscr, pal_vwxyzscr, pal_qrstuscr, pal_win1, pal_win1, pal_win1, pal_win1, pal_dcredit, pal_lightblb, pal_hijkdon, pal_hijkdon, pal_dtitle};
int pic_needs_ega[] = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0};
struct file_entry g_cmpFiles[] = {
    {"VWXYZPET.CMP", 4442L, 0, 0, 0L},
    {"HIJKPET.CMP", 4657L, 0, 0, 0L},
    {"QRSTUPET.CMP", 4993L, 0, 0, 0L},
    {"EFGPET.CMP", 5336L, 0, 0, 0L},
    {"HIJKDON.CMP", 5557L, 0, 0, 0L},
    {"ABCDPET.CMP", 5645L, 0, 0, 0L},
    {"ABCDDON.CMP", 5795L, 0, 0, 0L},
    {"LMNOPPET.CMP", 5988L, 0, 0, 0L},
    {"QRSTUDON.CMP", 6299L, 0, 0, 0L},
    {"LMNOPDON.CMP", 6617L, 0, 0, 0L},
    {"VWXYZDON.CMP", 6871L, 0, 0, 0L},
    {"EFGDON.CMP", 7183L, 0, 0, 0L},
    {"HIJKSCR.CMP", 11836L, 0, 0, 0L},
    {"EFGSCR.CMP", 12536L, 0, 0, 0L},
    {"LMNOPSCR.CMP", 15321L, 0, 0, 0L},
    {"ABCDSCR.CMP", 17054L, 0, 0, 0L},
    {"VWXYZSCR.CMP", 17557L, 0, 0, 0L},
    {"QRSTUSCR.CMP", 19219L, 0, 0, 0L},
    {"WIN1.CMP", 7039L, 0, 0, 0L},
    {"WIN2.CMP", 6950L, 0, 0, 0L},
    {"WIN3.CMP", 8696L, 0, 0, 0L},
    {"WIN4.CMP", 8785L, 0, 0, 0L},
    {"DCREDIT.CMP", 6947L, 0, 0, 0L},
    {"LIGHTBLB.CMP", 411L, 0, 0, 0L},
    {"0DONALD.CMP", 918L, 0, 0, 0L},
    {"0DONALD0.CMP", 11462L, 0, 0, 0L},
    {"DTITLE.CMP", 11159L, 0, 0, 0L},
    {"", 0L, 0, 0, 0L}
};
