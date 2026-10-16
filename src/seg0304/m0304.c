/* Module at segment 0304 (one translation unit; functions in address order). */
#include "donald.h"

unsigned char rand8();
char far *grab();
void far reset_actors(void);
void far init_slots(void);
void far load_level_gfx(void);
int far handle_key(void);
int far run_script(int i);
int far ending(void);

/* Module data: DGROUP 0094-0209 (detect_video's messages, palette maps, disk prompt). */
char g_0094[] = "\n\r\nA CGA ";
char g_009E[] = "\n\r\nAn EGA ";
char g_00A9[] = "\n\r\nA TANDY ";
char g_00B5[] = "graphic card has been detected.  If you wish to\n\roverride this choice, you will have 20 seconds to do so.\n\r\n\rInput graphics mode, 1:CGA 2:EGA/VGA 3:TANDY";
char g_014F = 10;
char g_0150 = 13;
char d_0151[1] = {0};
char g_0152[16] = {0, 5, 3, 2, 10, 14, 12, 6, 4, 11, 9, 1, 0, 8, 7, 15};
int g_0162[] = {15, 13, 12, 14, 17, 16};
int g_016E[] = {5, 3, 1, 7, 2, 0};
int g_017A[] = {6, 11, 4, 9, 8, 10};
char g_0186[16] = {1, 5, 3, 2, 10, 14, 12, 6, 4, 11, 9, 1, 0, 8, 7, 15};
char g_0196[16] = {1, 5, 3, 2, 10, 14, 12, 6, 4, 11, 9, 1, 0, 8, 7, 15};
char g_01A6[100] = "Please make sure that Donald's Alphabet Chase disk is in the disk drive, then press the space bar.";

/* Uninitialised data (_BSS): DGROUP 3868-3AE3 (ownership inferred, see docs/MATCHING.md). */
int g_3868;
int g_386A[8];
int g_387A[8];
int g_388A;
int g_388C[5];
int g_3896;
char g_3898[4];
int g_389C;
int g_389E[8];
int g_38AE;
int g_38B0;
int g_38B2;
char far *g_38B4;
int g_38B8;
char far *g_38BA[5];
char far *g_38CE;
char far *g_38D2;
char far *g_38D6;
int g_38DA;
int g_38DC;
int g_38DE;
int g_38E0;
char g_38E2[40];
int g_390A[5];
int g_3914;
char g_3916[4];
int g_391A;
int g_391C[8];
int g_392C[5];
int g_3936;
char g_3938[4];
char far *g_393C;
int g_3940[26];
int g_3974[8];
char far *g_3984[70];
char g_3A9C[2];
int g_3A9E[8];
int g_3AAE[26];
int g_3AE2;

/* FUNCTION: DONALD 0304:000C */

void blit_dispatch(char far *src, register int x, register int y, int w, int h)
{
    if (g_videoMode != 2)
        blit_generic(x, y, w, h >> 3, src);
    else
        blit_ega(x, y, x, y, w, h >> 3, (char far *)0xA8000000L, (char far *)0xA0000000L);
}

/* FUNCTION: DONALD 0304:0066 */
void check_collisions(void)
{
    register int i;
    register int j;
    int x1, x2, y1, y2, ox1, ox2, oy1, oy2, k;

    for (k = 0; k < 8; k++)
        for (i = 0; i < 8; i++) {
            if (g_389E[i] == -1)
                continue;
            for (j = 0; j < 8; j++) {
                if (j == i)
                    continue;
                x1 = (g_386A[i] >> 3) - 1;
                x2 = g_391C[i] + x1 + 2;
                y1 = (g_387A[i] >> 3) - 1;
                y2 = g_3A9E[i] + y1 + 2;
                ox1 = g_386A[j] >> 3;
                ox2 = g_391C[j] + ox1;
                oy1 = g_387A[j] >> 3;
                oy2 = g_3A9E[j] + oy1;
                if (g_3A9E[i] != 3 && g_3A9E[i] != 8) {
                    x1--;
                    x2++;
                }
                if (x1 <= ox2 && x2 >= ox1 && y1 <= oy2 && y2 >= oy1)
                    g_389E[j] = g_388C[j];
            }
        }
}

