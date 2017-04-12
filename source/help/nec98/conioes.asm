;   Console I/O
;
;   Copyright (c) Express Software 1998-2003
;   See docs\htmlhelp\copying for licensing terms
;
;   Created by: Joseph Cosentino.
;
;   Updated for masm by RP. Also added MONO mode checking.

.MODEL COMPACT
.DATA

PUBLIC	_ScreenWidth
PUBLIC	_ScreenHeight
PUBLIC	_MouseInstalled
PUBLIC  _WheelSupported
PUBLIC  _MonoOrColor    ; Added by RP. Mono=1, Color = 0.
PUBLIC	_ScreenHeight2

_MonoOrColor    DB   ?  ; Added by RP
oldvidmod       DB   ?  ; Added by RP
;oldcursorshape  DW   ?  ; Added by RP
_ScreenArea	EQU DWord Ptr _ScreenOffset
_ScreenOffset	DW   ?	; 0000h
_ScreenSegment	DW   ?	; A000h
_ScreenWidth	DB   ?	;  80
_ScreenHeight	DB   ?	;  25
_ScreenLength	DW   ?	; 80*25
_MouseInstalled	DW   ?	; 0 or 1
_WheelSupported DW   ?  ; 0 or 1
_LastKeyShifts	DW   ?	;
_LastMousePosX	DW   ?  ;
_LastMousePosY	DW   ?  ;
_LastMouseBtns	DW   ?	;
OriginalTimer1	DW   ?	;
OriginalTimer2	DW   ?	;
;ExtendedKeyb    DB   ?  ;

cursordisped	db   ?	; 0=erase, 1=show
mode40columns	db   ?	; 0=80cols, 1=40cols
screencharstep	dw   ?	; 2=80cols, 4=40cols
fkeystate	db   ?	; [0060:0111] 0=none, 1=show fkey, 2=show (shifted)
fkeystate2	db   ?	; [0060:008C] ' '=normal '*'=shifted
_ScreenHeight2	db   ?

.CODE

PUBLIC	_conio_init2
PUBLIC	_conio_exit2
PUBLIC	_show_mouse
PUBLIC	_hide_mouse
PUBLIC	_move_mouse
PUBLIC	_cursor_type
PUBLIC	_move_cursor
PUBLIC	_get_event
PUBLIC	_write_char
PUBLIC	_write_string
PUBLIC	_load_window
PUBLIC	_save_window
PUBLIC	_clear_window
PUBLIC	_scroll_window
PUBLIC	_border_window
PUBLIC	_write_charattrs_to_window

Show_Mouse	MACRO
		cmp	_MouseInstalled, 1
		jne	@@nomouse1
		mov	ax, 0001h
		int	33h
    @@nomouse1:
		ENDM


Hide_Mouse	MACRO
		cmp	_MouseInstalled, 1
		jne	@@nomouse2
		mov	ax, 0002h
		int	33h
    @@nomouse2:
		ENDM


check_mouse_stat	PROC	NEAR
		mov	ax, 3
		xor	bx, bx
		int	33h
		; check NEC mouse.sys
		cmp	ah, 0FFh
		je	@@necmouse
		cmp	bh, 0FFh
		je	@@necmouse
		ret
    @@necmouse:
		; int 33h AX=3
		; NEC mouse.sys: return position and button status
		;
		; AX = left button (-1=pressed, 0=not pressed)
		; BX = right button (-1=pressed, 0=not pressed)
		; CX = X cood of pointer (by actual pixel)
		; DX = Y cood of pointer (by actual pixel)
		and	ax, 1
		and	bx, 2
		or	bx, ax
		ret
check_mouse_stat	ENDP



puts_con	PROC	NEAR
		push	ax
    @@lp:
		mov	al, byte ptr cs:[si]
		inc	si
		test	al, al
		jz	@@brk
		int	29h
		jmp	short @@lp
    @@brk:
		pop	ax
		ret
puts_con	ENDP

cursor_type_n	PROC	NEAR
	push	ax
	push	si
	mov	si, offset @@esc_scr
	call	puts_con
	test	al, al
	mov	al, 'l'
	jnz	@@csronoff
	mov	al, 'h'
    @@csronoff:
	int	29h
    @@exit:
	pop	si
	pop	ax
	ret

