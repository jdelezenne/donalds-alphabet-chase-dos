/* Module at segment 06F0 (compiled without -O). Functions in address order. */
#include "donald.h"

long mem_read(int i, char far *buf, long len);

char far *strupr();
char far *normalize_ptr();
char far *farmalloc();
void far inset_rect(int n);
void show_error(void);
void error_msg(void);

/* Initialised data of this module: DGROUP 1ECE-2193 (pointer table, then TC's literal pool at 1F40).
   Ownership of 1ECE-1EF1 is inferred (it lies after seg0612's literals and before this module's table). */
int g_cgaSmallWin = 0;
int unused_1ED0[3] = {0, 0, 0};
int g_curWindow = 0;                         /* current window */
int win_x = 0, win_y = 0;             /* error box x, y (text cells) */
int win_w = 40, win_h = 25;           /* error box w, h */
int g_textFg = 15, g_textBg = 0;            /* text fg, bg */
int g_textCol = 0, g_textRow = 0, g_windowSet = 0;
int arrow_scancodes[4] = {-72, -80, -75, -77};
char far *msg_err_create = "Could not create the file on disk...";
char far *msg_err_mode = "Illegal MODE in Open_File...";
char far *msg_insert_disk_n = "Insert disk _ in drive _: and press a key...";
char far *msg_err_too_many = "Too many files open...";
char far *msg_err_close = "Attempting to close unopened file...";
char far *msg_err_read = "Attempting to read unopened file...";
char far *msg_err_write = "Attempting to write unopened file...";
char far *msg_err_seek = "Attempting to seek unopened file...";
char far *msg_err_seek_pos = "Illegal starting position in Seek_File...";
char far *msg_err_write_res = "Attempting to write a resident file...";
char far *msg_err_disk_num = "Attempting to Find_Disk_Number on unknown file...";
char far *msg_err_res_index = "Attempting to Get_Resident_Index on unknown file...";
char far *msg_err_open_files = "You are exiting with open files...";
char far *msg_err_write_io = "A write error has occurred.  Press a key.";
char far *msg_err_fatal = "A fatal disk error has occurred.  Now returning to DOS.";
void (far *g_errShowHook)(void) = show_error;  /* error box hooks */
void (far *g_errMsgHook)(void) = error_msg;
int g_diskRetries = 3;                         /* disk retries */
int g_memReserve = 200;                       /* memory reserve (paragraphs?) */
char far *g_errSaveBuf = 0;                   /* saved screen under the error box */
int g_errWindow = 0;

/* Uninitialised data (_BSS): DGROUP 3B4E-3B6D (ownership inferred, see docs/MATCHING.md). */
int g_videoMode;
char far *g_errMsg;
int g_diskNum;
int g_diskSwapOn;
int g_fileHandles[10];
int g_errHooked;

/* FUNCTION: DONALD 06F0:000E */
void fatal(char far *msg)
{
    g_errMsg = msg;
    (*g_errShowHook)();
    (*g_errMsgHook)();
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
            g_diskNum = lookup_value(name);
            if (g_diskSwapOn)
                music_toggle(g_diskNum);
        }
        oflag = 0x8001;
        break;
    case 2:
        oflag = 0x8002;
        delete_ok(name);
    case 3:
        tries = g_diskRetries;
        if (!file_exists(name)) {
            while (!create_file(name) && tries--) {
                g_errMsg = msg_err_create;
                (*g_errShowHook)();
            }
            if (!file_exists(name)) {
                (*g_errMsgHook)();
                quit(1);
            }
        }
        if (mode == 3)
            oflag = 0x8004;
        break;
    default:
        g_errMsg = msg_err_mode;
        (*g_errShowHook)();
        (*g_errMsgHook)();
        quit(1);
        break;
    }
    if (!is_loaded(name)) {
        tries = g_diskRetries;
        fd = open(name, oflag);
        while (fd == -1 && tries) {
            fd = open(name, oflag);
            if (fd == -1) {
                tries--;
                g_diskNum = lookup_value(name);
                g_errMsg = msg_insert_disk_n;
                (*g_errShowHook)();
            }
        }
        if (fd == -1) {
            (*g_errMsgHook)();
            quit(1);
        }
    } else {
        fd = find_name(name);
        g_cmpFiles[fd].pos = 0;
        fd = fd | 0x8000;
    }
    slot = 10;
    for (tries = 0; tries < 10; tries++)
        if (g_fileHandles[tries] == 0x7fff) {
            slot = tries;
            break;
        }
    if (slot == 10) {
        g_errMsg = msg_err_too_many;
        (*g_errShowHook)();
        (*g_errMsgHook)();
    }
    g_fileHandles[slot] = fd;
    return slot;
}

