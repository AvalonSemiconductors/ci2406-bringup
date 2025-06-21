EXT4_OKAY equ 0
EXT4_LAST_EXTENT equ 1
EXT4_TOO_DEEP equ 2
EXT4_IO_ERR equ 3
EXT4_BLOCKS_TOO_BIG equ 4
EXT4_INVALID_MAGIC equ 5
EXT4_INCOMPAT equ 6
EXT4_INVALID_PARAMS equ 7
EXT4_CHECKSUM_BAD equ 8
EXT4_FILE_GAP equ 9
EXT4_EOF equ 10
EXT4_BAD_DIR_START equ 11
EXT4_BAD_ROOT_DIR equ 12
EXT4_BAD_DIR_TREE equ 13
EXT4_FILE_NOT_FOUND equ 15
EXT4_FN_TOO_LONG equ 16
EXT4_OUT_OF_BOUNDS equ 17
	
	align 16
	; Reads one 4K block from SD card
	; Destination for the read is implicitely ext4_blockbuff
	; Args: block address
	; Returns error code (r23)
	; Uses: r1
ext4_read_block:
	sw r60, 0(r61) #
	sw r24, -4(r61) #
	sw r25, -8(r61)
	---
	sw r26, -12(r61)
	subi r61, r61, 16
	---
	xor r23, r23, r23
	lliu r2, ext4_lastblock&0xFFFF
	lui r2, ext4_lastblock>>16
	---
	lw r1, 0(r2) #
	be r16, r1, ext4_read_block_return
	slli r16, r16, 3
	---
	lliu r1, ext4_partition_start&0xFFFF
	lui r1, ext4_partition_start>>16 #
	lw r1, 0(r1)
	---
	add r16, r1, r16
	lliu r1, ext4_s_first_data_block&0xFFFF
	lui r1, ext4_s_first_data_block>>16 #
	---
	lw r1, 0(r1)
	lliu r26, ext4_blockbuff&0xFFFF
	lui r26, ext4_blockbuff>>16
	---
	slli r1, r1, 3 #
	add r16, r1, r16
	lliu r1, ext4_partition_end&0xFFFF
	---
	lui r1, ext4_partition_end>>16 #
	lliu r23, EXT4_OUT_OF_BOUNDS
	lw r1, 0(r1)
	---
	bge r16, r1, ext4_read_block_return
	cpy r24, r16
	liu r25, 7
	---
	lli r1, -1 #
	sw r1, 0(r2)
	lliu r23, EXT4_IO_ERR
	---
ext4_read_block_loop:
	cpy r17, r24
	addi r24, r24, 1
	cpy r16, r26
	---
	lipc r60, zero #
	jalr r60, r60, (sdcard_read_block-$)>>4
	addi r26, r26, 512
	---
	bnez r2, ext4_read_block_return
	subi r25, r25, 1
	bnez r25, ext4_read_block_loop
	---
	lliu r23, EXT4_OKAY
	---
ext4_read_block_return:
	lw r26, 4(r61) #
	lw r25, 8(r61) #
	lw r24, 12(r61)
	---
	lw r60, 16(r61)
	addi r61, r61, 16
	jalr zero, r60, 0
	---

	align 4
ext4_lastblock:
	dd 0xFFFFFFFF
ext4_partition_start:
	dd 0
ext4_partition_end:
	dd 0
ext4_partition_size:
	dd 0
ext4_s_first_data_block:
	dd 0 ; TODO: ensure reset to zero before mount
ext4_blockbuff:
	dd 0 ; TODO: can remove this?
	org $+4096
	dd 0
	dd 0x69696969
