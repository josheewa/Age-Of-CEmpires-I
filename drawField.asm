drawfield_loc = $
relocate(mpShaData)

DrawField:
	bit need_to_redraw_tiles, (iy+0)
	jr z, +_
	call DrawTiles
_:	ld de, vRAM+(32*320)+32												; Copy the buffer to/from (32, 32)
	ld hl, screenBuffer+(32*320)+32
	ld b, 0
	mlt bc
	ld a, 240-32-32
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
	ret
DrawFieldEnd:
	
endrelocate()
drawtiles_loc = $
relocate(cursorImage)

DrawTiles:
	ld b, (ix+OFFSET_X)
	bit 4, b
	ld a, 16
	ld c, 028h
	jr z, +_
	ld a, -16
	ld c, 020h
_:	ld (TopRowLeftOrRight), a
	ld a, c
	ld (IncrementRowXOrNot), a
	ld e, (ix+OFFSET_Y)
	ld d, 160
	mlt de
	ld hl, screenBuffer
	add hl, de
	add hl, de
	ld d, 0
	ld a, b
	add a, 15
	ld e, a
	add hl, de
	ld (startingPosition), hl
	ld de, (TopLeftYTile)
	ld b, 27
	ld hl, (TopLeftXTile)
	ld (TempSP2), sp
	ld sp, 320
DisplayEachRowLoop:
; Registers:
;   B' = row index
;   BC = length of row tile
;   DE = pointer to output
;   HL = pointer to tile/black
;   DE' = x index tile
;   HL' = y index tile
	bit 0, b													; Here are the shadow registers active
startingPosition = $+2
	ld iy, 0
	jr nz, +_
TopRowLeftOrRight = $+2
	lea iy, iy+0
_:	ld a, 9
	exx
	lea de, iy													; Populate DE to be the poiter to the output tile
	exx
DisplayTile:
	ld c, a														; Check if x/y tile is within the bounds
	ld a, d
	or a, h
	scf
	jr nz, +_
	ld a, e
	cp a, MAP_SIZE
	ccf
	jr c, +_
	ld a, l
	cp a, MAP_SIZE
	ccf
_:	ld a, c
	exx															; Here are the normal registers active
	ld hl, _tile_test \.r2
	jr nc, +_
	ld hl, 0E40000h
_:	ld ix, 0
	lea bc, ix+2
	add ix, de
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
	exx															; Shadow registers are active here
	inc hl
	dec de
	dec a
	jp nz, DisplayTile
	ld a, b
	ld bc, -9
	add hl, bc
	ex de, hl
	ld bc, 9+1
	add hl, bc
	ex de, hl
	ld b, a
	bit 0, b
IncrementRowXOrNot:
	jr nz, +_
	dec de
	inc hl
_:	exx															; Main registers are active here
	ld hl, (startingPosition)
	ld de, 8*320
	add hl, de
	ld (startingPosition), hl
	exx
	dec b
	jp nz, DisplayEachRowLoop
TempSP2 = $+1
	ld sp, 0
	ret
DrawTilesEnd:

endrelocate()