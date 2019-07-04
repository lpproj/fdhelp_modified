#include <dos.h>
#include <stdlib.h>
#include <string.h>

#include "dbcs.h"

#if defined(DBCS)

#define isCP932Lead(c) (((c)>=0x81 && (c)<=0x9f) || ((c)>=0xe0 &&(c)<=0xfc))

static char dbcs_is_ready = 0;
static unsigned char dbcstbl[16];

static void  setup_dbcstbl(void)
{
    union REGS r;
    struct SREGS sr;

    sr.ds = r.x.si = 0;
    r.x.ax = 0x6300;
    intdosx(&r, &r, &sr);
    if (r.x.si && sr.ds) {
        unsigned char far *p = MK_FP(sr.ds, r.x.si);
        unsigned n;
        if (*p > 0 && *p < 16) p += 2;  /* workaround for a bug on some DOS clones */
        for (n=0; n<sizeof(dbcstbl)-2; n+=2) {
            dbcstbl[n] = *p++;
            if ((dbcstbl[n + 1] = *p++) == '\0') break;
        }
    }
    else {
        char tmp_cinfo[34];
        r.x.ax = 0x3800;
        sr.ds = FP_SEG(tmp_cinfo);
        r.x.dx = FP_OFF(tmp_cinfo);
        r.x.bx = 0;
        intdosx(&r, &r, &sr);
        if (r.x.bx = 81) { /* JPN (SJIS) */
            dbcstbl[0] = 0x81; dbcstbl[1] = 0x9f;
            dbcstbl[2] = 0xe0; dbcstbl[3] = 0xfc;
            dbcstbl[3] = dbcstbl[4] = '\0';
        }
        else {
            dbcstbl[0] = dbcstbl[1] = '\0';
        }
    }
}

int isDBCSLead(const char *p)
{
#if defined(ONLY_SJIS)
    /* SJIS (CP932) only */
    register unsigned char c = (unsigned char)(*p);
    return isCP932Lead(c);
#else
    register unsigned n = 0;
    register unsigned char c = (unsigned char)(*p);

    if (!dbcs_is_ready) {
        setup_dbcstbl();
        dbcs_is_ready = 1;
    }
    while(dbcstbl[n]) {
        if (dbcstbl[n] <= c && c <= dbcstbl[n+1]) return 1;
        n += 2;
    }
    return 0;
#endif
}

int mblen_loose(const char *p)
{
    return (isDBCSLead(p) && (unsigned char)(p[1]) >= 0x20) ? 2 : 1;
}


#endif /* DBCS */

