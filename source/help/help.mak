.AUTODEPEND

.PATH.obj = BIN\\

#		*Translator Definitions*
CC = bcc +HELP.CFG
TASM = TASM
TLINK = tlink


#		*Implicit Rules*
.c.obj:
  $(CC) -c {$< }

.cpp.obj:
  $(CC) -c {$< }

#		*List Macros*


EXE_dependencies =  \
  help.obj \
  help_gui.obj \
  help_htm.obj \
  prepare.obj \
  search.obj \
  events.obj \
  parse.obj \
  utfcp.obj \
  readfile.obj \
  pes.obj \
  conio.obj \
  ioapi.obj \
  unzip.obj \
  unz\zlib_l.lib \
  cats\catdb.lib

#		*Explicit Rules*
bin\help.exe: help.cfg $(EXE_dependencies)
  $(TLINK) /x/c/P-/LC:\BORLANDC\LIB @&&|
c0l.obj+
bin\help.obj+
bin\help_gui.obj+
bin\help_htm.obj+
bin\prepare.obj+
bin\search.obj+
bin\events.obj+
bin\parse.obj+
bin\utfcp.obj+
bin\readfile.obj+
bin\pes.obj+
bin\conio.obj+
bin\ioapi.obj+
bin\unzip.obj
bin\help
		# no map file
unz\zlib_l.lib+
cats\catdb.lib+
cl.lib
|


#		*Individual File Dependencies*
help.obj: help.c 

help_gui.obj: help_gui.c 

help_htm.obj: help_htm.c 

prepare.obj: prepare.c 

search.obj: search.c 

events.obj: events.c 

parse.obj: parse.c 

utfcp.obj: utfcp.c 

readfile.obj: readfile.c 

pes.obj: pes.c 

ioapi.obj: unz\ioapi.c 
	$(CC) -c unz\ioapi.c

unzip.obj: unz\unzip.c 
	$(CC) -c unz\unzip.c

#		*Compiler Configuration File*
help.cfg: help.mak
  copy &&|
-ml
-f-
-ff-
-G
-O
-Z
-k-
-d
-vi
-Ff=32567
-nBIN\\
-IC:\BORLANDC\INCLUDE
-LC:\BORLANDC\LIB
| help.cfg


