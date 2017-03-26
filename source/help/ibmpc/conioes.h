/*  Console I/O
    Copyright (c) Express Software 1998.
    All Rights Reserved.

    Created by: Joseph Cosentino.

*/

#ifndef _CONIO_H_INCLUDED
#define _CONIO_H_INCLUDED

/* The middle character will be
   used to fill the window space */
#ifdef NOTEXTERN_IN_CONIO
char *Border22f = "…Õª∫ ∫»Õº";
char *Border22if = "ÃÕπ∫ ∫»Õº";
char BarBlock1 = 176;
char BarBlock2 = 178;
char BarUpArrow = 24;		/* '' */
char BarDownArrow = 25;		/* '' */
char BarLeftArrow = 27;
char BarRightArrow = 26;
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

#define COLOR_MODE 0
#define MONO_MODE  1

#define CURSOR_ERASE 0
#define CURSOR_NORMAL 2

#define curvideopage() (*(unsigned char far *)MK_FP(0x40, 0x62))
#define cursor_wherex()	(1 + *(unsigned char far *)MK_FP(0x40, 0x50 + (curvideopage()*2)))
#define cursor_wherey()	(1 + *(unsigned char far *)MK_FP(0x40, 0x51 + (curvideopage()*2)))

#ifdef __cplusplus
extern "C"
{
#endif

/* Use these to define the memory model for
   the external conio.asm functions listed
   below
*/
#define __CON_FUNC far
#define __CON_DATA far

  void __CON_FUNC conio_init (int force_mono);
  void __CON_FUNC conio_exit (void);
  void __CON_FUNC show_mouse (void);
  void __CON_FUNC hide_mouse (void);
  void __CON_FUNC move_mouse (int x, int y);
  void __CON_FUNC move_cursor (int x, int y);
#if 1
  void __CON_FUNC cursor_type (int typ);
#else
  void __CON_FUNC cursor_size (int top, int bottom);
#endif
  void __CON_FUNC get_event (struct event __CON_DATA * ev, int flags);
  void __CON_FUNC write_char (int attr, int x, int y, int ch);
  void __CON_FUNC write_string (int attr, int x, int y,
				const char __CON_DATA * str);
  void __CON_FUNC save_window (int x, int y, int w, int h,
			       char __CON_DATA * buf);
  void __CON_FUNC load_window (int x, int y, int w, int h,
			       char __CON_DATA * buf);
  void __CON_FUNC clear_window (int attr, int x, int y, int w, int h);
  void __CON_FUNC scroll_window (int attr, int x, int y, int w, int h,
				 int len);
  void __CON_FUNC border_window (int attr, int x, int y, int w, int h,
				 const char __CON_DATA * border);

#ifdef __cplusplus
}
#endif

#define SK_R_SHIFT       0x01
#define SK_L_SHIFT       0x02
#define SK_SHIFT         0x03
#define SK_CTRL          0x04
#define SK_ALT           0x08
#define SK_SCROLL_LOCKED 0x10
#define SK_NUM_LOCKED    0x20
#define SK_CAPS_LOCKED   0x40
#define SK_INSERT        0x80

#define SK_L_CTRL        0x0100
#define SK_L_ALT         0x0200
#define SK_R_CTRL        0x0400
#define SK_R_ALT         0x0800
#define SK_SCROLL_LOCK   0x1000
#define SK_NUM_LOCK      0x2000
#define SK_CAPS_LOCK     0x4000
#define SK_SYS_REQ       0x8000

#define EV_SCAN_DEL	0x5300
#define EV_SCAN_DELE	0x53E0
#define EV_SCAN_F1		0x3B00
#define EV_SCAN_F2		0x3C00
#define EV_SCAN_F3		0x3D00
#define EV_SCAN_F4		0x3E00
#define EV_SCAN_ALT_F4	0x6B00
#define EV_SCAN_F5		0x3F00
#define EV_SCAN_HOME	0x4700
#define EV_SCAN_HOMEE	0x47E0
#define EV_SCAN_END	0x4F00
#define EV_SCAN_ENDE	0x4FE0
#define EV_SCAN_LEFT	0x4B00
#define EV_SCAN_LEFTE	0x4BE0
#define EV_SCAN_ALT_LEFTE	0x9B00
#define EV_SCAN_RIGHT	0x4D00
#define EV_SCAN_RIGHTE	0x4DE0
#define EV_SCAN_ALT_RIGHTE	0x9D00
#define EV_SCAN_UP		0x4800
#define EV_SCAN_UPE		0x48E0
#define EV_SCAN_CTRL_UP	0x8D00
#define EV_SCAN_CTRL_UPE	0x8DE0
#define EV_SCAN_ALT_UPE	0x9800
#define EV_SCAN_DOWN	0x5000
#define EV_SCAN_DOWNE	0x50E0
#define EV_SCAN_CTRL_DOWN	0x9100
#define EV_SCAN_CTRL_DOWNE	0x91E0
#define EV_SCAN_ALT_DOWNE	0xA000

