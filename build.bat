@echo off
echo Compilando ScavengeSurvive.pwn
echo ###########################################
echo.
set start=%time%
pawno\pawncc.exe -Dgamemodes ScavengeSurvive.pwn -;+ -(+ -d3
set end=%time%
set /a seconds=%end:~6,2%-%start:~6,2%
echo.
echo ###########################################
echo Compilado em %seconds% segundos
echo.