/* FUNCTION: DONALD 0304:0187 */

void draw_items(int p)
{
    register int i;
    register int d;
    int a, b;

    for (i = 0; i < 8; i++) {
        a = 1;
        b = 8;
        d = 2;
        if (g_3A9E[i] != 3 && g_3A9E[i] != 8) {
            a = d;
            b = 16;
            d = 4;
        }
        if (g_389E[i] != -1)
            draw_item(p, (g_386A[i] >> 3) - a, g_387A[i] - b, g_391C[i] + d, (g_3A9E[i] + d) << 3);
    }
}

/* FUNCTION: DONALD 0304:0221 */
void draw_item(int mode, register int x, register int y, int w, int h)
{
    char far *src;
    char far *dst;

    while (x < 0) {
        x++;
        w--;
    }
    while (y < 0) {
        y++;
        h--;
    }
    if (w <= 0)
        return;
    if (h <= 0)
        return;
    switch (mode) {
    case 0:
        src = (char far *)0xA0000000L;
        dst = (char far *)0xA8000000L;
        break;
    case 1:
        src = (char far *)0xA8000000L;
        dst = (char far *)0xA0000000L;
        break;
    case 2:
        src = (char far *)0xA8000000L;
        dst = (char far *)0xA4000000L;
        break;
    case 3:
        src = (char far *)0xA4000000L;
        dst = (char far *)0xA8000000L;
        break;
    case 4:
        src = (char far *)0xA0000000L;
        dst = (char far *)0xA4000000L;
        break;
    case 5:
        src = (char far *)0xA4000000L;
        dst = (char far *)0xA0000000L;
        break;
    }
    if (g_videoMode != 2) {
        switch (mode) {
        case 0:
            src = g_3AF8;
            dst = g_3AF2;
            break;
        case 1:
            src = g_3AF2;
            dst = g_3AF8;
            break;
        case 2:
            src = g_3AF2;
            dst = g_393C;
            break;
        case 3:
            src = g_393C;
            dst = g_3AF2;
            break;
        case 4:
            src = g_3AF8;
            dst = g_393C;
            break;
        case 5:
            src = g_393C;
            dst = g_3AF8;
            break;
        }
    }
    fn_0000_03BA(src, dst, x, y, w, h);
}

/* FUNCTION: DONALD 0304:0383 */
void step(register int i)
{
    if (g_389C) {
        if (g_3868)
            g_386A[i] += 8;
        else
            g_386A[i] -= 8;
    } else
        g_387A[i] -= 8;
    g_38DC -= g_38B0;
    if (g_38DC < 0) {
        g_38DC += g_38AE;
        if (!g_389C) {
            if (g_3868)
                g_386A[i] += 8;
            else
                g_386A[i] -= 8;
        } else
            g_387A[i] -= 8;
    }
}

/* FUNCTION: DONALD 0304:03FC */
void draw_frame(int mode, register int i, register int x, int y)
{
    char far *p;

    p = g_3AF2;
    if (g_videoMode == 2)
        p = (char far *)0xA8000000L;
    g_1AAA[1].a = 0;
    g_1AAA[1].c = 40;
    g_1AAA[1].b = 0;
    g_1AAA[1].d = 25;
    switch (mode) {
    case 0:
        draw_sprite(g_3AF8, g_3984[i], x, y, 1);
        break;
    case 1:
        draw_sprite(p, g_3984[i], x, y, 1);
        break;
    case 2:
        draw_sprite_masked(p, g_3984[i], x, y, 1);
        break;
    case 3:
        draw_sprite_masked(g_3AF8, g_3984[i], x, y, 1);
        break;
    }
}