/* FUNCTION: DONALD 06F0:0245 */
void close_slot(register int i)
{
    if (g_fileHandles[i] == 0x7fff)
        fatal(msg_err_close);
    if (!(g_fileHandles[i] & 0x8000))
        close(g_fileHandles[i]);
    g_fileHandles[i] = 0x7fff;
}

/* FUNCTION: DONALD 06F0:028D */
long read_file(register int slot, char far *buf, long len)
{
    register unsigned n;
    long total;

    if (g_fileHandles[slot] == 0x7fff)
        fatal(msg_err_read);
    if (g_fileHandles[slot] & 0x8000)
        return mem_read(g_fileHandles[slot] & 0x7fff, buf, len);
    total = 0;
    while (len > 0xFA00L) {
        n = read(g_fileHandles[slot], buf, 0xFA00);
        len -= 0xFA00;
        if (n == -1)
            return 0L;
        else
            total += n;
    }
    n = read(g_fileHandles[slot], buf, len);
    if (n == -1)
        return 0L;
    return n + total;
}

/* FUNCTION: DONALD 06F0:0373 */
long write_file(register int slot, char far *buf, long len)
{
    register unsigned n;
    long total;

    if (g_fileHandles[slot] == 0x7fff)
        fatal(msg_err_write);
    if (g_fileHandles[slot] & 0x8000)
        fatal(msg_err_write_res);
    total = 0;
    while (len > 0xFA00L) {
        n = write(g_fileHandles[slot], buf, 0xFA00);
        if (n == -1)
            return 0L;
        len -= 0xFA00;
        total += n;
    }
    n = write(g_fileHandles[slot], buf, len);
    if (n == -1)
        return 0L;
    return n + total;
}

/* FUNCTION: DONALD 06F0:0442 */
long seek_slot(register int slot, long off, int whence)
{
    long pos;
    register int i;

    if (g_fileHandles[slot] == 0x7fff)
        fatal(msg_err_seek);
    if (g_fileHandles[slot] & 0x8000) {
        i = g_fileHandles[slot] & 0x7fff;
        pos = g_cmpFiles[i].pos;
        switch (whence) {
        case 0:
            if (g_cmpFiles[i].size < off)
                pos = g_cmpFiles[i].size;
            else
                pos = off;
            break;
        case 2:
            pos = g_cmpFiles[i].size;
        case 1:
            if (pos + off > g_cmpFiles[i].size)
                pos = g_cmpFiles[i].size;
            else if (pos + off < 0)
                pos = 0;
            else
                pos += off;
            break;
        default:
            fatal(msg_err_seek_pos);
            break;
        }
        g_cmpFiles[i].pos = pos;
        return pos;
    }
    switch (whence) {
    case 0:
    case 1:
    case 2:
        break;
    default:
        fatal(msg_err_seek_pos);
        break;
    }
    return lseek(g_fileHandles[slot], off, whence);
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
    for (; *g_cmpFiles[i].name; i++)
        if (strcmp(g_cmpFiles[i].name, name) == 0)
            return g_cmpFiles[i].value;
    fatal(msg_err_disk_num);
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
    oldwin = g_curWindow;
    set_window(g_errWindow);
    alloc = 0;
    if (g_errSaveBuf == 0) {
        sz = win_w * win_h;
        alloc = 5;
        if (g_videoMode == 3)
            alloc = 6;
        sz <<= alloc;
        g_errSaveBuf = farmalloc(sz);
        alloc = 1;
    }
    save_window(win_x, win_y, win_w, win_h, g_errSaveBuf);
    redraw_rect();
    draw_line(win_x << 3, win_y << 3, ((win_x + win_w) << 3) - 1, win_y << 3, 15);
    draw_line(win_x << 3, ((win_y + win_h) << 3) - 1, ((win_x + win_w) << 3) - 1, ((win_y + win_h) << 3) - 1, 15);
    draw_line(win_x << 3, win_y << 3, win_x << 3, ((win_y + win_h) << 3) - 1, 15);
    draw_line(((win_x + win_w) << 3) - 1, win_y << 3, ((win_x + win_w) << 3) - 1, ((win_y + win_h) << 3) - 1, 15);
    inset_rect(-1);
    if (g_errMsg == msg_insert_disk_n) {
        g_errMsg[12] = ch + g_diskNum;
        if (g_noDiskCheck == 0)
            g_errMsg[23] = g_multiDisk + 'A';
    }
    fg = g_textFg;
    bg = g_textBg;
    g_textFg = 15;
    g_textBg = 0;
    print_wrapped(g_errMsg);
    g_textFg = fg;
    g_textBg = bg;
    get_key();
    inset_rect(1);
    blit_generic(win_x, win_y, win_w, win_h, g_errSaveBuf);
    set_window(oldwin);
    if (alloc) {
        farfree(g_errSaveBuf);
        g_errSaveBuf = 0;
    }
}

