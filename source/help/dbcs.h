#ifndef DBCS_H_INCLUDED
#define DBCS_H_INCLUDED

#include <stdlib.h>
#ifndef MB_CUR_MAX
# define MB_CUR_MAX  2
#endif

#ifdef DBCS

#ifdef __cplusplus
extern "C" {
#endif

int isDBCSLead(const char *);
int mblen_loose(const char *);

#ifdef __cplusplus
}
#endif


#else /* !defined(DBCS) */

#define isDBCSLead(p) (1)
#define mblen_loose(p) (1)


#endif /* DBCS */

#define myMBLEN(p,n)  mblen_loose(p)


#endif /* DBCS_H_INCLUDED */

