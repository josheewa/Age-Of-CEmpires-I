drawfield_loc = $
relocate(mpShaData)

DrawField:
	bit need_to_redraw_tiles, (iy+0)
	call nz, DrawTiles
	ld de, vRAM+(32*320)+32										; Copy the buffer from (32, 64) to (32, 32)
	ld hl, screenBuffer+(64*320)+32
	ld b, 0
	mlt bc
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
.echo $-DrawField
	
endrelocate()
drawtiles_loc = $
relocate(cursorImage)

DrawTiles:
	ld b, (ix+OFFSET_X)											; We start with the shadow registers active
	bit 4, b
	ld a, 16
	ld c, 028h
	jr z, +_
	ld a, -16
	ld c, 020h
_:	ld (TopRowLeftOrRight), a
	ld a, c
	ld (IncrementRowXOrNot), a
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
	ld de, mapAddress
	add hl, de
	ld de, (TopLeftXTile)
	ld ix, (TopLeftYTile)
	ld a, 27
	ld (TempSP2), sp
	ld sp, 320
DisplayEachRowLoop:
; Registers:
;   A' = row index
;   BC = length of row tile
;   DE = pointer to output
;   HL = pointer to tile/black tile
;   BC' = temp
;   DE' = x index tile
;   HL' = pointer to map data
;   IX = y index tile
;   IY = where to draw
;   SP = 320

	bit 0, a													; Here are the shadow registers active
startingPosition = $+2
	ld iy, 0
	jr nz, +_
TopRowLeftOrRight = $+2
	lea iy, iy+0
_:	ex af, af'
	ld a, 9
	exx
	lea de, iy													; Populate DE to be the poiter to the output tile
	exx
DisplayTile:
	ld iyh, a													; Check if x/y tile is within the bounds
	ld a, d														; = Check if both DE and IX < MAP_SIZE
	or a, ixh
	jr nz, TileIsOutOfField
	ld a, e
	cp a, MAP_SIZE
	jr nc, TileIsOutOfField
	ld a, ixl
	cp a, MAP_SIZE
TileIsOutOfField:
	ld a, (hl)
	exx															; Here are the normal registers active
	ld hl, blackBuffer
	jr nc, StartDisplayIsoTile
	ld c, a
	ld b, 3
	mlt bc
	ld hl, TilesWithResourcesPointers
	add hl, bc
	ld hl, (hl)
StartDisplayIsoTile:
	ld a, iyh
	ld iy, 0													; Display isometric tile
	lea bc, iy+2
	add iy, de
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
	ld hl, 30-(320*16)
	add hl, de
	ex de, hl
	exx															; Shadow registers are active here
	inc de
	dec ix
	ld bc, -MAP_SIZE+1
	add hl, bc
	dec a
	jp nz, DisplayTile
	ex af, af'
	ld bc, MAP_SIZE*10-9
	add hl, bc
	ex de, hl
	ld bc, -9
	add hl, bc
	ex de, hl
	lea ix, ix+9+1
	bit 0, a
IncrementRowXOrNot:
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
	ret
DrawTilesEnd:

endrelocate()