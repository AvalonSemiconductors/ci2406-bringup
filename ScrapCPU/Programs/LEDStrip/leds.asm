PC equ $3A
PDIR equ $3B
PB equ $3C
PA equ $3F

NUM_LEDS equ 30

counter equ $00
curr_led equ $02
RB1 equ $03
RB2 equ $04
red equ $05
green equ $06
blue equ $07
curr_color equ $08
TEMP equ $09
loop_count equ $0A
TEMP2 equ $0C
BRIGHTNESS equ $0D
divi00 equ $0E
divi01 equ $0F
divi10 equ $10
dres equ $11
dshift equ $12
div_cntr equ $13
curr_step equ $14 ;2
color_temp equ $16 ;2
sub_temp equ $18 ;2
color_function_rb1 equ $1A
color_function_rb2 equ $1B

LOOP_INCREMENT equ 22
STEP_SIZE equ 175

reset:
	JMP main
interrupt:
	NOP
	IRET
main:
	; $00 - $1F
	LDI $10
	STA BRIGHTNESS
	LDI $3F
	STA PDIR
	LDI 0
	STA PC
	STB PB
	STB PA
	STB loop_count
	STB loop_count+1
loop:
	CALL delay_sub
	LDI 0
	STA TEMP
	CALL startend_frame

	; There are three counters:
	; curr_led = index of current LED, range 0 - NUM_LEDS-1
	; curr_step = curr_led * STEP_SIZE, range 0 - 4095
	; loop_count: increments by LOOP_INCREMENT after every full update of the LED strip, range 0 - 4095

	LDI 0
	STA curr_led
	STB curr_step
	STB curr_step+1
leds_loop:
	CALL next_led_color

	LDI STEP_SIZE&63
	qADD curr_step
	STB curr_step
	LDI STEP_SIZE>>6
	qADC curr_step+1
	STB curr_step+1

	LDI 1
	ADD curr_led
	STB curr_led
	LDI NUM_LEDS
	qEQL curr_led
	JZ leds_loop

	LDI 1
	STA TEMP
	CALL startend_frame
	LDI 1
	ADD PC
	STA PC
	LDI LOOP_INCREMENT&63
	qADD loop_count
	STB loop_count
	LDI LOOP_INCREMENT>>6
	qADC loop_count+1
	STB loop_count+1
	JMP loop

	; Calculate and set the color of the next LED in the chain
	; curr_led contains the index of this LED, range 0 to NUM_LEDS - 1
next_led_color:
	; Send 3 ones = LED color header
	LDI 1
	STA PA
	NOP
	LDI 3
	STA PA
	NOP
	LDI 1
	STA PA
	NOP
	LDI 3
	STA PA
	NOP
	LDI 1
	STA PA
	NOP
	LDI 3
	STA PA
	NOP
	LDI 1
	STA PA
	NOP
	; Send 5-bit brightness setting
	LDI 5
	STA counter
	LDA BRIGHTNESS
	STA TEMP2
	LDI 2
	STA TEMP
	LDI 0
	STA counter+1
brightness_loop:
	; Shift-left
	LDA TEMP2
	qADD TEMP2
	STB TEMP2
	; Trick to move carry into A and B
	LDI 0
	ADC counter+1
	; Set data to output (setup)
	STB PA
	NOP
	; Clock high (note A is not changed)
	qADD TEMP
	STB PA
	; Clock low
	NOP
	STA PA
	
	LDI $3F
	qADD counter
	STB counter
	JNZ brightness_loop
	
	; Backup return address
	LDA $3D
	STA RB1
	LDA $3E
	STA RB2
	
	; Compute R, G and B for this LED
	LDI 0
	STA green
	STA blue
	STA red
	
	; Basic color pattern. Use LOOP_INCREMENT equ 1 for this
	;LDA loop_count+1
	;RSHC
	;STB TEMP
	;LDA loop_count
	;RSHC
	;STB TEMP2
	;LDA TEMP
	;RSHC
	;STB TEMP
	;LDA TEMP2
	;RSHC
	;STB TEMP2
	;LDA TEMP
	;RSHC
	;STB TEMP
	;LDA TEMP2
	;RSHC
	;STB TEMP2
	
	;LDA curr_led
	;qSUB TEMP2
	;STB TEMP2
	
	;LDI 0
	;STA green
	;STB blue
	;STB red
	;LDI 1
	;qAND TEMP2
	;JZ not_red
	;LDI $3F
	;STA red
;not_red:
	;LDI 2
	;qAND TEMP2
	;JZ not_green
	;LDI $3F
	;STA green
;not_green:
	;LDI 4
	;qAND TEMP2
	;JZ not_blue
	;LDI $3F
	;STA blue
