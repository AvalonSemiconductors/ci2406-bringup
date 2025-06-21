mmio_base equ 0xFFFFFF80

TMR0 equ 0x00
TMR1 equ 0x04
TTOP0 equ 0x08
TTOP1 equ 0x0C
PRE0 equ 0x10
PRE1 equ 0x14
UDIV equ 0x18
SDIV equ 0x1C
UDAT equ 0x20
SDAT equ 0x24
STAT equ 0x28
DDRA equ 0x2C
PORTA equ 0x30
PINA equ 0x34
ICEN equ 0x34
ALT equ 0x38
CHC equ 0x40
PWM equ 0x50

; GPIO Port Assignments:
; 0 - SCL
; 1 - SDA
; 2 - Button
; 3 - LEDb & Test Point
; 4 - SPI Breakout CSb
; 5 - SD Card CSb
; 6 - LED
; 7 - LED

SPI_CSB equ 16
SDCARD_CSB equ 32
UART_CLKDIV equ 129 ; 115200 at 15MHz
;UART_CLKDIV equ 4

INITIAL_SPI_DIV equ 300
;INITIAL_SPI_DIV equ 6
FAST_SPI_DIV equ 4

; r62 permanently holds MMIO address
; r61 is the stack pointer
; r60 is the default link register
; r59 is the workaround zero-reg
; r1 - r15 are local/non-saved vars
; r16 - r23 are function params
; r24 - r58 are saved vars

mem_start equ 0
mem_size equ 0x40000
mem_last_addr equ (mem_start+mem_size-4)

	org 0
reset:
	lui r61, mem_last_addr>>16
	lliu r61, mem_last_addr&0xFFFF
	bez r0, start
	---
external_int:
	nop
	nop
	jalr zero, r63, 0
	---
t0_irupt:
	nop
	nop
	jalr zero, r63, 0
	---
sw_trap:
	nop
	nop
	jalr zero, r63, 0
	---
uart_irupt:
	nop
	nop
	jalr zero, r63, 0
	---
start:
	xor r59, r59, r59
	---
	lui r62, mmio_base>>16
	lli r3, 0b11111000
	lliu r62, mmio_base&0xFFFF
	---
	lui r4, 0
	lliu r4, UART_CLKDIV #
	sw r4, UDIV(r62)
	---
	nop
	lli r4, INITIAL_SPI_DIV # ; Low SDIV at first for SD card init
	sw r4, SDIV(r62)
	---
	sw r3, DDRA(r62) ; Outputs on LEDs
	nop
	sw zero, CHC(r62)
	---
	lui r16, string_1>>16
	lliu r16, string_1&0xFFFF
	nop
	---
	lipc r60, zero #
	jalr r60, r60, (putstr-$)>>4
	---
	lipc r60, zero #
	jalr r60, r60, (sdcard_init-$)>>4
	---
	
	xor r17, r17, r17
	lui r16, byte_buff>>16
	lliu r16, byte_buff&0xFFFF
	---
	lipc r60, zero #
	jalr r60, r60, (sdcard_read_block-$)>>4
	---
	lui r18, byte_buff>>16
	lliu r18, byte_buff&0xFFFF
	---
	lui r17, 0
	lli r17, 511
	---
print_loop:
	lb r16, 0(r18)
	addi r18, r18, 1
	---
	lipc r60, zero #
	jalr r60, r60, (puthex8-$)>>4
	---
	lli r16, ' '
	lipc r60, zero #
	jalr r60, r60, (putchar_cachef-$)>>4
	---
	andi r1, r17, 15 #
	bnez r1, print_loop_cond
	---
	lipc r60, zero #
	jalr r60, r60, (newl-$)>>4
	---
print_loop_cond:
	subi r17, r17, 1
	bnez r17, print_loop
	---
	lipc r60, zero #
	jalr r60, r60, (newl-$)>>4
	---
	
	lipc r60, zero #
	jalr r60, r60, (parse_mbr-$)>>4
	---
	bez r2, partition_not_found
	---
	lliu r16, text_partition_found&0xFFFF
	lui r16, text_partition_found>>16
	---
	lipc r60, zero #
	jalr r60, r60, (putstr-$)>>4
	---
	lliu r10, ext4_partition_start&0xFFFF
	lui r10, ext4_partition_start>>16 #
	lw r16, 0(r10)
	---
	lipc r60, zero #
	jalr r60, r60, (puthex32_cachef-$)>>4
	---
	lliu r16, text_partition_found2&0xFFFF
	lui r16, text_partition_found2>>16
	---
	lipc r60, zero #
	jalr r60, r60, (putstr-$)>>4
	---
	lliu r10, ext4_partition_size&0xFFFF
	lui r10, ext4_partition_size>>16 #
	lw r16, 0(r10)
	---
	lipc r60, zero #
	jalr r60, r60, (puthex32_cachef-$)>>4
	---
	lipc r60, zero #
	jalr r60, r60, (newl_cachef-$)>>4
	---
blink:
	lui r24, test_var>>16
	lliu r24, test_var&0xFFFF #
	sw zero, 0(r24)
	---
	nop
	lli r3, 1 #
	sw r3, ICEN(r62) # ; Enable icache
	---
	lli r51, (puthex32_cachef-$-16)>>4
	lli r52, (newl_cachef-$-16)>>4
	nop
	---
	lipc r51, r51
	lipc r52, r52
	nop
	---
loop:
	; Two output pins must always be high (chip-selects)
	xor.u r20, r20, r20
	lli r20, SPI_CSB+SDCARD_CSB
	lw r3, 0(r24) ; Restore counter value from RAM
	---
	or r20, r3, r20 ; Or chip-selects
	addi r3, r3, 1 ; Increment counter
	nop
	---
	sw r20, PORTA(r62) ; Counter to GPIO outputs
	lliu r58, 0xFFFF ; Set delay length
	lui r58, 0x0003
	;lliu r58, 0x10
	;lui r58, 0
	---
	sw r3, 0(r24) ; Store counter in RAM
	xor r3, r3, r3 ; Erase counter value out of r3
	cpy r16, r3
	---
	jalr r60, r51, 0
	---
	jalr r60, r52, 0
	---
	; Delay loop
wait_loop:
	subi r58, r58, 1
	bne r58, r0, wait_loop
	bez r0, loop
	---
	
partition_not_found:
	lliu r16, text_partition_not_found&0xFFFF
	lui r16, text_partition_not_found>>16
	---
	lipc r60, zero #
	jalr r60, r60, (putstr-$)>>4
	---
halt_loop:
	nop
	nop
	nop
	---
	nop
	nop
	nop
	---
	nop
	nop
	bez zero, halt_loop
	---
	
	include "serial.asm"
	include "sdcard.asm"
	include "mbr.asm"
	include "ext4.asm"
	align 4
test_var:
	dd 0
string_1:
	db "Tholin's VLIW CPU\r\n",0
hex_chars:
	db "0123456789ABCDEF"
text_partition_not_found:
	db 0x1B,"[1;31m","ext4 partition not found, can’t continue",0x1B,"[0m",13,10,0
text_partition_found:
	db "ext4 partition found at ",0
text_partition_found2:
	db " with size ",0
	align 4
byte_buff:
	db 0
