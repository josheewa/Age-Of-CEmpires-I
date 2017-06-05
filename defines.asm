MAP_SIZE                    .equ 128
OFFSET_X                    .equ 0
OFFSET_Y                    .equ 1
OFFSET_X_TILE0              .equ 0
OFFSET_Y_TILE0              .equ 3

currDrawingBuffer           .equ 0E30014h
screenBuffer                .equ vRAM+(320*240)
mapAddress                  .equ pixelShadow
blackBuffer                 .equ 0E40000h

need_to_redraw_tiles        .equ 0

kpUp                        .equ 3
kpLeft                      .equ 1
kpRight                     .equ 2
kpDown                      .equ 0
kpClear                     .equ 6
kpEnter                     .equ 0

; Only 2 walkable tiles
TILE_EMPTY                  .equ 0
TILE_GRASS                  .equ 1

; These are not walkable tiles
TILE_FOOD                   .equ 2
TILE_GOLD                   .equ 3
TILE_STONE                  .equ 4
TILE_TREE                   .equ 5
TILE_BUILDING_1             .equ 6