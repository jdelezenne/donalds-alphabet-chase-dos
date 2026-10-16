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
char msg_cga[] = "\n\r\nA CGA ";
char msg_ega[] = "\n\r\nAn EGA ";
char msg_tandy[] = "\n\r\nA TANDY ";
char msg_detected[] = "graphic card has been detected.  If you wish to\n\roverride this choice, you will have 20 seconds to do so.\n\r\n\rInput graphics mode, 1:CGA 2:EGA/VGA 3:TANDY";
char str_lf = 10;
char str_cr = 13;
char pad_0151[1] = {0};
char pal_level[16] = {0, 5, 3, 2, 10, 14, 12, 6, 4, 11, 9, 1, 0, 8, 7, 15};
int group_scene_pic[] = {15, 13, 12, 14, 17, 16};
int group_letters_pic[] = {5, 3, 1, 7, 2, 0};
int group_donald_pic[] = {6, 11, 4, 9, 8, 10};
char pal_title[16] = {1, 5, 3, 2, 10, 14, 12, 6, 4, 11, 9, 1, 0, 8, 7, 15};
char pal_ending[16] = {1, 5, 3, 2, 10, 14, 12, 6, 4, 11, 9, 1, 0, 8, 7, 15};
char msg_insert_disk[100] = "Please make sure that Donald's Alphabet Chase disk is in the disk drive, then press the space bar.";

/* Uninitialised data (_BSS): DGROUP 3868-3AE3 (ownership inferred, see docs/MATCHING.md). */
int jump_right;
int slot_x[8];
int slot_y[8];
int g_group;
int slot_frame[8];
int jump_x_major;
int slot_shown[8];
int jump_major;
int jump_minor;
int g_keysEnabled;
char far *g_packBuf;
int jump_steps;
char far *slot_pc[8];
int g_letterPicked;
int jump_err;
int g_idleTicks;
int g_pickedLetter;
char unused_38E2[40];
int slot_delay[8];
int g_gameWon;
int slot_w[8];
int slot_timer[8];
char far *g_workBuf;
int g_letterDone[26];
int slot_flag[8];
char far *g_sprites[70];
char unused_3A9C[2];
int slot_h[8];
int g_letterScore[26];
int g_jumping;

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
            if (slot_shown[i] == -1)
                continue;
            for (j = 0; j < 8; j++) {
                if (j == i)
                    continue;
                x1 = (slot_x[i] >> 3) - 1;
                x2 = slot_w[i] + x1 + 2;
                y1 = (slot_y[i] >> 3) - 1;
                y2 = slot_h[i] + y1 + 2;
                ox1 = slot_x[j] >> 3;
                ox2 = slot_w[j] + ox1;
                oy1 = slot_y[j] >> 3;
                oy2 = slot_h[j] + oy1;
                if (slot_h[i] != 3 && slot_h[i] != 8) {
                    x1--;
                    x2++;
                }
                if (x1 <= ox2 && x2 >= ox1 && y1 <= oy2 && y2 >= oy1)
                    slot_shown[j] = slot_frame[j];
            }
        }
}

/* FUNCTION: DONALD 0304:0187 */

void draw_items(int mode)
{
    register int i;
    register int grow;
    int padX, padY;

    for (i = 0; i < 8; i++) {
        padX = 1;
        padY = 8;
        grow = 2;
        if (slot_h[i] != 3 && slot_h[i] != 8) {
            padX = grow;
            padY = 16;
            grow = 4;
        }
        if (slot_shown[i] != -1)
            draw_item(mode, (slot_x[i] >> 3) - padX, slot_y[i] - padY, slot_w[i] + grow, (slot_h[i] + grow) << 3);
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
            src = g_videoMem;
            dst = g_backBuf;
            break;
        case 1:
            src = g_backBuf;
            dst = g_videoMem;
            break;
        case 2:
            src = g_backBuf;
            dst = g_workBuf;
            break;
        case 3:
            src = g_workBuf;
            dst = g_backBuf;
            break;
        case 4:
            src = g_videoMem;
            dst = g_workBuf;
            break;
        case 5:
            src = g_workBuf;
            dst = g_videoMem;
            break;
        }
    }
    copy_rect_ega(src, dst, x, y, w, h);
}

