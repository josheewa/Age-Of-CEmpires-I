start:
#define db .db
#define equ .equ
#include "gfx/Main/gfx_main1.inc"
#include "gfx/Main/gfx_main2.inc"

size_graphics_appv = $-start+8+8

.echo "Size of graphics appvar 1:  ",size_graphics_appv

#IF size_graphics_appv > 0FFFFh
.error "Graphics appvar too large!"
#ENDIF

.echo >> offset.asm "_AoCEI_compressed equ ",_AoCEI_compressed,"\n"
.echo >> offset.asm "_soldier_compressed equ ",_soldier_compressed,"\n"
.echo >> offset.asm "_playhelpquit_compressed equ ",_playhelpquit_compressed,"\n"
.echo >> offset.asm "_singlemultiplayer_compressed equ ",_singlemultiplayer_compressed,"\n"
.echo >> offset.asm "_newloadgame_compressed equ ",_newloadgame_compressed,"\n"
.echo >> offset.asm "_intro_compressed equ ",_intro_compressed,"\n"
.echo >> offset.asm "_pointer equ ",_pointer,"\n"