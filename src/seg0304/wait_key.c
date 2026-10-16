/* FUNCTION: DONALD 0304:1B37 */
int wait_key(int any)
{
    register int key;
    register int i;

    for (i = key = 0; i < 250; i++) {
        repeat_call(1);
        if (key_ready()) {
            key = get_key();
            if (any || key == 27)
                break;
        }
    }
    return key;
}