@@esc_scr	db	1Bh, "[>5", 0
cursor_type_n	ENDP

; clear screen and redraw fkey status line
clear_screen		PROC	NEAR
		push	ds
		mov	si, 60h
		mov	ds, si
		mov	si, offset @@clr_scrn20_s
		cmp	byte ptr ds:[0113h], 0		; lines: 0=20, 1=25
		jz	@@l2
		mov	si, offset @@clr_scrn25_s
    @@l2:
		pop	ds
		jmp	short puts_con		; call + retn
    @@clr_scrn20_s	db	1Bh, "[>3h", 0
    @@clr_scrn25_s	db	1Bh, "[>3l", 0
clear_screen		ENDP


showhide_fkey		PROC	NEAR
		push	ax
		push	si
		mov	si, offset @@erase_fk
		cmp	al, 0
		je	@@l2
		mov	si, offset @@show_fk
    @@l2:
		call	puts_con
		pop	si
		pop	ax
		ret
    @@erase_fk	db	1Bh, "[>1h", 0
    @@show_fk	db	1Bh, "[>1l", 0
showhide_fkey		ENDP




;----------------------------------------------------------------

_conio_init2	PROC
     forcemono  EQU     [bp+06h]

		push	bp
		mov	bp, sp
		push	es
		push	si
		push	di

		xor	ax, ax
		mov	es, ax
		mov	al, byte ptr es:[053Ch]
		and	al, 2
		shr	al, 1
		mov	mode40columns, al
		mov	ax, 60h
		mov	es, ax
		
		mov	ax, word ptr es:[0032h]
		test	ax, ax
		jnz	@@setscrnseg
		mov	ax, 0a000h		; A000:0000 if 0 (epson DOS 4.0)
    @@setscrnseg:
		mov	_ScreenSegment, ax
		;mov	_ScreenOffset, 0
		

		mov	al, byte ptr es:[0111h]
		mov	fkeystate, al
		mov	al, byte ptr es:[008Ch]
		mov	fkeystate2, al
		mov	al, byte ptr es:[0112h]
		inc	al
		mov	_ScreenHeight2, al
		mov	al, 0
		call	showhide_fkey

		mov	al, byte ptr es:[0112h]
		inc	al
		mov	_ScreenHeight, al
		mov	ax, 80
		mov	cx, 2
		cmp	mode40columns, 0
		je	@@setscrnlen
		mov	al, 40
		mov	cl, 4
    @@setscrnlen:
		mov	_ScreenWidth, al
		mov	screencharstep, cx

		mov	al, byte ptr es:[011Bh]
		mov	cursordisped, al
		mov	al, 0
		call	cursor_type_n

		; check if int 33h is safe to call
		xor	ax, ax
		push	ds
		mov	ds, ax
		mov	ax, word ptr ds:[0033h * 4 + 2]
		pop	ds
		cmp	ax, 60h
		je	@@no_mouse
		cmp	ax, 0
		je	@@no_mouse
		
		mov	ax,0000h	; Check for a mouse
		mov	bx, 0
		int	33h
		; result:
		;  AX==-1 mouse driver is installed
		;  BX==0  NEC mouse.sys (guess 2 buttons)
		;  BX!=0  number of buttons (MS mouse.com)
		;  BX==-1 probably 2 buttons (MS mouse.com)
		cmp	ax, 0h
		je	@@No_Mouse
    @@_Mouse:
		mov	_MouseInstalled, 1
		;mov	ax, 0003h
		;int	33h
		call	check_mouse_stat
		mov	_LastMousePosX, cx
		mov	_LastMousePosY, dx
		mov	_LastMouseBtns, bx

        mov _WheelSupported, 0
IF 0
		; ctmouse extension:
		; int 33h AX=11h: Check wheel support and get capabilities flags
		; (conflict with NEC mouse.sys)
		;
		; NEC mouse.sys:
		; int 33h AX=10h: define horizontal range by pixel
		;   CX = minimum range by pixel (0 as default)
		;   DX = maximun range by pixel (639 as default)
		; int 33h AX=11h: define vertical range by pixel
		;   CX = minimum range by pixel (0 as default)
		;   DX = maximum range by pixel (399 as default)
        mov ax, 0011h
        int 33h
        cmp ax, 574Dh
        jne @@skip2
        mov _WheelSupported, 1
