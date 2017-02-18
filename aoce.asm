#include "ti84pce.inc"
#include "defines.asm"
#include "offset.asm"
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
	call.lis flock - 0D00000h
	ld iy, flags
	jp _DrawStatusBar
RunProgram:
	ld hl, funlock_loc
	ld bc, funlockEnd - funlock
	ld de, funlock
	ldir
	di
	call.lis funlock - 0D00000h
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
	ld hl, drawfield_loc
	ld de, DrawField
	ld bc, DrawFieldEnd - DrawField
	ldir
	ld de, DrawTiles
	ld bc, DrawTilesEnd - DrawTiles
	ldir
	ld hl, MAP_SIZE*16-8
	ld (ix+OFFSET_X), hl
	or a
	sbc hl, hl
	ld (ix+OFFSET_Y), hl
	ld hl, 0000000h
	ld (buildings_stack+0), hl
	ld de, vRAM
	ld hl, _resources \.r2
	ld bc, 320*15+1
	ldir
	ld hl, vRAM+(320*15)
	ld bc, 320*(240-15)-1
	ldir
MainGameLoop:
; Speed: 988734 cycles
	call DrawField
	ld ix, saveSScreen+21000
	call GetKeyFast
	ld l, 01Ch
	bit 6, (hl)
	jp nz, ForceStopProgram
	ld l, 01Eh
CheckIfPressedUp:
	bit 3, (hl)
	jr z, CheckIfPressedRight
	ld bc, (ix+OFFSET_Y)
	ld a, b
	or a, c
	jr z, CheckIfPressedRight
	dec bc
	dec bc
	;dec bc
	;dec bc
	ld (ix+OFFSET_Y), bc
CheckIfPressedRight:
	bit 2, (hl)
	jr z, CheckIfPressedLeft
	ex de, hl
	ld hl, MAP_SIZE*32-16
	ld bc, (ix+OFFSET_X)
	scf
	sbc hl, bc
	ex de, hl
	jr c, CheckIfPressedLeft
	inc bc
	inc bc
	;inc bc
	;inc bc
	ld (ix+OFFSET_X), bc
CheckIfPressedLeft:
	bit 1, (hl)
	jr z, CheckIfPressedDown
	ld bc, (ix+OFFSET_X)
	ld a, b
	or a, c
	jr z, CheckIfPressedDown
	dec bc
	dec bc
	;dec bc
	;dec bc
	ld (ix+OFFSET_X), bc
CheckIfPressedDown:
	bit 0, (hl)
	jr z, +_
	ex de, hl
	ld hl, MAP_SIZE*17-42
	ld bc, (ix+OFFSET_Y)
	scf
	sbc hl, bc
	ex de, hl
	jr c, +_
	inc bc
	inc bc
	;inc bc
	;inc bc
	ld (ix+OFFSET_Y), bc
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