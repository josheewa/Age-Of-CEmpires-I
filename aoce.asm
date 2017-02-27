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
	call.lis fLockFlash - 0D10000h
	ld a, 0D0h
	.db 0EDh, 06Dh															; ld mb, a
	ld iy, flags
	jp _DrawStatusBar
#include "flash.asm"
RunProgram:
	or a, a
	sbc hl, hl
	ex de, hl
	ld hl, mpTmrCtrl
	ld (hl), %00000010
	inc hl
	set 1, (hl)
	set 2, (hl)
	ld l, 0
	ld (hl), de
	inc l
	ld (hl), de
	ld l, 010h
	ld (hl), de
	inc hl
	ld (hl), de
	ld l, $30
	set 0, (hl)
	set 3, (hl)
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
		jp ForceStopProgram
_:		call _ChkInRAM
		call nc, _Arc_Unarc
		call _ChkFindSym
		ld hl, 20
		add hl, de
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
	di
	ld.sis sp, 0987Eh
	ld a, 0D1h
	.db 0EDh, 06Dh															; ld mb, a
	call.lis fUnlockFlash - 0D10000h
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
	pop hl
	call DrawMainMenu
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
; Speed: 908839/342212 cycles
	call DrawField
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
	inc a
	and %00001111
	ld (ix+OFFSET_Y), a
	jr nz, CheckIfPressedRight
	shift_tile0_x_left()
	shift_tile0_y_up()
CheckIfPressedRight:
	bit kpRight, (hl)
	jr z, CheckIfPressedLeft
	ld a, (ix+OFFSET_X)
	or a, a
	jr nz, +_
	shift_tile0_x_right()
	shift_tile0_y_up()
_:	dec a
	and %00011111
	ld (ix+OFFSET_X), a
CheckIfPressedLeft:
	bit kpLeft, (hl)
	jr z, CheckIfPressedDown
	ld a, (ix+OFFSET_X)
	inc a
	and %00011111
	ld (ix+OFFSET_X), a
	jr nz, CheckIfPressedDown
	shift_tile0_x_left()
	shift_tile0_y_down()
CheckIfPressedDown:
	bit kpDown, (hl)
	jr z, CheckKeyPressesStop
	ld a, (ix+OFFSET_Y)
	or a, a
	jr nz, +_
	shift_tile0_x_right()
	shift_tile0_y_down()
_:	dec a
	and %00001111
	ld (ix+OFFSET_Y), a
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
#include "data.asm"
#include "mainmenu.asm"
#include "map.asm"
#include "decompress.asm"

#include "relocation_table1.asm"
	.dw 0FFFFh
#include "relocation_table2.asm"
	.dw 0FFFFh

.echo "Size of main program:       ",$-start+2+9+4