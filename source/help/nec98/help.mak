# makefile for building NEC PC-98 version of HELP.EXE
# with Turbo C 2.0/Turbo C++ 1.01

CC = tcc
CFLAGS = -ml -O -f- -I. -I.. -DNEC98
LD = tcc
LDFLAGS = -ml -f-
AS = tasm
ASFLAGS = /Mx /jLOCALS /jJUMPS /m9 /dNEC98
#AS = ml
#ASFLAGS = -c -Cx -DNEC98

UPX = upx --best --8086

.AUTODEPEND

SPATH = ..\\
OPATH = .\\
CATSPATH = $(SPATH)cats\\

SHELL_C = command /c
ECHOTO = $(SHELL_C) $(SPATH)myechoto.bat
RM = $(SHELL_C) $(SPATH)myrm.bat

.c.obj:
	$(CC) $(CFLAGS) -c -o$@ $<

.cpp.obj:
	$(CC) $(CFLAGS) -c -o$@ $<

#LIBS = \
#	$(SPATH)unz\\zlib_l.lib \
#	$(SPATH)cats\\catdb.lib

LIBS = \
	$(SPATH)unz\\zlib_l.lib


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

OBJS_CAT = \
	$(OPATH)kitten.obj

OBJS_C = \
	$(OPATH)conioesn.obj \
	$(OPATH)conioes.obj 

OBJS = $(OBJS01) $(OBJS02) $(OBJS03) $(OBJS04) $(OBJS05) $(OBJS_CAT)

OBJS_RSP = objs.rsp

default:
	@echo to build HELP.EXE : make -fhelp_tc.mak exe
	@echo compress with upx : make -fhelp_tc.mak upx

clean:
	$(RM) $(OBJS01)
	$(RM) $(OBJS02)
	$(RM) $(OBJS03)
	$(RM) $(OBJS04)
	$(RM) $(OBJS05)
	$(RM) $(OBJS_C) $(OBJS_CAT)
	$(RM) $(OBJS_RSP) help.exe help_upx.exe


upx: help_upx.exe

exe: help.exe

help_upx.exe: help.exe
	$(RM) help_upx.exe
	$(UPX) -o help_upx.exe help.exe

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

$(OPATH)kitten.obj: $(CATSPATH)kitten.c
	$(CC) $(CFLAGS) -I$(CATSPATH)  -c -o$< $(CATSPATH)kitten.c

$(OPATH)conioesn.obj: conioesn.c
	$(CC) $(CFLAGS) -c -o$< conioesn.c


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
	$(ECHOTO) -a $(OBJS_RSP) $(OBJS_C) $(OBJS_CAT)
	$(ECHOTO) -a $(OBJS_RSP) $(LIBS)


