drawfield_loc = $
relocate(cursorImage)

DrawField:
    ld b, (ix+OFFSET_X)                                         ; We start with the shadow registers active
    bit 4, b
    ld a, 16
    ld c, 028h
    jr z, +_
    ld a, -16
    ld c, 020h
_:  ld (TopRowLeftOrRight), a
    ld a, c
    ld (IncrementRowXOrNot1), a
    ld a, (ix+OFFSET_Y)                                         ; Point to the output
    add a, 31 - 8                                               ; We start at row 31
    ld e, a
    ld d, 160
    mlt de
    ld hl, (currDrawingBuffer)
    add hl, de
    add hl, de
    ld d, 0
    ld a, b
    add a, 15
    ld e, a
    add hl, de
    ld (startingPosition), hl
    ld hl, (_IYOffsets + TopLeftYTile)                           ; Y*MAP_SIZE+X, point to the map data
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    ld de, (_IYOffsets + TopLeftXTile)
    add hl, de
    add hl, hl                                                  ; Each tile is 2 bytes worth
    ld bc, mapAddress
    add hl, bc
    ld ix, (_IYOffsets + TopLeftYTile)
    ld a, 23
    ld (TempSP2), sp
    ld sp, lcdWidth
DisplayEachRowLoop:
; Registers:
;   A   = height of tile/building
;   BC  = length of row tile
;   DE  = pointer to output
;   HL  = pointer to tile/black tile
;   A'  = row index
;   B'  = column index
;   DE' = x index tile
;   HL' = pointer to map data
;   IX  = y index tile
;   IY  = pointer to output
;   SP  = SCREEN_WIDTH

startingPosition = $+2                                          ; Here are the shadow registers active
    ld iy, 101
    ld bc, 8*320
    add iy, bc
    ld (startingPosition), iy
    bit 0, a
    jr nz, +_
TopRowLeftOrRight = $+2
    lea iy, iy+0
_:  ex af, af'
    ld a, 9
DisplayTile:
    ld b, a
    ld a, d
    or a, ixh
    jr nz, TileIsOutOfField
    ld a, e                                                     ; Check if one of the both indexes is more than the MAP_SIZE, which is $80
    or a, ixl
    add a, a
    jr c, TileIsOutOfField
CheckWhatTypeOfTileItIs:
    ld a, (hl)
    exx                                                         ; Here are the main registers active
    or a, a
    jp z, SkipDrawingOfTile
    ld c, a
    ld b, 7
    mlt bc
    ld hl, TilePointers-7
    add hl, bc
    ld de, (hl)                                                 ; Offset from the current position, if the tile/building has a height
    add iy, de
    inc hl
    inc hl
    inc hl
    ld a, (hl)                                                  ; Height of the tile
    inc hl
    ld hl, (hl)                                                 ; Pointer to the tile
    jr +_
TileIsOutOfField:
    exx
    ld hl, blackBuffer
    ld a, 1
_:  lea de, iy
    jp DrawTiles
ActuallyDisplayTile:
    add iy, sp
    lea de, iy-14
    ld c, 30
    ldir
_:  add iy, sp                                                  ; Display middle part of the building/tile
    lea de, iy-15
    ld c, 32
    ldir
    dec a
    jr nz, -_
    add iy, sp
    lea de, iy-14
    ld c, 30
    ldir
    add iy, sp
    lea de, iy-12
    ld c, 26
    ldir
    add iy, sp
    lea de, iy-10
    ld c, 22
    ldir
    add iy, sp
    lea de, iy-8
    ld c, 18
    ldir
    add iy, sp
    lea de, iy-6
    ld c, 14
    ldir
    add iy, sp
    lea de, iy-4
    ld c, 10
    ldir
    add iy, sp
    lea de, iy-2
    ld c, 6
    ldir
    add iy, sp
    lea de, iy-0
    ldi
    ldi
    ld de, 32-(320*16)
    jr +_
SkipDrawingOfTile:
    ld de, 32
_:  add iy, de
    exx
    inc de
    dec ix
    ld a, b
    ld bc, (-MAP_SIZE+1)*2
    add hl, bc
    dec a
    jp nz, DisplayTile
    ld bc, (MAP_SIZE*10-9)*2
    add hl, bc
    ex de, hl
    ld bc, -9
    add hl, bc
    ex de, hl
    lea ix, ix+9+1
    ex af, af'
    bit 0, a
