#include <defs.h>

#define reg_mprj_proj_sel (*(volatile uint32_t*)0x30100004)
#define reg_mprj_counter  (*(volatile uint32_t*)0x30100008)
#define reg_mprj_settings (*(volatile uint32_t*)0x3010000C)

#define IO_AND_RAM

void delay(const int d) {
	reg_timer0_config = 0;
	reg_timer0_data = d;
	reg_timer0_config = 1;

	reg_timer0_update = 1;
	while (reg_timer0_value > 0) {
		reg_timer0_update = 1;
	}
}

static void fix(void) {
	reg_mprj_counter = 0;
#ifdef IO_AND_RAM
	reg_mprj_settings = 3;
#else
	//TODO: Fix broken with this option
	reg_mprj_settings = 0;
#endif
	asm volatile("nop");
	asm volatile("nop");
	//Setup for timing-sensitive code
	//and EXACT padding so said code gets pre-fetched entirely
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("lui	a5,0x30100");
	asm volatile("li	a4,0b11011");
	asm volatile("lui	t1,0x30100");
	asm volatile("__l2: li t2, 14730");
	asm volatile("lui	t3,0x26000");
	asm volatile("addi	t3,t3,16");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	
	//Timing-sensitive code hand-written in assembly
	//To be so tiny, it fits entirely into icache
	asm volatile("sw	a4,4(t1)"); 
	asm volatile("__l1: lw	a4,8(a5)");
	asm volatile("bgeu	t2,a4,__l1");
	asm volatile("sw	zero,0(t3)");
}

void main() {
    reg_gpio_mode1 = 1;
    reg_gpio_mode0 = 0;
    reg_gpio_ien = 1;
    reg_gpio_oe = 1;
    
    reg_uart_enable = 0;
    reg_wb_enable = 1;
    
    reg_gpio_out = 0;
	reg_mprj_io_0 = GPIO_MODE_USER_STD_INPUT_PULLDOWN;
    reg_mprj_io_1 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_2 = GPIO_MODE_MGMT_STD_INPUT_NOPULL;
    reg_mprj_io_3 = GPIO_MODE_MGMT_STD_INPUT_NOPULL;
    reg_mprj_io_4 = GPIO_MODE_MGMT_STD_INPUT_NOPULL;
	
	reg_mprj_io_5 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_6 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_7 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_8 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_9 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_10 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_11 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_12 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_13 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_14 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_15 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_16 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_17 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_18 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_19 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_20 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_21 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_22 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_23 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_24 = GPIO_MODE_USER_STD_INPUT_PULLDOWN;
	reg_mprj_io_25 = GPIO_MODE_USER_STD_INPUT_PULLDOWN;
	reg_mprj_io_26 = GPIO_MODE_USER_STD_INPUT_PULLDOWN;
	reg_mprj_io_27 = GPIO_MODE_USER_STD_INPUT_PULLDOWN;
	reg_mprj_io_28 = GPIO_MODE_USER_STD_INPUT_PULLDOWN;
	reg_mprj_io_29 = GPIO_MODE_USER_STD_INPUT_PULLDOWN;
	reg_mprj_io_30 = GPIO_MODE_USER_STD_INPUT_PULLDOWN;
	reg_mprj_io_31 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_32 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_33 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_34 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_35 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_36 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_37 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_datah = 32;
	
	reg_mprj_xfer = 1;
	while(reg_mprj_xfer == 1);
	reg_mprj_proj_sel = 0b11001;
	reg_gpio_out = 0;
	delay(10000000);
	
	fix();
    
    while(1) {
		reg_gpio_out = 1;
		delay(10000000);
		reg_gpio_out = 0;
		delay(10000000);
	}
}