;not_blue:

	; Advanced color pattern. Use LOOP_INCREMENT equ 5 for this
	LDA loop_count
	qADD curr_step
	STB color_temp
	LDA loop_count+1
	qADC curr_step+1
	STB color_temp+1
	CALL color_function
	LDA dres
	STA red
	
	LDA loop_count
	qADD curr_step
	STB color_temp
	LDA loop_count+1
	qADC curr_step+1
	STB color_temp+1
	LDI COLOR_RISING&63
	qADD color_temp
	STB color_temp
	LDI COLOR_RISING>>6
	qADC color_temp+1
	STB color_temp+1
	CALL color_function
	LDA dres
	STA green
	
	LDA loop_count
	qADD curr_step
	STB color_temp
	LDA loop_count+1
	qADC curr_step+1
	STB color_temp+1
	LDI COLOR_RISING&63
	qADD color_temp
	STB color_temp
	LDI COLOR_RISING>>6
	qADC color_temp+1
	STB color_temp+1
	LDI COLOR_RISING&63
	qADD color_temp
	STB color_temp
	LDI COLOR_RISING>>6
	qADC color_temp+1
	STB color_temp+1
	CALL color_function
	LDA dres
	STA blue
	
	; Send R, G and B values
	LDA blue
	STA curr_color
	CALL send_color
	LDA green
	STA curr_color
	CALL send_color
	LDA red
	STA curr_color
	CALL send_color
	
	; Restore return address & return
	LDA RB1
	STA $3D
	LDA RB2
	STA $3E
	RETURN

	; Sends one color channel value from curr_color
	; As this is a 6-bit processor, the value transmitted is padded with two zeroes at the end to get to 8 bits
	; This reduces the available color depth, but should be fine
send_color:
	; Set up some constants
	LDI 0
	STA counter+1
	LDI 2
	STA TEMP
	LDI 6
	STA counter
send_color_loop:
	; Shift-left
	LDA curr_color
	qADD curr_color
	STB curr_color
	; Trick to move carry into A and B
	LDI 0
	ADC counter+1
	; Set data to output (setup)
	STB PA
	NOP
	; Clock high (note A is not changed)
	qADD TEMP
	STB PA
	; Clock low
	NOP
	STA PA

	LDI $3F
	qADD counter
	STB counter
	JNZ send_color_loop
	
	; Now send two zeroes of padding
	LDI 0
	STA PA
	NOP
	LDI 2
	STA PA
	NOP
	LDI 0
	STA PA
	NOP
	LDI 2
	STA PA
	NOP
	LDI 0
	STA PA
	
	RETURN

	; just sends 32 clocks to the LEDs, which is either a start or end frame depending on the state of TEMP
	; Start frame is 32 zeroes
	; End frame is 32 ones
startend_frame:
	LDI 32
	STA counter
startend_loop:
	LDI 2
	ADD TEMP
	STB PA
	NOP
	LDA TEMP
	STA PA
	LDI $3F
	ADD counter
	STB counter
	JNZ startend_loop
	RETURN

COLOR_RISING equ 1365
COLOR_FALLING equ 2730
    ; Computes pattern for single color channel shaped like
    ;  /\       /\
    ; /  \     /  \     /
    ;/    \---/    \---/
    ;
    ; input (x-coordinate) in color_temp
    ; output (y-coordinate / intensity) in dres
    ; Each color channel should be phase-shifted by COLOR_RISING steps from the previous
color_function:
	LDI 0
	STA TEMP
	LDI COLOR_FALLING&63
	qSUB color_temp
	LDI COLOR_FALLING>>6
	qSBC color_temp+1
	LDI 0
	qADC TEMP
	JZ color_zero
	
	LDI COLOR_RISING&63
	qSUB color_temp
	LDI COLOR_RISING>>6
	qSBC color_temp+1
	LDI 0
	qADC TEMP
	JZ color_falling_adjust
color_step_adjusted:
	; color_temp is now in range 0 - 1365 and ready to be divided
	; Backup return address
	LDA $3D
	STA color_function_rb1
	LDA $3E
	STA color_function_rb2
	; Divide by 22 to get a value in range 0 - 63
	LDI 22
	STA divi10
	LDA color_temp
	STA divi00
	LDA color_temp+1
	STA divi01
	CALL div_cycles
	; The result of the division is the final result, so just return now
	
	; Restore return address & return
	LDA color_function_rb1
	STA $3D
	LDA color_function_rb2
	STA $3E
	
	RETURN
color_zero:
	LDI 0
	STA dres
	RETURN
color_falling_adjust:
	LDI COLOR_RISING&63
	STA sub_temp
	LDI COLOR_RISING>>6
	STA sub_temp+1
	LDA color_temp
	qSUB sub_temp
	STB color_temp
	LDA color_temp+1
	qSBC sub_temp+1
	STB color_temp+1
	; color temp is now in range 0 - 1365, but in the wrong direction
	LDI COLOR_RISING&63
	qSUB color_temp
	STB color_temp
	LDI COLOR_RISING>>6
	qSBC color_temp+1
	STB color_temp+1
	JMP color_step_adjusted

	; Divides (unsigned) the 12-bit value in DIVI0x by the 6-bit value in DIVI10
	; Result in the 6-bit DRES (does not check overflows)
div_cycles:
	LDI 0
	STA dres
	STB dshift
	LDI 12
	STA div_cntr
div_loop:
	; dres <<= 1
	LDA dres
	qADD dres
	STB dres
	; {dshift, divi01, divi00} <<= 1
	LDA divi00
	qADD divi00
	STB divi00
	LDA divi01
	qADC divi01
	STB divi01
	LDA dshift
	ADC dshift
	STB dshift
	; if dshift >= divi10: dshift -= divi10; dres++;
	qEQL divi10
	JNZ div_ge
	qMAG divi10
	JZ div_not_ge
div_ge:
	qSUB divi10
	STB dshift
	LDI 1
	qADD dres
	STB dres
div_not_ge:
	LDI $3F
	qADD div_cntr
	STB div_cntr
	JNZ div_loop
	RETURN

	; Wastes some cycles
delay_sub:
	LDI 0
	STA counter
	LDI 47
	STA counter+1
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
