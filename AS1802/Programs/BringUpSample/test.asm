R0		EQU	0
R1		EQU	1
R2		EQU	2
R3		EQU	3
R4		EQU	4
R5		EQU	5
R6		EQU	6
R7		EQU	7
R8		EQU	8
R9		EQU	9
R10		EQU	10
R11		EQU	11
R12		EQU	12
R13		EQU	13
R14		EQU	14
R15		EQU	15

	org 0
start:
	nop
	sex r0
	dis
	db 0
	req

	sex r1
	ldi 255
	plo r1
	ldi 7Fh
	phi r1
	
	ldi 0
	plo r3
	ldi 128
	phi r3
	ldi 55h
	str r3
	inc r3
	ldi 1
	str r3
	ldi 128
	str r3
loop:
	ldi 0
	plo r10
	phi r10
del_loop:
	nop
	nop
	nop
	nop
	ldi 128
inner_del_loop:
	adi 1
	bnz inner_del_loop
	nop
	nop
	nop
	nop
	dec r10
	ghi r10
	bnz del_loop
	glo r10
	bnz del_loop
	
	bq clr_q
	seq
	br s_q
clr_q:
	req
s_q:
	
	br loop

testdata:
	db 6Bh
