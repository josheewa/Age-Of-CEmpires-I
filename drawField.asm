drawfield_loc = $
relocate(mpShaData)

DrawField:
	bit need_to_redraw_tiles, (iy+0)
	call nz, DrawTiles
	ld de, vRAM+(32*320)+32										; Copy the buffer from (32, 64) to (32, 32)
	ld hl, screenBuffer+(64*320)+32
	ld bc, 0
	ld a, 240-32-32
CopyBufferLoop:
	ld c, b
	inc b														; Copy 256 bytes
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
	ld b, (ix+OFFSET_X)											; We start with the shadow registers active
	bit 4, b
	ld a, 16
	ld c, 020h
	jr z, +_
	ld a, -16
	ld c, 028h
_:	ld (TopRowLeftOrRight), a
	ld a, c
	ld (IncrementRowXOrNot1), a
	ld (IncrementRowXOrNot2), a
	ld e, (ix+OFFSET_Y)											; Point to the output
	ld d, 160
	mlt de
	ld hl, screenBuffer+(320*32)
	add hl, de
	add hl, de
	ld d, 0
	ld a, b
	add a, 15
	ld e, a
	add hl, de
	ld (startingPosition), hl
	ld hl, (TopLeftYTile)										; Y*MAP_SIZE+X, point to the map data
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	push hl
	pop de
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, de
	ld de, (TopLeftXTile)
	add hl, de
	ld bc, mapAddress
	add hl, bc
	ld (startingMapAddress), hl
	ld ix, (TopLeftYTile)
	ld a, 28
	ld (TempSP2), sp
	ld sp, 320
DisplayEachRowLoop:
; Registers:
;   A' = row index
;   BC = length of row tile
;   DE = pointer to output
;   HL = pointer to tile/black tile
;   B' = column index
;   DE' = x index tile
;   HL' = pointer to map data
;   IX = y index tile
;   IY = where to draw
;   SP = 320

	bit 0, a													; Here are the shadow registers active
startingPosition = $+2
	ld iy, 0
	jr z, +_
TopRowLeftOrRight = $+2
	lea iy, iy+0
_:	ex af, af'
	ld a, 9
DisplayTile:
	ld b, a
	ld a, d
	or a, ixh
	jr nz, TileIsOutOfField
	ld a, e
	cp a, MAP_SIZE
	jr nc, TileIsOutOfField
	ld a, ixl
	cp a, MAP_SIZE
	jr nc, TileIsOutOfField
CheckWhatTypeOfTileItIs:
	ld a, (hl)
	exx															; Here are the main registers active
	cp a, TileIsPartOfBuiling
	jp nc, SkipDrawingOfTile
	ld c, a
	ld b, 3
	mlt bc
	ld hl, TilesWithResourcesPointers
	add hl, bc
	ld hl, (hl)
	jr +_
TileIsOutOfField:
	exx
	ld hl, blackBuffer
_:	lea de, iy
	ld bc, 2
	ldir
	add iy, sp
	lea de, iy-2
	ld c, 6
	ldir
	add iy, sp
	lea de, iy-4
	ld c, 10
	ldir
	add iy, sp
	lea de, iy-6
	ld c, 14
	ldir
	add iy, sp
	lea de, iy-8
	ld c, 18
	ldir
	add iy, sp
	lea de, iy-10
	ld c, 22
	ldir
	add iy, sp
	lea de, iy-12
	ld c, 26
	ldir
	add iy, sp
	lea de, iy-14
	ld c, 30
	ldir
	add iy, sp
	lea de, iy-15
	ld c, 32
	ldir
	add iy, sp
	lea de, iy-14
	ld c, 30
	ldir
	add iy, sp
	lea de, iy-12
	ld c, 26
	ldir
	add iy, sp
	lea de, iy-10
	ld c, 22
	ldir
	add iy, sp
	lea de, iy-8
	ld c, 18
	ldir
	add iy, sp
	lea de, iy-6
	ld c, 14
	ldir
	add iy, sp
	lea de, iy-4
	ld c, 10
	ldir
	add iy, sp
	lea de, iy-2
	ld c, 6
	ldir
	add iy, sp
	lea de, iy-0
	ldi
	ldi
	ld de, 32-(320*16)
	jr +_
SkipDrawingOfTile:
	ld de, 32
_:	add iy, de
	exx
	inc de
	dec ix
	ld a, b
	ld bc, -MAP_SIZE+1
	add hl, bc
	dec a
	jp nz, DisplayTile
	ld bc, MAP_SIZE*10-9
	add hl, bc
	ex de, hl
	ld bc, -9
	add hl, bc
	ex de, hl
	lea ix, ix+9+1
	ex af, af'
	bit 0, a
IncrementRowXOrNot1:
	jr nz, +_
	inc de
	ld bc, -MAP_SIZE+1
	add hl, bc
	dec ix
_:	exx
	ld hl, (startingPosition)
	ld de, 8*320
	add hl, de
	ld (startingPosition), hl
	exx
	dec a
	jp nz, DisplayEachRowLoop
TempSP2 = $+1
	ld sp, 0
DrawAllBuildings:										; We start here 3 tiles to the left of the upperleft corner, because buildings can be 4 tiles width
startingMapAddress = $+2
	ld ix, 0
	ld bc, (MAP_SIZE-1)*3
	add ix, bc
	ld hl, (TopLeftXTile)
	dec hl
	dec hl
	dec hl
	ld de, (TopLeftYTile)
	ld b, 28+(101/32)
CheckEntireRowLoop:
	ld c, b
	ld b, 9+3+3											; Thus, we need to check +3 tiles at the left, and +3 tiles at the right
CheckTileLoop:
	ld a, h
	or a, d
	jr nz, SkipTile
	ld a, l
	cp a, MAP_SIZE
	jr nc, SkipTile
	ld a, e
	cp a, MAP_SIZE
	jr nc, SkipTile
	ld a, (ix)
	cp a, TileIsTree
	jr c, SkipTile
	exx
	; Display tree or building
	exx
SkipTile:
	inc hl
	dec de
	ld a, c
	ld bc, -MAP_SIZE+1
	add ix, bc
	djnz CheckTileLoop
	ld bc, -9-3-3
	add hl, bc
	ex de, hl
	ld bc, 9+3+3+1
	add hl, bc
	ex de, hl
	ld bc, MAP_SIZE*(9+3+3+1)-9-3-3
	bit 0, a
IncrementRowXOrNot2:
	jr nz, +_
	inc hl
	dec de
	ld bc, (MAP_SIZE*(9+3+3+1)-9-3-3)-MAP_SIZE+1
_:	add ix, bc
	ld b, a
	djnz CheckEntireRowLoop


	
	
	ret
DrawTilesEnd:

endrelocate()