#define EV_SCAN_SHIFT_TAB	0x0F00

#define EV_SCAN_BS		0x0E08
#define EV_SCAN_CTRL_BS	0x0E7F
#define EV_SCAN_ALT_BS	0x0E00

#define EV_SCAN_PGUP	0x4900
#define EV_SCAN_SHIFT_PGUP	0x4939
#define EV_SCAN_CTRL_PGUP	0x8400
#define EV_SCAN_PGUPE	0x49E0
#define EV_SCAN_CTRL_PGUPE	0x84E0
#define EV_SCAN_ALT_PGUPE	0x9900
#define EV_SCAN_PGDOWN	0x5100
#define EV_SCAN_SHIFT_PGDOWN	0x5133
#define EV_SCAN_CTRL_PGDOWN	0x7600
#define EV_SCAN_PGDOWNE	0x51E0
#define EV_SCAN_CTRL_PGDOWNE	0x76E0
#define EV_SCAN_ALT_PGDOWNE	0xA100


#define IS_SCAN_DEL(s)		((s)==EV_SCAN_DEL || (s)==EV_SCAN_DELE)
#define IS_SCAN_HOME(s)		((s)==EV_SCAN_HOME || (s)==EV_SCAN_HOMEE)
#define IS_SCAN_END(s)		((s)==EV_SCAN_END || (s)==EV_SCAN_ENDE)
#define IS_SCAN_LEFT(s)		((s)==EV_SCAN_LEFT || (s)==EV_SCAN_LEFTE)
#define IS_SCAN_ALT_LEFT(s)	((s)==EV_SCAN_ALT_LEFTE)
#define IS_SCAN_RIGHT(s)	((s)==EV_SCAN_RIGHT || (s)==EV_SCAN_RIGHTE)
#define IS_SCAN_ALT_RIGHT(s)	((s)==EV_SCAN_ALT_RIGHTE)
#define IS_SCAN_UP(s)		((s)==EV_SCAN_UP || (s)==EV_SCAN_UPE)
#define IS_SCAN_ALT_UP(s)	((s)==EV_SCAN_ALT_UPE)
#define IS_SCAN_DOWN(s)		((s)==EV_SCAN_DOWN || (s)==EV_SCAN_DOWNE)
#define IS_SCAN_ALT_DOWN(s)	((s)==EV_SCAN_ALT_DOWNE)
#define IS_SCAN_SHIFT_TAB(s)	((s)==EV_SCAN_SHIFT_TAB)
#define IS_SCAN_BS(s)		((s)==EV_SCAN_BS)

#define IS_SCAN_F1(s)		((s)==EV_SCAN_F1)
#define IS_SCAN_ALT_F4(s)	((s)==EV_SCAN_ALT_F4)
#define IS_SCAN_F5(s)		((s)==EV_SCAN_F5)

#define IS_SCAN_PGUP(s)		((s)==EV_SCAN_PGUP || (s)==EV_SCAN_PGUPE)
#define IS_SCAN_SHIFT_PGUP(s)	((s)==EV_SCAN_SHIFT_PGUP)
#define IS_SCAN_CTRL_PGUP(s)		((s)==EV_SCAN_CTRL_PGUP || (s)==EV_SCAN_CTRL_PGUPE)
#define IS_SCAN_ALT_PGUP(s)	((s)==EV_SCAN_ALT_PGUPE)

#define IS_SCAN_PGDOWN(s)		((s)==EV_SCAN_PGDOWN || (s)==EV_SCAN_PGDOWNE)
#define IS_SCAN_SHIFT_PGDOWN(s)	((s)==EV_SCAN_SHIFT_PGDOWN)
#define IS_SCAN_CTRL_PGDOWN(s)		((s)==EV_SCAN_CTRL_PGDOWN || (s)==EV_SCAN_CTRL_PGDOWNE)
#define IS_SCAN_ALT_PGDOWN(s)	((s)==EV_SCAN_ALT_PGDOWNE)

#define IS_SCAN_ALT_B(s)	((s)==0x3000)
#define IS_SCAN_ALT_C(s)	((s)==0x2E00)
#define IS_SCAN_ALT_F(s)	((s)==0x2100)
#define IS_SCAN_CTRL_R(s)	((s)==0x1312)
#define IS_SCAN_ALT_S(s)	((s)==0x1F00)
#define IS_SCAN_ALT_X(s)	((s)==0x2D00)



#endif
