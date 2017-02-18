DisplayMenu:
	ld de, (currDrawingBuffer)
	ld hl, 0E40000h
	ld bc, 320*240
	ldir