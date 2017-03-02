DrawMainMenu:
	ld de, vRAM
	ld hl, 0E40000h
	ld bc, 320*240
	ldir
	ld hl, 5
	push hl
		push hl
			ld de, plotSScreen
			push de
				ld hl, _AoCEI_compressed \.r1
				call DecompressSprite
				call gfx_Sprite_NoClip									; gfx_Sprite_NoClip(_AoCEI_compressed, 5, 5);
			pop de
		pop hl
		ld hl, 215
		push hl
			push de
				ld hl, _soldier_compressed \.r1
				call DecompressSprite
				call gfx_Sprite_NoClip									; gfx_Sprite_NoClip(_soldier_compressed, 215, 5);
			pop de
		pop hl
	pop hl
SelectLoopDrawPlayHelpQuit:
	call EraseArea
	ld de, plotSScreen
	ld l, 110
	push hl
		ld hl, 50
		push hl
			push de
				ld hl, _playhelpquit_compressed \.r1
				call DecompressSprite
				call gfx_Sprite_NoClip									; gfx_Sprite_NoClip(_playhelpquit_compressed, 50, 110);
			pop hl
		pop hl
	pop hl
	ld hl, SelectMenuMax
	ld (hl), 2
	call SelectMenu
	jp c, ForceStopProgram
	dec c
	jr z, DisplayHelp
	dec c
	jp z, ForceStopProgram
	jp SelectedPlay
	
DisplayHelp:
	call EraseArea
	ld l, 112
	push hl
		ld hl, 5
		push hl
			ld hl, GetHelp1
			push hl
				call gfx_PrintStringXY									; gfx_PrintStringXY(GetHelp1, 5, 112);
			pop hl
		pop de
	pop hl
	ld l, 122
	push hl
		push de
			ld hl, GetHelp2
			push hl
				call gfx_PrintStringXY									; gfx_PrintStringXY(GetHelp2, 5, 122);
			pop hl
		pop de
	pop hl
	ld l, 132
	push hl
		push de
			ld hl, GetHelp3
			push hl
				call gfx_PrintStringXY									; gfx_PrintStringXY(GetHelp2, 5, 132);
			pop hl
		pop hl
	pop hl
	call GetAnyKeyFast
	jp SelectLoopDrawPlayHelpQuit
SelectedPlay:
	call EraseArea
	ld l, 110
	push hl
		ld hl, 50
		push hl
			ld de, saveSScreen
			push de
				ld hl, _singlemultiplayer_compressed \.r1
				call DecompressSprite
				call gfx_Sprite_NoClip									; gfx_Sprite_NoClip(_singlemultiplayer_compressed, 50, 110);
			pop hl
		pop hl
	pop hl
	ld hl, SelectMenuMax
	ld (hl), 1
	call SelectMenu
	jp c, SelectLoopDrawPlayHelpQuit
	dec c
	jr nz, SelectedSinglePlayer
	call EraseArea
	ld l, 112
	push hl
		ld hl, 5
		push hl
			ld hl, NoMultiplayer1
			push hl
				call gfx_PrintStringXY									; gfx_PrintStringXY(NoMultiplayer1, 5, 112);
			pop hl
		pop de
	pop hl
	ld l, 122
	push hl
		push de
			ld hl, NoMultiplayer2
			push hl
				call gfx_PrintStringXY									; gfx_PrintStringXY(NoMultiplayer2, 5, 122);
			pop hl
		pop de
	pop hl
	call GetAnyKeyFast
	jr SelectedPlay
SelectedSinglePlayer:
	ld hl, AoCEMapAppvar
	call _Mov9ToOP1
	call _ChkFindSym
	jr c, +_
	call EraseArea
	ld l, 110
	push hl
		ld hl, 50
		push hl
			ld de, saveSScreen
			push de
				ld hl, _newloadgame_compressed \.r1
				call DecompressSprite
				call gfx_Sprite_NoClip									; gfx_Sprite_NoClip(_newloadgame_compressed, 50, 110);
			pop hl
		pop hl
	pop hl
	ld hl, SelectMenuMax
	dec (hl)
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
	call GetKeyFast
	ld a, 10
	call _DelayTenTimesAms
	ld l, 01Eh
	bit kpDown, (hl)
	jr z, +_
	ld a, c
SelectMenuMax = $+1
	cp a, 2
	jr z, +_
	inc c
	jr EraseCursor
_:	bit kpUp, (hl)
	jr z, +_
	ld a, c
	or a, a
	jr z, +_
	dec c
	jr EraseCursor
_:	ld l, 01Ch
	bit kpEnter, (hl)
	ret nz
	bit kpClear, (hl)
	jr z, KeyLoop
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