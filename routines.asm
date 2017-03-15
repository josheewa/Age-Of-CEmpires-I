GetKeyFast:
	ld hl, 0F50200h
	ld (hl), h
	xor a, a
_:	cp a, (hl)
	jr nz, -_
	ret