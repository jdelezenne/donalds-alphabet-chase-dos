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
