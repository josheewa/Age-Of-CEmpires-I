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