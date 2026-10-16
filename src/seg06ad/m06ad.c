/* Module 06AD: text output into the current window (compiled with -ml). */
#include "donald.h"

/* FUNCTION: DONALD 06AD:0002 */
void print_word(char far *s, int nl)
{
    register int i;
    register int n;

    if (g_1EE6 >= win_h) {
        n = i = strlen(s);
        for (; i < win_w; i++)
            s[i] = ' ';
        s[win_w] = 0;
        blit_ega(win_x, win_y + 1, win_x, win_y, win_w, win_h - 1, g_videoMem, g_videoMem);
        fill_rect(win_x << 3, (win_y + win_h - 1) << 3, (win_x + win_w - 1) << 3,
                  ((win_y + win_h) << 3) - 1, 0);
        print_text(s, win_x, win_y + win_h - 1, g_1EE0, g_1EE2);
        if (nl) {
            g_1EE4 = 0;
            g_1EE6++;
        } else {
            g_1EE4 += n;
            g_1EE6 = win_h - 1;
            if (g_1EE4 >= win_w) {
                g_1EE4 = 0;
                g_1EE6++;
            }
        }
    } else {
        print_text(s, g_1EE4 + win_x, g_1EE6 + win_y, g_1EE0, g_1EE2);
        if (nl) {
            g_1EE4 = 0;
            g_1EE6++;
        } else {
            g_1EE4 += strlen(s);
            if (g_1EE4 >= win_w) {
                g_1EE4 = 0;
                g_1EE6++;
            }
        }
    }
    *s = 0;
}
