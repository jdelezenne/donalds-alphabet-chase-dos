/* FUNCTION: DONALD 061A:0005 */
void load_file(char far *name, void far *buf)
{
    register int fd;
    unsigned len;

    fd = open_slot(name, 1);
    read_file(fd, (void far *)&len, 2L);
    read_file(fd, buf, (long)len);
    close_slot(fd);
}
