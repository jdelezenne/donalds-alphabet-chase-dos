/* Module at segment 06F0 (compiled without -O). Functions in address order. */
#include "donald.h"

long mem_read(int i, char far *buf, long len);

struct name_entry { char far *name; long size; char far *data; int value; long pos; };
extern struct name_entry g_1772[];
char far *fn_08E1_0003();
char far *fn_0000_115F();

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
    fn_04FC_0142();
    exit(code);
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
        n = read(g_3B58[slot], buf, 0xFA00);
        if (n == -1)
            return 0L;
        len -= 0xFA00;
        total += n;
    }
    n = read(g_3B58[slot], buf, len);
    if (n == -1)
        return 0L;
    return n + total;
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

    name = fn_08E1_0003(name);
    for (; *g_1772[i].name; i++)
        if (fn_087E_0009(g_1772[i].name, name) == 0)
            return g_1772[i].value;
    fatal(g_1F1A);
}

/* FUNCTION: DONALD 06F0:098D */
void free_all(void)
{
    register int i;

    for (i = 0; *g_1772[i].name; i++)
        if (g_1772[i].data) {
            free(g_1772[i].data);
            g_1772[i].data = 0L;
        }
    for (i = 0; i < 10; i++)
        if (g_3B58[i] != 0x7fff)
            fatal(g_1F22);
}

/* FUNCTION: DONALD 06F0:0BFC */
int is_loaded(char far *name)
{
    register int i = 0;

    name = fn_08E1_0003(name);
    for (; *g_1772[i].name; i++)
        if (fn_087E_0009(g_1772[i].name, name) == 0) {
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

    name = fn_08E1_0003(name);
    for (; *g_1772[i].name; i++)
        if (fn_087E_0009(g_1772[i].name, name) == 0)
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