ENDIF

        jmp @@skip2
    @@No_Mouse:
		mov	_MouseInstalled, 0
        
    @@skip2:
                sti
                mov     ah, 2h          ; Get keyboard status
		int	18h
		mov	byte ptr [_LastKeyShifts], al
		
		pop	di
		pop	si
		pop	es
		pop	bp
		retf
_conio_init2	ENDP

;----------------------------------------------------------------

_conio_exit2	PROC

		push	bp
		mov	bp, sp
		push	ds
		push	di
		push	si

		Hide_Mouse
		mov	_MouseInstalled, 0

		push	es
		mov	ax, 60h
		mov	es, ax
		; restore status line
		mov	al, fkeystate
		mov	byte ptr es:[0111h], al
		mov	ah, fkeystate2
		mov	byte ptr es:[008Ch], ah
		pop	es
		call	clear_screen
		; restore cursor status
		mov	al, cursordisped
		call	cursor_type_n

		pop	di
		pop	si
		pop	es
		pop	bp
		retf
_conio_exit2	ENDP


;----------------------------------------------------------------

colorxlattbl:
		db	00000001b	; 0000
		db	00100001b	; 0001
		db	10000001b	; 0010
		db	10100001b	; 0011
		db	01000001b	; 0100
		db	01100001b	; 0101
		db	11000001b	; 0110
		db	11100001b	; 0111
		db	11100001b	; 1000
		db	00100011b	; 1001
		db	10000011b	; 1010
		db	10100011b	; 1011
		db	01000011b	; 1100
		db	01100011b	; 1101
		db	11000011b	; 1110
		db	11100011b	; 1111


xlat_attr_to_nec98	PROC	NEAR
		push	dx
		push	bx
		mov	dl, ah
		mov	dh, ah
		shr	dh, 1
		shr	dh, 1
		shr	dh, 1
		shr	dh, 1
		and	dx, 0F0Fh
		xor	bh, bh
		mov	bl, dh
		mov	dh, byte ptr cs:[bx + colorxlattbl]
		mov	bl, dl
		mov	dl, byte ptr cs:[bx + colorxlattbl]
		mov	ah, dl
		cmp	dl, dh
		jae	@@ppv2
		mov	ah, dh
		or	ah, 4
    @@ppv2:
		and	ah, 0E5h
		pop	bx
		pop	dx
		ret
xlat_attr_to_nec98	ENDP


nec98_video_rep_stosw	PROC	NEAR
		jcxz	@@justret
		push	ax
		push	dx
		push	bx
		pushf
		pop	bx
		test	bh, 4
		mov	bx, 2
		jz	@@store_incr
		neg	bx
    @@store_incr:
		call	xlat_attr_to_nec98
		mov	dx, ax
		xor	ah, ah
    @@lp:
		mov	al, dl
		mov	es:[di], ax
		mov	al, dh
		mov	es:[di + 2000h], ax
		add	di, bx
		loop	@@lp
		pop	bx
		pop	dx
		pop	ax
    @@justret:
		ret
nec98_video_rep_stosw	ENDP

nec98_video_rep_movsw_fromto_screen	PROC	NEAR
		jcxz	@@ret
		push	ax
		push	bx
		pushf
		pop	ax
		mov	bx, 2
		test	ah, 4
		jz	@@lp
		neg	bx
    @@lp:
		mov	ax, [si]
		mov	es:[di], ax
		mov	ax, [si + 2000h]
		mov	es:[di + 2000h], ax
		add	si, bx
		add	di, bx
		loop	@@lp
		pop	bx
		pop	ax
    @@ret:
		ret
nec98_video_rep_movsw_fromto_screen	ENDP

nec98_video_rep_movsw_for_save_window_raw	PROC NEAR
		jcxz	@@ret
		push	ax
		push	bx
		pushf
		pop	ax
		mov	bx, 2
		test	ah, 4
		jz	@@lp
		neg	bx
    @@lp:
		mov	ax, [si]
		stosw
		mov	ax, [si + 2000h]
		stosw
		add	si, bx
		loop	@@lp
		pop	bx
		pop	ax
    @@ret:
		ret
nec98_video_rep_movsw_for_save_window_raw	ENDP

