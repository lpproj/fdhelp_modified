#include <dos.h>
#include <stdio.h>
#include <string.h>
#include "conioes.h"
#include "parse.h"

extern void __CON_FUNC conio_init2 (int force_mono);

void __CON_FUNC conio_init (int force_mono)
{
	conio_init2(force_mono);
	if (IsDOSVText) {
		/* assume DOS/V DBCS text mode */
		strcpy(Border22f,  "\x01\x06\x02\x05 \x05\x03\x06\x04");
		strcpy(Border22if, "\x19\x06\x17\x05 \x05\x03\x06\x04");
		BarBlock1 = 0x1a;
		BarBlock2 = 0x14;
		BarUpArrow = 0x1c;
		BarDownArrow = 0x07;
		BarLeftArrow = 0x1f;
		BarRightArrow = 0x1e;
		tagChangeAsciiChar();
		TagSub_li[1] = '\x0F'; /* '\x09'; '\xA5'; */
	}
	
}


