start2:
#define db .db
#define equ .equ
#include "gfx2/Main/gfx_main1.inc"
#include "gfx2/Main/gfx_main2.inc"

size_graphics_appv = $-start2+8+8

.echo "Size of graphics appvar 1:  ",size_graphics_appv

#IF size_graphics_appv > 0FFFFh
.error "Graphics appvar too large!"
#ENDIF
