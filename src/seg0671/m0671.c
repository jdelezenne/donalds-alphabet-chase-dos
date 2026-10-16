/* Module 0671: word-wrapped text output (compiled with -ml). */
#include "donald.h"

/* FUNCTION: DONALD 0671:000D */
void print_wrapped(char far *s)
{
    int idx;
    int cnt;
    int flag;
    char ch;
    char word[42];
    char line[42];
    register int wlen;
    register int col;

    /* odd but byte-exact (found by permute.py) */
    wlen = 0;
    flag = wlen;
    idx = wlen = wlen;
    line[0] = 0;
    col = g_win.col;
    while ((ch = s[idx++]) != 0 && !flag) {
        if (ch & 0x80) {
            ch &= 0x7f;
            flag = 1;
        }
        if (ch == '\r') {
            word[wlen] = 0;
            if (wlen + col <= g_win.w) {
                strcat(line, word);
                print_word(line, 1);
            } else {
                print_word(line, 1);
                print_word(word, 1);
            }
            col = wlen = 0;
        } else if (ch == 2) {
            word[wlen] = 0;
            if (wlen + col <= g_win.w) {
                strcat(line, word);
                print_word(line, 0);
            } else {
                print_word(line, 1);
                print_word(word, 0);
            }
            wlen = 0;
            col = g_win.col;
            g_win.bg = s[idx];
            idx++;
        } else if (ch == 6) {
            word[wlen] = 0;
            if (wlen + col <= g_win.w) {
                strcat(line, word);
                print_word(line, 0);
            } else {
                print_word(line, 1);
                print_word(word, 0);
            }
            wlen = 0;
            col = g_win.col;
            g_win.fg = s[idx];
            idx++;
        } else if (ch == 9) {
            word[wlen] = 0;
            if (wlen + col <= g_win.w) {
                strcat(line, word);
                print_word(line, 0);
            } else {
                print_word(line, 1);
                print_word(word, 0);
            }
            wlen = 0;
            g_win.col = col = s[idx];
            idx++;
            if (g_win.col >= g_win.w) {
                col = 0;
                g_win.col = col;
            }
        } else if (ch == 0x13) {
            cnt = s[idx];
            idx++;
            if (g_win.col < cnt) {
                while (g_win.col < cnt) {
                    word[wlen] = ' ';
                    wlen++;
                    cnt--;
                }
                word[wlen] = 0;
                strcat(line, word);
                col += wlen;
                wlen = 0;
            }
        } else if (ch == ' ') {
            if (wlen + col <= g_win.w) {
                if (wlen + col != g_win.w && wlen + col != 0) {
                    word[wlen] = ' ';
                    wlen++;
                }
                word[wlen] = 0;
                strcat(line, word);
            } else {
                word[wlen] = ' ';
                wlen++;
                word[wlen] = 0;
                print_word(line, 1);
                col = 0;
                strcpy(line, word);
                while ((ch = s[idx]) == ' ')
                    idx++;
            }
            col += wlen;
            wlen = 0;
        } else if (g_win.w - 1 <= wlen) {
            if (line[0])
                print_word(line, 1);
            word[wlen] = ch;
            wlen++;
            word[wlen] = 0;
            strcat(line, word);
            print_word(line, 1);
            col = wlen = 0;
        } else {
            word[wlen] = ch;
            wlen++;
        }
    }
    if (wlen || line[0]) {
        word[wlen] = 0;
        if (wlen + col <= g_win.w) {
            strcat(line, word);
            print_word(line, 0);
        } else {
            print_word(line, 1);
            print_word(word, 0);
        }
    }
}
