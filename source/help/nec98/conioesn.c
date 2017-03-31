#include <dos.h>
#include <stdio.h>
#include <string.h>
#include "conioes.h"
#include "parse.h"

extern void __CON_FUNC conio_init2 (int force_mono);
extern void __CON_FUNC conio_exit2 (void);

static char *gettag(const tagSubsEntry *t, const char *tag)
{
	char *s;
	while((s = t->after) != NULL) {
		if (strcmp(t->before, tag) == 0) break;
		++t;
	}
	return s;
}

void __CON_FUNC conio_init (int force_mono)
{
	conio_init2(force_mono);
}

void __CON_FUNC conio_exit (void)
{
	conio_exit2();
}

