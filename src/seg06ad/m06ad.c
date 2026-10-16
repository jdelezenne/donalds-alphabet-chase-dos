/* Module 06AD: text output into the current window (compiled with -ml). */
#include "donald.h"

/* FUNCTION: DONALD 06AD:0002 */
void print_word(char far *s, int nl)
{
    register int i;
    register int n;

    if (g_textRow >= win_h) {
        n = i = strlen(s);
        for (; i < win_w; i++)
            s[i] = ' ';
        s[win_w] = 0;
        blit_ega(win_x, win_y + 1, win_x, win_y, win_w, win_h - 1, g_videoMem, g_videoMem);
        fill_rect(win_x << 3, (win_y + win_h - 1) << 3, (win_x + win_w - 1) << 3,
                  ((win_y + win_h) << 3) - 1, 0);
        print_text(s, win_x, win_y + win_h - 1, g_textFg, g_textBg);
        if (nl) {
            g_textCol = 0;
            g_textRow++;
        } else {
            g_textCol += n;
            g_textRow = win_h - 1;
            if (g_textCol >= win_w) {
                g_textCol = 0;
                g_textRow++;
            }
        }
    } else {
        print_text(s, g_textCol + win_x, g_textRow + win_y, g_textFg, g_textBg);
        if (nl) {
            g_textCol = 0;
            g_textRow++;
        } else {
            g_textCol += strlen(s);
            if (g_textCol >= win_w) {
                g_textCol = 0;
                g_textRow++;
            }
        }
    }
    *s = 0;
}
