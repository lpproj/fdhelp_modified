#include <dos.h>
#include <stdlib.h>
#include <string.h>

#include "dbcs.h"

#if defined(DBCS)

#define isSJLead(c) (((c)>=0x81 && (c)<=0x9f) || ((c)>=0xe0 &&(c)<=0xfc))

int isDBCSLead(const char *p)
{
    /* SJIS (CP932) only */
    register unsigned char c = (unsigned char)(*p);
    return isSJLead(c);
}

int mblen_loose(const char *p)
{
    return (isDBCSLead(p) && (unsigned char)(p[1]) >= 0x20) ? 2 : 1;
}


#endif /* DBCS */