/* FUNCTION: DONALD 0304:04F9 */
void next_level(void)
{
    char i, sum;

    for (i = sum = 0; i < 26; i++)
        sum += g_3AAE[i];
    if (sum < 26) {
        do {
            g_388A++;
            if (g_388A >= 6)
                g_388A = 0;
            sum = 0;
            for (i = g_1485[g_388A]; i < g_1485[g_388A + 1]; i++)
                sum += g_3AAE[i];
        } while (sum == g_146D[g_388A]);
        i = 0;
        if (key_ready())
            i = handle_key();
        if (i == 0 || i == 27) {
            load_level_gfx();
            reset_actors();
        }
    } else
        g_391A = 1;
}

/* FUNCTION: DONALD 0304:05C0 */
int rom_check(void)
{
    register int r = 0;
    char c = 0;

    c = *(char far *)0xF000C000L;
    if (c == 0x21)
        r = 1;
    return r;
}

/* FUNCTION: DONALD 0304:05EB */
void detect_video(void)
{
    register int i;
    long t0, t1;

    set_text_mode();
    for (i = 0; i < 8; i++) {
        dos_putc(g_014F);
        dos_putc(g_0150);
    }
    i = 0;
    if (rom_check()) {
        g_videoMode = 1;
        while (g_00A9[i])
            dos_putc(g_00A9[i++]);
    } else if (ega_present()) {
        g_videoMode = 2;
        while (g_009E[i])
            dos_putc(g_009E[i++]);
    } else {
        g_videoMode = 0;
        while (g_0094[i])
            dos_putc(g_0094[i++]);
    }
    i = 0;
    while (g_00B5[i])
        dos_putc(g_00B5[i++]);
    i = 0;
    time(&t0);
    do {
        if (key_ready())
            i = get_key();
        time(&t1);
    } while (!i && t1 - t0 < 20);
    time(&g_25FB);
    if (i) {
        switch (i) {
        case '1':
            g_videoMode = 0;
            break;
        case '2':
            g_videoMode = 2;
            break;
        case '3':
            g_videoMode = 1;
            break;
        }
    }
    set_video_type(g_videoMode);
}

/* FUNCTION: DONALD 0304:0737 */
int level_sum(void)
{
    register int sum = 0;
    register int i;

    for (i = g_1485[g_388A]; i < g_1485[g_388A + 1]; i++)
        sum += g_3AAE[i];
    if (g_146D[g_388A] > sum)
        sum = 0;
    return sum;
}

/* FUNCTION: DONALD 0304:0776 */
void aim(int i)
{
    register int d;
    register int target;
    int x, y, t;

    target = *g_38BA[i];
    x = g_386A[i] >> 3;
    y = g_387A[i] >> 3;
    if (x >= target) {
        d = x - target;
        g_3868 = 0;
    } else {
        d = target - x;
        g_3868 = 1;
    }
    t = y;
    if (d >= t) {
        g_38AE = d;
        g_38B0 = t;
        g_389C = 1;
    } else {
        g_38AE = t;
        g_38B0 = d;
        g_389C = 0;
    }
    g_38DC = g_38AE >> 1;
    g_38B8 = g_38AE;
}

/* FUNCTION: DONALD 0304:080E */
void reset_actors(void)
{
    register int i;

    for (i = 0; i < 8; i++) {
        g_391C[i] = g_3A9E[i] = 3;
        g_38BA[i] = g_1332;
        g_386A[i] = -160;
        g_387A[i] = 0;
        g_392C[i] = g_390A[i] = 10;
        g_388C[i] = -1;
    }
    g_391C[7] = g_3A9E[7] = 8;
    g_38D6 = g_13EA;
    g_38CE = g_1336;
    g_386A[5] = 0x128;
    g_387A[5] = g_3896 = 0;
    g_3936 = g_3914 = 20;
    init_slots();
}

