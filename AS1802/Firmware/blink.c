#include <defs.h>
#include "../Programs/BringUpSample/pgmdata.h"

#define reg_mprj_proj_sel (*(volatile uint32_t*)0x30100004)
#define reg_mprj_counter  (*(volatile uint32_t*)0x30100008)
#define reg_mprj_settings (*(volatile uint32_t*)0x3010000C)

#define START_ADDRESS 0
#define START_X 1
#define START_P 0
#define GATE_TPA 1
#define CS 1

#define MRD (1 << 21)
#define MWR (1 << 22)
#define Q_L (1 << 23)
#define TPA (1 << 24)


void delay(const int d) {
	#ifdef BROKEN_CHIP
	for(int i = 0; i < d >> 2; i++) asm volatile("nop");
	#else
	reg_timer0_config = 0;
	reg_timer0_data = d;
	reg_timer0_config = 1;
	
	reg_timer0_update = 1;
	while (reg_timer0_value > 0) {
		reg_timer0_update = 1;
	}
	#endif
}

uint32_t datal_shadow;

void configure_io_mgmt(uint8_t input) {
	reg_mprj_io_0 = GPIO_MODE_USER_STD_INPUT_PULLDOWN;
	reg_mprj_io_1 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_2 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_3 = GPIO_MODE_MGMT_STD_INPUT_PULLUP;
	reg_mprj_io_4 = GPIO_MODE_MGMT_STD_OUTPUT;
	
	reg_mprj_io_5 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_6 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_7 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_8 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_9 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_10 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_11 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_12 = GPIO_MODE_MGMT_STD_OUTPUT;
	if(input) {
		reg_mprj_io_13 = GPIO_MODE_MGMT_STD_INPUT_PULLUP;
		reg_mprj_io_14 = GPIO_MODE_MGMT_STD_INPUT_PULLUP;
		reg_mprj_io_15 = GPIO_MODE_MGMT_STD_INPUT_PULLUP;
		reg_mprj_io_16 = GPIO_MODE_MGMT_STD_INPUT_PULLUP;
		reg_mprj_io_17 = GPIO_MODE_MGMT_STD_INPUT_PULLUP;
		reg_mprj_io_18 = GPIO_MODE_MGMT_STD_INPUT_PULLUP;
		reg_mprj_io_19 = GPIO_MODE_MGMT_STD_INPUT_PULLUP;
		reg_mprj_io_20 = GPIO_MODE_MGMT_STD_INPUT_PULLUP;
	}else {
		reg_mprj_io_13 = GPIO_MODE_MGMT_STD_OUTPUT;
		reg_mprj_io_14 = GPIO_MODE_MGMT_STD_OUTPUT;
		reg_mprj_io_15 = GPIO_MODE_MGMT_STD_OUTPUT;
		reg_mprj_io_16 = GPIO_MODE_MGMT_STD_OUTPUT;
		reg_mprj_io_17 = GPIO_MODE_MGMT_STD_OUTPUT;
		reg_mprj_io_18 = GPIO_MODE_MGMT_STD_OUTPUT;
		reg_mprj_io_19 = GPIO_MODE_MGMT_STD_OUTPUT;
		reg_mprj_io_20 = GPIO_MODE_MGMT_STD_OUTPUT;
	}
	reg_mprj_io_21 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_22 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_23 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_24 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_25 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_26 = GPIO_MODE_MGMT_STD_INPUT_NOPULL;
	reg_mprj_io_27 = GPIO_MODE_MGMT_STD_INPUT_PULLUP;
	reg_mprj_io_28 = GPIO_MODE_MGMT_STD_INPUT_PULLUP;
	reg_mprj_io_29 = GPIO_MODE_MGMT_STD_INPUT_PULLUP;
	reg_mprj_io_30 = GPIO_MODE_MGMT_STD_INPUT_PULLUP;
	reg_mprj_io_31 = GPIO_MODE_MGMT_STD_INPUT_PULLUP;
	reg_mprj_io_32 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_33 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_34 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_35 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_36 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_37 = GPIO_MODE_MGMT_STD_OUTPUT;
	
	reg_mprj_datal = datal_shadow = MRD | MWR;
	reg_mprj_datah = 0xFFFFFFFF;
	reg_mprj_xfer = 1;
	while(reg_mprj_xfer == 1);
}

