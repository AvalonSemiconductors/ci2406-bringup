FIELD_SIZE equ		6
FIELD_BUF_START equ	36
FIELD_BUF_SIZE equ	12
FIELD_ARR_SIZE equ	48

PC equ $3A
PDIR equ $3B
PB equ $3C
PA equ $3F

VAR_X equ			60
VAR_Y equ			59
TEMP equ			63
ADDR_TEMP equ		57
ROW_POS equ			56
CELL_POS equ		55
NEIGHBORS equ		54
M_TEMP equ			53
COUNT_LENGTH equ	52
CONST_ONE equ		51
UPDATE_CNTR equ		50
OUT_TEMP equ		49

reset:
	JMP main
interrupt:
	NOP
	IRET
main:
	LDI		0
	STA		62
	LDI		1
	STA		CONST_ONE
fill_loop:
	LDM		62
	LDM
	LDI		0
	STA
	LDI		1
	qADD	62
	STB
	LDI		FIELD_ARR_SIZE
	qEQL	62
	JZ		fill_loop
	
;A period 4 oscillator
;000110		0, 0
;001001		1, 1
;100101		0, 1, 1
;000010		2
;101100		0, 0, 1
;010000		2
	LDI		1
	
	STA		3
	STB		4
	
	STB		8
	STB		11
	
	STB		12
	STB		15
	STB		17
	
	STB		22
	
	STB		24
	STB		26
	STB		27
	STB		31
;A glider
;010000
;001000
;111000
;000000
;000000
;000000
	;STOREA		1
	
	;STORE		8
	
	;STORE		12
	;STORE		13
	;STORE		14
	
	LDI		0
	STA		UPDATE_CNTR
	JMP		loop
	
loop:
	CALL	display_state
	LDI		1
	qADD	UPDATE_CNTR
	STB
	STB		PC
	
	JMP		conway

conway:
	LDI		0
	STA		VAR_Y
	STB		ROW_POS
	STB		CELL_POS
conway_loop_y:
	CALL		load_buffer
	
	LDI		0
	STA		VAR_X
conway_loop_x:
	LDI		0
	STA		M_TEMP
	LDI		2
	STA		COUNT_LENGTH
	LDI		0
	qEQL	VAR_X
	JNZ		S1
	
	LDI		1
	STA		M_TEMP
	
	LDI		FIELD_SIZE
	SUB		CONST_ONE
	qEQL	VAR_X
	JNZ		s1
	
	LDI		3
	STA		COUNT_LENGTH
s1:
	LDI		0
	STA		NEIGHBORS
	
	LDI		0
	qEQL	VAR_Y
	JNZ		skip_top_row
	
	LDI		FIELD_BUF_START
	qADD	VAR_X
	STB		ADDR_TEMP
	LDI		FIELD_SIZE
	ADD		ADDR_TEMP
	qSUB	M_TEMP
	STB		ADDR_TEMP
	CALL	count_neighbors_in_row
skip_top_row:
	
	LDI		FIELD_BUF_START
	ADD		VAR_X
	qSUB	M_TEMP
	STB		ADDR_TEMP
	CALL	count_neighbors_in_row
	
	LDI		FIELD_SIZE
	SUB		CONST_ONE
	qEQL	VAR_Y
	JNZ		skip_bottom_row
	
	LDI		FIELD_SIZE
	ADD		CELL_POS
	qSUB	M_TEMP
	STB		ADDR_TEMP
	CALL	count_neighbors_in_row
skip_bottom_row:
	
	LDI		0
	LDM		CELL_POS
	LDM
	qEQL
	JNZ		this_dead
	
this_alive:
	LDI		63
	qADD	NEIGHBORS
	STB						; Since count_neighbors_in_row also counts the cell we're on, we have to substract 1 from the count to get the real number of neighbors
	;STB		PC			; Sequence should be  2, 2, 2, 2, 0, 2, 2, 3, 1, 2, 2, 2
	;LDI		63
	;STA		PC
	
	; Any live Cell with two or three neighbors survives
	LDI		2
	qEQL	NEIGHBORS
	STB		TEMP
	LDI		3
	EQL		NEIGHBORS
	qADD	TEMP
	JNZ		this_ifend
	; All other live cells die
	LDI		0
	LDM		CELL_POS
	LDM
	STA
	
	JMP			THIS_IFEND
this_dead:
	; A dead cell with three live neighbors becomes a live cell
	LDI		3
	qEQL	NEIGHBORS
	JZ		this_ifend
	LDI		1
	LDM		CELL_POS
	LDM
	STA
this_ifend:
	
	LDI		1
	qADD	CELL_POS
	STB
	qADD	VAR_X
	STB
	LDI		FIELD_SIZE
	qEQL
	JZ		conway_loop_x
	
	LDI		FIELD_SIZE
	qADD	ROW_POS
	STB
	LDI		1
	qADD	VAR_Y
	STB
	LDI		FIELD_SIZE
	qEQL
	JZ		conway_loop_y
	
	JMP			loop
	
load_buffer:
	LDI		0
	STA		VAR_X
swap_buff_loop:
	LDI		FIELD_BUF_START
	qADD	VAR_X
	STB		ADDR_TEMP
	LDI		FIELD_SIZE
	qADD	ADDR_TEMP
	STB		TEMP
	LDM		ADDR_TEMP
	LDM
	LDA
	LDM		TEMP
	LDM
	STA
	
	LDA		ROW_POS
	qADD	VAR_X
	STB		TEMP
	LDM
	LDA
	LDM		ADDR_TEMP
	LDM
	STA
	
	LDI		1
	qADD	VAR_X
	STB
	LDI		FIELD_SIZE
	qEQL
	JZ		swap_buff_loop
	
	RETURN
	
count_neighbors_in_row:
	LDI		0
	STA		TEMP
count_loop:
	LDM		ADDR_TEMP
	LDM
	LDA
	qADD	NEIGHBORS ; Cells are 0 for dead, 1 for alive. So to count the alive cells, just add the cell value to the count
	STB
	
	LDI		1
	qADD	ADDR_TEMP
	STB
	ADD		TEMP
	STB
	qEQL	COUNT_LENGTH
	JZ		count_loop
	
	RETURN
	
display_state: ; Only works with a 6x6 field, but it's not like you can make it any larger anyways
	LDI		0
	STA		VAR_Y
	STB		CELL_POS
display_loop_y:
	LDI		0
	STA		VAR_X
	STB		OUT_TEMP
	LDI		1
	STA		TEMP
display_loop_x:
	LDM		CELL_POS
	LDM
	LDI		1
	qEQL
	JZ		is_dead
	LDA		TEMP
	qADD	OUT_TEMP
	STB
is_dead:
	LDA		TEMP
	qADD
	STB
	LDI		1
	qADD	CELL_POS
	STB
	LDI		1
	qADD	VAR_X
	STB
	LDI		6
	qEQL
	JZ			display_loop_x
	
	LDA		OUT_TEMP
	STA		PC
	LDI		10
	STA		NEIGHBORS
delay_loop:
	NOP
	NOP
	NOP
	NOP
	LDI		63
	qADD	NEIGHBORS
	STB
	JNZ		delay_loop
	LDI		63
	STA		PC
	
	LDI		1
	qADD	VAR_Y
	STB
	LDI		6
	qEQL
	JZ		display_loop_y
	
	RETURN
