/*  Console I/O
    Copyright (c) Express Software 1998.
    All Rights Reserved.

    Created by: Joseph Cosentino.

    Ported to NEC PC-98 series by: sava
*/

#ifndef _CONIO_H_INCLUDED
#define _CONIO_H_INCLUDED

#define DEFAULT_ASCII_EXTENDED_CHARS 1

/* The middle character will be
   used to fill the window space */
#ifdef NOTEXTERN_IN_CONIO
# if 1
char *Border22f  = "\x9C\x95\x9D\x96 \x96\x9E\x95\x9F";
char *Border22if = "\x93\x95\x92\x96 \x96\x9E\x95\x9F";
# else
char *Border22f  = "\x98\x95\x99\x96 \x96\x9A\x95\x9B";
char *Border22if = "\x93\x95\x92\x96 \x96\x9A\x95\x9B";
# endif
char BarBlock1 = 0xA5;
char BarBlock2 = 0x8E;
char BarUpArrow = 0x1E;
char BarDownArrow = 0x1F;
char BarLeftArrow = 0x1D;
char BarRightArrow = 0x1C;
#else
extern const char *Border22f;
extern const char *Border22if;
extern char BarBlock1;
extern char BarBlock2;
extern char BarUpArrow;
extern char BarDownArrow;
extern char BarLeftArrow;
extern char BarRightArrow;
#endif

/* Foreground colours */
#define Black     0x00
#define Blue      0x01
#define Green     0x02
#define Cyan      0x03
#define Red       0x04
#define Magenta   0x05
#define Brown     0x06
#define White     0x07

#define Gray      0x08
#define BrBlue    0x09
#define BrGreen   0x0A
#define BrCyan    0x0B
#define BrRed     0x0C
#define BrMagenta 0x0D
#define Yellow    0x0E
#define BrWhite   0x0F

/* Background Colours */
#define BakBlack   0x00
#define BakBlue    0x10
#define BakGreen   0x20
#define BakCyan    0x30
#define BakRed     0x40
#define BakMagenta 0x50
#define BakBrown   0x60
#define BakWhite   0x70
#define Blink      0x80

#define EV_KEY   1
#define EV_SHIFT 2
#define EV_MOUSE 4
#define EV_TIMER 8
#define EV_NONBLOCK 16

#define CONIO_TICKS_PER_SEC  18.2
#define CONIO_TIMER(seconds) ((seconds)*18.2)

struct event
{
  unsigned int ev_type;

  unsigned int key;
  unsigned int scan;
  unsigned int shift;
  unsigned int shiftX;

  unsigned int x, y;
  unsigned int left;
  unsigned int right;
  unsigned int middle;
  signed   int wheel;

  long timer;
};

extern unsigned char const ScreenWidth;
extern unsigned char const ScreenHeight;
extern unsigned int const MouseInstalled;
extern unsigned int const WheelSupported;
extern unsigned char const MonoOrColor;
extern unsigned char const ScreenHeight2;

#define COLOR_MODE 0
#define MONO_MODE  1

#define CURSOR_ERASE 0
#define CURSOR_NORMAL 2

#define cursor_wherex()	(1 + *(unsigned char far *)MK_FP(0x60, 0x11C))
#define cursor_wherey()	(1 + *(unsigned char far *)MK_FP(0x60, 0x110))

#define savewindowsize(w,h)  ((unsigned)(w) * 4U * (unsigned)(h))

#ifdef __cplusplus
extern "C"
{
#endif

/* Use these to define the memory model for
   the external conio.asm functions listed
   below
*/
#define __CON_FUNC far cdecl
#define __CON_DATA far cdecl

  void __CON_FUNC conio_init (int force_mono);
  void __CON_FUNC conio_exit (void);
  void __CON_FUNC show_mouse (void);
  void __CON_FUNC hide_mouse (void);
  void __CON_FUNC move_mouse (int x, int y);
  void __CON_FUNC move_cursor (int x, int y);
  void __CON_FUNC cursor_type (int typ);
  void __CON_FUNC get_event (struct event __CON_DATA * ev, int flags);
  void __CON_FUNC write_char (int attr, int x, int y, int ch);
  void __CON_FUNC write_string (int attr, int x, int y,
				const char __CON_DATA * str);
  void __CON_FUNC save_window (int x, int y, int w, int h,
			       char __CON_DATA * buf);
  void __CON_FUNC load_window (int x, int y, int w, int h,
			       char __CON_DATA * buf);
  void __CON_FUNC write_charattrs_to_window (int x, int y, int w, int h,
                                             char __CON_DATA * buf);
  void __CON_FUNC clear_window (int attr, int x, int y, int w, int h);
  void __CON_FUNC scroll_window (int attr, int x, int y, int w, int h,
				 int len);
  void __CON_FUNC border_window (int attr, int x, int y, int w, int h,
				 const char __CON_DATA * border);

#ifdef __cplusplus
}
#endif

