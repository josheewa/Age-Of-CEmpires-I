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
.echo >> offset.asm "_barracks_height equ ",_barracks_height,"\n"
.echo >> offset.asm "_farm equ ",_farm,"\n"
.echo >> offset.asm "_farm_height equ ",_farm_height,"\n"
.echo >> offset.asm "_house equ ",_house,"\n"
.echo >> offset.asm "_house_height equ ",_house_height,"\n"
.echo >> offset.asm "_lumbercamp equ ",_lumbercamp,"\n"
.echo >> offset.asm "_lumbercamp_height equ ",_lumbercamp_height,"\n"
.echo >> offset.asm "_mill equ ",_mill,"\n"
.echo >> offset.asm "_mill_height equ ",_mill_height,"\n"
.echo >> offset.asm "_miningcamp equ ",_miningcamp,"\n"
.echo >> offset.asm "_miningcamp_height equ ",_miningcamp_height,"\n"
.echo >> offset.asm "_towncenter equ ",_towncenter,"\n"
.echo >> offset.asm "_towncenter_height equ ",_towncenter_height,"\n"
.echo >> offset.asm "_resources equ ",_resources,"\n"
.echo >> offset.asm "_grass equ ",_grass,"\n"
.echo >> offset.asm "_food equ ",_food,"\n"
.echo >> offset.asm "_gold equ ",_gold,"\n"
.echo >> offset.asm "_stone equ ",_stone,"\n"
.echo >> offset.asm "_tree equ ",_tree,"\n"