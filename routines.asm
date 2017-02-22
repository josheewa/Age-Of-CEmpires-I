GetKeyFast:
	ld hl, 0F50200h
	ld (hl), h
	xor a, a
_:	cp a, (hl)
	jr nz, -_
	ret
	
CheckTileInField:
	push hl
		add hl, hl
	pop hl
	ret c
	ex de, hl
	push hl
		add hl, hl
	pop hl
	ex de, hl
	ret c
	ld c, a
	ld a, d
	or a, h
	ld a, c
	ret nz
	ld a, e
	cp a, MAP_SIZE
	ccf
	ld a, c
	ret c
	ld a, l
	cp a, MAP_SIZE
	ld a, c
	ccf
	ret