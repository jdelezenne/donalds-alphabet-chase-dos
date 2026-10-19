/* FUNCTION: DONALD 061A:0005 */
void load_file(char far *name, void far *buf)
{
    register int fd;
    unsigned len;

    fd = Open_File(name, 1);
    Read_File(fd, (void far *)&len, 2L);
    Read_File(fd, buf, (long)len);
    Close_File(fd);
}