nec98_video_rep_movsw_for_load_window_raw	PROC NEAR
		jcxz	@@ret
		push	ax
		push	bx
		pushf
		pop	ax
		mov	bx, 2
		test	ah, 4
		jz	@@lp
		neg	bx
    @@lp:
		lodsw
		mov	es:[di], ax
		lodsw
		mov	es:[di + 2000h], ax
		add	di, bx
		loop	@@lp
		pop	bx
		pop	ax
    @@ret:
		ret
nec98_video_rep_movsw_for_load_window_raw	ENDP


nec98_video_rep_movsw_for_write_charattrs	PROC NEAR
		jcxz	@@justret
		jmp	short @@l00
    @@justret:
		ret
    @@l00:
		push	ax
		push	dx
		push	bx
		pushf
		pop	bx
		test	bh, 4
		mov	bx, 2
		jz	@@store_incr
		neg	bx
    @@store_incr:
		xor	dx, dx
    @@lp:
		mov	al, [si]
		xor	ah, ah
		mov	es:[di], ax
		mov	ah, [si + 1]
		call	xlat_attr_to_nec98
		mov	es:[di + 2000h], ah
		test	dx, dx
		jnz	@@chkdbtrail
		; check dbcs lead
		cmp	al, 81h
		jb	@@nextone
		cmp	al, 9Fh
		jbe	@@dblead
		cmp	al, 0E0h
		jb	@@nextone
		cmp	al, 0FCh
		ja	@@nextone
    @@dblead:
		mov	dh, al
		jmp	short @@nextone
    @@chkdbtrail:
		; check dbcs trail
		cmp	al, 40h
		jb	@@nextone
		cmp	al, 7Fh
		je	@@nextone
		cmp	al, 0FCh
		ja	@@nextone
    ;@@write_dbcs:
		mov	ah, al
		mov	al, dh
		; sjis to jis
		; by Q-taro (from KNJ.TUT in Jan 13, 1993)
		; in:  AL = sjis lead, AH = sjis trail
		; out: AX = jis codepoint (AL = lower byte as cell, AH = upper byte as row)
		and	al, 3fh
		shl	al, 1
		sub	ah, 9fh
		jae	@@sj0
		cmp	ah, 0e1h
		adc	ah, 5eh
    @@sj0:
		sbb	ax, (0dee0h + 20h)	; (+20h... for nec98 vram)
		; sjis to jis end
		sub	di, bx
		mov	es:[di], ax
		add	di, bx
		or	al, 80h
		mov	es:[di], ax
		xor	dx, dx

    @@nextone:
		add	si, bx
		add	di, bx
		loop	@@lp
		pop	bx
		pop	dx
		pop	ax
		ret
nec98_video_rep_movsw_for_write_charattrs	ENDP


VIDEO_STOSW	MACRO
		push	cx
		mov	cx, 1
		call	nec98_video_rep_stosw
		pop	cx
		ENDM

VIDEO_REP_STOSW	MACRO
		call	nec98_video_rep_stosw
		ENDM

VIDEO_REP_MOVSW_FROMTO_SCREEN	MACRO
		call	nec98_video_rep_movsw_fromto_screen
		ENDM

VIDEO_REP_MOVSW_FOR_WRITE_CHARATTRS	MACRO
		call	nec98_video_rep_movsw_for_write_charattrs
		ENDM

VIDEO_REP_MOVSW_FOR_SAVE_WINDOW_RAW	MACRO
		call	nec98_video_rep_movsw_for_save_window_raw
		ENDM

VIDEO_REP_MOVSW_FOR_LOAD_WINDOW_RAW	MACRO
		call	nec98_video_rep_movsw_for_load_window_raw
		ENDM


;----------------------------------------------------------------


_show_mouse	PROC
		Show_Mouse
		retf
_show_mouse	ENDP



_hide_mouse	PROC
		Hide_Mouse
		retf
_hide_mouse	ENDP



