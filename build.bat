@echo off
setlocal EnableDelayedExpansion
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set "DEL=%%a"
)
if not exist bin mkdir bin
if exist relocation_table1.asm del "relocation_table1.asm"
if exist relocation_table2.asm del "relocation_table2.asm"
cd gfx
spasm -E -L -I bin\ appvar1.asm ..\bin\AOCEGFX1.8xv
spasm -E -L -I bin\ appvar2.asm ..\bin\AOCEGFX2.8xv
spasm -E -L -I bin\ a1.asm ..\bin\AGE1.8xv
spasm -E -L -I bin\ a2.asm ..\bin\AGE2.8xv
spasm -E -L -I bin\ a3.asm ..\bin\AGE3.8xv
spasm -E -L -I bin\ a4.asm ..\bin\AGE4.8xv
cd ..\bin
call :editFile AOCEGFX1.lab
call :editFile AOCEGFX2.lab
call :editFile AGE1.lab
call :editFile AGE2.lab
call :editFile AGE3.lab
call :editFile AGE4.lab
cd ..
spasm -E -T -L aoce.asm bin\aoce.bin
convhex -x bin\aoce.bin
del bin\aoce.bin
del bin\AOCEGFX1.lab
del bin\AOCEGFX2.lab
del bin\AGE1.lab
del bin\AGE2.lab
del bin\AGE3.lab
del bin\AGE4.lab
pause
exit

:editFile
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
del %filename%
ren temp.txt %filename%
exit /b