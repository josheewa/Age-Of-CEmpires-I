FindPath:
    di
    ld iy, PathFindingData
    ld (iy+PFStartX), 2
    ld (iy+PFStartY), 4    ld (iy+PFEndX), 6    ld (iy+PFEndY), 5    ld (iy+PFAmountOfOpenTiles), 1    ld (iy+PFAmountOfClosedTiles), 0    ld hl, PFOpenedList
    ld (hl), 2
    inc hl
    ld (hl), 4
    inc hl
    ld (hl), 0
    inc hl
    ld (hl), 5-4+6-2
    jr FindPath2
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
;  Lists stack entry:
;   1b - X
;   1b - Y
;   1b - Depth
;   1b - Total score

    ld ix, PFOpenedList-4                                                       ; Get the minimum score
    xor a, a
    ld b, a                                                                     ; B = index of tile in open list
    ld (iy+PFIndexOfCurInOpenList), a
    ld d, a                                                                     ; D = current minimum score
    ld a, (iy+PFAmountOfOpenTiles)
    or a, a
    ret z                                                                       ; There exists no path
    ld e, a                                                                     ; E = amount of open tiles
GetMinimumTile:
    lea ix, ix+4
    ld c, (ix+3)                                                                ; C = score of tile in open list
    ld a, d
    cp a, c
    jr c, +_
    ld d, c                                                                     ; The score is lower than the current score, so change the active tile and score
    ld (iy+PFIndexOfCurInOpenList), b
_:  inc b
    ld a, b
    cp a, e                                                                     ; Check if the index is equal to the amount of tiles in the open list
    jr nz, GetMinimumTile
    ld e, (iy+PFIndexOfCurInOpenList)                                           ; Get the tile with the lowest score
    ld d, 4
    mlt de
    ld ix, PFOpenedList
    add ix, de
    ld e, (iy+PFAmountOfClosedTiles)                                            ; Copy current tile to closed tiles
    ld d, 4
    mlt de
    ld hl, PFClosedList
    add hl, de
    ld bc, (ix)
    ld (hl), bc
    ld a, (ix+3)
    inc hl
    inc hl
    inc hl
    ld (hl), a
    inc (iy+PFAmountOfClosedTiles)
    ld (iy+PFCurX), bc                                                          ; Copy the X, Y and depth of the current tile
    ld a, (iy+PFIndexOfCurInOpenList)
    ld b, (iy+PFAmountOfOpenTiles)
    dec b
    ld (iy+PFAmountOfOpenTiles), b
    sub a, b
    jr z, CheckLeftNeighbour                                                    ; The selected tile was the last in the list, so don't move the others
    lea de, ix                                                                  ; Move selected tile to closed list
    lea hl, ix+4
    ld c, a
    ld b, 4
    ldir
CheckLeftNeighbour:
    ld d, (iy+PFCurX)
    ld e, (iy+PFCurY)
    ld a, d
    or a, a
    jr z, CheckUpperNeighbour
    dec d
    call FindTileInBothLists
    call nz, AddTileIfWalkable
    inc b
CheckUpperNeighbour:
    ld a, (iy+PFCurY)
    or a, a
    jr z, CheckRightNeighbour
    dec e
    call FindTileInBothLists
    call nz, AddTileIfWalkable
    inc e
CheckRightNeighbour:
    ld a, (iy+PFCurX)
    cp a, 8
    jr z, CheckLowerNeightbour
    inc d
    call FindTileInBothLists
    call nz, AddTileIfWalkable
    dec d
CheckLowerNeightbour:
    ld a, (iy+PFCurY)
    cp a, 7
    jr z, +_
    inc e
    call FindTileInBothLists
    call nz, AddTileIfWalkable
_:  jp FindPath2
FoundPath:
    ret
    
FindTileInBothLists:
    ld a, (iy+PFEndX)
    cp a, d
    jr nz, +_
    ld a, (iy+PFEndY)
    cp a, e
    jr nz, +_
    pop hl
    jr FoundPath
_:  ld hl, PFOpenedList
    ld b, (iy+PFAmountOfOpenTiles)
    call FindTileInList
    ret z
    ld hl, PFClosedList
    ld b, (iy+PFAmountOfClosedTiles)
FindTileInList:
; Input:
;   B = Amount of elements
;   D = X coordinate
;   E = Y coordinate
;  HL = Pointer to list
; Output:
;   Z = Found the tile
;  NZ = Didn't find the tile
    ld a, b
    or a, a
    jr nz, FindTileInListLoop
    inc a
    ret
FindTileInListLoop:
    ld a, (hl)
    inc hl
    ld c, (hl)
    inc hl
    inc hl
    inc hl
    cp a, d
    jr nz, +_
    ld a, c
    cp a, e
    ret z
_:  djnz FindTileInListLoop
    ret
    
AddTileIfWalkable:
    ld l, e
    ld h, 9
    mlt hl
    ld c, d
    ld b, 1
    mlt bc
    add hl, bc
    ld bc, TempMapData
    add hl, bc
    ld a, (hl)
    or a, a
    ret z
    ld c, (iy+PFAmountOfOpenTiles)
    ld b, 4
    mlt bc
    ld hl, PFOpenedList
    add hl, bc
    ld (hl), d
    inc hl
    ld (hl), e
    inc hl
    ld a, (iy+PFCurTileDepth)
    inc a
    ld (hl), a
    inc hl
    ld c, a
    ld a, (iy+PFEndX)                                                           ; Find the distance to end, abs(X_end - X_curr) + abs(Y_end - Y_curr)
    sub a, d                                                                    ; abs(X_end - X_curr)
    jr nc, +_
    neg
_:  ld b, a
    ld a, (iy+PFEndY)                                                           ; abs(Y_end - Y_curr)
    sub a, e
    jr nc, +_
    neg
_:  add a, b                                                                    ; Add them, and add the distance
    add a, c
    ld (hl), a
    inc (iy+PFAmountOfOpenTiles)
    ret