/* FUNCTION: DONALD 0304:0383 */
void step(register int i)
{
    if (jump_x_major) {
        if (jump_right)
            slot_x[i] += 8;
        else
            slot_x[i] -= 8;
    } else
        slot_y[i] -= 8;
    jump_err -= jump_minor;
    if (jump_err < 0) {
        jump_err += jump_major;
        if (!jump_x_major) {
            if (jump_right)
                slot_x[i] += 8;
            else
                slot_x[i] -= 8;
        } else
            slot_y[i] -= 8;
    }
}

/* FUNCTION: DONALD 0304:03FC */
void draw_frame(int mode, register int i, register int x, int y)
{
    char far *p;

    p = g_backBuf;
    if (g_videoMode == 2)
        p = (char far *)0xA8000000L;
    g_windows[1].x = 0;
    g_windows[1].w = 40;
    g_windows[1].y = 0;
    g_windows[1].h = 25;
    switch (mode) {
    case 0:
        draw_sprite(g_videoMem, g_sprites[i], x, y, 1);
        break;
    case 1:
        draw_sprite(p, g_sprites[i], x, y, 1);
        break;
    case 2:
        draw_sprite_masked(p, g_sprites[i], x, y, 1);
        break;
    case 3:
        draw_sprite_masked(g_videoMem, g_sprites[i], x, y, 1);
        break;
    }
}

/* FUNCTION: DONALD 0304:04F9 */
void next_level(void)
{
    char i, sum;

    for (i = sum = 0; i < 26; i++)
        sum += g_letterScore[i];
    if (sum < 26) {
        do {
            g_group++;
            if (g_group >= 6)
                g_group = 0;
            sum = 0;
            for (i = g_groupFirst[g_group]; i < g_groupFirst[g_group + 1]; i++)
                sum += g_letterScore[i];
        } while (sum == group_letter_count[g_group]);
        i = 0;
        if (key_ready())
            i = handle_key();
        if (i == 0 || i == 27) {
            load_level_gfx();
            reset_actors();
        }
    } else
        g_gameWon = 1;
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
        dos_putc(str_lf);
        dos_putc(str_cr);
    }
    i = 0;
    if (rom_check()) {
        g_videoMode = 1;
        while (msg_tandy[i])
            dos_putc(msg_tandy[i++]);
    } else if (ega_present()) {
        g_videoMode = 2;
        while (msg_ega[i])
            dos_putc(msg_ega[i++]);
    } else {
        g_videoMode = 0;
        while (msg_cga[i])
            dos_putc(msg_cga[i++]);
    }
    i = 0;
    while (msg_detected[i])
        dos_putc(msg_detected[i++]);
    i = 0;
    time(&t0);
    do {
        if (key_ready())
            i = get_key();
        time(&t1);
    } while (!i && t1 - t0 < 20);
    time(&g_randSeed);
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

    for (i = g_groupFirst[g_group]; i < g_groupFirst[g_group + 1]; i++)
        sum += g_letterScore[i];
    if (group_letter_count[g_group] > sum)
        sum = 0;
    return sum;
}

/* FUNCTION: DONALD 0304:0776 */
void aim(int i)
{
    register int d;
    register int target;
    int x, y, t;

    target = *slot_pc[i];
    x = slot_x[i] >> 3;
    y = slot_y[i] >> 3;
    if (x >= target) {
        d = x - target;
        jump_right = 0;
    } else {
        d = target - x;
        jump_right = 1;
    }
    t = y;
    if (d >= t) {
        jump_major = d;
        jump_minor = t;
        jump_x_major = 1;
    } else {
        jump_major = t;
        jump_minor = d;
        jump_x_major = 0;
    }
    jump_err = jump_major >> 1;
    jump_steps = jump_major;
}

/* FUNCTION: DONALD 0304:080E */
void reset_actors(void)
{
    register int i;

    for (i = 0; i < 8; i++) {
        slot_w[i] = slot_h[i] = 3;
        slot_pc[i] = g_scriptTable[SCR_IDLE];
        slot_x[i] = -160;
        slot_y[i] = 0;
        slot_timer[i] = slot_delay[i] = 10;
        slot_frame[i] = -1;
    }
    slot_w[7] = slot_h[7] = 8;
    slot_pc[7] = g_scriptTable[SCR_DONALD];
    slot_pc[5] = g_scriptTable[SCR_BUBBLE];
    slot_x[5] = 0x128;
    slot_y[5] = slot_frame[5] = 0;
    slot_timer[5] = slot_delay[5] = 20;
    init_slots();
}

