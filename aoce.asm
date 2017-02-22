#include "ti84pce.inc"
#include "defines.asm"
#include "offset.asm"
#include "macros.inc"
#include "relocation.inc"

.db tExtTok, tAsm84CECmp
.org UserMem

#define db .db

start:
	ld hl, LibLoadAppVar
	call _Mov9ToOP1
	ld a, AppVarObj
	ld (OP1), a
_:	call _ChkFindSym
	jr c, NotFound
	call _ChkInRAM
	jr nz, InArc
	call _PushOP1
	call _Arc_UnArc
	call _PopOP1
	jr -_
InArc:
	ex de, hl
	ld de, 9
	add hl, de
	ld e, (hl)
	add hl, de
	inc hl
	inc hl
	inc hl
	ld de, RelocationStart
	jp (hl)
NotFound:
	call _ClrScrn
	call _HomeUp
	ld hl, MissingAppVar
	call _PutS
	call _NewLine
	jp _PutS
RelocationStart:
	.db 0C0h, "GRAPHX", 0, 4
gfx_Begin:
	jp 0
gfx_End:
	jp 3
gfx_SetDraw:
	jp 27
gfx_SwapDraw:
	jp 30
gfx_PrintChar:
	jp 42
gfx_PrintUInt:
	jp 48
gfx_PrintStringXY:
	jp 54
gfx_SetTextXY:
	jp 57
gfx_SetTextFGColor:
	jp 63
gfx_FillRectangle_NoClip:
	jp 126
gfx_TransparentSprite:
	jp 174
gfx_Sprite_NoClip:
	jp 177
gfx_SetTransparentColor:
	jp 225
	
	call _HomeUp
	call _ClrLCDFull
	call _RunIndicOff
	ld (backupSP), sp
	call RunProgram
ForceStopProgram:
backupSP = $+1
	ld sp, 0
	call gfx_End
	call.lis flock - 0D10000h
	ld a, 0D0h
	.db 0EDh, 06Dh															; ld mb, a
	ld iy, flags
	jp _DrawStatusBar
funlock:
	ld a, 08Ch
	out0 (024h), a
	ld c, 4
	in0 a, (6)
	or c
	out0 (6), a
	out0 (028h), c
	ret.l
flock:
	xor	a, a
	out0 (028h), a
	in0 a, (6)
	res 2, a
	out0 (6), a
	ld a, 088h
	out0(024h), a
	ret.l
RunProgram:
	ld a, 0D1h
	.db 0EDh, 06Dh															; ld mb, a
	di
	call.lis funlock - 0D10000h
	ld b, 2
	ld ix, GraphicsAppvar
LoadSpritesAppvar:
	push bc
		inc (ix+8)
		lea hl, ix
		call _Mov9ToOP1
		call _ChkFindSym
		jr nc, +_
		ld hl, GraphicsAppvarNotFound
		call _PutS
		call _NewLine
		lea hl, ix+1
		call _PutS
		call _GetKey
		jr ForceStopProgram
_:		call _ChkInRAM
		ex de, hl
		jr nc, +_
		ld de, 18
		add hl, de
_:		inc hl
		inc hl
		ld (GraphicsAppvarStart), hl
	pop bc
	ld d, b
	ld e, 3
	dec d
	mlt de
	ld hl, RelocationTables
	add hl, de
	ld hl, (hl)
ChangeRelocationTableLoop:
	push hl
		ld hl, (hl)
		ld a, h
		and a, l
		inc a
		jr z, +_
		push hl
			ld hl, (hl)
GraphicsAppvarStart = $+1
			ld de, 0
			add hl, de
			ex de, hl
		pop hl
		ld (hl), de
	pop hl
	inc hl
	inc hl
	inc hl
	jr ChangeRelocationTableLoop
