DrawBuildings:
	ld hl, 256
	ld (MaxMinYOffset), hl
	ld hl, MAP_SIZE*16+(320/2)-16-16
	ld de, (ix+OFFSET_X)
	or a, a
	sbc hl, de
	ld (OffsetX2), hl
	ld a, (AmountOfBuildings)
	or a, a
	jp z, DrawBuildingsStop
	ld iy, buildings_stack
DrawBuildingsLoop:
	push af
		push iy
			ld de, 0
			ld e, (iy+2)
			push de
			pop hl
			ld e, (iy+1)
			add hl, de
			add hl, hl
			add hl, hl
			add hl, hl
			ld bc, 240/2-8
			add hl, bc
			push hl
				ld hl, BuildingsSizes
				ld c, (iy+0)
				add hl, bc
				ld c, (hl)
				ld b, 8
				mlt bc
			pop hl
			add hl, bc
			ld bc, (ix+OFFSET_Y)
			or a, a
			sbc hl, bc
			push hl
				ld hl, BuildingsHeights
				ld bc, 0
				ld c, (iy+0)
				add hl, bc
				ld c, (hl)
			pop hl
			sbc hl, bc
			push hl
				call CheckIfSpriteYIsOffscreen
				jr nc, ++_
				or a, a
				sbc hl, hl
				ex de, hl
				ld e, (iy+2)
				sbc hl, de
				add hl, hl
				add hl, hl
				add hl, hl
				add hl, hl
OffsetX2 = $+1
				ld bc, 0
				add hl, bc
				push hl
					call CheckIfSpriteXIsOffscreen
					jr nc, +_
					ld c, (iy+0)
					ld b, 3
					mlt bc
					ld hl, BuildingsPointer
					add hl, bc
					ld hl, (hl)
					push hl
						call gfx_TransparentSprite
					pop hl
_:				pop hl
_:			pop hl
		pop iy
	pop af
	lea iy, iy+3
	dec a
	jp nz, DrawBuildingsLoop
DrawBuildingsStop: