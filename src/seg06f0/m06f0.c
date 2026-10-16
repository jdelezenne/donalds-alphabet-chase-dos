/* Module at segment 06F0 (compiled without -O). Functions in address order. */
#include "donald.h"

long mem_read(int i, char far *buf, long len);

char far *strupr();
char far *fn_0000_115F();
char far *farmalloc();
void far inset_rect(int n);
void show_error(void);
extern char far *g_1F0E, far *g_1F12, far *g_1F2A;

/* FUNCTION: DONALD 06F0:000E */
void fatal(char far *msg)
{
    g_3B50 = msg;
    (*g_1F2E)();
    (*g_1F32)();
    quit(1);
}

/* FUNCTION: DONALD 06F0:0030 */
void quit(int code)
{
    shutdown();
    exit(code);
}

/* FUNCTION: DONALD 06F0:0043 */
int open_slot(char far *name, int mode)
{
    int oflag;
    int slot;
    register int fd;
    register int tries;

    switch (mode) {
    case 1:
        if (!is_loaded(name) && !file_exists(name)) {
            g_3B54 = lookup_value(name);
            if (g_3B56)
                music_toggle(g_3B54);
        }
        oflag = 0x8001;
        break;
    case 2:
        oflag = 0x8002;
        delete_ok(name);
    case 3:
        tries = g_1F36;
        if (!file_exists(name)) {
            while (!create_file(name) && tries--) {
                g_3B50 = g_1EF2;
                (*g_1F2E)();
            }
            if (!file_exists(name)) {
                (*g_1F32)();
                quit(1);
            }
        }
        if (mode == 3)
            oflag = 0x8004;
        break;
    default:
        g_3B50 = g_1EF6;
        (*g_1F2E)();
        (*g_1F32)();
        quit(1);
        break;
    }
    if (!is_loaded(name)) {
        tries = g_1F36;
        fd = open(name, oflag);
        while (fd == -1 && tries) {
            fd = open(name, oflag);
            if (fd == -1) {
                tries--;
                g_3B54 = lookup_value(name);
                g_3B50 = g_1EFA;
                (*g_1F2E)();
            }
        }
        if (fd == -1) {
            (*g_1F32)();
            quit(1);
        }
    } else {
        fd = find_name(name);
        g_1772[fd].pos = 0;
        fd = fd | 0x8000;
    }
    slot = 10;
    for (tries = 0; tries < 10; tries++)
        if (g_3B58[tries] == 0x7fff) {
            slot = tries;
            break;
        }
    if (slot == 10) {
        g_3B50 = g_1EFE;
        (*g_1F2E)();
        (*g_1F32)();
    }
    g_3B58[slot] = fd;
    return slot;
}

/* FUNCTION: DONALD 06F0:0245 */
void close_slot(register int i)
{
    if (g_3B58[i] == 0x7fff)
        fatal(g_1F02);
    if (!(g_3B58[i] & 0x8000))
        close(g_3B58[i]);
    g_3B58[i] = 0x7fff;
}

/* FUNCTION: DONALD 06F0:028D */
long read_file(register int slot, char far *buf, long len)
{
    register unsigned n;
    long total;

    if (g_3B58[slot] == 0x7fff)
        fatal(g_1F06);
    if (g_3B58[slot] & 0x8000)
        return mem_read(g_3B58[slot] & 0x7fff, buf, len);
    total = 0;
    while (len > 0xFA00L) {
        n = read(g_3B58[slot], buf, 0xFA00);
        len -= 0xFA00;
        if (n == -1)
            return 0L;
        else
            total += n;
    }
    n = read(g_3B58[slot], buf, len);
    if (n == -1)
        return 0L;
    return n + total;
}

/* FUNCTION: DONALD 06F0:0373 */
long write_file(register int slot, char far *buf, long len)
{
    register unsigned n;
    long total;

    if (g_3B58[slot] == 0x7fff)
        fatal(g_1F0A);
    if (g_3B58[slot] & 0x8000)
        fatal(g_1F16);
    total = 0;
    while (len > 0xFA00L) {
        n = write(g_3B58[slot], buf, 0xFA00);
        if (n == -1)
            return 0L;
        len -= 0xFA00;
        total += n;
    }
    n = write(g_3B58[slot], buf, len);
    if (n == -1)
        return 0L;
    return n + total;
}

/* FUNCTION: DONALD 06F0:0442 */
long seek_slot(register int slot, long off, int whence)
{
    long pos;
    register int i;

    if (g_3B58[slot] == 0x7fff)
        fatal(g_1F0E);
    if (g_3B58[slot] & 0x8000) {
        i = g_3B58[slot] & 0x7fff;
        pos = g_1772[i].pos;
        switch (whence) {
        case 0:
            if (g_1772[i].size < off)
                pos = g_1772[i].size;
            else
                pos = off;
            break;
        case 2:
            pos = g_1772[i].size;
        case 1:
            if (pos + off > g_1772[i].size)
                pos = g_1772[i].size;
            else if (pos + off < 0)
                pos = 0;
            else
                pos += off;
            break;
        default:
            fatal(g_1F12);
            break;
        }
        g_1772[i].pos = pos;
        return pos;
    }
    switch (whence) {
    case 0:
    case 1:
    case 2:
        break;
    default:
        fatal(g_1F12);
        break;
    }
    return lseek(g_3B58[slot], off, whence);
}

/* FUNCTION: DONALD 06F0:0620 */
int file_exists(char far *name)
{
    register int fd;

    fd = open(name, 0x8001);
    if (fd == -1)
        return 0;
    close(fd);
    return 1;
}

/* FUNCTION: DONALD 06F0:0650 */
int delete_ok(char far *name)
{
    return !unlink(name);
}

