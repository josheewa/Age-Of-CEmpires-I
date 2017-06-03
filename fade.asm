;------------------------------------------------
; fadeIn - fade the screen in
;   input:  none
;   output: none
;------------------------------------------------
fadeIn:
        ld      hl,fadeInSub
        jr      fadeLcd
fadeInSub:
        dec     c
        ret

;------------------------------------------------
; fadeOut - fade the screen out by slowing erasing the palette
;   input:  none
;   output: none
;------------------------------------------------
fadeOut:
        ld      hl,fadeOutSub
        jr      fadeLcd
fadeOutSub:
        ld      a,c
        sub     32
        neg
        ld      c,a
        ret

;------------------------------------------------
; fadeLcd - fade the screen out or in
;   input:  HL => routine to calculate RGB modifier
;   output: none
;------------------------------------------------
fadeLcd:
        ld      (__flSubCalc),hl
        ld      c,32
flOuter:
        ld      b,0                           ; B = number of colours in palette
        ld      iy,mpLcdPalette
        ld      ix,pal_sprites                  ; IX => palette being used
flInner:
        push    bc
__flSubCalc             = $+1
        call    $000000
        ld      hl,0
        ; red
        ld      a,(ix+1)
        rrca \ rrca
        and     %00011111
        sub     c
        jr      nc,flSkipR
        xor     a
flSkipR:
        rlca \ rlca
        ld      l,a
        ; green
        ld      e,(ix+1)
        ld      d,(ix)
        sla d \ rl e
        sla d \ rl e
        sla d \ rl e
        ld      a,e
        and     %00011111
        sub     c
        jr      nc,flSkipG
        xor     a
flSkipG:
        ld      d,0
        ld      e,a
        srl e \ rr d
        srl e \ rr d
        srl e \ rr d
        ld      a,l
        or      e
        ld      l,a
        ld      a,h
        or      d
        ld      h,a
        ; blue
        ld      a,(ix)
        and     %00011111
        sub     c
        jr      nc,flSkipB
        xor     a
flSkipB:
        or      h
        ld      h,a
        ld      (iy),h
        ld      (iy+1),l
        inc ix \ inc ix
        inc iy \ inc iy
        pop     bc
        djnz    flInner
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
        dec     c
        jr      nz,flOuter
        ret