/* FUNCTION: DONALD 0304:08B1 */
void setup_level(int lv)
{
    char i;

    for (i = 0; i < 8; i++)
        g_392C[i] = 0;
    for (i = 0; i < 5; i++) {
        g_38BA[i] = g_145A;
        g_3A9E[i] = 3;
    }
    g_3A9E[5] = 3;
    g_3A9E[6] = 3;
    g_021D = g_021E = g_1493[lv];
    g_38D2 = g_1452;
    init_slots();
}

/* FUNCTION: DONALD 0304:093C */
void show_picture(register int n)
{
    char c;

    load_file(g_cmpFiles[n].name, g_393C);
    if (g_173C[n]) {
        c = 0;
        if (g_videoMode == 0) {
            set_palette16(g_16D0[n]);
            c = g_videoMode = 1;
            set_video_type(g_videoMode);
        }
        draw_pic(g_393C, g_3AF2);
        if (c) {
            g_videoMode = 0;
            set_video_type(0);
            clear_buffer(g_3AF2, 0);
        }
    } else {
        if (g_videoMode == 0)
            set_palette16(g_16D0[n]);
        draw_pic(g_393C, g_3AF2);
        if (g_videoMode == 2)
            present_buffer(g_3AF2, 0xA800);
    }
    if (g_videoMode == 0)
        cga_select_palette(1);
}

/* FUNCTION: DONALD 0304:0A4E */
void load_level_gfx(void)
{
    register int i;

    play_sound(17);
    for (i = 4; i < 41; i++)
        if (g_3984[i] != (char far *)-1L) {
            free(g_3984[i]);
            g_3984[i] = (char far *)-1L;
        }
    for (i = 57; i < 65; i++)
        if (g_3984[i] != (char far *)-1L) {
            free(g_3984[i]);
            g_3984[i] = (char far *)-1L;
        }
    show_picture(g_016E[g_388A]);
    for (i = 1; i < 28; i++)
        g_3984[i + 3] = grab(((i - 1) % 13) * 3, ((i - 1) / 13) * 24, 3, 24);
    show_picture(g_017A[g_388A]);
    for (i = 57; i < 65; i++)
        g_3984[i] = grab(((i - 57) % 5) * 8, ((i - 57) / 5) * 64, 8, 64);
    show_picture(g_0162[g_388A]);
    if (g_videoMode)
        ega_select_palette(0);
    set_palette(g_0152);
    blit_dispatch(g_3AF2, 0, 0, 40, 200);
    draw_item(0, 0, 0, 40, 200);
    draw_item(4, 0, 0, 40, 200);
    g_38DE = 0;
}

