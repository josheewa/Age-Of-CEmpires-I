FindPath:
	di
	ld	iy, PathFindingData
	ld	(iy+PFStartX), 2
	ld	(iy+PFStartY), 4
	ld	(iy+PFEndX), 6
	ld	(iy+PFEndY), 5
	ld	(iy+PFAmountOfOpenTiles), 1
	ld	(iy+PFAmountOfClosedTiles), 0
	ld	hl, PFOpenedList
	ld	(hl), 4
	inc	hl
	ld	(hl), 2
	inc	hl
	ld	(hl), 0
	inc	hl
	ld	(hl), 5-4+6-2
	jr	FindPath2
TempMapData:
    .db 0, 0, 0, 0, 0, 0, 0, 0, 0
    .db 0, 1, 1, 1, 1, 1, 1, 1, 0
    .db 0, 1, 1, 1, 0, 1, 1, 1, 0
    .db 0, 1, 1, 1, 0, 1, 1, 1, 0
    .db 0, 1, 1, 1, 0, 1, 1, 1, 0
    .db 0, 1, 0, 1, 0, 1, 1, 1, 0
    .db 0, 1, 1, 1, 1, 1, 1, 1, 0
    .db 0, 0, 0, 0, 0, 0, 0, 0, 0
FindPath2:
; 25049 cycles
;  Lists stack entry:
;   1b - Y
;   1b - X  (yes, X and Y are reversed)
;   1b - Depth
;   1b - Total score

	xor	a, a
	ld	e, a			; E = selected tile index
	ld	b, (iy+PFAmountOfOpenTiles) ; B = amount of open tiles
	or	a, b
	ret	z			; There exists no path
	dec	(iy+PFAmountOfOpenTiles)
	ld	hl, PFOpenedList-1	; Get the minimum score
	ld	a, -1			; A = current minimum score
GetMinimumTile:
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	cp	a, (hl)
	jr	c, +_
	ld	a, (hl)
	ld	(iy+PFIndexOfCurInOpenList), e
_:	inc	e
	djnz	GetMinimumTile
	ld	l, (iy+PFIndexOfCurInOpenList) ; Get the tile with the lowest score
	ld	h, b
	add	hl, hl
	add	hl, hl
	ex.s	de, hl
	ld	ix, PFOpenedList
	add	ix, de
	ld	l, (iy+PFAmountOfClosedTiles) ; Copy current tile to closed tiles
	ld	h, b
	add	hl, hl
	add	hl, hl
	ld	de, PFClosedList
	add	hl, de
	ld	de, (ix)
	ld	(hl), de
	inc	hl
	inc	hl
	inc	hl
	ld	(hl), a
	inc	(iy+PFAmountOfClosedTiles)
	ld	(iy+PFCurY), de		; Copy the X, Y and depth of the current tile
	ld	a, (iy+PFIndexOfCurInOpenList)
	sub	a, (iy+PFAmountOfOpenTiles)
	jr	z, CheckLeftNeighbour	; The selected tile was the last in the list, so don't move the others
	exx
	lea	de, ix			; Move selected tile to closed list
	lea	hl, ix+4
	neg
	ld	c, a
	ld	b, 4
	mlt	bc
	ldir
	exx
CheckLeftNeighbour:
	ld	a, d
	or	a, a
	jr	z, CheckUpperNeighbour
	dec	d
	call	AddMaybeTileToStack
	inc	d
CheckUpperNeighbour:
	ld	a, e
	or	a, a
	jr	z, CheckRightNeighbour
	dec	e
	call	AddMaybeTileToStack
	inc	e
CheckRightNeighbour:
	ld	a, d
	cp	a, 8
	jr	z, CheckLowerNeightbour
	inc	d
	call	AddMaybeTileToStack
	dec	d
CheckLowerNeightbour:
	ld	a, e
	cp	a, 7
	jr	z, +_
	inc	e
	call	AddMaybeTileToStack
_:	jp	FindPath2
FoundPath:
	pop	hl
	ret
    
AddMaybeTileToStack:
	ld	hl, (iy+PFEndY)
	xor	a, a
	sbc.s	hl, de
	jr	z, FoundPath
CheckOpenList:
	ld	ix, PFOpenedList
	or	a, (iy+PFAmountOfOpenTiles)
	jr	z, CheckClosedList
	ld	b, a
_:	ld	hl, (ix)
	xor	a, a
	sbc.s	hl, de
	ret	z
	lea	ix, ix+4
	djnz	-_
CheckClosedList:
	ld	ix, PFClosedList
	or	a, (iy+PFAmountOfClosedTiles)
	jr	z, AddTileIfWalkable
	ld	b, a
_:	ld	hl, (ix)
	xor	a, a
	sbc.s	hl, de
	ret	z
	lea	ix, ix+4
	djnz	-_
AddTileIfWalkable:
	ld	c, d
	ld	d, a
	ld	b, a
	ld	l, e
	ld	h, a
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, de
	add.s	hl, bc
	ld	d, c			; Restore DE
	ld	bc, TempMapData
	add	hl, bc
	or	a, (hl)
	ret	z
	ld	l, (iy+PFAmountOfOpenTiles)
	ld	h, 0
	add.s	hl, hl
	add	hl, hl
	ld	bc, PFOpenedList
	add	hl, bc
	ld	(hl), e
	inc	hl
	ld	(hl), d
	inc	hl
	ld	a, (iy+PFCurTileDepth)
	inc	a
	ld	(hl), a
	inc	hl
	ld	c, a
	ld	a, (iy+PFEndX)		; Find the distance to end, abs(X_end - X_curr) + abs(Y_end - Y_curr)
	sub	a, d			; abs(X_end - X_curr)
	jr	nc, +_
	cpl
_:	adc	a, c			; Add the distance
	ld	b, a
	ld	a, (iy+PFEndY)		; abs(Y_end - Y_curr)
	sub	a, e
	jr	nc, +_
	cpl
_:	adc	a, b			; Add them
	ld	(hl), a
	inc	(iy+PFAmountOfOpenTiles)
	ret