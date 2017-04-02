#include <dos.h>
#include <stdio.h>
#include <string.h>
#include "conioes.h"
#include "parse.h"

extern void __CON_FUNC conio_init2 (int force_mono);
extern void __CON_FUNC conio_exit2 (void);

void __CON_FUNC conio_init (int force_mono)
{
	conio_init2(force_mono);
	tagChangeAsciiChar();
	TagSub_li[1] = '\xA5';
}

void __CON_FUNC conio_exit (void)
{
	conio_exit2();
}