_move_mouse	PROC

	Y	EQU	[bp+08h]
	X	EQU	[bp+06h]

		push	bp
		mov	bp, sp
		mov	cx, X
		mov	dx, Y 

		cmp	cl, 0
		je	@@x2
		mov	al, _ScreenWidth
		cmp	cl, al
		jbe	@@x
		mov	cl, al
    @@x:
		dec	cx
    @@x2:
		shl	cx, 1
		shl	cx, 1
		shl	cx, 1

		cmp	dl, 0
		je	@@y2
		mov	al, _ScreenHeight
		cmp	dl, al
		jbe	@@y
		mov	dl, al
    @@y:
		dec	dx
    @@y2:
		shl	dx, 1
		shl	dx, 1
		shl	dx, 1
		shl	dx, 1

		mov	ax, 0004h
		int	33h
		pop	bp
		retf
_move_mouse  ENDP


;----------------------------------------------------------------


_move_cursor	PROC

	Y	EQU	[bp+08h]
	X	EQU	[bp+06h]

		push	bp
		mov	bp, sp
		mov	ah, 3
		mov	cl, 10h
		mov	dl, X
		mov	dh, Y
		sub	dx, 0101h
		int	0DCh
		pop	bp
		retf
_move_cursor	ENDP


_cursor_type	PROC

	typ	EQU	[bp+06h]

		push	bp
		mov	bp, sp
		mov	ax, typ
		call	cursor_type_n
		pop	bp
		retf

_cursor_type	ENDP


;----------------------------------------------------------------


_write_char	PROC

        Char    EQU     [bp+0Ch] ; Renamed this variable from C to Char, since
        Y       EQU     [bp+0Ah] ; C is reserved in MASM - RP
	X	EQU	[bp+08h]
    Attribute	EQU	[bp+06h]

		Hide_Mouse

		push	bp
		mov	bp, sp
		push	ds
		push	di
		push	si
		sub	ax, ax
		mov	bx, ax
		mov	cx, bx
		mov	dx, cx
	
		mov	dl, _ScreenWidth
		mov	al, Y
		mov	bl, X	 
		dec	al
		dec	bl	 
		mul	dl
		add	ax, bx
		shl	ax, 1
		les	di, _ScreenArea
		add	di, ax

                mov     al, Char
		mov	ah, Attribute
		VIDEO_STOSW

		pop	si
		pop	di
		pop	ds
		pop	bp

		Show_Mouse
		retf
_write_char	ENDP



_write_string	PROC

	S	EQU	[bp+0Ch]
	Y	EQU	[bp+0Ah]
	X	EQU	[bp+08h]
    Attribute	EQU	[bp+06h]

		Hide_Mouse

		push	bp
		mov	bp, sp
		push	ds
		push	di
		push	si
		sub	ax, ax
		mov	bx, ax
		mov	cx, bx
		mov	dx, cx
	
		mov	dl, _ScreenWidth
		mov	al, Y
		mov	bl, X	 
		dec	al
		dec	bl	 
		mul	dl
		add	ax, bx
		shl	ax, 1
		les	di, _ScreenArea
		lds	si, S
		add	di, ax

		mov	ah, Attribute
		jmp	@@first
    @@next:
		VIDEO_STOSW
    @@first:
		lodsb
		cmp	al, 0
		jne	@@next
		
		pop	si
		pop	di
		pop	ds
		pop	bp

		Show_Mouse
		retf
_write_string	ENDP


;----------------------------------------------------------------


_write_charattrs_to_window	PROC

     Source	EQU	[bp+0Eh]
	H	EQU	[bp+0Ch]
	W	EQU	[bp+0Ah]
	Y	EQU	[bp+08h]
	X	EQU	[bp+06h]

		Hide_Mouse

		push	bp
		mov	bp, sp
		push	ds
		push	di
		push	si
		sub	ax, ax
		mov	bx, ax
		mov	cx, bx
		mov	dx, cx
	
		mov	dl, _ScreenWidth
		mov	al, Y
		mov	bl, X	 
		dec	al
		dec	bl	 
		mul	dl
		add	ax, bx
		shl	ax, 1
		les	di, _ScreenArea
		lds	si, Source
		add	di, ax

		mov	bl, W
		mov	bh, H
		sub	dl, bl
		shl	dx, 1
		
    @@next_row:
		mov	cl, bl
		VIDEO_REP_MOVSW_FOR_WRITE_CHARATTRS
		add	di, dx
		dec	bh
		jne	@@next_row
				
		pop	si
		pop	di
		pop	ds
		pop	bp

		Show_Mouse
		retf