/* FUNCTION: DONALD 0304:0C0D */
void game(void)
{
    int now;
    int last;
    int dt;
    register int i;
    register int key;

    for (i = key = 0; i < 70; i++)
        g_3984[i] = (char far *)-1L;
    set_palette(g_0186);
    if (g_videoMode)
        ega_select_palette(1);
    kbd_flush();
    show_picture(26);
    blit_dispatch(g_3AF2, 0, 0, 40, 200);
    play_sound(24);
    for (i = 0; i < 1000; i++) {
        repeat_call(1);
        if (key_ready()) {
            get_key();
            break;
        }
    }
    play_sound(17);
    show_picture(25);
    for (i = 41; i < 56; i++)
        g_3984[i] = grab(((i - 41) % 5) * 8, ((i - 41) / 5) * 64, 8, 64);
    show_picture(24);
    g_3984[56] = grab(0, 0, 8, 64);
    show_picture(23);
    g_3984[1] = grab(0, 0, 1, 1);
    g_3984[2] = grab(3, 0, 1, 1);
    g_3984[3] = grab(6, 0, 3, 24);
    for (i = 57; i < 65; i++)
        g_3984[i] = grab(((i - 57) % 5) * 8, ((i - 57) / 5) * 64, 8, 64);
    for (i = 1; i < 28; i++)
        g_3984[i + 3] = grab(((i - 1) % 13) * 3, ((i - 1) / 13) * 24, 3, 24);
    key = 1;
    if (!key)
        key = 27;
    if (key != 27)
        key = 0;
    while (key != 27) {
        for (i = 0; i < 26; i++)
            g_3AAE[i] = g_3940[i] = 0;
        i = 0; g_391A = 0; g_38DE = 0; g_38DA = 0; g_38B2 = g_388A = g_3AE2 = 0;
        load_level_gfx();
        reset_actors();
        last = now = timer_ticks();
        for (i = 0; i < 8; i++)
            draw_item(4, (g_386A[i] >> 3) - 1, g_387A[i] - 8, g_391C[i] + 2, (g_3A9E[i] + 2) << 3);
        for (;;) {
            g_38DE++;
            draw_items(3);
            for (i = 0; i < 8; i++) {
                g_389E[i] = run_script(i);
                if (g_389E[i] != -1)
                    g_388C[i] = g_389E[i];
            }
            for (i = 0; i < 8; i++)
                if (g_389E[i] != -1) {
                    i = 0;
                    break;
                }
            if (!i) {
                check_collisions();
                draw_items(2);
                for (i = 0; i < 8; i++)
                    if (g_389E[i] != -1 && g_389E[i] != 0) {
                        if (g_3974[i] == 0)
                            draw_frame(1, g_388C[i], g_386A[i], g_387A[i]);
                        else
                            draw_frame(2, g_388C[i], g_386A[i], g_387A[i]);
                    }
                draw_items(1);
            }
            do {
                now = timer_ticks();
                if (last < 0)
                    last = now;
                if (last > now)
                    now += 0x123;
            } while ((dt = now - last) <= 4);
            last = timer_ticks();
            if (!snd_get_option()) {
                key = 27;
                break;
            }
            if (key_ready()) {
                key = handle_key();
                if (key == 27)
                    break;
            }
            if (g_391A) {
                key = ending();
                break;
            }
        }
    }
    for (i = 1; i < 65; i++)
        if (g_3984[i] != (char far *)-1L)
            free(g_3984[i]);
    free(g_393C);
}

/* FUNCTION: DONALD 0304:1061 */
int handle_key(void)
{
    register int key = 0;
    register int r;

    if (!g_38B2) {
        kbd_flush();
        goto done;
    }
    if (key_ready()) {
        key = get_key();
        kbd_flush();
        if (key >= 'a' && key <= 'z')
            key = key - 32;
        if ((key < 'A' || key > 'Z') && key != 27 && key != '1')
            key = 0;
    }
    if (key && key != 27 && !g_38DA && key != '1') {
        r = level_sum();
        if (r)
            goto done;
        key -= 'A';
        if (g_3AAE[key])
            goto clear;
        g_38DE = 0;
        for (r = 5; r >= 0; r--)
            if (g_1485[r] <= key)
                break;
        if (r != g_388A) {
            g_388A = r;
            load_level_gfx();
            reset_actors();
        } else if (key != g_145E)
            setup_level(key);
        else
            play_sound(0);
        g_145E = g_38E0 = key;
        g_38DA = 1;
        g_3940[g_38E0] = 1;
        g_38CE = g_1336;
        g_0211 = 0;
        g_0210 = 3;
        g_020C = (key - g_1485[g_388A]) * 4 + 1;
        goto done;
    }
    if (key != '1')
        goto done;
    snd_play(g_tunes[4]);
    g_1460 ^= 1;
    if (!g_1460)
        stop_sound();
clear:
    key = 0;
done:
    return key;
}

