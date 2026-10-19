/* FUNCTION: DONALD 05C2:000B */
int key_ready(void)
{
    return kbd_hit() ? 1 : 0;
}

/* FUNCTION: DONALD 05C2:001C */
int get_key(void)
{
    register int r;
    char c;

    c = kbd_getchar();
    r = c;
    return r;
}
