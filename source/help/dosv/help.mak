# makefile for building IBM PC version of HELP.EXE
# with Turbo C 2.0/Turbo C++ 1.01

CC = tcc
CFLAGS = -ml -O -f- -I. -I.. -DDOSV
LD = tcc
LDFLAGS = -ml -f-
AS = tasm
ASFLAGS = /Mx /jLOCALS /jJUMPS /m9 /dDOSV
#AS = ml
#ASFLAGS = -c -Cx -DIBMPC -DTOPVIEW


.AUTODEPEND

SPATH = ..\\
OPATH = .\\

SHELL_C = command /c
ECHOTO = $(SHELL_C) $(SPATH)myechoto.bat
RM = $(SHELL_C) $(SPATH)myrm.bat

.c.obj:
	$(CC) $(CFLAGS) -c -o$@ $<

.cpp.obj:
	$(CC) $(CFLAGS) -c -o$@ $<

LIBS = \
	$(SPATH)unz\\zlib_l.lib \
	$(SPATH)cats\\catdb.lib


OBJS01 = \
	$(OPATH)help.obj \
	$(OPATH)help_gui.obj \
	$(OPATH)help_htm.obj 

OBJS02 = \
	$(OPATH)events.obj \
	$(OPATH)parse.obj \
	$(OPATH)pes.obj 

OBJS03 = \
	$(OPATH)prepare.obj \
	$(OPATH)search.obj \
	$(OPATH)readfile.obj

OBJS04 = \
	$(OPATH)utfcp.obj 

OBJS05 = \
	$(OPATH)ioapi.obj \
	$(OPATH)unzip.obj 

OBJS_C = \
	$(OPATH)conioesv.obj \
	$(OPATH)conioes.obj 

OBJS = $(OBJS01) $(OBJS02) $(OBJS03) $(OBJS04) $(OBJS05)

OBJS_RSP = objs.rsp

default:
	@echo to build: make -fhelp_tc.mak help.exe

clean:
	$(RM) $(OBJS01)
	$(RM) $(OBJS02)
	$(RM) $(OBJS03)
	$(RM) $(OBJS04)
	$(RM) $(OBJS05)
	$(RM) $(OBJS_C)
	$(RM) $(OBJS_RSP) help.exe

help.exe: $(OBJS) $(OBJS_C) $(LIBS) $(OBJS_RSP)
	$(LD) $(LDFLAGS) -ehelp.exe @$(OBJS_RSP)


$(OPATH)ioapi.obj: $(SPATH)unz\\ioapi.c
	$(CC) $(CFLAGS) -c -o$< $(SPATH)unz\\ioapi.c

$(OPATH)unzip.obj: $(SPATH)unz\\unzip.c
	$(CC) $(CFLAGS) -c -o$< $(SPATH)unz\\unzip.c

$(OPATH)events.obj: $(SPATH)events.c
	$(CC) $(CFLAGS) -c -o$< $(SPATH)events.c

$(OPATH)help.obj: $(SPATH)help.c
	$(CC) $(CFLAGS) -c -o$< $(SPATH)help.c

$(OPATH)help_gui.obj: $(SPATH)help_gui.c
	$(CC) $(CFLAGS) -c -o$< $(SPATH)help_gui.c

$(OPATH)help_htm.obj: $(SPATH)help_htm.c
	$(CC) $(CFLAGS) -c -o$< $(SPATH)help_htm.c

$(OPATH)parse.obj: $(SPATH)parse.c
	$(CC) $(CFLAGS) -c -o$< $(SPATH)parse.c

$(OPATH)pes.obj: $(SPATH)pes.c
	$(CC) $(CFLAGS) -c -o$< $(SPATH)pes.c

$(OPATH)prepare.obj: $(SPATH)prepare.c
	$(CC) $(CFLAGS) -c -o$< $(SPATH)prepare.c

$(OPATH)readfile.obj: $(SPATH)readfile.c
	$(CC) $(CFLAGS) -c -o$< $(SPATH)readfile.c

$(OPATH)search.obj: $(SPATH)search.c
	$(CC) $(CFLAGS) -c -o$< $(SPATH)search.c

$(OPATH)utfcp.obj: $(SPATH)utfcp.c
	$(CC) $(CFLAGS) -c -o$< $(SPATH)utfcp.c

$(OPATH)conioesv.obj: conioesv.c
	$(CC) $(CFLAGS) -c -o$< conioesv.c


# tasm
$(OPATH)conioes.obj: conioes.asm
	$(RM) $<
	$(AS) $(ASFLAGS) conioes.asm,$<

# ml.exe (masm 6)
#$(OPATH)conioes.obj: conioes.asm
#	$(AS) $(ASFLAGS) -Fo$< conioes.asm


$(OBJS_RSP): $(OBJS) $(OBJS_C)
	$(ECHOTO) $(OBJS_RSP)
	$(ECHOTO) -a $(OBJS_RSP) $(OBJS01)
	$(ECHOTO) -a $(OBJS_RSP) $(OBJS02)
	$(ECHOTO) -a $(OBJS_RSP) $(OBJS03)
	$(ECHOTO) -a $(OBJS_RSP) $(OBJS04)
	$(ECHOTO) -a $(OBJS_RSP) $(OBJS05)
	$(ECHOTO) -a $(OBJS_RSP) $(OBJS_C)
	$(ECHOTO) -a $(OBJS_RSP) $(LIBS)