/* FUNCTION: DONALD 0304:11AA */
int run_script(register int i)
{
    int r;
    int cont;
    int t;
    register int j;

    if (g_392C[i]) {
        g_392C[i]--;
        if (g_videoMode == 1 && g_392C[i])
            g_392C[i]--;
        return -1;
    }
    g_392C[i] = g_390A[i];
    g_3974[i] = 0;
    cont = 1;
    r = -1;
    while (r < 0 && cont != -1) {
        r = *g_38BA[i]++;
        if (r < 0)
        switch (r) {
        case -1:
            if (g_386A[i] >> 3 == *g_38BA[i]) {
                g_38BA[i] += 3;
                break;
            }
            if (g_386A[i] >> 3 < *g_38BA[i])
                g_386A[i] += 8;
            else {
                g_386A[i] -= 8;
                g_3974[i] = 1;
            }
            g_388C[i]++;
            if (g_388C[i] > g_38BA[i][2])
                g_388C[i] = g_38BA[i][1];
            if (g_388C[i] < g_38BA[i][1])
                g_388C[i] = g_38BA[i][1];
        back:
            g_38BA[i]--;
            r = g_388C[i];
            break;
        case -2:
            r = cont = -1;
            g_38BA[i] = g_1332;
            break;
        case -3:
            g_386A[i] = *g_38BA[i]++ << 3;
            g_387A[i] = *g_38BA[i]++ << 3;
            break;
        case -4:
            g_390A[i] = g_392C[i] = *g_38BA[i]++;
            break;
        case -5:
            if ((t = level_sum()) != 0) {
                g_38BA[i] = g_13E2;
                break;
            }
            if (!g_38DA) {
                if (g_38DE > 5000) {
                    g_38BA[i] = g_13E6;
                    g_38DE = 0;
                    break;
                }
                do
                    j = roll(1, g_146D[g_388A], g_1479[g_388A]);
                while (g_3AAE[j]);
                g_38BA[j - g_1485[g_388A]] = g_1262[j];
                g_145E = j;
                g_38CE = g_1336;
                g_0210 = 3;
                g_0211 = 0;
                g_020C = ((j - g_1485[g_388A]) << 2) + 1;
                break;
            } else {
                if (g_145E == g_38E0)
                    break;
                g_145E = j = g_38E0;
                g_38BA[j - g_1485[g_388A]] = g_1262[j];
                break;
            }
        case -6:
            if (g_386A[7] >> 3 == *g_38BA[i])
                g_38BA[i]++;
            else {
        back3:
                g_38BA[i]--;
                r = cont = -1;
            }
            break;
        case -7:
            j = *g_38BA[i]++;
            if (*g_38BA[i]++ < g_386A[j] >> 3)
                goto back2;
            else
                g_38BA[i]++;
            break;
        case -8:
            j = *g_38BA[i]++;
            if (*g_38BA[i]++ != g_386A[j] >> 3)
                goto back2;
            else
                goto inc;
            break;
        case -9:
            g_3A9E[i]++;
            break;
        case -10:
            g_3A9E[i]--;
            break;
        case -11:
            j = *g_38BA[i]++;
            j = roll(1, j, -1);
            g_38BA[i] += j;
            g_38BA[i] = g_1262[*g_38BA[i]];
            break;
        case -12:
            g_3974[i] = 1;
            break;
        case -13:
            if (rand8() & 1)
                g_38BA[i] += *g_38BA[i];
            else
                g_38BA[i]++;
            break;
        case -14:
            if (rand8() & 3)
                g_38BA[i]++;
            else
        back2:
                g_38BA[i] -= *g_38BA[i];
            break;
        case -15:
            next_level();
            break;
        case -16:
            if (g_387A[7] >> 3 != *g_38BA[i])
                goto back3;
            else
                goto inc;
            break;
        case -17:
            if ((g_386A[i] >> 3) + *g_38BA[i] != g_386A[7] >> 3)
                goto back3;
            else
                g_38BA[i]++;
            break;
        case -18:
            if (g_3940[g_1485[g_388A] + i] == 0)
                g_38BA[i]++;
            else {
                g_38BA[i] += *g_38BA[i];
                g_3AAE[g_1485[g_388A] + i] = 1;
            }
            break;
        case -19:
            g_38D6[3] = *g_38BA[i]++ + (g_386A[i] >> 3);
            break;
        case -20:
            if (!g_3AE2) {
                g_392C[i] = g_390A[i] = 4;
                g_3AE2++;
                aim(i);
                g_0210 = g_0211 = 0;
                g_38CE = g_1336;
                g_020C = 0x25;
                play_sound(11);
            }
            if (g_38B8) {
                step(i);
                g_38B8--;
            }
            if (!g_38B8) {
                g_38DA = 0;
                g_3AE2 = 0;
                g_38BA[i]++;
                play_sound(10);
            } else
                g_38BA[i]--;
            r = g_388C[i];
            break;
        case -22:
            init_slots();
            break;
        case -23:
            g_38BA[0] = g_1262[g_1461[g_388A]];
            break;
        case -24:
            if (*g_38BA[i]++ == g_388A)
                g_38BA[i] += *g_38BA[i];
            else
                g_38BA[i]++;
            break;
        case -21:
            g_38BA[i] += *g_38BA[i];
            break;
        case -25:
            j = *g_38BA[i]++;
            g_38BA[j] = g_1262[*g_38BA[i]++];
            g_392C[j] = 0;
            break;
        case -26:
            g_386A[i] += 8;
            break;
        case -28:
            g_386A[i] -= 8;
            break;
        case -30:
            g_386A[i] += 8;
            g_387A[i] += 8;
            break;
        case -31:
            g_386A[i] += 8;
            g_387A[i] -= 8;
            break;
        case -32:
            g_386A[i] -= 8;
        case -27:
            g_387A[i] += 8;
            break;
        case -33:
            g_386A[i] -= 8;
        case -29:
            g_387A[i] -= 8;
            break;
        case -34:
            g_386A[i] += 8;
            r = g_388C[i];
            break;
        case -36:
            g_386A[i] -= 8;
            r = g_388C[i];
            break;
        case -38:
            g_386A[i] += 8;
            g_387A[i] += 8;
            r = g_388C[i];
            break;
        case -39:
            g_386A[i] += 8;
            g_387A[i] -= 8;
            r = g_388C[i];
            break;
        case -40:
            g_386A[i] -= 8;
        case -35:
            g_387A[i] += 8;
            r = g_388C[i];
            break;
        case -41:
            g_386A[i] -= 8;
        case -37:
            g_387A[i] -= 8;
            r = g_388C[i];
            break;
        case -42:
            g_145E = -1;
            g_0210 = g_0211 = 0;
            g_38CE = g_1336;
            g_020C = 0x25;
            break;
        case -43:
            if (!g_38DA)
        inc:
                g_38BA[i]++;
            else
                setup_level(g_145E);
            break;
        case -44:
            g_386A[i] = g_386A[7] + 16;
            g_387A[i] = 0x60;
            break;
        case -45:
            g_145E = -1;
            break;
        case -46:
            j = *g_38BA[i]++;
            play_sound(j);
            break;
        case -47:
            g_38B2 = 1;
            break;
        case -48:
            g_38B2 = 0;
            break;
        }
    }
    return r;
}

