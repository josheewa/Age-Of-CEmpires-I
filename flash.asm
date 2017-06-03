.assume ADL=0
fUnlockFlash:
    ld a, 08Ch
    out0 (024h), a
    ld c, 4
    in0 a, (6)
    or c
    out0 (6), a
    out0 (028h), c
    ret.l
fLockFlash:
    xor    a, a
    out0 (028h), a
    in0 a, (6)
    res 2, a
    out0 (6), a
    ld a, 088h
    out0(024h), a
    ret.l
.assume ADL=1
    
fCopyRAMToFlash:
    ld a, 03Ch
    call fMemorySafeErase
    ld a, 03Dh
    call fMemorySafeErase
    ld a, 03Eh
    call fMemorySafeErase
    ld a, 03Fh
    call fMemorySafeErase
    ld hl, 0D00001h
    ld (hl), 0A5h
    dec hl
    ld (hl), 05Ah
    ld de, 03C0000h
    ld bc, 040000h
    jp _WriteFlash
    
fRestoreFlashToRAM:
; restore RAM state
    ld hl, $3C0000
    ld de, ramStart + 0000000h
    ld bc, $01887C
    ldir
    ld hl, $3E0000
    ld de, ramStart+020000h
    ld bc, $020000
    ldir
    ret
fMemorySafeErase:
    ld bc,$0000F8
    push bc
        jp _EraseFlashSector