/* FUNCTION: DONALD 0304:08B1 */
void setup_level(int lv)
{
    char i;

    for (i = 0; i < 8; i++)
        slot_timer[i] = 0;
    for (i = 0; i < 5; i++) {
        slot_pc[i] = g_scriptTable[SCR_PICK_LETTER];
        slot_h[i] = 3;
    }
    slot_h[5] = 3;
    slot_h[6] = 3;
    pick_frame1 = pick_frame2 = letter_frame[lv];
    slot_pc[6] = g_scriptTable[SCR_PICK_HELPER];
    init_slots();
}

/* FUNCTION: DONALD 0304:093C */
void show_picture(register int n)
{
    char c;

    load_file(g_cmpFiles[n].name, g_workBuf);
    if (pic_needs_ega[n]) {
        c = 0;
        if (g_videoMode == 0) {
            set_palette16(g_palettes[n]);
            c = g_videoMode = 1;
            set_video_type(g_videoMode);
        }
        draw_pic(g_workBuf, g_backBuf);
        if (c) {
            g_videoMode = 0;
            set_video_type(0);
            clear_buffer(g_backBuf, 0);
        }
    } else {
        if (g_videoMode == 0)
            set_palette16(g_palettes[n]);
        draw_pic(g_workBuf, g_backBuf);
        if (g_videoMode == 2)
            present_buffer(g_backBuf, 0xA800);
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
        if (g_sprites[i] != (char far *)-1L) {
            free(g_sprites[i]);
            g_sprites[i] = (char far *)-1L;
        }
    for (i = 57; i < 65; i++)
        if (g_sprites[i] != (char far *)-1L) {
            free(g_sprites[i]);
            g_sprites[i] = (char far *)-1L;
        }
    show_picture(group_letters_pic[g_group]);
    for (i = 1; i < 28; i++)
        g_sprites[i + 3] = grab(((i - 1) % 13) * 3, ((i - 1) / 13) * 24, 3, 24);
    show_picture(group_donald_pic[g_group]);
    for (i = 57; i < 65; i++)
        g_sprites[i] = grab(((i - 57) % 5) * 8, ((i - 57) / 5) * 64, 8, 64);
    show_picture(group_scene_pic[g_group]);
    if (g_videoMode)
        ega_select_palette(0);
    set_palette(pal_level);
    blit_dispatch(g_backBuf, 0, 0, 40, 200);
    draw_item(0, 0, 0, 40, 200);
    draw_item(4, 0, 0, 40, 200);
    g_idleTicks = 0;
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
        g_sprites[i] = (char far *)-1L;
    set_palette(pal_title);
    if (g_videoMode)
        ega_select_palette(1);
    kbd_flush();
    show_picture(26);
    blit_dispatch(g_backBuf, 0, 0, 40, 200);
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
        g_sprites[i] = grab(((i - 41) % 5) * 8, ((i - 41) / 5) * 64, 8, 64);
    show_picture(24);
    g_sprites[56] = grab(0, 0, 8, 64);
    show_picture(23);
    g_sprites[1] = grab(0, 0, 1, 1);
    g_sprites[2] = grab(3, 0, 1, 1);
    g_sprites[3] = grab(6, 0, 3, 24);
    for (i = 57; i < 65; i++)
        g_sprites[i] = grab(((i - 57) % 5) * 8, ((i - 57) / 5) * 64, 8, 64);
    for (i = 1; i < 28; i++)
        g_sprites[i + 3] = grab(((i - 1) % 13) * 3, ((i - 1) / 13) * 24, 3, 24);
    key = 1;
    if (!key)
        key = 27;
    if (key != 27)
        key = 0;
    while (key != 27) {
        for (i = 0; i < 26; i++)
            g_letterScore[i] = g_letterDone[i] = 0;
        i = 0; g_gameWon = 0; g_idleTicks = 0; g_letterPicked = 0; g_keysEnabled = g_group = g_jumping = 0;
        load_level_gfx();
        reset_actors();
        last = now = timer_ticks();
        for (i = 0; i < 8; i++)
            draw_item(4, (slot_x[i] >> 3) - 1, slot_y[i] - 8, slot_w[i] + 2, (slot_h[i] + 2) << 3);
        for (;;) {
            g_idleTicks++;
            draw_items(3);
            for (i = 0; i < 8; i++) {
                slot_shown[i] = run_script(i);
                if (slot_shown[i] != -1)
                    slot_frame[i] = slot_shown[i];
            }
            for (i = 0; i < 8; i++)
                if (slot_shown[i] != -1) {
                    i = 0;
                    break;
                }
            if (!i) {
                check_collisions();
                draw_items(2);
                for (i = 0; i < 8; i++)
                    if (slot_shown[i] != -1 && slot_shown[i] != 0) {
                        if (slot_flag[i] == 0)
                            draw_frame(1, slot_frame[i], slot_x[i], slot_y[i]);
                        else
                            draw_frame(2, slot_frame[i], slot_x[i], slot_y[i]);
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
            if (g_gameWon) {
                key = ending();
                break;
            }
        }
    }
    for (i = 1; i < 65; i++)
        if (g_sprites[i] != (char far *)-1L)
            free(g_sprites[i]);
    free(g_workBuf);
}

/* FUNCTION: DONALD 0304:1061 */
int handle_key(void)
{
    register int key = 0;
    register int r;

    if (!g_keysEnabled) {
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
    if (key && key != 27 && !g_letterPicked && key != '1') {
        r = level_sum();
        if (r)
            goto done;
        key -= 'A';
        if (g_letterScore[key])
            goto clear;
        g_idleTicks = 0;
        for (r = 5; r >= 0; r--)
            if (g_groupFirst[r] <= key)
                break;
        if (r != g_group) {
            g_group = r;
            load_level_gfx();
            reset_actors();
        } else if (key != g_curLetter)
            setup_level(key);
        else
            play_sound(0);
        g_curLetter = g_pickedLetter = key;
        g_letterPicked = 1;
        g_letterDone[g_pickedLetter] = 1;
        slot_pc[5] = g_scriptTable[SCR_BUBBLE];
        bubble_arg2 = 0;
        bubble_arg1 = 3;
        bubble_frame = (key - g_groupFirst[g_group]) * 4 + 1;
        goto done;
    }
    if (key != '1')
        goto done;
    snd_play(g_tunes[4]);
    g_soundOn ^= 1;
    if (!g_soundOn)
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

    if (slot_timer[i]) {
        slot_timer[i]--;
        if (g_videoMode == 1 && slot_timer[i])
            slot_timer[i]--;
        return -1;
    }
    slot_timer[i] = slot_delay[i];
    slot_flag[i] = 0;
    cont = 1;
    r = -1;
    while (r < 0 && cont != -1) {
        r = *slot_pc[i]++;
        if (r < 0)
        switch (r) {
        case -1:
            if (slot_x[i] >> 3 == *slot_pc[i]) {
                slot_pc[i] += 3;
                break;
            }
            if (slot_x[i] >> 3 < *slot_pc[i])
                slot_x[i] += 8;
            else {
                slot_x[i] -= 8;
                slot_flag[i] = 1;
            }
            slot_frame[i]++;
            if (slot_frame[i] > slot_pc[i][2])
                slot_frame[i] = slot_pc[i][1];
            if (slot_frame[i] < slot_pc[i][1])
                slot_frame[i] = slot_pc[i][1];
        back:
            slot_pc[i]--;
            r = slot_frame[i];
            break;
        case -2:
            r = cont = -1;
            slot_pc[i] = g_scriptTable[SCR_IDLE];
            break;
        case -3:
            slot_x[i] = *slot_pc[i]++ << 3;
            slot_y[i] = *slot_pc[i]++ << 3;
            break;
        case -4:
            slot_delay[i] = slot_timer[i] = *slot_pc[i]++;
            break;
        case -5:
            if ((t = level_sum()) != 0) {
                slot_pc[i] = g_scriptTable[SCR_LEVEL_DONE];
                break;
            }
            if (!g_letterPicked) {
                if (g_idleTicks > 5000) {
                    slot_pc[i] = g_scriptTable[SCR_IDLE_TIMEOUT];
                    g_idleTicks = 0;
                    break;
                }
                do
                    j = roll(1, group_letter_count[g_group], group_roll_base[g_group]);
                while (g_letterScore[j]);
                slot_pc[j - g_groupFirst[g_group]] = g_scriptTable[j];
                g_curLetter = j;
                slot_pc[5] = g_scriptTable[SCR_BUBBLE];
                bubble_arg1 = 3;
                bubble_arg2 = 0;
                bubble_frame = ((j - g_groupFirst[g_group]) << 2) + 1;
                break;
            } else {
                if (g_curLetter == g_pickedLetter)
                    break;
                g_curLetter = j = g_pickedLetter;
                slot_pc[j - g_groupFirst[g_group]] = g_scriptTable[j];
                break;
            }
        case -6:
            if (slot_x[7] >> 3 == *slot_pc[i])
                slot_pc[i]++;
            else {
        back3:
                slot_pc[i]--;
                r = cont = -1;
            }
            break;
        case -7:
            j = *slot_pc[i]++;
            if (*slot_pc[i]++ < slot_x[j] >> 3)
                goto back2;
            else
                slot_pc[i]++;
            break;
        case -8:
            j = *slot_pc[i]++;
            if (*slot_pc[i]++ != slot_x[j] >> 3)
                goto back2;
            else
                goto inc;
            break;
        case -9:
            slot_h[i]++;
            break;
        case -10:
            slot_h[i]--;
            break;
        case -11:
            j = *slot_pc[i]++;
            j = roll(1, j, -1);
            slot_pc[i] += j;
            slot_pc[i] = g_scriptTable[*slot_pc[i]];
            break;
        case -12:
            slot_flag[i] = 1;
            break;
        case -13:
            if (rand8() & 1)
                slot_pc[i] += *slot_pc[i];
            else
                slot_pc[i]++;
            break;
        case -14:
            if (rand8() & 3)
                slot_pc[i]++;
            else
        back2:
                slot_pc[i] -= *slot_pc[i];
            break;
        case -15:
            next_level();
            break;
        case -16:
            if (slot_y[7] >> 3 != *slot_pc[i])
                goto back3;
            else
                goto inc;
            break;
        case -17:
            if ((slot_x[i] >> 3) + *slot_pc[i] != slot_x[7] >> 3)
                goto back3;
            else
                slot_pc[i]++;
            break;
        case -18:
            if (g_letterDone[g_groupFirst[g_group] + i] == 0)
                slot_pc[i]++;
            else {
                slot_pc[i] += *slot_pc[i];
                g_letterScore[g_groupFirst[g_group] + i] = 1;
            }
            break;
        case -19:
            slot_pc[7][3] = *slot_pc[i]++ + (slot_x[i] >> 3);
            break;
        case -20:
            if (!g_jumping) {
                slot_timer[i] = slot_delay[i] = 4;
                g_jumping++;
                aim(i);
                bubble_arg1 = bubble_arg2 = 0;
                slot_pc[5] = g_scriptTable[SCR_BUBBLE];
                bubble_frame = 0x25;
                play_sound(11);
            }
            if (jump_steps) {
                step(i);
                jump_steps--;
            }
            if (!jump_steps) {
                g_letterPicked = 0;
                g_jumping = 0;
                slot_pc[i]++;
                play_sound(10);
            } else
                slot_pc[i]--;
            r = slot_frame[i];
            break;
        case -22:
            init_slots();
            break;
        case -23:
            slot_pc[0] = g_scriptTable[group_intro_script[g_group]];
            break;
        case -24:
            if (*slot_pc[i]++ == g_group)
                slot_pc[i] += *slot_pc[i];
            else
                slot_pc[i]++;
            break;
        case -21:
            slot_pc[i] += *slot_pc[i];
            break;
        case -25:
            j = *slot_pc[i]++;
            slot_pc[j] = g_scriptTable[*slot_pc[i]++];
            slot_timer[j] = 0;
            break;
        case -26:
            slot_x[i] += 8;
            break;
        case -28:
            slot_x[i] -= 8;
            break;
        case -30:
            slot_x[i] += 8;
            slot_y[i] += 8;
            break;
        case -31:
            slot_x[i] += 8;
            slot_y[i] -= 8;
            break;
        case -32:
            slot_x[i] -= 8;
        case -27:
            slot_y[i] += 8;
            break;
        case -33:
            slot_x[i] -= 8;
        case -29:
            slot_y[i] -= 8;
            break;
        case -34:
            slot_x[i] += 8;
            r = slot_frame[i];
            break;
        case -36:
            slot_x[i] -= 8;
            r = slot_frame[i];
            break;
        case -38:
            slot_x[i] += 8;
            slot_y[i] += 8;
            r = slot_frame[i];
            break;
        case -39:
            slot_x[i] += 8;
            slot_y[i] -= 8;
            r = slot_frame[i];
            break;
        case -40:
            slot_x[i] -= 8;
        case -35:
            slot_y[i] += 8;
            r = slot_frame[i];
            break;
        case -41:
            slot_x[i] -= 8;
        case -37:
            slot_y[i] -= 8;
            r = slot_frame[i];
            break;
        case -42:
            g_curLetter = -1;
            bubble_arg1 = bubble_arg2 = 0;
            slot_pc[5] = g_scriptTable[SCR_BUBBLE];
            bubble_frame = 0x25;
            break;
        case -43:
            if (!g_letterPicked)
        inc:
                slot_pc[i]++;
            else
                setup_level(g_curLetter);
            break;
        case -44:
            slot_x[i] = slot_x[7] + 16;
            slot_y[i] = 0x60;
            break;
        case -45:
            g_curLetter = -1;
            break;
        case -46:
            j = *slot_pc[i]++;
            play_sound(j);
            break;
        case -47:
            g_keysEnabled = 1;
            break;
        case -48:
            g_keysEnabled = 0;
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

    for (i = 0; i < group_letter_count[g_group]; i++)
        if (g_letterScore[g_groupFirst[g_group] + i]) {
            slot_x[i] = (i * 4 + 1) * 8;
            slot_y[i] = 0;
            slot_frame[i] = letter_frame[g_groupFirst[g_group] + i];
            slot_pc[i] = scr_letter_wait;
            slot_timer[i] = 0;
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
    load_file(g_cmpFiles[18].name, g_workBuf);
    load_file(g_cmpFiles[19].name, g_workBuf + 0x1b8a);
    load_file(g_cmpFiles[20].name, g_workBuf + 0x3714);
    load_file(g_cmpFiles[21].name, g_workBuf + 0x5910);
    if (g_videoMode == 0)
        set_palette16(g_palettes[18]);
    draw_pic(g_workBuf, g_backBuf);
    if (g_videoMode == 2)
        present_buffer(g_backBuf, 0xA800);
    blit_dispatch(g_backBuf, 0, 0, 40, 200);
    play_sound(24);
    draw_pic(g_workBuf + 0x1b8a, g_backBuf);
    if (g_videoMode == 2)
        present_buffer(g_backBuf, 0xA800);
    k = wait_key(0);
    if (k == 27)
        return k;
    blit_dispatch(g_backBuf, 0, 0, 40, 200);
    draw_pic(g_workBuf + 0x3714, g_backBuf);
    if (g_videoMode == 2)
        present_buffer(g_backBuf, 0xA800);
    k = wait_key(0);
    if (k == 27)
        return k;
    blit_dispatch(g_backBuf, 0, 0, 40, 200);
    draw_pic(g_workBuf + 0x5910, g_backBuf);
    if (g_videoMode == 2)
        present_buffer(g_backBuf, 0xA800);
    k = wait_key(0);
    if (k == 27)
        return k;
    blit_dispatch(g_backBuf, 0, 0, 40, 200);
    k = wait_key(0);
    if (k == 27)
        return k;
    play_sound(17);
    load_file(g_cmpFiles[22].name, g_workBuf);
    if (g_videoMode == 0)
        set_palette16(g_palettes[22]);
    set_palette(pal_ending);
    if (g_videoMode)
        ega_select_palette(1);
    draw_pic(g_workBuf, g_backBuf);
    if (g_videoMode == 2)
        present_buffer(g_backBuf, 0xA800);
    blit_dispatch(g_backBuf, 0, 0, 40, 200);
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
    draw_line((win_x - 1) << 3, (win_y - 1) << 3, ((win_x + win_w + 1) << 3) - 1, (win_y - 1) << 3, 15);
    draw_line((win_x - 1) << 3, ((win_y + win_h + 1) << 3) - 1, ((win_x + win_w + 1) << 3) - 1, ((win_y + win_h + 1) << 3) - 1, 15);
    draw_line((win_x - 1) << 3, (win_y - 1) << 3, (win_x - 1) << 3, ((win_y + win_h + 1) << 3) - 1, 15);
    draw_line(((win_x + win_w + 1) << 3) - 1, (win_y - 1) << 3, ((win_x + win_w + 1) << 3) - 1, ((win_y + win_h + 1) << 3) - 1, 15);
    print_wrapped(msg_insert_disk);
    get_key();
    clear_screen();
}


