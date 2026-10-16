/* Module at segment 06F0 (compiled without -O). Functions in address order. */
#include "donald.h"

struct name_entry { char far *name; char pad[8]; int value; char pad2[4]; };
extern struct name_entry g_1772[];
char far *fn_08E1_0003();

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

/* FUNCTION: DONALD 06F0:0DF9 */
void inset_rect(register int n)
{
    g_1ED8 -= n;
    g_1EDA -= n;
    g_1EDC += n * 2;
    g_1EDE += n * 2;
}
