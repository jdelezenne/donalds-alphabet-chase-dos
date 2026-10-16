/* Module at segment 0304 (one translation unit; functions in address order). */
#include "donald.h"

unsigned char fn_0000_1197();
char far *fn_062D_0005();
void far reset_actors(void);
void far init_slots(void);
void far load_level_gfx(void);
int far handle_key(void);

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
    if (g_3B4E != 2) {
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
    if (g_3B4E == 2)
        p = (char far *)0xA8000000L;
    g_1ABA = 0;
    g_1ABE = 40;
    g_1ABC = 0;
    g_1AC0 = 25;
    switch (mode) {
    case 0:
        draw_sprite(g_3AF8, g_3984[i], x, y, 0);
        break;
    case 1:
        draw_sprite(p, g_3984[i], x, y, 1);
        break;
    case 2:
        fn_06D3_000C(p, g_3984[i], x, y, 1);
        break;
    case 3:
        fn_06D3_000C(g_3AF8, g_3984[i], x, y, 1);
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

    fn_0000_01E8();
    for (i = 0; i < 8; i++) {
        fn_0000_1180(g_014F);
        fn_0000_1180(g_0150);
    }
    i = 0;
    if (rom_check()) {
        g_3B4E = 1;
        while (g_00A9[i])
            fn_0000_1180(g_00A9[i++]);
    } else if (fn_0000_01C9()) {
        g_3B4E = 2;
        while (g_009E[i])
            fn_0000_1180(g_009E[i++]);
    } else {
        g_3B4E = 0;
        while (g_0094[i])
            fn_0000_1180(g_0094[i++]);
    }
    i = 0;
    while (g_00B5[i])
        fn_0000_1180(g_00B5[i++]);
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
            g_3B4E = 0;
            break;
        case '2':
            g_3B4E = 2;
            break;
        case '3':
            g_3B4E = 1;
            break;
        }
    }
    fn_0000_14C7(g_3B4E);
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
    g_392A = g_3AAC = 8;
    g_38D6 = g_13EA;
    g_38CE = g_1336;
    g_3874 = 0x128;
    g_3884 = g_3896 = 0;
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

    load_file(g_1772[n].name, g_393C);
    if (g_173C[n]) {
        c = 0;
        if (g_3B4E == 0) {
            fn_0000_0FF2(g_16D0[n]);
            c = g_3B4E = 1;
            fn_0000_14C7(g_3B4E);
        }
        draw_pic(g_393C, g_3AF2);
        if (c) {
            g_3B4E = 0;
            fn_0000_14C7(0);
            fn_0000_10D2(g_3AF2, 0);
        }
    } else {
        if (g_3B4E == 0)
            fn_0000_0FF2(g_16D0[n]);
        draw_pic(g_393C, g_3AF2);
        if (g_3B4E == 2)
            fn_0000_0A6B(g_3AF2, 0xA800);
    }
    if (g_3B4E == 0)
        fn_0000_1478(1);
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
        g_3984[i + 3] = fn_062D_0005(((i - 1) % 13) * 3, ((i - 1) / 13) * 24, 3, 24);
    show_picture(g_017A[g_388A]);
    for (i = 57; i < 65; i++)
        g_3984[i] = fn_062D_0005(((i - 57) % 5) * 8, ((i - 57) / 5) * 64, 8, 64);
    show_picture(g_0162[g_388A]);
    if (g_3B4E)
        fn_0000_01FE(0);
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
    if (g_3B4E)
        fn_0000_01FE(1);
    fn_056A_019E();
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
        g_3984[i] = fn_062D_0005(((i - 41) % 5) * 8, ((i - 41) / 5) * 64, 8, 64);
    show_picture(24);
    g_3984[56] = fn_062D_0005(0, 0, 8, 64);
    show_picture(23);
    g_3984[1] = fn_062D_0005(0, 0, 1, 1);
    g_3984[2] = fn_062D_0005(3, 0, 1, 1);
    g_3984[3] = fn_062D_0005(6, 0, 3, 24);
    for (i = 57; i < 65; i++)
        g_3984[i] = fn_062D_0005(((i - 57) % 5) * 8, ((i - 57) / 5) * 64, 8, 64);
    for (i = 1; i < 28; i++)
        g_3984[i + 3] = fn_062D_0005(((i - 1) % 13) * 3, ((i - 1) / 13) * 24, 3, 24);
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
        last = now = fn_0512_0544();
        for (i = 0; i < 8; i++)
            draw_item(4, (g_386A[i] >> 3) - 1, g_387A[i] - 8, g_391C[i] + 2, (g_3A9E[i] + 2) << 3);
        for (;;) {
            g_38DE++;
            draw_items(3);
            for (i = 0; i < 8; i++) {
                g_389E[i] = fn_0304_11AA(i);
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
                now = fn_0512_0544();
                if (last < 0)
                    last = now;
                if (last > now)
                    now += 0x123;
            } while ((dt = now - last) <= 4);
            last = fn_0512_0544();
            if (!fn_0512_00EE()) {
                key = 27;
                break;
            }
            if (key_ready()) {
                key = handle_key();
                if (key == 27)
                    break;
            }
            if (g_391A) {
                key = fn_0304_1B74();
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
        fn_056A_019E();
        goto done;
    }
    if (key_ready()) {
        key = get_key();
        fn_056A_019E();
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
    fn_0512_03CD(g_1E32);
    g_1460 ^= 1;
    if (!g_1460)
        stop_sound();
clear:
    key = 0;
done:
    return key;
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
            d = fn_0000_1197() & 0x0f;
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
    load_file(g_1772[18].name, g_393C);
    load_file(g_1772[19].name, g_393C + 0x1b8a);
    load_file(g_1772[20].name, g_393C + 0x3714);
    load_file(g_1772[21].name, g_393C + 0x5910);
    if (g_3B4E == 0)
        fn_0000_0FF2(g_16D0[18]);
    draw_pic(g_393C, g_3AF2);
    if (g_3B4E == 2)
        fn_0000_0A6B(g_3AF2, 0xA800);
    blit_dispatch(g_3AF2, 0, 0, 40, 200);
    play_sound(24);
    draw_pic(g_393C + 0x1b8a, g_3AF2);
    if (g_3B4E == 2)
        fn_0000_0A6B(g_3AF2, 0xA800);
    k = wait_key(0);
    if (k == 27)
        return k;
    blit_dispatch(g_3AF2, 0, 0, 40, 200);
    draw_pic(g_393C + 0x3714, g_3AF2);
    if (g_3B4E == 2)
        fn_0000_0A6B(g_3AF2, 0xA800);
    k = wait_key(0);
    if (k == 27)
        return k;
    blit_dispatch(g_3AF2, 0, 0, 40, 200);
    draw_pic(g_393C + 0x5910, g_3AF2);
    if (g_3B4E == 2)
        fn_0000_0A6B(g_3AF2, 0xA800);
    k = wait_key(0);
    if (k == 27)
        return k;
    blit_dispatch(g_3AF2, 0, 0, 40, 200);
    k = wait_key(0);
    if (k == 27)
        return k;
    play_sound(17);
    load_file(g_1772[22].name, g_393C);
    if (g_3B4E == 0)
        fn_0000_0FF2(g_16D0[22]);
    set_palette(g_0196);
    if (g_3B4E)
        fn_0000_01FE(1);
    draw_pic(g_393C, g_3AF2);
    if (g_3B4E == 2)
        fn_0000_0A6B(g_3AF2, 0xA800);
    blit_dispatch(g_3AF2, 0, 0, 40, 200);
    k = wait_key(1);
    if (k != 27)
        k = wait_key(1);
    return k;
}

/* FUNCTION: DONALD 0304:1E5B */
void about(void)
{
    fn_0000_08B9();
    set_and_redraw(2);
    draw_line((g_1ED8 - 1) << 3, (g_1EDA - 1) << 3, ((g_1ED8 + g_1EDC + 1) << 3) - 1, (g_1EDA - 1) << 3, 15);
    draw_line((g_1ED8 - 1) << 3, ((g_1EDA + g_1EDE + 1) << 3) - 1, ((g_1ED8 + g_1EDC + 1) << 3) - 1, ((g_1EDA + g_1EDE + 1) << 3) - 1, 15);
    draw_line((g_1ED8 - 1) << 3, (g_1EDA - 1) << 3, (g_1ED8 - 1) << 3, ((g_1EDA + g_1EDE + 1) << 3) - 1, 15);
    draw_line(((g_1ED8 + g_1EDC + 1) << 3) - 1, (g_1EDA - 1) << 3, ((g_1ED8 + g_1EDC + 1) << 3) - 1, ((g_1EDA + g_1EDE + 1) << 3) - 1, 15);
    print_wrapped(g_01A6);
    get_key();
    fn_0000_08B9();
}
