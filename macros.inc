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