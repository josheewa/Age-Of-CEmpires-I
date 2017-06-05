#include "ti84pce.inc"
#include "defines.asm"
#include "macros.inc"
#include "bin/AOCEGFX1.lab"
#include "bin/AOCEGFX2.lab"
#include "relocation.inc"

.db tExtTok, tAsm84CECmp
.org UserMem

start:
    jp AoCEStart
    .db 1
    .db 16,16
    .db 000h,000h,000h,000h,020h,061h,081h,0A1h,0A1h,0A0h,0A0h,040h,001h,000h,000h,000h
    .db 000h,000h,000h,020h,061h,0A2h,0C2h,0C1h,0C0h,0A0h,0C0h,061h,021h,021h,021h,000h
    .db 000h,000h,020h,061h,0A1h,0C1h,0A1h,0A0h,061h,0A1h,0C1h,062h,029h,029h,021h,021h
    .db 000h,000h,061h,0A1h,0A1h,0A0h,061h,081h,061h,061h,082h,08Ch,04Ah,04Ah,029h,021h
    .db 000h,020h,060h,0C1h,0A0h,060h,040h,069h,06Ah,06Ah,08Bh,094h,094h,04Ah,049h,021h
    .db 000h,020h,0A0h,0C2h,081h,040h,021h,06Bh,06Bh,094h,0D6h,0B5h,0B5h,06Bh,049h,021h
    .db 000h,020h,081h,0C1h,081h,040h,04Ah,04Bh,04Bh,094h,0DEh,0DEh,094h,06Bh,04Ah,021h
    .db 000h,020h,060h,0A1h,081h,020h,04Bh,04Ah,04Ah,06Bh,0B6h,0DEh,0B5h,06Bh,04Ah,021h
    .db 000h,020h,040h,060h,060h,041h,06Bh,02Ah,02Ah,04Bh,0B4h,0B5h,0B5h,0B5h,06Ch,029h
    .db 000h,020h,060h,0A0h,080h,041h,094h,06Bh,04Ah,029h,049h,06Ch,094h,06Bh,04Ah,06Bh
    .db 000h,0FFh,0FFh,0FFh,0A0h,040h,04Ah,04Ah,04Bh,06Bh,029h,021h,001h,000h,029h,06Bh
    .db 020h,080h,0FFh,0C0h,0A0h,040h,021h,04Ah,04Ah,06Bh,06Bh,08Ch,06Bh,06Ch,08Ch,029h
    .db 040h,0A0h,0FFh,0A0h,080h,020h,000h,04Ah,04Ah,04Bh,04Ah,06Bh,06Bh,08Ch,06Bh,000h
    .db 061h,0A1h,0FFh,060h,040h,000h,000h,021h,04Ah,04Ah,06Bh,08Ch,08Ch,0B4h,06Bh,000h
    .db 081h,0FFh,0FFh,0FFh,020h,000h,000h,021h,04Ah,04Ah,04Bh,094h,0B5h,0D6h,06Bh,000h
    .db 081h,081h,040h,040h,000h,000h,000h,000h,021h,029h,04Ah,04Ah,04Ah,06Bh,029h,000h
    .db "Age of CEmpires I - By Peter \"PT_\" Tillema", 0
AoCEStart:
    ld hl, LibLoadAppVar
    call _Mov9ToOP1
    ld a, AppVarObj
    ld (OP1), a
_:  call _ChkFindSym
    jr c, NotFound
    call _ChkInRAM
    jr nz, InArc
    call _PushOP1
    call _Arc_UnArc
    call _PopOP1
    jr -_
InArc:
    ex de, hl
    ld de, 9
    add hl, de
    ld e, (hl)
    add hl, de
    inc hl
    inc hl
    inc hl
    ld de, RelocationStart
    jp (hl)
NotFound:
    call _ClrScrn
    call _HomeUp
    ld hl, MissingAppVar
    call _PutS
    call _NewLine
    jp _PutS
RelocationStart:
    .db 0C0h, "GRAPHX", 0, 4
gfx_Begin:
    jp 0
gfx_End:
    jp 3
gfx_SetDraw:
    jp 27
gfx_SwapDraw:
    jp 30
gfx_PrintChar:
    jp 42
gfx_PrintUInt:
    jp 48
gfx_PrintStringXY:
    jp 54
gfx_SetTextXY:
    jp 57
gfx_SetTextFGColor:
    jp 63
gfx_FillRectangle_NoClip:
    jp 126
gfx_TransparentSprite:
    jp 174
gfx_Sprite_NoClip:
    jp 177
gfx_SetTransparentColor:
    jp 225
    
Main:
    call _HomeUp
    call _ClrLCDFull
    call _RunIndicOff
    ld (backupSP), sp
    jp RunProgram
ForceStopProgramWithFadeOut:
    call fadeOut
ForceStopProgram:
    call gfx_End
backupSP = $+1
    ld sp, 0
    ld a, 0D1h
    ld mb, a
    call.lis fLockFlash & 0FFFFh
    ld a, 0D0h
    ld mb, a
    ld iy, flags
    call _DrawStatusBar
    ld a, kClear
    jp _JForceCmd
