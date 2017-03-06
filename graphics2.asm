start:
#define db .db
#define equ .equ
#include "gfx/Buildings/gfx_buildings.inc"
#include "gfx/Gameplay/gfx_gameplay.inc"
#include "gfx/Tiles/gfx_tiles.inc"

size_graphics_appv = $-start+8+8

.echo "Size of graphics appvar 2:  ",size_graphics_appv

#IF size_graphics_appv > 0FFFFh
.error "Graphics appvar too large!"
#ENDIF

.echo >> offset.asm "_barracks equ ",_barracks,"\n"
.echo >> offset.asm "_farm equ ",_farm,"\n"
.echo >> offset.asm "_house equ ",_house,"\n"
.echo >> offset.asm "_lumbercamp equ ",_lumbercamp,"\n"
.echo >> offset.asm "_mill equ ",_mill,"\n"
.echo >> offset.asm "_miningcamp equ ",_miningcamp,"\n"
.echo >> offset.asm "_towncenter equ ",_towncenter,"\n"
.echo >> offset.asm "_resources equ ",_resources,"\n"
.echo >> offset.asm "_grass equ ",_grass,"\n"
.echo >> offset.asm "_food equ ",_food,"\n"
.echo >> offset.asm "_gold equ ",_gold,"\n"
.echo >> offset.asm "_stone equ ",_stone,"\n"
.echo >> offset.asm "_grass_tree equ ",_grass_tree,"\n"
.echo >> offset.asm "_tree_up equ ",_tree_up,"\n"