_write_charattrs_to_window	ENDP


;----------------------------------------------------------------


_save_window	PROC

   Destination	EQU	[bp+0Eh]
	H	EQU	[bp+0Ch]
	W	EQU	[bp+0Ah]
	Y	EQU	[bp+08h]
	X	EQU	[bp+06h]

		Hide_Mouse

		push	bp
		mov	bp, sp
		push	ds
		push	di
		push	si
		sub	ax, ax
		mov	bx, ax
		mov	cx, bx
		mov	dx, cx
	
		mov	dl, _ScreenWidth
		mov	al, Y
		mov	bl, X	 
		dec	al
		dec	bl	 
		mul	dl
		add	ax, bx
		shl	ax, 1
		les	di, Destination
		lds	si, _ScreenArea
		add	si, ax
		mov	bl, W
		mov	bh, H
		sub	dl, bl
		shl	dx, 1
    @@next_row:
		mov	cl, bl
		VIDEO_REP_MOVSW_FOR_SAVE_WINDOW_RAW
		add	si, dx
		dec	bh
		jne	@@next_row

		pop	si
		pop	di
		pop	ds
		pop	bp

		Show_Mouse
		retf
_save_window	ENDP



_load_window	PROC

     Source	EQU	[bp+0Eh]
	H	EQU	[bp+0Ch]
	W	EQU	[bp+0Ah]
	Y	EQU	[bp+08h]
	X	EQU	[bp+06h]

		Hide_Mouse

		push	bp
		mov	bp, sp
		push	ds
		push	di
		push	si
		sub	ax, ax
		mov	bx, ax
		mov	cx, bx
		mov	dx, cx
	
		mov	dl, _ScreenWidth
		mov	al, Y
		mov	bl, X	 
		dec	al
		dec	bl	 
		mul	dl
		add	ax, bx
		shl	ax, 1
		les	di, _ScreenArea
		lds	si, Source
		add	di, ax

		mov	bl, W
		mov	bh, H
		sub	dl, bl
		shl	dx, 1
		
    @@next_row:
		mov	cl, bl
		VIDEO_REP_MOVSW_FOR_LOAD_WINDOW_RAW
		add	di, dx
		dec	bh
		jne	@@next_row
				
		pop	si
		pop	di
		pop	ds
		pop	bp

		Show_Mouse
		retf
_load_window	ENDP


;----------------------------------------------------------------


_clear_window	PROC

	H	EQU	[bp+0Eh]
	W	EQU	[bp+0Ch]
	Y	EQU	[bp+0Ah]
	X	EQU	[bp+08h]
    Attribute	EQU	[bp+06h]

		Hide_Mouse

		push	bp
		mov	bp, sp
		push	ds
		push	di
		push	si
		sub	ax, ax
		mov	bx, ax
		mov	cx, bx
		mov	dx, cx
	
		mov	dl, _ScreenWidth
		mov	al, Y
		mov	bl, X	 
		dec	al
		dec	bl	 
		mul	dl
		add	ax, bx
		shl	ax, 1
		les	di, _ScreenArea
		add	di, ax

		mov	bl, W
		mov	bh, H
		sub	dl, bl
		shl	dx, 1
		
		mov	ah, Attribute
		mov	al, ' '

    @@next_row:
		mov	cl, bl
		VIDEO_REP_STOSW
		add	di, dx
		dec	bh
		jne	@@next_row
				
		pop	si
		pop	di
		pop	ds
		pop	bp

		Show_Mouse
		retf
_clear_window	ENDP



