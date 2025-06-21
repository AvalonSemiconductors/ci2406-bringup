PC equ $3A
PDIR equ $3B
PB equ $3C
PA equ $3F

counter equ $00

reset:
	JMP main
interrupt:
	NOP
	IRET
main:
	LDI $07
	STA PDIR
	LDI 0
	STA PC
	STA PB
	STA PA
loop:
	CALL delay_sub
test:

	LDI 1
	qADD PA
	STB PA
	LDI 0
	qADC PC
	STB PC
	JMP loop

delay_sub:
	LDI 0
	STA counter
	STB counter+1
delay_loop:
	NOP
	LDI 1
	qADD counter
	STB counter
	LDI 0
	qADC counter+1
	STB counter+1
	JNZ delay_loop
	LDI 0
	qEQL counter
	JZ delay_loop
	RETURN
