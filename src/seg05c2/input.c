/* FUNCTION: DONALD 05C2:000B */
int key_ready(void)
{
    return fn_056A_0194() ? 1 : 0;
}

/* FUNCTION: DONALD 05C2:001C */
int get_key(void)
{
    register int r;
    char c;

    c = fn_056A_01CB();
    r = c;
    return r;
}
