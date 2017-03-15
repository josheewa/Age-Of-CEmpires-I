#macro shift_tile0_x_left()
	ld de, (iy+OFFSET_X_TILE0)
	dec de
	ld (iy+OFFSET_X_TILE0), de
#endmacro

#macro shift_tile0_x_right()
	ld de, (iy+OFFSET_X_TILE0)
	inc de
	ld (iy+OFFSET_X_TILE0), de
#endmacro

#macro shift_tile0_y_up()
	ld de, (iy+OFFSET_Y_TILE0)
	dec de
	ld (iy+OFFSET_Y_TILE0), de
#endmacro

#macro shift_tile0_y_down()
	ld de, (iy+OFFSET_Y_TILE0)
	inc de
	ld (iy+OFFSET_Y_TILE0), de
#endmacro

#macro printString(message, x, y)
	ld l, y
	push hl
		ld hl, x
		push hl
			ld hl, message
			push hl
				call gfx_PrintStringXY
			pop hl
		pop hl
	pop hl
#endmacro

#macro dispCompressedImage(pointer, x, y)
#IF x==y
	ld hl, x
	push hl
		push hl
#ELSE
	ld l, y
	push hl
		ld hl, x
		push hl
#ENDIF
			ld de, plotSScreen
			push de
				ld hl, pointer \.r1
				call DecompressSprite
				call gfx_Sprite_NoClip
			pop de
		pop hl
	pop hl
#endmacro