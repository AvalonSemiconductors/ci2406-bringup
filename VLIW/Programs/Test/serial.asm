	; Prints a string over UART
	; Args: byte*
	; Uses: none
putstr:
	sw r15, 0(r61)
	subi r61, r61, 4
	nop
	---
putstr_loop:
	lb r15, 0(r16) #
	bez r15, putstr_done #
	sw r15, UDAT(r62)
	---
	lw r15, STAT(r62) #
	andi r15, r15, 4 #
	bnez r15, $
	---
	addi r16, r16, 1
	nop
	bez r0, putstr_loop
	---
putstr_done:
	lw r15, 4(r61)
	addi r61, r61, 4
	jalr zero, r60, 0
	---

putchar_cachef:
	sw r1, 0(r61)
	---
	sw r16, UDAT(r62)
	---
putchar_cachef_wait_loop:
	lw r1, STAT(r62)
	---
	andi r1, r1, 4
	---
	bnez r1, putchar_cachef_wait_loop
	---
putchar_cachef_done:
	lw r1, 0(r61)
	jalr zero, r60, 0
	---

	; Prints a single byte as hexadecimal over UART
	; Args: byte
	; Uses: none
puthex8:
	sw r15, 0(r61) #
	sw r33, -4(r61)
	subi r61, r61, 8
	---
	lui r33, hex_chars>>16
	lliu r33, hex_chars&0xFFFF
	nop
	---
	srli r15, r16, 4 #
	andi r15, r15, 0xF #
	add r15, r15, r33
	---
	lb r15, 0(r15) #
	sw r15, UDAT(r62)
	nop
	---
	lw r15, STAT(r62) #
	andi r15, r15, 4 #
	bnez r15, $
	---
	andi r15, r16, 0xF #
	add r15, r33, r15 #
	lb r15, 0(r15)
	---
	sw r15, UDAT(r62) #
	lw r33, 4(r61)
	nop
	---
	lw r15, STAT(r62) #
	andi r15, r15, 4 #
	bnez r15, $
	---
	lw r15, 8(r61)
	addi r61, r61, 8
	jalr zero, r60, 0
	---

	; Same as puthex8, but cache-friendly
	; (Workaround for CI2406 bug)
puthex8_cachef:
	sw r15, 0(r61)
	subi r61, r61, 8
	---
	sw r33, 4(r61)
	srli r15, r16, 4
	---
	lui r33, hex_chars>>16
	lliu r33, hex_chars&0xFFFF
	andi r15, r15, 0xF
	---
	add r15, r15, r33
	---
	lb r15, 0(r15)
	---
	sw r15, UDAT(r62)
	---
	lw r15, STAT(r62)
	---
	andi r15, r15, 4
	---
	bnez r15, $-32
	andi r15, r16, 0xF
	---
	add r15, r33, r15
	---
	lb r15, 0(r15)
	---
	sw r15, UDAT(r62)
	---
	lw r15, STAT(r62)
	---
	andi r15, r15, 4
	---
	bnez r15, $-32
	---
	lw r33, 4(r61)
	---
	lw r15, 8(r61)
	addi r61, r61, 8
	jalr zero, r60, 0
	---

	; Same as puthex32, but cache-friendly
	; (Workaround for CI2406 bug)
puthex32_cachef:
	sw r51, -8(r61)
	---
	sw r60, 0(r61)
	lli r51, (puthex8_cachef-$-16)>>4
	---
	sw r33, -4(r61)
	subi r61, r61, 16
	lipc r51, r51
	---
	cpy r33, r16
	sw r16, 4(r61)
	nop
	---
	srli r16, r33, 24
	jalr r60, r51, 0
	---
	srli r16, r33, 16
	jalr r60, r51, 0
	---
	srli r16, r33, 8
	jalr r60, r51, 0
	---
	srli r16, r33, 0
	jalr r60, r51, 0
	---
	lw r16, 4(r61)
	---
	lw r51, 8(r61)
	addi r61, r61, 16
	---
	lw r60, 0(r61)
	---
	lw r33, -4(r61)
	nop
	jalr zero, r60, 0
	---

	; Sends a newline (\r\n) over the UART
	; Args: none
	; Uses: none
newl:
	sw r1, 0(r61)
	---
	lui r1, 0
	lliu r1, '\r' #
	sw r1, UDAT(r62)
	---
	lw r1, STAT(r62) #
	andi r1, r1, 4 #
	bnez r1, $
	---
	lui r1, 0
	lliu r1, '\n' #
	sw r1, UDAT(r62)
	---
	lw r1, STAT(r62) #
	andi r1, r1, 4 #
	bnez r1, $
	---
	lw r1, 0(r61)
	jalr zero, r60, 0
	---

	; Same as puthex8, but cache-friendly
	; (Workaround for CI2406 bug)
newl_cachef:
	sw r1, 0(r61)
	---
	lui r1, 0
	lliu r1, '\r'
	---
	sw r1, UDAT(r62)
	---
	lw r1, STAT(r62)
	---
	nop
	andi r1, r1, 4
	nop
	---
	bnez r1, $-32
	lui r1, 0
	lliu r1, '\n'
	---
	sw r1, UDAT(r62)
	---
	lw r1, STAT(r62)
	---
	andi r1, r1, 4
	---
	bnez r1, $-32
	---
	lw r1, 0(r61)
	jalr zero, r60, 0
	---