_scroll_window	PROC

       Len	EQU	[bp+10h]
	H	EQU	[bp+0Eh]
	W	EQU	[bp+0Ch]
	Y	EQU	[bp+0Ah]
	X	EQU	[bp+08h]
    Attribute	EQU	[bp+06h]

		Hide_Mouse

		push	bp
		mov	bp, sp
		push	ds
		push	di
		push	si
		sub	ax, ax
		mov	bx, ax
		mov	cx, bx
		mov	dx, cx
	
		mov	dl, _ScreenWidth
		les	di, _ScreenArea
		lds	si, _ScreenArea
		mov	cl, dl
		sub	dl, W
		shl	dx, 1
	
		mov	al, Len
		imul	cl
		shl	ax, 1
		add	si, ax
		or	ax, ax
	
		mov	al, Y
		mov	ah, X
		mov	bl, H
		mov	bh, W
		jns	@@n12

		std
		neg	Byte Ptr Len
		neg	dx
		add	ax, bx
		sub	ax, 0101h
    @@n12:
		sub	ax, 0101h
		xchg	ah, cl
		mul	ah
		add	ax, cx
		shl	ax, 1
		add	si, ax
		add	di, ax
		sub	bl, Len
	
    @@next_row:
		mov	cl, bh
		VIDEO_REP_MOVSW_FROMTO_SCREEN
		add	di, dx
		add	si, dx
		dec	bl
		jne	@@next_row

		mov	bl, Len
		mov	ah, Attribute
		mov	al, ' '

    @@clr_row:
		mov	cl, bh
		VIDEO_REP_STOSW
		add	di, dx
		dec	bl
		jne		@@clr_row

		cld

		pop	si
		pop	di
		pop	ds
		pop	bp

		Show_Mouse
		retf
_scroll_window	ENDP



_border_window	PROC

      Border	EQU	[bp+10h]
	 H	EQU	[bp+0Eh]
	 W	EQU	[bp+0Ch]
	 Y	EQU	[bp+0Ah]
	 X	EQU	[bp+08h]
     Attribute	EQU	[bp+06h]

		Hide_Mouse

		push	bp
		mov	bp, sp
		push	ds
		push	di
		push	si
		sub	ax, ax
		mov	bx, ax
		mov	cx, bx
		mov	dx, cx
	
		mov	dl, _ScreenWidth
		mov	al, Y
		mov	bl, X	 
		dec	al
		dec	bl	 
		mul	dl
		add	ax, bx
		shl	ax, 1
		les	di, _ScreenArea
		lds	si, Border
		add	di, ax

		mov	bl, W
		mov	bh, H
		sub	dl, bl
		shl	dx, 1
		sub	bx, 0202h
		
		mov	ah, Attribute

		lodsb			; Upper row
		VIDEO_STOSW
		mov	cl, bl
		lodsb
		VIDEO_REP_STOSW
		lodsb
		VIDEO_STOSW
		add	di, dx
		cmp	bh, 00
		je	@@NoMiddleRows
	
    @@next_row:
		lodsb			; All rows in the middle
		VIDEO_STOSW
		mov	cl, bl
		lodsb
		cmp	al, 00
		je	@@NoFill
		VIDEO_REP_STOSW
		jmp	@@FillDone
    @@NoFill:
		add	di, cx
		add	di, cx
    @@FillDone:
		lodsb
		VIDEO_STOSW
		add	di, dx
		sub	si, 03
		dec	bh
		jne	@@next_row

 @@NoMiddleRows:
		add	si, 03		; Bottom row
		lodsb
		VIDEO_STOSW
		mov	cl, bl
		lodsb
		VIDEO_REP_STOSW
		lodsb
		VIDEO_STOSW

		pop	si
		pop	di
		pop	ds
		pop	bp

		Show_Mouse
		retf
_border_window	ENDP


;----------------------------------------------------------------


_get_event	PROC

  flags		EQU	Word Ptr [bp+0Ah]
  event		EQU	[bp+06h]

 ev_type	EQU	Word Ptr es:[si]

 key		EQU	Word Ptr es:[si+2]
 scan		EQU	Word Ptr es:[si+4]
 shift		EQU	Word Ptr es:[si+6]
 shiftX		EQU	Word Ptr es:[si+8]

 x          EQU Word Ptr es:[si+10]
 y          EQU Word Ptr es:[si+12]
 left		EQU	Word Ptr es:[si+14]
 right		EQU	Word Ptr es:[si+16]
 middle		EQU	Word Ptr es:[si+18]
 wheel      EQU Word Ptr es:[si+20]

 timer1     EQU Word Ptr es:[si+22]
 timer2     EQU Word Ptr es:[si+24]

 EV_KEY		EQU	 1
 EV_SHIFT	EQU	 2
 EV_MOUSE	EQU	 4
 EV_TIMER	EQU	 8
 EV_NONBLOCK	EQU	16

		push	bp
		mov	bp, sp
		push	ds
		push	es
		push	si
		push	di
		les	si, event
		sub	ax, ax
		mov	ev_type, ax
		mov	key, ax
		mov	scan, ax

		test	flags, EV_TIMER
		jz	@@main_loop
		mov	ah, 0h