/* FUNCTION: DONALD 06F0:0669 */
int create_file(char far *name)
{
    register int fd;

    fd = open(name, 0x8102, 0x180);
    if (fd == -1)
        return 0;
    close(fd);
    return 1;
}

/* FUNCTION: DONALD 06F0:069D */
int lookup_value(char far *name)
{
    register int i = 0;

    name = strupr(name);
    for (; *g_1772[i].name; i++)
        if (strcmp(g_1772[i].name, name) == 0)
            return g_1772[i].value;
    fatal(g_1F1A);
}

/* FUNCTION: DONALD 06F0:071F */
void show_error(void)
{
    int alloc;
    int bg;
    char ch;
    long sz;
    register int oldwin;
    register int fg;

    ch = 'A';
    oldwin = g_1ED6;
    set_window(g_1F3E);
    alloc = 0;
    if (g_1F3A == 0) {
        sz = g_1EDC * g_1EDE;
        alloc = 5;
        if (g_videoMode == 3)
            alloc = 6;
        sz <<= alloc;
        g_1F3A = farmalloc(sz);
        alloc = 1;
    }
    fn_0000_277E(g_1ED8, g_1EDA, g_1EDC, g_1EDE, g_1F3A);
    redraw_rect();
    draw_line(g_1ED8 << 3, g_1EDA << 3, ((g_1ED8 + g_1EDC) << 3) - 1, g_1EDA << 3, 15);
    draw_line(g_1ED8 << 3, ((g_1EDA + g_1EDE) << 3) - 1, ((g_1ED8 + g_1EDC) << 3) - 1, ((g_1EDA + g_1EDE) << 3) - 1, 15);
    draw_line(g_1ED8 << 3, g_1EDA << 3, g_1ED8 << 3, ((g_1EDA + g_1EDE) << 3) - 1, 15);
    draw_line(((g_1ED8 + g_1EDC) << 3) - 1, g_1EDA << 3, ((g_1ED8 + g_1EDC) << 3) - 1, ((g_1EDA + g_1EDE) << 3) - 1, 15);
    inset_rect(-1);
    if (g_3B50 == g_1EFA) {
        g_3B50[12] = ch + g_3B54;
        if (g_3AFC == 0)
            g_3B50[23] = g_3AF6 + 'A';
    }
    fg = g_1EE0;
    bg = g_1EE2;
    g_1EE0 = 15;
    g_1EE2 = 0;
    print_wrapped(g_3B50);
    g_1EE0 = fg;
    g_1EE2 = bg;
    get_key();
    inset_rect(1);
    blit_generic(g_1ED8, g_1EDA, g_1EDC, g_1EDE, g_1F3A);
    set_window(oldwin);
    if (alloc) {
        farfree(g_1F3A);
        g_1F3A = 0;
    }
}

/* FUNCTION: DONALD 06F0:097C */
void error_msg(void)
{
    g_3B50 = g_1F2A;
    show_error();
}

/* FUNCTION: DONALD 06F0:098D */
void free_all(void)
{
    register int i;

    for (i = 0; *g_1772[i].name; i++)
        if (g_1772[i].data) {
            farfree(g_1772[i].data);
            g_1772[i].data = 0L;
        }
    for (i = 0; i < 10; i++)
        if (g_3B58[i] != 0x7fff)
            fatal(g_1F22);
}

/* FUNCTION: DONALD 06F0:0A23 */
void load_resources(void)
{
    char far *buf;
    int avail;
    int need;
    register int i;
    register int fd;

    for (i = 0; i < 10; i++)
        g_3B58[i] = 0x7fff;
    avail = fn_0000_0EFE() - g_1F38;
    i = 0;
    g_3B56 = i;
    while (*g_1772[i].name) {
        g_3B56 |= g_1772[i].value;
        if (g_3B6C) {
            g_1772[i].name = strupr(g_1772[i].name);
            need = g_1772[i].size / 1024L + 1;
            if (avail >= need)
                buf = farmalloc(g_1772[i].size);
            else
                buf = 0;
            if (buf == 0) {
                i++;
                continue;
            }
            fd = open(g_1772[i].name, 0x8001);
            if (fd == -1) {
                farfree(buf);
                i++;
                continue;
            }
            if ((long)read(fd, buf, g_1772[i].size) == g_1772[i].size) {
                g_1772[i].data = buf;
                close(fd);
                i++;
                avail -= need;
            } else {
                farfree(buf);
                i++;
                continue;
            }
        } else
            i++;
    }
}

/* FUNCTION: DONALD 06F0:0BFC */
int is_loaded(char far *name)
{
    register int i = 0;

    name = strupr(name);
    for (; *g_1772[i].name; i++)
        if (strcmp(g_1772[i].name, name) == 0) {
            if (g_1772[i].data)
                return 1;
            else
                return 0;
        }
    return 0;
}

/* FUNCTION: DONALD 06F0:0C83 */
int find_name(char far *name)
{
    register int i = 0;

    name = strupr(name);
    for (; *g_1772[i].name; i++)
        if (strcmp(g_1772[i].name, name) == 0)
            return i;
    fatal(g_1F1E);
}

/* FUNCTION: DONALD 06F0:0CF4 */
long mem_read(register int i, char far *buf, long len)
{
    char far *src;

    if (g_1772[i].pos + len > g_1772[i].size)
        len = g_1772[i].size - g_1772[i].pos;
    src = fn_0000_115F(g_1772[i].data + g_1772[i].pos);
    fn_0000_0A2E(src, buf, len);
    g_1772[i].pos += len;
    return len;
}

/* FUNCTION: DONALD 06F0:0DF9 */
void inset_rect(register int n)
{
    g_1ED8 -= n;
    g_1EDA -= n;
    g_1EDC += n * 2;
    g_1EDE += n * 2;
}
