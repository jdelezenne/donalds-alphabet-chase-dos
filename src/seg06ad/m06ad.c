/* Module 06AD: text output into the current window (compiled with -ml). */
#include "donald.h"

/* FUNCTION: DONALD 06AD:0002 */
void print_word(char far *s, int nl)
{
    register int i;
    register int n;

    if (g_1EE6 >= g_1EDE) {
        n = i = strlen(s);
        for (; i < g_1EDC; i++)
            s[i] = ' ';
        s[g_1EDC] = 0;
        blit_ega(g_1ED8, g_1EDA + 1, g_1ED8, g_1EDA, g_1EDC, g_1EDE - 1, g_3AF8, g_3AF8);
        fill_rect(g_1ED8 << 3, (g_1EDA + g_1EDE - 1) << 3, (g_1ED8 + g_1EDC - 1) << 3,
                  ((g_1EDA + g_1EDE) << 3) - 1, 0);
        print_text(s, g_1ED8, g_1EDA + g_1EDE - 1, g_1EE0, g_1EE2);
        if (nl) {
            g_1EE4 = 0;
            g_1EE6++;
        } else {
            g_1EE4 += n;
            g_1EE6 = g_1EDE - 1;
            if (g_1EE4 >= g_1EDC) {
                g_1EE4 = 0;
                g_1EE6++;
            }
        }
    } else {
        print_text(s, g_1EE4 + g_1ED8, g_1EE6 + g_1EDA, g_1EE0, g_1EE2);
        if (nl) {
            g_1EE4 = 0;
            g_1EE6++;
        } else {
            g_1EE4 += strlen(s);
            if (g_1EE4 >= g_1EDC) {
                g_1EE4 = 0;
                g_1EE6++;
            }
        }
    }
    *s = 0;
}
