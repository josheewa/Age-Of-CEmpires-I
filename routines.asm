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
    
fadeIn:
    ld hl, fadeInSub
    jr fadeLcd
fadeInSub:
    dec c
    ret

fadeOut:
    ld hl, fadeOutSub
    jr fadeLcd
fadeOutSub:
    ld a, c
    sub a, 32
    neg
    ld c,a
    ret

fadeLcd:
    ld (__flSubCalc), hl
    ld c, 32
flOuter:
    ld b, 0                           ; B = number of colours in palette
    ld iy, mpLcdPalette
    ld ix, pal_sprites                  ; IX => palette being used
flInner:
    push bc
__flSubCalc = $+1
        call 0000000h
        ld hl, 0
        ; red
        ld a,(ix+1)
        rrca
        rrca
        and a, %00011111
        sub a, c
        jr nc,flSkipR
        xor a, a
flSkipR:
        rlca
        rlca
        ld l,a
        ; green
        ld e,(ix+1)
        ld d,(ix)
        sla d
        rl e
        sla d
        rl e
        sla d
        rl e
        ld a, e
        and a, %00011111
        sub a, c
        jr nc,flSkipG
        xor a, a
flSkipG:
        ld d,0
        ld e,a
        srl e
        rr d
        srl e
        rr d
        srl e
        rr d
        ld a, l
        or a, e
        ld l, a
        ld a, h
        or a, d
        ld h, a
        ; blue
        ld a,(ix)
        and a, %00011111
        sub a, c
        jr nc,flSkipB
        xor a, a
flSkipB:
        or a, h
        ld h, a
        ld (iy), h
        ld (iy+1), l
        inc ix
        inc ix
        inc iy
        inc iy
    pop bc
    djnz flInner
    ld b, 4
Wait0Loop:
    ld d, b
    ld b, 0
Wait1Loop:
    ld e, b
    ld b, 0
Wait2Loop:
    djnz Wait2Loop
    ld b, e
    djnz Wait1Loop
    ld b, d
    djnz Wait0Loop
    dec c
    jr nz,flOuter
    ret