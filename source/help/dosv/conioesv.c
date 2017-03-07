#include <dos.h>
#include <stdio.h>
#include <string.h>
#include "conioes.h"

extern void __CON_FUNC conio_init2 (int force_mono);

void __CON_FUNC conio_init (int force_mono)
{
	union REGS r;
	struct SREGS sr;
	conio_init2(force_mono);
	/* check DOS/V (IBM PC BIOS DBCS extension) */
	r.x.ax = 0x4900;
	r.x.bx = 0xffff;
	int86x(0x15, &r, &r, &sr);
	if (r.h.ah == 0 && r.h.bl == 0) {
		/* check DOS/V text mode */
		r.h.ah = 0xfe;
		r.x.di = 0;
		sr.es = 0xb800;
		int86x(0x10, &r, &r, &sr);
		if (sr.es != 0xb800 || r.x.di != 0) {
			/* assume DOS/V DBCS text mode */
			strcpy(Border22f,  "\x01\x06\x02\x05 \x05\x03\x06\x04");
			strcpy(Border22if, "\x19\x06\x17\x05 \x05\x03\x06\x04");
			BarBlock1 = 0x1a;
			BarBlock2 = 0x14;
			BarUpArrow = 0x1c;
			BarDownArrow = 0x07;
		}
	}
	
}


