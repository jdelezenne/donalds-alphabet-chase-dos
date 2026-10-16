/* FUNCTION: DONALD 061A:0005 */
void load_file(char far *name, void far *buf)
{
    register int fd;
    unsigned len;

    fd = fn_06F0_0043(name, 1);
    fn_06F0_028D(fd, (void far *)&len, 2L);
    fn_06F0_028D(fd, buf, (long)len);
    close_slot(fd);
}
