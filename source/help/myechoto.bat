@echo off
rem desc: yet another echoto.bat
rem author: sava (https://github.com/lpproj)
rem date: Mar 1, 2017
rem license: so-called `Public Domain'
rem          (You can use/modify/distribute it freely BUT NO WARRANTY)
rem DOS 5.0+ version of COMMAND.COM will be required...
goto loc_start

:help
echo usage: myechoto [-a] outfile [param1] [param2] ...
echo option -a write to file with append mode
goto exit

:loc_start
if exist Z:\RESCAN.COM Z:\RESCAN >nul
if "%1" == "" goto help
if "%1" == "-?" goto help

set MYECHO_OF=
set MYECHO_A=
if "%1" == "-a" goto opt_a
if "%1" == "-A" goto opt_a
goto opt_p1
:opt_a
set MYECHO_A=1
shift
:opt_p1
if "%1" == "" goto help
set MYECHO_OF=%1
if not "%MYECHO_A%" == "" goto loc_lp1
if exist "%MYECHO_OF%" del "%MYECHO_OF%"

:loc_lp1
shift
if "%1" == "" goto exit
echo %1 >> %MYECHO_OF%
goto loc_lp1
:exit

