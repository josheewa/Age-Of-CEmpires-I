; Converted using ConvPNG
; This file contains all the graphics for easier inclusion in a project
#ifndef gfx_buildings_H
#define gfx_buildings_INC

; assembler defines
#define db .db
#define dw .dw
#define dl .dl

#include "gfx_buildings.asm"
gfx_buildings_transpcolor_index equ 0

#include "barracks.asm" ; 7778 bytes
#include "farm.asm" ; 4706 bytes
#include "house.asm" ; 3330 bytes
#include "lumbercamp.asm" ; 3138 bytes
#include "mill.asm" ; 3330 bytes
#include "miningcamp.asm" ; 2754 bytes
#include "towncenter.asm" ; 12930 bytes

#endif
