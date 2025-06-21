#include <defs.h>

#define reg_mprj_proj_sel (*(volatile uint32_t*)0x30100004)
#define reg_mprj_counter  (*(volatile uint32_t*)0x30100008)
#define reg_mprj_settings (*(volatile uint32_t*)0x3010000C)

void delay(const int d) {
	reg_timer0_config = 0;
	reg_timer0_data = d;
	reg_timer0_config = 1;

	reg_timer0_update = 1;
	while (reg_timer0_value > 0) {
		reg_timer0_update = 1;
	}
}

int putchar(int c) {
	reg_uart_data = c;
	return c;
}

void puts(const char *s) {
	while(*s) {
		putchar(*s);
		s++;
	}
}

void puthex_nibble(unsigned char c) {
	if(c >= 10) putchar('A' + (c - 10));
	else putchar('0' + c);
}

void puthex(unsigned char c) {
	puthex_nibble(c >> 4);
	puthex_nibble(c & 15);
}

void puthex32(uint32_t a) {
	puthex(a >> 24);
	puthex(a >> 16);
	puthex(a >> 8);
	puthex(a);
}

void newl() {
	putchar('\r');
	putchar('\n');
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
	
	reg_mprj_io_5 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_6 = GPIO_MODE_USER_STD_OUTPUT;
	//reg_mprj_io_6 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_7 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_8 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_9 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_10 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_11 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_12 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_13 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_14 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_15 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_16 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_17 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_18 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_19 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_20 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_21 = GPIO_MODE_USER_STD_INPUT_PULLDOWN;
	reg_mprj_io_22 = GPIO_MODE_USER_STD_INPUT_PULLUP;
	reg_mprj_io_23 = GPIO_MODE_USER_STD_INPUT_PULLDOWN;
	reg_mprj_io_24 = GPIO_MODE_USER_STD_INPUT_PULLUP;
	reg_mprj_io_25 = GPIO_MODE_USER_STD_INPUT_PULLDOWN;
	reg_mprj_io_26 = GPIO_MODE_USER_STD_INPUT_PULLUP;
	reg_mprj_io_27 = GPIO_MODE_USER_STD_INPUT_PULLUP;
	reg_mprj_io_28 = GPIO_MODE_USER_STD_INPUT_PULLUP;
	reg_mprj_io_29 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_30 = GPIO_MODE_USER_STD_INPUT_PULLUP;
	reg_mprj_io_31 = GPIO_MODE_USER_STD_INPUT_PULLUP;
	reg_mprj_io_32 = GPIO_MODE_USER_STD_INPUT_PULLUP;
	reg_mprj_io_33 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_34 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_35 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_36 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_37 = GPIO_MODE_USER_STD_OUTPUT;
	
	delay(800000);
	reg_spi_enable = 0;
	
	reg_mprj_xfer = 1;
	while(reg_mprj_xfer == 1);
	reg_mprj_proj_sel = 0b10001;
	reg_mprj_proj_sel = 0b10011;
	reg_mprj_settings = 0;
	reg_gpio_out = 0;
    
    while(1) {
		reg_gpio_out = 1;
		delay(10000000);
		reg_gpio_out = 0;
		delay(7000000);
		//puthex32(reg_mprj_proj_sel);
		//newl();
	}
}
