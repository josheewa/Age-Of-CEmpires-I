GenerateMap:
	call EraseArea
	ld l, 112
	push hl
		ld hl, 5
		push hl
			ld hl, GeneratingMapMessage
			push hl
				call gfx_PrintStringXY									; gfx_PrintStringXY(GeneratingMapMessage, 5, 122);
			pop hl
		pop de
	pop hl
	ld hl, (mpTmr1Counter)
	ld (seed_1), hl
	ld hl, (mpTmr2Counter)
	ld (seed_2), hl
	ld de, screenBuffer
	ld hl, 0E40000h
	ld bc, 320*240
	ldir
	ld b, 255
FillMapLoop:
	ld ixh, b
	call prng24
	ld bc, 46
	call __idvrmu
	inc hl
	inc hl
	inc hl
	inc hl
	push hl
		call prng24
		ld bc, MAP_SIZE
		call __idvrmu
		push hl
			call prng24
			ld bc, MAP_SIZE
			call __idvrmu
			push hl
				call _IncrementFilledCircle
			pop hl
		pop hl
	pop hl
	ld b, ixh
	djnz FillMapLoop
PlaceTrees:
	ld hl, screenBuffer													; Check for every pixel, if it's lower than $1E, it becomes a tree
	ld bc, 320*240
CheckPixelLoop:
	ld a, (hl)
	ld e, 0
	cp 01Eh
	jr nc, CheckPixelNotTree
	ld e, 4
CheckPixelNotTree:
	ld (hl), e
	cpi
	jp pe, CheckPixelLoop
	ld b, 3																; Food, stone, gold
PlaceAllResourceTypesLoop:
	ld ixh, b
	ld b, 15															; Place 15 resources of each
PlaceResourceTypeLoop:
	ld ixl, b
	call prng24
	ld bc, 7
	call __idvrmu
	push hl
	pop de
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, de
	ld de, ResourcesType1
	add hl, de
	push hl
		call prng24
		ld bc, MAP_SIZE-20-20
		call __idvrmu
		ld a, l
		add a, 20
		ld l, a
		ld h, 160
		mlt hl
		add hl, hl
		push hl
			call prng24
			ld bc, MAP_SIZE-20-20
			call __idvrmu
			ld a, l
			add a, 20
			ld l, a
		pop de
		add hl, de
		ld de, screenBuffer
		add hl, de
		push hl
		pop iy
		ld de, 318
		ld a, (hl)														; Check if one of the 9 blocks is already a tree/part of resource
		inc hl
		or a, (hl)
		inc hl
		or a, (hl)
		add hl, de
		or a, (hl)
		inc hl
		or a, (hl)
		inc hl
		or a, (hl)
		add hl, de
		or a, (hl)
		inc hl
		or a, (hl)
		inc hl
		or a, (hl)
	pop hl
	jr nz, DontDrawResource
	lea de, iy
	ld b, 3
PlaceResource:
	ld c, b
	ld b, 3
PlaceResourceRowLoop:
	ld a, (hl)
	or a, a
	jr z, +_
ResourceType = $+1
	ld a, 1
	ld (de), a
_:	inc hl
	inc de
	djnz PlaceResourceRowLoop
	ld a, c
	ex de, hl
	inc b
	ld c, 320-256-3
	add hl, bc
	ex de, hl
	ld b, a
	djnz PlaceResource
DontDrawResource:
	ld b, ixl
	dec b
	jp nz, PlaceResourceTypeLoop
	ld hl, ResourceType
	inc (hl)
	ld b, ixh
	dec b
	jp nz, PlaceAllResourceTypesLoop
	call _ChkFindSym
	call nc, _DelVarArc
	ld hl, MAP_SIZE*MAP_SIZE
	call _EnoughMem
	jp c, ForceStopProgram
	ex de, hl
	call _CreateAppvar
	ld bc, 0
	ld hl, screenBuffer
	inc de
	inc de
	ld a, MAP_SIZE
CopyMapToNewAppvarLoop:
	ld c, MAP_SIZE
	ldir
	ld c, 320-MAP_SIZE
	add hl, bc
	dec a
	jr nz, CopyMapToNewAppvarLoop
	call _OP4ToOP1
LoadMap:
	call EraseArea
	ld l, 112
	push hl
		ld hl, 5
		push hl
			ld hl, LoadingMapMessage
			push hl
				call gfx_PrintStringXY									; gfx_PrintStringXY(LoadingMapMessage, 5, 122);
			pop hl
		pop de
	pop hl
	call _ChkFindSym
	call _ChkInRAM
	call c, _Arc_Unarc
	ld hl, mapAddress
	ld (hl), 0
	ex de, hl
	inc hl
	inc hl
	inc hl
	inc de
	ld bc, MAP_SIZE*MAP_SIZE
	ldir
	ret
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
prng24:
    ld de, (seed_1)
    or a, a
    sbc hl, hl
    add hl, de
    add hl, hl
    add hl, hl
    inc l
    add hl, de
    ld (seed_1), hl
    ld hl, (seed_2)
    add hl, hl
    sbc a, a
    and %00011011
    xor a, l
    ld l, a
    ld (seed_2), hl
    add hl, de
    ret
	
seed_1:
	.dl 0
seed_2:
	.dl 0
	
