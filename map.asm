GenerateMap:
    call EraseArea
    printString(GeneratingMapMessage, 5, 112)
    ld hl, (mpTmr1Counter)
    ld (seed_1), hl
    ld hl, (mpTmr2Counter)
    ld (seed_2), hl
    ld b, 0
PlaceTreesLoop:
    ld ixh, b
    call prng24
    ld bc, MAP_SIZE
    call __idvrmu
    push hl
        call prng24
        ld bc, MAP_SIZE
        call __idvrmu
        ld h, 160
        mlt hl
        add hl, hl
    pop de
    add hl, de
    ld (hl), TILE_TREE
    ld b, ixh
    djnz PlaceTreesLoop
    ld b, 3                                                                ; Food, stone, gold
PlaceAllResourceTypesLoop:
    ld ixh, b
    ld b, 15                                                            ; Place 15 resources of each
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
        ld de, 320-2
        ld a, (hl)                                                        ; Check if one of the 9 blocks is already a tree/part of resource
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
    pop de
    jr nz, DontDrawResource
    lea hl, iy
    mlt bc
    ld b, 3
PlaceResource:
    ld c, b
    ld b, 3
PlaceResourceRowLoop:
    ld a, (de)
    or a, a
    jr z, +_
ResourceType = $+1
    ld (hl), TILE_FOOD
_:  inc hl
    inc de
    djnz PlaceResourceRowLoop
    ld a, c
    inc b
    ld c, 320-256-3
    add hl, bc
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
    printString(LoadingMapMessage, 5, 112)
    call _ChkFindSym
    call _ChkInRAM
    call c, _Arc_Unarc
    ld hl, mapAddress
    ex de, hl
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