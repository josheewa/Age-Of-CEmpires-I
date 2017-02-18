drawfield_loc = $
relocate(mpShaData)

DrawField:
	ld b, (ix+OFFSET_X)
	bit 4, b
	ld a, 020h
	jr z, +_
	ld a, 028h
_:	ld e, (ix+OFFSET_Y)
	bit 3, e
	jr z, +_
	xor a, %00001000										; switch jr z/nz
_:	ld (TopRowOrSecondRowLeft), a
	ld a, e
	and %00000111
	ld e, a
	ld d, 160
	mlt de
	call DrawTiles
	ld de, vRAM+(16*320)+32
	ld hl, screenBuffer+(16*320)+32
	ld b, 0
	mlt bc
	ld a, 240-16-32
CopyBufferLoop:
	ld c, b
	inc b
	ldir
	ld c, 32+32
	add hl, bc
	ex de, hl
	add hl, bc
	ex de, hl
	dec a
	jr nz, CopyBufferLoop
	ret
DrawFieldEnd:
	
.echo $-DrawField
	
endrelocate()
drawfieldstart_loc = $
relocate(cursorImage)
	
DrawTiles:
	ld hl, screenBuffer
	add hl, de
	add hl, de
	ld a, b
	and %00001111
	add a, 15
	ld d, 0
	ld e, a
	add hl, de
	ld (startingPosition), hl
	ld de, 8*320
	ld b, 27
	ld (TempSP2), sp
	ld sp, 320
DisplayEachRowLoop:
	bit 0, b
	exx
startingPosition = $+2
	ld iy, 0
TopRowOrSecondRowLeft:
	jr nz, +_
	lea iy, iy+16
_:	ld a, 9
	lea de, iy
DisplayTile:
	ld ix, 0
	lea bc, ix+2
	add ix, de
	ld hl, _tile_test \.r2
	ldir
	add ix, sp
	lea de, ix-2
	ld c, 6
	ldir
	add ix, sp
	lea de, ix-4
	ld c, 10
	ldir
	add ix, sp
	lea de, ix-6
	ld c, 14
	ldir
	add ix, sp
	lea de, ix-8
	ld c, 18
	ldir
	add ix, sp
	lea de, ix-10
	ld c, 22
	ldir
	add ix, sp
	lea de, ix-12
	ld c, 26
	ldir
	add ix, sp
	lea de, ix-14
	ld c, 30
	ldir
	add ix, sp
	lea de, ix-15
	ld c, 32
	ldir
	add ix, sp
	lea de, ix-14
	ld c, 30
	ldir
	add ix, sp
	lea de, ix-12
	ld c, 26
	ldir
	add ix, sp
	lea de, ix-10
	ld c, 22
	ldir
	add ix, sp
	lea de, ix-8
	ld c, 18
	ldir
	add ix, sp
	lea de, ix-6
	ld c, 14
	ldir
	add ix, sp
	lea de, ix-4
	ld c, 10
	ldir
	add ix, sp
	lea de, ix-2
	ld c, 6
	ldir
	add ix, sp
	lea de, ix
	ldi
	ldi
	ld hl, 30-(320*16)
	add hl, de
	ex de, hl
	dec a
	jp nz, DisplayTile
	exx
	add hl, de
	ld (startingPosition), hl
	dec b
	jp nz, DisplayEachRowLoop
TempSP2 = $+1
	ld sp, 0
	ret
DrawTilesEnd:

endrelocate()