;-------------------------------------------------------------------------------
_IncrementFilledCircle:
; Increments an clipped circle
; Arguments:
;  arg0 : X coordinate
;  arg1 : Y coordinate
;  arg2 : Radius
; Returns:
;  None
	push ix
		ld ix, 0
		add ix, sp
		lea hl, ix-9
		ld sp, hl
		sbc hl, hl
		ld (ix-3), hl
		ld bc, (ix+12)
		ld (ix-6), bc
		inc hl
		sbc hl, bc
		ld (ix-9), hl
		jp b_4
_FillCircleSectors:
		ld	hl, (ix-3)
		add	hl, hl
		push hl
			ld bc, (ix-6)
			ld hl, (ix+9)
			add hl, bc
			push hl
				ld bc, (ix-3)
				ld hl, (ix+6)
				or a, a
				sbc hl, bc
				push hl
					call _HorizLine
					lea hl, ix-9
					ld sp, hl
		ld hl, (ix-3)
		add hl, hl
		push hl
			ld bc, (ix-6)
			ld hl, (ix+9)
			or a, a
			sbc hl, bc
			push hl
				ld bc, (ix-3)
				ld hl, (ix+6)
				or a, a
				sbc hl, bc
				push hl
					call _HorizLine
					lea hl, ix-9
					ld sp, hl
		ld hl, (ix-6)
		add hl, hl
		push hl
			ld bc, (ix-3)
			ld hl, (ix+9)
			add	hl, bc
			push hl
				ld bc, (ix-6)
				ld hl, (ix+6)
				or a, a
				sbc hl, bc
				push hl
					call _HorizLine
					lea hl, ix-9
					ld sp, hl
		ld hl, (ix-6)
		add hl, hl
		push hl
			ld bc, (ix-3)
			ld hl, (ix+9)
			or a, a
			sbc hl, bc
			push hl
				ld bc, (ix-6)
				ld hl, (ix+6)
				or a, a
				sbc hl, bc
				push hl
					call _HorizLine
					lea hl, ix-9
					ld sp, hl
		ld bc, (ix-3)
		inc bc
		ld (ix-3), bc
		ld bc, (ix-9)
		or a, a
		sbc hl, hl
		sbc hl, bc
		jp m, b__2
		jp pe, b_3
		jr b__3
b__2:	
		jp po, b_3
b__3:	
		ld hl, (ix-3)
		add hl, hl
		inc hl
		ld bc, (ix-9)
		add hl, bc
		ld (ix-9), hl
		jr b_4
b_3:	
		ld bc, (ix-6)
		dec	bc
		ld (ix-6), bc
		ld hl, (ix-3)
		ld de, (ix-9)
		or a, a
		sbc hl, bc
		add hl, hl
		inc hl
		add hl, de
		ld (ix-9), hl
b_4:	
		ld bc, (ix-3)
		ld hl, (ix-6)
		or a, a
		sbc hl, bc
		jp p, +_
		jp pe, _FillCircleSectors
		ld sp, ix
	pop	ix
	ret
_:		jp po, _FillCircleSectors
		ld sp, ix
	pop ix
	ret

	
;-------------------------------------------------------------------------------
_HorizLine:
; Draws an clipped horizontal line with the global color index
; Arguments:
;  arg0 : X coordinate
;  arg1 : Y coordinate
;  arg2 : Length
; Returns:
;  None
	ld iy, 0
	add iy, sp
	ld de, 0
	ld hl, (iy+6)
	call _SignedCompare_ASM     	; compare y coordinate <-> ymin
	ret c
	ld hl, MAP_SIZE-1				; inclusive
	ld de, (iy+6)
	call _SignedCompare_ASM      	; compare y coordinate <-> ymax
	ret c
	ld hl, (iy+9)
	ld de, (iy+3)
	add hl, de
	ld (iy+9), hl
	ld hl, 0
	call _Max_ASM 
	ld (iy+3), hl                   ; save maximum x value
	ld hl, MAP_SIZE 
	ld de, (iy+9)
	call _Min_ASM 
	ld (iy+9), hl                   ; save minimum x value
	ld de, (iy+3)
	call _SignedCompare_ASM 
	ret c
	ld hl, (iy+9)
	sbc hl, de
	push hl
	pop bc                          ; bc = length
	ld e, (iy+6)                    ; e = y coordinate
	sbc hl, hl
	adc hl, bc
	ret z                           ; make sure the width is not 0 	
	ld hl, (iy+3)
_HorizLine_NoClip_ASM:
	ld d, 160
	mlt de
	add hl, de
	add hl, de
	ld de, screenBuffer
	add hl, de                       ; hl -> place to draw
IncrementPixelLoop:
	inc (hl)
	inc hl
	dec bc
	ld a, b
	or a, c
	jr nz, IncrementPixelLoop
	ret
	
_SignedCompare_ASM:
	or	a,a
	sbc	hl,de
	add	hl,hl
	ret	po
	ccf
	ret
	
_Max_ASM:
; Calculate the resut of a signed comparison
; Inputs:
;  DE,HL=numbers
; Oututs:
;  HL=max number
	or	a,a
	sbc	hl,de
	add	hl,de
	jp	p,+_
	ret	pe
	ex	de,hl
_:	ret	po
	ex	de,hl
	ret
	
;-------------------------------------------------------------------------------
_Min_ASM:
; Calculate the resut of a signed comparison
; Inputs:
;  DE,HL=numbers
; Oututs:
;  HL=min number
	or	a,a
	sbc	hl,de
	ex	de,hl
	jp	p,+_
	ret	pe
	add	hl,de
_:	ret	po
	add	hl,de
	ret