IF 0
		; todo: NEC98 timer
		int	1Ah
		mov	OriginalTimer1, dx
		mov	OriginalTimer2, cx
ENDIF

    @@main_loop:
		test	flags, EV_KEY
		jz	@@test_shifts

		mov	ah, 1h			; Check for a key
		int	18h
		test	bh, 1
		jz	@@test_shifts

		or	ev_type, EV_KEY		; Key was pressed
		mov	ah, 0h
		int	18h
		mov	scan, ax
		cmp	ah, 0
		je	@@normal_key
		;mov	al, 0
    @@normal_key:
		mov	ah, 0
		mov	key, ax
		jmp	@@break_out

    @@test_shifts:
		test	flags, EV_SHIFT
		jz	@@test_mouse

		mov	ah, 2h			; Check if shifts changed
		int	18h
		mov	ah, 0
		cmp	ax, _LastKeyShifts
		jz	@@test_mouse

		or	ev_type, EV_SHIFT
		mov	bx, _LastKeyShifts
		xor	bx, ax
		mov	shift, ax
		mov	shiftX, bx
		mov	_LastKeyShifts, ax
		jmp	@@break_out2

    @@test_mouse:
		test	flags, EV_MOUSE
		jz	@@test_time
		cmp	_MouseInstalled, 1
		jne	@@test_time

		;mov	ax, 0003h		; Check mouse status
		;int	33h
		call	check_mouse_stat
		cmp	bx, _LastMouseBtns
		jne	@@mouse
		cmp	cx, _LastMousePosX
		jne	@@mouse
		cmp	dx, _LastMousePosY
		je	@@test_time
    @@mouse:
		or	ev_type, EV_MOUSE

		mov	_LastMouseBtns, bx
		mov	_LastMousePosX, cx
		mov	_LastMousePosY, dx
		jmp	@@break_out
    @@test_time:
		test	flags, EV_TIMER
		jz	@@loop_tail

IF 0
		; todo: NEC98 timer
		mov	ah, 0h			; Check timer
		int	1Ah
		sub	dx, OriginalTimer1
		sbb	cx, OriginalTimer2
		cmp	cx, timer2
		jb	@@loop_tail
		cmp	dx, timer1
		jb	@@loop_tail
		or	ev_type, EV_TIMER
		jmp	@@break_out
ENDIF
    @@loop_tail:
		test	flags, EV_NONBLOCK
		jnz	@@break_out
		int	28h			; yield
		jmp	@@main_loop

    @@break_out:
		mov	ah, 2h          ; Update shift status
		int	18h
		mov	ah, 0
		mov	shift, ax
		mov	bx, _LastKeyShifts
		xor	bx, ax
		mov	shiftX, bx

    @@break_out2:
    		cmp	_MouseInstalled, 1
    		jne	@@end

		;mov	ax, 0003h	; Update mouse status
		;int	33h
		call	check_mouse_stat

		; mouse x = (cx / 8) + 1
		shr	cx, 1
		shr	cx, 1
		shr	cx, 1
		inc	cx
		mov	x, cx
		; mouse y = (cx / 16) + 1
		shr	dx, 1
		shr	dx, 1
		shr	dx, 1
		shr	dx, 1
		inc	dx
		mov	y, dx

		test	bl, 01h
		jne	@@left
		mov	word ptr left, 0h
		jmp	@@leftE
	@@left:
		mov	word ptr left, 1h
	@@leftE:
		test	bl, 02h
		jne	@@right
		mov	word ptr right, 0h
		jmp	@@rightE
	@@right:
		mov	word ptr right, 1h
	@@rightE:
		test	bl, 04h
		jne	@@middle
		mov	word ptr middle, 0h
		jmp	@@middleE
	@@middle:
		mov	word ptr middle, 1h
	@@middleE:
    ; Wheel counter - RP 2004:
        mov bl, bh
        xor bh, bh
        mov word ptr wheel, bx


	@@end:
		pop	di
		pop	si
		pop	es
		pop	ds
		pop	bp
		retf
_get_event	ENDP

END