_:	pop hl
	djnz LoadSpritesAppvar
	ld hl, drawfield_loc
	ld de, DrawField
	ld bc, DrawFieldEnd - DrawField
	ldir
	ld de, DrawTiles
	ld bc, DrawTilesEnd - DrawTiles
	ldir
	
	ld ix, saveSScreen+21000
	ld l, lcdBpp8
	push hl
		call gfx_Begin
		ld l, 254
		ex (sp), hl
		call gfx_SetTextFGColor
		ld l, 255
		ex (sp), hl
		call gfx_SetTransparentColor
		ld l, 1
		ex (sp), hl
		call gfx_SetDraw
	pop hl
	;ld hl, MAP_SIZE*16-8
	;ld (ix+OFFSET_X), hl
	xor a, a
	ld (ix+OFFSET_X), a
	ld (ix+OFFSET_Y), a
	ld iy, AoCEFlags
	set need_to_redraw_tiles, (iy+0)
	ld hl, 0000000h
	ld (buildings_stack+0), hl
	ld de, vRAM
	ld hl, _resources \.r2
	ld bc, 320*15
	ldir
	ld hl, 0E40000h
	ld bc, 320*(240-15)
	ldir
	
	
MainGameLoop:
; Speed: 994146/376705 cycles
	bit need_to_redraw_tiles, (iy+0)
	call nz, DrawField
	ld de, vRAM+(16*320)+32												; Copy the buffer to/from (32, 16)
	ld hl, screenBuffer+(16*320)+32
	ld b, 0
	mlt bc
	ld a, 240-16-32
CopyBufferLoop:
	ld c, b
	inc b																; Copy 256 bytes
	ldir
	ld c, 32+32
	add hl, bc
	ex de, hl
	add hl, bc
	ex de, hl
	dec a
	jr nz, CopyBufferLoop
	ld ix, saveSScreen+21000
	call GetKeyFast
	ld iy, TopLeftXTile
	ld l, 01Ch
	bit kpClear, (hl)
	jp nz, ForceStopProgram
	ld l, 01Eh
CheckIfPressedUp:
	bit kpUp, (hl)
	jr z, CheckIfPressedRight
	ld a, (ix+OFFSET_Y)
	or a, a
	jr nz, +_
	shift_tile0_x_right()
	shift_tile0_y_down()
_:	dec a
	and %00001111
	ld (ix+OFFSET_Y), a
CheckIfPressedRight:
	bit kpRight, (hl)
	jr z, CheckIfPressedLeft
	ld a, (ix+OFFSET_X)
	inc a
	and %00011111
	ld (ix+OFFSET_X), a
	jr nz, CheckIfPressedLeft
	shift_tile0_x_left()
	shift_tile0_y_down()
CheckIfPressedLeft:
	bit 1, (hl)
	jr z, CheckIfPressedDown
	ld a, (ix+OFFSET_X)
	or a, a
	jr nz, +_
	shift_tile0_x_right()
	shift_tile0_y_up()
_:	dec a
	and %00011111
	ld (ix+OFFSET_X), a
CheckIfPressedDown:
	bit kpDown, (hl)
	jr z, CheckKeyPressesStop
	ld a, (ix+OFFSET_Y)
	inc a
	and %00001111
	ld (ix+OFFSET_Y), a
	jr nz, CheckKeyPressesStop
	shift_tile0_x_left()
	shift_tile0_y_up()
CheckKeyPressesStop:
	ld iy, AoCEFlags
	res need_to_redraw_tiles, (iy+0)
	ld a, (hl)
	or a, a
	jr z, +_
	set need_to_redraw_tiles, (iy+0)
_:	jp MainGameLoop
	
#include "routines.asm"
#include "drawField.asm"
#include "drawMenu.asm"
#include "data.asm"
#include "decompress.asm"

#include "relocation_table1.asm"
	.dw 0FFFFh
#include "relocation_table2.asm"
	.dw 0FFFFh

.echo "Size of main program:       ",$-start+2+9+4