void configure_io_as1802() {
	reg_mprj_io_0 = GPIO_MODE_USER_STD_INPUT_PULLDOWN;
	reg_mprj_io_1 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_2 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_3 = GPIO_MODE_MGMT_STD_INPUT_PULLUP;
	reg_mprj_io_4 = GPIO_MODE_USER_STD_OUTPUT;
	
	reg_mprj_io_5 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_6 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_7 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_8 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_9 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_10 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_11 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_12 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_13 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_14 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_15 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_16 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_17 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_18 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_19 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_20 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_21 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_22 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_23 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_24 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_25 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_26 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_27 = GPIO_MODE_USER_STD_INPUT_PULLUP;
	reg_mprj_io_28 = GPIO_MODE_USER_STD_INPUT_PULLUP;
	reg_mprj_io_29 = GPIO_MODE_USER_STD_INPUT_PULLUP;
	reg_mprj_io_30 = GPIO_MODE_USER_STD_INPUT_PULLUP;
	reg_mprj_io_31 = GPIO_MODE_USER_STD_INPUT_PULLUP;
	reg_mprj_io_32 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_33 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_34 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_35 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_36 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_37 = GPIO_MODE_USER_STD_OUTPUT;
	
	reg_mprj_xfer = 1;
	while(reg_mprj_xfer == 1);
}

void set_addr(uint16_t addr) {
	datal_shadow &= ~(0xFF << 5);
	reg_mprj_datal = datal_shadow | ((uint32_t)(addr >> 8) << 5);
	reg_mprj_datal = datal_shadow | ((uint32_t)(addr >> 8) << 5) | TPA | Q_L;
	reg_mprj_datal = datal_shadow | ((uint32_t)(addr >> 8) << 5);
	reg_mprj_datal = datal_shadow = datal_shadow | ((uint32_t)(addr & 0xFF) << 5);
}

void set_data(uint8_t data) {
	datal_shadow &= ~(0xFF << 13);
	reg_mprj_datal = datal_shadow = datal_shadow | ((uint32_t)data << 13);
}

uint8_t get_data() {
	return (reg_mprj_datal >> 13) & 0xFF;
}

void error_out() {
	while(1) {
		reg_gpio_out = 1;
		delay(1000000);
		reg_gpio_out = 0;
		delay(700000);
	}
}

void main() {
	reg_uart_enable = 0;
	reg_spi_enable = 0;
	reg_wb_enable = 1;
	configure_io_mgmt(0);
	reg_gpio_mode1 = 1;
	reg_gpio_mode0 = 0;
	reg_gpio_ien = 1;
	reg_gpio_oe = 1;
	reg_gpio_out = 0;

	reg_mprj_proj_sel = 0b10001;
	//Cache bug workaround
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	reg_mprj_settings = START_ADDRESS | (START_X << 16) | (START_P <<  20) | (2 << 24) | (GATE_TPA << 26) | (1 << 27) | (CS << 28);
	//Cache bug workaround
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	
	uint32_t val = 0xAAAAAAAA;
	
	configure_io_mgmt(0);
	while(1) {
		set_addr(val);
		delay(28000000);
		val = ~val;
	}
	
	for(uint32_t i = 0; i < pgm_len; i++) {
		val = pgm[i >> 1];
		if((i & 1) != 0) val >>= 8;
		set_addr(i);
		set_data(val & 0xFF);
		reg_mprj_datal = datal_shadow & ~MWR;
		reg_mprj_datal = datal_shadow;
	}
	set_data(0);
	configure_io_mgmt(1);
	for(uint32_t i = 0; i < pgm_len; i++) {
		val = pgm[i >> 1];
		if((i & 1) != 0) val >>= 8;
		set_addr(i);
		reg_mprj_datal = datal_shadow & ~MRD;
		if(get_data() != (val & 0xFF)) {
			reg_mprj_datal = datal_shadow;
			error_out();
		}
		reg_mprj_datal = datal_shadow;
	}
	
	configure_io_as1802();
	reg_mprj_proj_sel = 0b10011;
	reg_gpio_out = 0;
    
    while(1) {
		reg_gpio_out = 1;
		delay(40000000);
		reg_gpio_out = 0;
		delay(28000000);
	}
}
