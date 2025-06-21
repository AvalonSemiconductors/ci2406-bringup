	org 0
test:
	nop
	xmit 0, IVL
	xor AUX, AUX
	move AUX, LIV7
	xmit 8, IVR
	move AUX, RIV7
	xmit 1, R1
loop:
	move RIV7, AUX
	add R1, RIV7
	move AUX, LIV7
	xmit 200, R11
delay_loop_outer:
	move R11, AUX
	add R1, R11
	xmit 0, AUX
delay_loop_inner:
	nop
	add R1, AUX
	nop
	nzt AUX, delay_loop_inner
	nzt R11, delay_loop_outer
	jmp loop
