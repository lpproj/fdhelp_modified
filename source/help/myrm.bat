@echo off
rem desc: yet another rmfiles.bat
rem author: sava (https://github.com/lpproj)
rem date: Mar 1, 2017
rem license: so-called `Public Domain'
rem          (You can use/modify/distribute it freely BUT NO WARRANTY)
rem DOS 5.0+ version of COMMAND.COM will be required...
goto loc_start

:help
echo remove spedicied files (wild card is not allowed)
echo usage: myrm [files]
goto exit

:loc_start
if exist Z:\RESCAN.COM Z:\RESCAN >nul
if "%1" == "" goto help
if "%1" == "-?" goto help

:loc_lp
if "%1" == "" goto exit
if exist %1 del %1
shift
goto loc_lp

:exit
if exist Z:\RESCAN.COM Z:\RESCAN >nul