#include "flash.asm"
RunProgram:
    or a, a
    sbc hl, hl
    ex de, hl
    ld hl, mpTmrCtrl
    ld (hl), %00000010
    inc hl
    set 1, (hl)
    set 2, (hl)
    ld l, 0
    ld (hl), de
    inc l
    ld (hl), de
    ld l, 010h
    ld (hl), de
    inc hl
    ld (hl), de
    ld l, 030h
    set 0, (hl)
    set 3, (hl)
    ld b, 2
    ld ix, GraphicsAppvar
LoadSpritesAppvar:
    push bc
        inc (ix+8)
        lea hl, ix
        call _Mov9ToOP1
        call _ChkFindSym
        jr nc, +_
        ld hl, GraphicsAppvarNotFound
        call _PutS
        call _NewLine
        lea hl, ix+1
        call _PutS
        call _GetKey
        jp ForceStopProgram
_:      call _ChkInRAM
        call c, _Arc_Unarc
        inc de
        inc de
        ld (GraphicsAppvarStart), de
    pop bc
    ld d, b
    ld e, 3
    dec d
    mlt de
    ld hl, RelocationTables
    add hl, de
    ld hl, (hl)
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
    djnz LoadSpritesAppvar
    ld hl, AoCEMapAppvar
    call _Mov9ToOP1
    call _ChkFindSym
    call nc, _DelVarArc
    ld l, lcdBpp8
    push hl
        call gfx_Begin
        ld de, mpLcdPalette
        ld hl, blackBuffer
        ld bc, 256*2
        ;ldir
        ld l, 254
        ex (sp), hl
        call gfx_SetTextFGColor
        ld l, 255
        ex (sp), hl
        call gfx_SetTransparentColor
    pop hl
    ;call MainMenu
    call GenerateMap
    ld ix, saveSScreen+21000
    di
    ld.sis sp, 0987Eh
    ld a, 0D1h
    ld mb, a
    call.lis fUnlockFlash & 0FFFFh
    xor a, a
    ld (ix+OFFSET_X), a
    ld (ix+OFFSET_Y), a
    ld iy, AoCEFlags
    set need_to_redraw_tiles, (iy+0)
    ld hl, drawfield_loc
    ld de, DrawField
    ld bc, DrawFieldEnd - DrawField
    ldir
    ld de, DrawTiles
    ld bc, DrawTilesEnd - DrawTiles
    ldir
    
MainGameLoop:
    ld hl, 0D52C00h
    ld (mpLcdBase), hl
    call DrawField
    call GetKeyFast
    ld iy, TopLeftXTile
    ld l, 01Ch
    bit kpClear, (hl)
    jp z, ForceStopProgram
    ld l, 01Eh
CheckIfPressedUp:             ; All the controls are 'reversed', if you press [LEFT], it should scroll to the right
    bit kpUp, (hl)
    jr z, CheckIfPressedRight
    ld a, (ix+OFFSET_Y)
    inc a
    inc a
    inc a
    inc a
    and %00001111
    ld (ix+OFFSET_Y), a
    jr nz, CheckIfPressedRight
    shift_tile0_x_left()
    shift_tile0_y_up()
CheckIfPressedRight:
    bit kpRight, (hl)
    jr z, CheckIfPressedLeft
    ld a, (ix+OFFSET_X)
    or a, a
    jr nz, +_
    shift_tile0_x_right()
    shift_tile0_y_up()
_:  dec a
    dec a
    dec a
    dec a
    and %00011111
    ld (ix+OFFSET_X), a
CheckIfPressedLeft:
    bit kpLeft, (hl)
    jr z, CheckIfPressedDown
    ld a, (ix+OFFSET_X)
    inc a
    inc a
    inc a
    inc a
    and %00011111
    ld (ix+OFFSET_X), a
    jr nz, CheckIfPressedDown
    shift_tile0_x_left()
    shift_tile0_y_down()
CheckIfPressedDown:
    bit kpDown, (hl)
    jr z, CheckKeyPressesStop
    ld a, (ix+OFFSET_Y)
    or a, a
    jr nz, +_
    shift_tile0_x_right()
    shift_tile0_y_down()
_: dec a
    dec a
    dec a
    dec a
    and %00001111
    ld (ix+OFFSET_Y), a
CheckKeyPressesStop:
    ld iy, AoCEFlags
    res need_to_redraw_tiles, (iy+0)
    ld a, (hl)
    or a, a
    jr z, +_
    set need_to_redraw_tiles, (iy+0)
_:  jp MainGameLoop
    
#include "map.asm"
#include "data.asm"
#include "fade.asm"
#include "drawGame.asm"
#include "mainmenu.asm"
#include "routines.asm"
#include "drawField.asm"
#include "decompress.asm"

#include "relocation_table1.asm"
    .dw 0FFFFh
#include "relocation_table2.asm"
    .dw 0FFFFh

.echo "Size of main program:       ",$-start+2+9+4