;;; Variables
MAP_SIZE                    .equ 128
OFFSET_X                    .equ 0
OFFSET_Y                    .equ 1
OFFSET_X_TILE0              .equ 0
OFFSET_Y_TILE0              .equ 3

;;; Pointers
currDrawingBuffer           .equ 0E30014h
screenBuffer                .equ vRAM+(320*240)
mapAddress                  .equ pixelShadow
puppetStack                 .equ pixelShadow+(MAP_SIZE*MAP_SIZE*2)
blackBuffer                 .equ 0E40000h

;;; Keypresses
kpUp                        .equ 3
kpLeft                      .equ 1
kpRight                     .equ 2
kpDown                      .equ 0
kpClear                     .equ 6
kpEnter                     .equ 0

;;; Tiles
TILE_EMPTY                  .equ 0
TILE_GRASS                  .equ 1
TILE_FOOD                   .equ 2
TILE_GOLD                   .equ 3
TILE_STONE                  .equ 4
TILE_TREE                   .equ 5
TILE_BUILDING_1             .equ 6

;;; Puppet struct
puppetType                  .equ 0
puppetEvent                 .equ 1
puppetX                     .equ 2
puppetY                     .equ 3
puppetHealth                .equ 4
puppetHitpoints             .equ 5
puppetPath                  .equ 6