/* FUNCTION: DONALD 06F0:097C */
void error_msg(void)
{
    g_errMsg = msg_err_fatal;
    show_error();
}

/* FUNCTION: DONALD 06F0:098D */
void free_all(void)
{
    register int i;

    for (i = 0; *g_cmpFiles[i].name; i++)
        if (g_cmpFiles[i].data) {
            farfree(g_cmpFiles[i].data);
            g_cmpFiles[i].data = 0L;
        }
    for (i = 0; i < 10; i++)
        if (g_fileHandles[i] != 0x7fff)
            fatal(msg_err_open_files);
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
        g_fileHandles[i] = 0x7fff;
    avail = dos_free_kb() - g_memReserve;
    i = 0;
    g_diskSwapOn = i;
    while (*g_cmpFiles[i].name) {
        g_diskSwapOn |= g_cmpFiles[i].value;
        if (g_errHooked) {
            g_cmpFiles[i].name = strupr(g_cmpFiles[i].name);
            need = g_cmpFiles[i].size / 1024L + 1;
            if (avail >= need)
                buf = farmalloc(g_cmpFiles[i].size);
            else
                buf = 0;
            if (buf == 0) {
                i++;
                continue;
            }
            fd = open(g_cmpFiles[i].name, 0x8001);
            if (fd == -1) {
                farfree(buf);
                i++;
                continue;
            }
            if ((long)read(fd, buf, g_cmpFiles[i].size) == g_cmpFiles[i].size) {
                g_cmpFiles[i].data = buf;
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
    for (; *g_cmpFiles[i].name; i++)
        if (strcmp(g_cmpFiles[i].name, name) == 0) {
            if (g_cmpFiles[i].data)
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
    for (; *g_cmpFiles[i].name; i++)
        if (strcmp(g_cmpFiles[i].name, name) == 0)
            return i;
    fatal(msg_err_res_index);
}

/* FUNCTION: DONALD 06F0:0CF4 */
long mem_read(register int i, char far *buf, long len)
{
    char far *src;

    if (g_cmpFiles[i].pos + len > g_cmpFiles[i].size)
        len = g_cmpFiles[i].size - g_cmpFiles[i].pos;
    src = normalize_ptr(g_cmpFiles[i].data + g_cmpFiles[i].pos);
    far_copy(src, buf, len);
    g_cmpFiles[i].pos += len;
    return len;
}

/* FUNCTION: DONALD 06F0:0DF9 */
void inset_rect(register int n)
{
    win_x -= n;
    win_y -= n;
    win_w += n * 2;
    win_h += n * 2;
}
