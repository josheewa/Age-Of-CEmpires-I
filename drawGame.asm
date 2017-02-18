DrawGame:
	ld hl, _resources \.r2
	ld de, (currDrawingBuffer)
	ld bc, 320*15
	ldir
	ld hl, 4
	push hl
		ld l, 17
		push hl
			call gfx_SetTextXY
			ld l, 5
			push hl
				ld hl, (AmountOfWood)
				push hl
					call gfx_PrintUInt
				pop hl
			pop hl
		pop hl
		ld l, 78
		push hl
			call gfx_SetTextXY
			ld l, 5
			push hl
				ld hl, (AmountOfFood)
				push hl
					call gfx_PrintUInt
				pop hl
			pop hl
		pop hl
		ld l, 144
		push hl
			call gfx_SetTextXY
			ld l, 5
			push hl
				ld hl, (AmountOfGold)
				push hl
					call gfx_PrintUInt
				pop hl
			pop hl
		pop hl
		ld l, 200
		push hl
			call gfx_SetTextXY
			ld l, 5
			push hl
				ld hl, (AmountOfGold)
				push hl
					call gfx_PrintUInt
				pop hl
			pop hl
		pop hl
		inc h
		ld l, 5
		push hl
			call gfx_SetTextXY
			ld l, 3
			push hl
				ld a, (AmountOfPeople)
				sbc hl, hl
				ld l, a
				push hl
					call gfx_PrintUInt
				pop hl
			pop hl
			ld l, '/'
			push hl
				call gfx_PrintChar
			pop hl
			ld l, 3
			push hl
				ld a, (AmountOfMaxPeople)
				or a, a
				sbc hl, hl
				ld l, a
				push hl
					call gfx_PrintUInt
				pop hl
			pop hl
		pop hl
	pop hl