@ECHO OFF
mode con lines=30
if not exist bin\ mkdir bin
del "relocation_table1.asm"
del "relocation_table2.asm"
del "offset.asm"
tools\spasm -E graphics1.asm bin\AOCEGFX1.8xv
tools\spasm -E graphics2.asm bin\AOCEGFX2.8xv
tools\spasm -E -T -L aoce.asm bin\aoce.8xp
tools\convhex -x bin\aoce.8xp
del "bin\aoce.8xp"
ren bin\aoce_.8xp aoce.8xp
Pause