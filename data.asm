MissingAppVar:
	.db "Need"
LibLoadAppVar:
	.db " LibLoad", 0
	.db "tiny.cc/clibs", 0
GetHelp1:
	.db "Check http://tiny.cc/aoce", 0
GetHelp2:
	.db "for help, controls, AI's", 0
GetHelp3:
	.db "and much more!", 0
MadeByMessage:
	.db "Made by Peter \"PT_\" Tillema", 0
NoMultiplayer1:
	.db "Multiplayer is not", 0
NoMultiplayer2:
	.db "supported yet!", 0
GeneratingMapMessage:
	.db "Generating map...", 0
LoadingMapMessage:
	.db "Loading map...", 0
GraphicsAppvar:
	.db AppVarObj, "AOCEGFX0"
AoCEMapAppvar:
	.db AppVarObj, "AOCEMAP", 0
GraphicsAppvarNotFound:
	.db "Can't find appvar:", 0
LoadingMessage:
	.db "Loading...", 0
	
RelocationTables:
	.dl RelocationTable2, RelocationTable1
	
AmountOfWood:
	.dl 0
AmountOfFood:
	.dl 0
AmountOfGold:
	.dl 0
AmountOfStone:
	.dl 0
AmountOfPeople:
	.db 2
AmountOfMaxPeople:
	.db 10
AmountOfBuildings:
	.db 0
	
BuildingsPointer:
	.dl _barracks \.r2
	.dl _farm \.r2
	.dl _house \.r2
	.dl _lumbercamp \.r2
	.dl _mill \.r2
	.dl _miningcamp \.r2
	.dl _towncenter \.r2
BuildingsHeights:
	.db 32
	.db 0
	.db 19
	.db 16
	.db 19
	.db 10
	.db 36
#IF BuildingsHeights & 255 > 249
	.error "Please be sure that the lower byte of the pointer to BuildingsHeights is less than 250"
#ENDIF
	
TilesWithResourcesPointers:
	.dl _grass \.r2
	.dl _food \.r2
	.dl _gold \.r2
	.dl _stone \.r2
	.dl _grass_tree \.r2
	
AoCEFlags:
	.db 0
	
TopLeftXTile:
	.dl -10
TopLeftYTile:
	.dl -3
	
ResourcesType1:
	.db 0, 1, 0
	.db 0, 1, 1
	.db 1, 1, 1
ResourcesType2:
	.db 1, 0, 0
	.db 0, 1, 0
	.db 0, 1, 1
ResourcesType3:
	.db 0, 0, 0
	.db 1, 1, 0
	.db 0, 0, 0
ResourcesType4:
	.db 1, 1, 1
	.db 0, 1, 0
	.db 0, 0, 0
ResourcesType5:
	.db 0, 0, 0
	.db 0, 0, 1
	.db 1, 1, 1
ResourcesType6:
	.db 0, 0, 0
	.db 0, 1, 0
	.db 0, 0, 0
ResourcesType7:
	.db 0, 0, 0
	.db 0, 0, 1
	.db 0, 1, 1