/* FUNCTION: DONALD 0304:1A71 */
int roll(int n, int max, int base)
{
    register int sum = 0;
    register int d;
    int i;

    if (max == 0)
        max = 1;
    for (i = 0; i < n; i++) {
        do
            d = rand8() & 0x0f;
        while (d == 0 || d > max);
        sum += d;
    }
    sum += base;
    return sum;
}

/* FUNCTION: DONALD 0304:1ABA */
void init_slots(void)
{
    register int i;

    for (i = 0; i < g_146D[g_388A]; i++)
        if (g_3AAE[g_1485[g_388A] + i]) {
            g_386A[i] = (i * 4 + 1) * 8;
            g_387A[i] = 0;
            g_388C[i] = g_1493[g_1485[g_388A] + i];
            g_38BA[i] = g_14AD;
            g_392C[i] = 0;
        }
}

/* FUNCTION: DONALD 0304:1B37 */
int wait_key(int any)
{
    register int key;
    register int i;

    for (i = key = 0; i < 250; i++) {
        repeat_call(1);
        if (key_ready()) {
            key = get_key();
            if (any || key == 27)
                break;
        }
    }
    return key;
}

/* FUNCTION: DONALD 0304:1B74 */
int ending(void)
{
    register int k = 0;

    play_sound(17);
    load_file(g_cmpFiles[18].name, g_393C);
    load_file(g_cmpFiles[19].name, g_393C + 0x1b8a);
    load_file(g_cmpFiles[20].name, g_393C + 0x3714);
    load_file(g_cmpFiles[21].name, g_393C + 0x5910);
    if (g_videoMode == 0)
        set_palette16(g_16D0[18]);
    draw_pic(g_393C, g_3AF2);
    if (g_videoMode == 2)
        present_buffer(g_3AF2, 0xA800);
    blit_dispatch(g_3AF2, 0, 0, 40, 200);
    play_sound(24);
    draw_pic(g_393C + 0x1b8a, g_3AF2);
    if (g_videoMode == 2)
        present_buffer(g_3AF2, 0xA800);
    k = wait_key(0);
    if (k == 27)
        return k;
    blit_dispatch(g_3AF2, 0, 0, 40, 200);
    draw_pic(g_393C + 0x3714, g_3AF2);
    if (g_videoMode == 2)
        present_buffer(g_3AF2, 0xA800);
    k = wait_key(0);
    if (k == 27)
        return k;
    blit_dispatch(g_3AF2, 0, 0, 40, 200);
    draw_pic(g_393C + 0x5910, g_3AF2);
    if (g_videoMode == 2)
        present_buffer(g_3AF2, 0xA800);
    k = wait_key(0);
    if (k == 27)
        return k;
    blit_dispatch(g_3AF2, 0, 0, 40, 200);
    k = wait_key(0);
    if (k == 27)
        return k;
    play_sound(17);
    load_file(g_cmpFiles[22].name, g_393C);
    if (g_videoMode == 0)
        set_palette16(g_16D0[22]);
    set_palette(g_0196);
    if (g_videoMode)
        ega_select_palette(1);
    draw_pic(g_393C, g_3AF2);
    if (g_videoMode == 2)
        present_buffer(g_3AF2, 0xA800);
    blit_dispatch(g_3AF2, 0, 0, 40, 200);
    k = wait_key(1);
    if (k != 27)
        k = wait_key(1);
    return k;
}

/* FUNCTION: DONALD 0304:1E5B */
void about(void)
{
    clear_screen();
    set_and_redraw(2);
    draw_line((g_1ED8 - 1) << 3, (g_1EDA - 1) << 3, ((g_1ED8 + g_1EDC + 1) << 3) - 1, (g_1EDA - 1) << 3, 15);
    draw_line((g_1ED8 - 1) << 3, ((g_1EDA + g_1EDE + 1) << 3) - 1, ((g_1ED8 + g_1EDC + 1) << 3) - 1, ((g_1EDA + g_1EDE + 1) << 3) - 1, 15);
    draw_line((g_1ED8 - 1) << 3, (g_1EDA - 1) << 3, (g_1ED8 - 1) << 3, ((g_1EDA + g_1EDE + 1) << 3) - 1, 15);
    draw_line(((g_1ED8 + g_1EDC + 1) << 3) - 1, (g_1EDA - 1) << 3, ((g_1ED8 + g_1EDC + 1) << 3) - 1, ((g_1EDA + g_1EDE + 1) << 3) - 1, 15);
    print_wrapped(g_01A6);
    get_key();
    clear_screen();
}


