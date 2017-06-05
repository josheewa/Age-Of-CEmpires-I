@ECHO OFF
SETLOCAL EnableDelayedExpansion
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do     rem"') do (
  set "DEL=%%a"
)
mode con lines=40
echo --------------------------------------------------------
echo                 Age of CEmpires I v1.0
echo                 By Peter "PT_" Tillema
echo --------------------------------------------------------
echo                          See 
echo   http://github.com/PeterTillema/Age-Of-CEmpires-I.git
echo                 for more information!
echo --------------------------------------------------------
if not exist bin\ mkdir bin
del "relocation_table1.asm"
del "relocation_table2.asm"
call :colorEcho 73 "Building graphics appvars..."
tools\spasm -E -L graphics1.asm bin\AOCEGFX1.8xv
tools\spasm -E -L graphics2.asm bin\AOCEGFX2.8xv
call :editFile AOCEGFX1.lab
call :editFile AOCEGFX2.lab
call :colorEcho 73 "Building main program..."
tools\spasm -E -T -L aoce.asm bin\aoce.8xp
call :colorEcho 73 "Compressing main program..."
tools\convhex -x bin\aoce.8xp
call :colorEcho 73 "Cleaning up..."
del "bin\aoce.8xp"
del "bin\AOCEGFX1.lab"
del "bin\AOCEGFX2.lab"
ren bin\aoce_.8xp aoce.8xp
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
cd bin
set filename=%1%
if exist temp.txt del "temp.txt"
for /f "delims=," %%a in (%filename%) do (
    set string=%%a
    set substring1=!string:~0,1!
    set substring2=!string:~1,1!
    if !substring1! NEQ _ set string=""
    if !substring2!==_ set string=""
    if !string! NEQ "" echo !string! >> temp.txt
)
del "%filename%
ren temp.txt %filename%
cd ..
exit /b