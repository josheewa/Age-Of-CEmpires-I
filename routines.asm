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
