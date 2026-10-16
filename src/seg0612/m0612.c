#include <alloc.h>
#include "donald.h"

/* FUNCTION: DONALD 0612:0009 */
char far *xalloc(long size)
{
    register unsigned n = size;
    char far *p;

    if (size > 0xFFFFL) {
        fn_05D5_000D("Alloc too big!", 0, 10, 15, 0);
        get_key();
    } else
        p = malloc(n);
    if (p == NULL) {
        fn_05D5_000D("Alloc: Null pointer return!", 0, 10, 15, 0);
        get_key();
    }
    return p;
}