#define SK_SHIFT         0x01
#define SK_CTRL          0x10
#define SK_ALT           0x08
#define SK_CAPS_LOCKED   0x01

#define EV_SCAN_DEL	0x3900
#define EV_SCAN_F1		0x6200
#define EV_SCAN_F2		0x6300
#define EV_SCAN_F3		0x6400
#define EV_SCAN_F4		0x6500
#define EV_SCAN_ALT_F4		0x6500
#define EV_SCAN_F5		0x6600
#define EV_SCAN_HOME	0x3E00
#define EV_SCAN_END		0x3F00
#define EV_SCAN_LEFT	0x3B00
#define EV_SCAN_RIGHT	0x3C00
#define EV_SCAN_UP		0x3A00
#define EV_SCAN_DOWN	0x3D00

#define EV_SCAN_TAB		0x0F09

#define EV_SCAN_BS		0x0E08

#define EV_SCAN_PGUP	0x3700
#define EV_SCAN_PGDOWN	0x3600

#define IS_SHIFT_PRESSED(d) (*(unsigned char far *)0x53AUL & 1)
#define IS_CTRL_PRESSED(d) (*(unsigned char far *)0x53AUL & 0x10)
#define IS_ALT_PRESSED(d) (*(unsigned char far *)0x53AUL & 0x08)

#define IS_SCAN_DEL(s)		((s)==EV_SCAN_DEL)
#define IS_SCAN_HOME(s)		((s)==EV_SCAN_HOME)
#define IS_SCAN_END(s)		((s)==EV_SCAN_END)
#define IS_SCAN_LEFT(s)		((s)==EV_SCAN_LEFT)
#define IS_SCAN_ALT_LEFT(s)	((s)==EV_SCAN_LEFT && IS_ALT_PRESSED(s))
#define IS_SCAN_RIGHT(s)	((s)==EV_SCAN_RIGHT)
#define IS_SCAN_ALT_RIGHT(s)	((s)==EV_SCAN_RIGHT && IS_ALT_PRESSED(s))
#define IS_SCAN_UP(s)		((s)==EV_SCAN_UP)
#define IS_SCAN_ALT_UP(s)	((s)==EV_SCAN_UP && IS_ALT_PRESSED(s))
#define IS_SCAN_DOWN(s)		((s)==EV_SCAN_DOWN)
#define IS_SCAN_ALT_DOWN(s)	((s)==EV_SCAN_DOWN && IS_ALT_PRESSED(s))
#define IS_SCAN_SHIFT_TAB(s)	((s)==EV_SCAN_TAB && IS_SHIFT_PRESSED(s))
#define IS_SCAN_BS(s)		((s)==EV_SCAN_BS)

#define IS_SCAN_F1(s)		((s)==EV_SCAN_F1)
#define IS_SCAN_ALT_F4(s)	((s)==EV_SCAN_F4 && IS_ALT_PRESSED(s))
#define IS_SCAN_F5(s)		((s)==EV_SCAN_F5)

#define IS_SCAN_PGUP(s)		((s)==EV_SCAN_PGUP)
#define IS_SCAN_SHIFT_PGUP(s)	((s)==EV_SCAN_PGUP && IS_SHIFT_PRESSED(s))
#define IS_SCAN_CTRL_PGUP(s)	((s)==EV_SCAN_PGUP && IS_CTRL_PRESSED(s))
#define IS_SCAN_ALT_PGUP(s)	((s)==EV_SCAN_PGUP && IS_ALT_PRESSED(s))

#define IS_SCAN_PGDOWN(s)		((s)==EV_SCAN_PGDOWN)
#define IS_SCAN_SHIFT_PGDOWN(s)	((s)==EV_SCAN_PGDOWN && IS_SHIFT_PRESSED(s))
#define IS_SCAN_CTRL_PGDOWN(s)	((s)==EV_SCAN_PGDOWN && IS_CTRL_PRESSED(s))
#define IS_SCAN_ALT_PGDOWN(s)	((s)==EV_SCAN_PGDOWN && IS_ALT_PRESSED(s))

#define IS_SCAN_ALT_B(s)	((s)==0x2D84)
#define IS_SCAN_ALT_C(s)	((s)==0x2B82)
#define IS_SCAN_ALT_F(s)	((s)==0x20E7)
#define IS_SCAN_CTRL_R(s)	((s)==0x1312)
#define IS_SCAN_ALT_S(s)	((s)==0x1E9F)
#define IS_SCAN_ALT_X(s)	((s)==0x2A81)


#endif
