unsigned char fn_0000_1197();

/* FUNCTION: DONALD 0304:1A71 */
int roll(int n, int max, int base)
{
    register int sum = 0;
    register int d;
    int i;

    if (max == 0)
        max = 1;
    for (i = 0; i < n; i++) {
        do
            d = fn_0000_1197() & 0x0f;
        while (d == 0 || d > max);
        sum += d;
    }
    sum += base;
    return sum;
}
