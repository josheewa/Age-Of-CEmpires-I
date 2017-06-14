GetKeyFast:
    ld hl, 0F50200h
    ld (hl), h
    xor a, a
_:  cp a, (hl)
    jr nz, -_
    ret
    
GetKeyAnyFast:
    call GetKeyFast
    ld l, 012h
    ld a, (hl)
    inc l
    inc l
    or a, (hl)
    inc l
    inc l
    or a, (hl)
    inc l
    inc l
    or a, (hl)
    inc l
    inc l
    or a, (hl)
    inc l
    inc l
    or a, (hl)
    inc l
    inc l
    or a, (hl)
    jr z, GetKeyAnyFast
    ld a, 20
    jp _DelayTenTimesAms

LoadGraphicsAppvar:
    push de
        push hl
            call _Mov9ToOP1
            call _ChkFindSym
            jr nc, +_
            ld hl, GraphicsAppvarNotFound
            call _PutS
            call _NewLine
        pop hl
        inc hl
        call _PutS
        call _GetKey
        jp ForceStopProgram
_:      pop hl
        call _ChkInRAM
        call c, _Arc_Unarc
        inc de
        inc de
        ld (GraphicsAppvarStart), de
    pop hl
ChangeRelocationTableLoop:
    push hl
        ld hl, (hl)
        ld a, h
        and a, l
        inc a
        jr z, +_
        push hl
            ld hl, (hl)
GraphicsAppvarStart = $+1
            ld de, 0
            add hl, de
            ex de, hl
        pop hl
        ld (hl), de
    pop hl
    inc hl
    inc hl
    inc hl
    jr ChangeRelocationTableLoop
_:  pop hl
    ret