DrawMainMenu:
	ld hl, vRAM
	ld (hl), 094h
	ld de, vRAM+1
	ld bc, 320*240-1
	ldir
	dispCompressedImage(_intro_compressed, 72, 32)
	call fadeIn
	ld a, 200
	call _DelayTenTimesAms
	call fadeOut
	ld de, vRAM
	ld hl, blackBuffer
	ld bc, 320*240*2
	ldir
	dispCompressedImage(_AoCEI_compressed, 5, 5)
	dispCompressedImage(_soldier_compressed, 215, 5)
	printString(MadeByMessage, 18, 94)
	call fadeIn
SelectLoopDrawPlayHelpQuit:
	call EraseArea
	dispCompressedImage(_playhelpquit_compressed, 50, 110)
	ld hl, SelectMenuMax
	ld (hl), 2
	call SelectMenu
_:	jp c, ForceStopProgramWithFadeOut
	dec c
	jr z, DisplayHelp
	dec c
	jr z, -_
	jr SelectedPlay
	
DisplayHelp:
	call EraseArea
	printString(GetHelp1, 5, 112)
	printString(GetHelp2, 5, 122)
	printString(GetHelp3, 5, 132)
	call _GetKey
	jp SelectLoopDrawPlayHelpQuit
SelectedPlay:
	call EraseArea
	dispCompressedImage(_singlemultiplayer_compressed, 50, 110)
	ld hl, SelectMenuMax
	ld (hl), 1
	call SelectMenu
	jp c, SelectLoopDrawPlayHelpQuit
	dec c
	jr nz, SelectedSinglePlayer
	call EraseArea
	printString(NoMultiplayer1, 5, 112)
	printString(NoMultiplayer2, 5, 122)
	call _GetKey
	jr SelectedPlay
SelectedSinglePlayer:
	ld hl, AoCEMapAppvar
	call _Mov9ToOP1
	call _ChkFindSym
	jr c, +_
	call EraseArea
	dispCompressedImage(_newloadgame_compressed, 50, 110)
	call SelectMenu
	jp c, SelectedPlay
	dec c
	jr z, ++_
_:	jp GenerateMap
_:	jp LoadMap





	
	

EraseArea:
	ld hl, 130
	push hl
		ld l, 210
		push hl
			ld l, 110
			push hl
				ld l, 0
				push hl
					call gfx_FillRectangle_NoClip						; gfx_FillRectangle_NoClip(0, 110, 210, 130);
				pop hl
			pop hl
		pop hl
	pop hl
	ret
	
SelectMenu:
	ld c, 0
SelectLoop:
	push bc
		ld b, 40
		mlt bc
		ld hl, 110
		add hl, bc
		push hl
			ld hl, 10
			push hl
				ld hl, _pointer \.r1
				push hl
					call gfx_Sprite_NoClip								; gfx_Sprite_NoClip(_pointer, 10, 110+40*C);
				pop hl
			pop hl
		pop hl
	pop bc
	ld b, c
KeyLoop:
	call _GetCSC
	ld d, a
	cp a, skDown
	jr nz, +_
	ld a, c
SelectMenuMax = $+1
	cp a, 2
	jr z, +_
	inc c
	jr EraseCursor
_:	ld a, d
	cp a, skUp
	jr nz, +_
	ld a, c
	or a, a
	jr z, +_
	dec c
	jr EraseCursor
_:	ld a, d
	cp a, skEnter
	ret z	
_:	cp a, skClear
	jr nz, KeyLoop
	scf
	ret
	
EraseCursor:
	push bc
		ld l, 36
		push hl
			ld hl, 25
			push hl
				ld c, 40
				mlt bc
				ld hl, 110
				add hl, bc
				push hl
					ld hl, 10
					push hl
						call gfx_FillRectangle_NoClip					; gfx_FillRectangle_NoClip(10, 110+40*B, 25, 36);
					pop hl
				pop hl
			pop hl
		pop hl
	pop bc
	jr SelectLoop