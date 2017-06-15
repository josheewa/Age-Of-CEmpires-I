@echo off
setlocal EnableDelayedExpansion
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do     rem"') do (
  set "DEL=%%a"
)
call :colorEcho 73 "Converting graphics..."
cd gfx2\Main
convpng
call :editFile gfx_main1.inc Main
call :editFile gfx_main2.inc Main
cd ..\Buildings
convpng
call :editFile gfx_buildings.inc Buildings
cd ..\Tiles
convpng
call :editFile gfx_tiles.inc Tiles
cd ..\Game
convpng
call :editFile gfx_gameplay.inc Game
pause
exit

:colorEcho
echo off
<nul set /p ".=%DEL%" > "%~2"
findstr /v /a:%1 /R "^$" "%~2" nul
del "%~2" > nul 2>&1i
echo.
exit /b

:editFile
set filename=%1%
if exist temp.txt del "temp.txt"
for /f "delims=^" %%a in (%filename%) do (
    set string=%%a
    set substring=!string:~0,8!
    set substring2=!string:~10!
    if !substring!==#include set string=#include "gfx2/%2%/!substring2!
    echo !string! >> temp.txt
)
del "%filename%
ren temp.txt %filename%
exit /b