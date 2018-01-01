GenerateMap:
	call	EraseArea
	ld	hl, screenBuffer
	ld	(hl), 1
	ld	de, screenBuffer+1
	ld	bc, 320*240-1
	ldir
	jp	CreateMap
	printString(GeneratingMapMessage, 5, 112)
	ld	hl, (0F30044h)
	call	srand
	ld	b, 0
PlaceTreesLoop:
	ld	ixh, b
	call	prng24
	ld	bc, MAP_SIZE
	call	__idvrmu
	push	hl
	call	prng24
	ld	bc, MAP_SIZE
	call	__idvrmu
	ld	h, 160
	mlt	hl
	add	hl, hl
	pop	de
	add	hl, de
	ld	de, screenBuffer
	add	hl, de
	ld	(hl), TILE_TREE
	ld	b, ixh
	djnz	PlaceTreesLoop
	ld	b, 3			; Food, stone, gold
PlaceAllResourceTypesLoop:
	ld	ixh, b
	ld	b, 15			; Place 15 resources of each
PlaceResourceTypeLoop:
	ld	ixl, b
	call	prng24
	ld	bc, 7
	call	__idvrmu
	push	hl
	pop	de
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, de
	ld	de, ResourcesType1
	add	hl, de
	push	hl
	call	prng24
	ld	bc, MAP_SIZE-20-20
	call	__idvrmu
	ld	a, l
	add	a, 20
	ld	l, a
	ld	h, 160
	mlt	hl
	add	hl, hl
	push	hl
	call	prng24
	ld	bc, MAP_SIZE-20-20
	call	__idvrmu
	ld	a, l
	add	a, 20
	ld	l, a
	pop	de
	add	hl, de
	ld	de, screenBuffer
	add	hl, de
	push	hl
	pop	iy
	ld	de, 320-2
	ld	a, (hl)			; Check if one of the 9 blocks is already a tree/part of resource
	inc	hl
	or	a, (hl)
	inc	hl
	or	a, (hl)
	add	hl, de
	or	a, (hl)
	inc	hl
	or	a, (hl)
	inc	hl
	or	a, (hl)
	add	hl, de
	or	a, (hl)
	inc	hl
	or	a, (hl)
	inc	hl
	or	a, (hl)
	pop	de
	jr	nz, DontDrawResource
	lea	hl, iy
	mlt	bc
	ld	b, 3
PlaceResource:
	ld	c, b
	ld	b, 3
PlaceResourceRowLoop:
	ld	a, (de)
	or	a, a
	jr	z, +_
ResourceType = $+1
	ld	(hl), TILE_FOOD
_:	inc	hl
	inc	de
	djnz	PlaceResourceRowLoop
	ld	a, c
	inc	b
	ld	c, 320-256-3
	add	hl, bc
	ld	b, a
	djnz	PlaceResource
DontDrawResource:
	ld	b, ixl
	dec	b
	jp	nz, PlaceResourceTypeLoop
	ld	hl, ResourceType
	inc	(hl)
	ld	b, ixh
	dec	b
	jp	nz, PlaceAllResourceTypesLoop
CreateMap:
; All the resources are now placed, so copy them to the map appvar
	ld	hl, AoCEMapAppvar
	call	_Mov9ToOP1
	ld	hl, MAP_SIZE*MAP_SIZE*2
	call	_EnoughMem
	jp	c, ForceStopProgram
	ex	de, hl
	call	_CreateAppvar
	ld	hl, screenBuffer
	inc	de
	inc	de
	ld	ixh, MAP_SIZE
CopyMapToNewAppvarLoop:
	ld	b, MAP_SIZE
CopyRowLoop:
	ld	a, (hl)
	ld	(de), a
	inc	de
	dec	a
	jr	z, +_
	ld	a, 200
_:	ld	(de), a
	inc	hl
	inc	de
	djnz	CopyRowLoop
	ld	bc, 320-MAP_SIZE
	add	hl, bc
	dec	ixh
	jr	nz, CopyMapToNewAppvarLoop
	call	_OP4ToOP1
LoadMap:
	call	EraseArea
	printString(LoadingMapMessage, 5, 112)
	ld	hl, AoCEMapAppvar
	call	_Mov9ToOP1
	call	_ChkFindSym
	call	_ChkInRAM
	call	c, _Arc_Unarc
	ld	hl, mapAddress
    ; TEMP!!!
	ld	(hl), 1
	inc	hl
	ex	de, hl
	inc	hl
	inc	hl
	inc	hl
	ld	bc, MAP_SIZE*MAP_SIZE*2-1
	ldir
	ret
        
prng24:
	ld	iy, __state
	ld	hl, (iy+0*4+0)
	push	hl
	ld	hl, (iy+0*4+2)
	push	hl
	lea	hl, iy+1*4
	lea	de, iy+0*4
	ld	bc, 3*4
	ldir
	pop	bc
	pop	de
	ld	h, d
	ld	l, e
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	a, b
	xor	a, h
	ld	h, a
	xor	a, (iy+3*4+2)
	ld	(iy+3*4+3), a
	ld	b, a
	ld	a, c
	xor	a, l
	ld	l, a
	xor	a, (iy+3*4+1)
	ld	(iy+3*4+2), a
	xor	a, a
	add.s	hl, hl
	adc	a, a
	add.s	hl, hl
	adc	a, a
	add.s	hl, hl
	adc	a, a
	xor	a, d
	xor	a, (iy+3*4+0)
	ld	(iy+3*4+1), a
	ld	a, e
	xor	a, h
	ld	(iy+3*4+0), a
	ld	hl, (iy+3*4)
	ld	de, (iy+2*4)
	add	hl, de
	ret
	
__state:
	.db	10h, 0Fh, 0Eh, 0Dh
	.db	0Ch, 0Bh, 0Ah, 09h
	.db	08h, 07h, 06h, 05h
	.db	04h, 03h, 02h, 01h