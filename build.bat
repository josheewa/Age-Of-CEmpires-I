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
C:\programming\PHP\cli\php.exe edit.php remove
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