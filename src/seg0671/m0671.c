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
    col = g_1EE4;
    while ((ch = s[idx++]) != 0 && !flag) {
        if (ch & 0x80) {
            ch &= 0x7f;
            flag = 1;
        }
        if (ch == '\r') {
            word[wlen] = 0;
            if (wlen + col <= win_w) {
                strcat(line, word);
                print_word(line, 1);
            } else {
                print_word(line, 1);
                print_word(word, 1);
            }
            col = wlen = 0;
        } else if (ch == 2) {
            word[wlen] = 0;
            if (wlen + col <= win_w) {
                strcat(line, word);
                print_word(line, 0);
            } else {
                print_word(line, 1);
                print_word(word, 0);
            }
            wlen = 0;
            col = g_1EE4;
            g_1EE2 = s[idx];
            idx++;
        } else if (ch == 6) {
            word[wlen] = 0;
            if (wlen + col <= win_w) {
                strcat(line, word);
                print_word(line, 0);
            } else {
                print_word(line, 1);
                print_word(word, 0);
            }
            wlen = 0;
            col = g_1EE4;
            g_1EE0 = s[idx];
            idx++;
        } else if (ch == 9) {
            word[wlen] = 0;
            if (wlen + col <= win_w) {
                strcat(line, word);
                print_word(line, 0);
            } else {
                print_word(line, 1);
                print_word(word, 0);
            }
            wlen = 0;
            g_1EE4 = col = s[idx];
            idx++;
            if (g_1EE4 >= win_w) {
                col = 0;
                g_1EE4 = col;
            }
        } else if (ch == 0x13) {
            cnt = s[idx];
            idx++;
            if (g_1EE4 < cnt) {
                while (g_1EE4 < cnt) {
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
            if (wlen + col <= win_w) {
                if (wlen + col != win_w && wlen + col != 0) {
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
        } else if (win_w - 1 <= wlen) {
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
        if (wlen + col <= win_w) {
            strcat(line, word);
            print_word(line, 0);
        } else {
            print_word(line, 1);
            print_word(word, 0);
        }
    }
}
