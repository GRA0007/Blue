@echo off
title COMPILING
color 9F
choice /m "Did you update the version number?"
if /i errorlevel 2 exit
taskkill /im FlashPlayer.exe
cls
echo COMPILING BLUE (By GRA0007)
echo.
echo Please wait, compilation may take up to 2 minutes depending on the programs
echo open on your computer.
ant > COMPILE.LOG