IncrementRowXOrNot1:
    jr nz, +_
    inc de
    ld bc, (-MAP_SIZE+1)*2
    add hl, bc
    dec ix
_:  dec a
    jp nz, DisplayEachRowLoop
    ld de, (currDrawingBuffer)
    ld hl, _resources \.r2
    ld bc, _resources_width * _resources_height
    ldir
    ld hl, blackBuffer
    ld bc, 320*40+32
    ld a, 160
_:  ldir
    ex de, hl
    inc b
    add hl, bc
    ex de, hl
    ld c, 32+32
    dec b
    dec a
    jr nz, -_
    ld bc, 320*25+32
    ldir
TempSP2 = $+1
    ld sp, 0
DrawFieldEnd:

PuppetsEvents:
    ld a, (AmountOfPeople)
    or a, a
    ex af, af'
    ld ix, puppetStack
    ld iy, TempData
    ld hl, (_IYOffsets + TopLeftXTile)
    ld de, (_IYOffsets + TopLeftYTile)
    or a, a
    sbc hl, de
    ld (iy+0), hl
    add hl, de
    add hl, de
    ld (iy+3), hl
PuppetEventLoop:
    ex af, af'
    jr z, DisplaySelectedAreaBorder
    ex af, af'
    
; Check if we need to draw the puppet:
; X_tile - Y_tile in [X_1-Y_1,X_1-Y_1+9]
; X_tile - Y_tile - (X-1 - Y_1) in [0,9]
; X_tile - Y_tile - (iy+0) in [0,9]

; X_tile + Y_tile in [X_1+Y_1,X_1+Y_1+23]
; X_tile + Y_tile - (X_1+Y_1) in [0,23]
; X_tile + Y_tile - (iy+3) in [0,23]

; Check if X is in the range
    ld a, (ix+puppetX)
    sub a, (ix+puppetY)
    sbc hl, hl
    ld l, a
    ld de, (iy+0)
    or a, a
    sbc hl, de
    ld (iy+6), l
    ld de, -10
    add hl, de
    jr c, DontDrawPuppet
; Check if Y is in the range
    sbc hl, hl
    ld a, (ix+puppetX)
    add a, (ix+puppetY)
    ld l, a
    jr nc, +_
    inc h
_:  ld de, (iy+3)
    or a, a
    sbc hl, de
    ld (iy+7), l
    ld de, -24
    add hl, de
    jr c, DontDrawPuppet
DrawPuppet:
    ld a, (iy+6)
    add a, (iy+7)
    add a, a
    add a, a
    add a, a
    add a, 31
    ld hl, variables+OFFSET_Y
    add a, (hl)
    ld l, a
    ld h, 160
    mlt hl
    add hl, hl
    ld e, (iy+6)
    ld d, 16
    mlt de
    add hl, de
    ld a, (variables+OFFSET_X)
    ld d, 0
    ld e, a
    add hl, de
    ld de, (currDrawingBuffer)
    add hl, de
    

DontDrawPuppet:
    ; Event
    
    ex af, af'
    dec a
    lea ix, ix+9
    ex af, af'
    jr PuppetEventLoop
PuppetsEventsEnd:

DisplaySelectedAreaBorder:
    ld iy, _IYOffsets
    bit holdDownEnterKey, (iy+AoCEFlags1)
    ret z                                                               ; We didn't select an area
    ld a, (iy+SelectedAreaUpperBound)
    sub a, (iy+SelectedAreaLowerBound)
    ret z                                                               ; The area is 0 pixels height, so just a point (or line)
    ret
DisplaySelectedAreaBorderEnd:

#IF $ - DrawField > 1024
.error "cursorImage data too large: ",$-DrawField," bytes!"
#ENDIF
    
endrelocate()

drawtiles_loc = $
relocate(mpShaData)

DrawTiles:
    ld bc, 2
    ldir
    add iy, sp
    lea de, iy-2
    ld c, 6
    ldir
    add iy, sp
    lea de, iy-4
    ld c, 10
    ldir
    add iy, sp
    lea de, iy-6
    ld c, 14
    ldir
    add iy, sp
    lea de, iy-8
    ld c, 18
    ldir
    add iy, sp
    lea de, iy-10
    ld c, 22
    ldir
    add iy, sp
    lea de, iy-12
    ld c, 26
    ldir
    jp ActuallyDisplayTile
DrawTilesEnd:

#IF $ - DrawTiles > 64
.error "mpShaData data too large: ",$-DrawTiles," bytes!"
#ENDIF

endrelocate()