MAP_SIZE				.equ 200
OFFSET_X				.equ 0
OFFSET_Y				.equ 3

building_barracks		.equ 0
building_farm			.equ 1
building_house			.equ 2
building_lumbercamp		.equ 3
building_mill			.equ 4
building_miningcamp		.equ 5
building_towncenter		.equ 6
buildings_stack			.equ plotSScreen+50000

currDrawingBuffer		.equ 0E30014h
screenBuffer			.equ vRAM+(320*240)