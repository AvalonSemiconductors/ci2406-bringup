#include <defs.h>
#include "../Programs/Test/pgmdata.h"

#define reg_mprj_proj_sel (*(volatile uint32_t*)0x30100004)
#define reg_mprj_counter  (*(volatile uint32_t*)0x30100008)
#define reg_mprj_settings (*(volatile uint32_t*)0x3010000C)

#define BROKEN_CHIP

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
	reg_mprj_io_0 = GPIO_MODE_USER_STD_INPUT_NOPULL;
    reg_mprj_io_1 = GPIO_MODE_MGMT_STD_INPUT_NOPULL;
    reg_mprj_io_2 = GPIO_MODE_MGMT_STD_INPUT_NOPULL;
    reg_mprj_io_3 = GPIO_MODE_MGMT_STD_INPUT_PULLUP;
    reg_mprj_io_4 = GPIO_MODE_MGMT_STD_INPUT_NOPULL;
    if(input) {
		reg_mprj_io_5 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
		reg_mprj_io_6 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
		reg_mprj_io_7 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
		reg_mprj_io_8 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
		reg_mprj_io_9 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
		reg_mprj_io_10 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
		reg_mprj_io_11 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
		reg_mprj_io_12 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
		reg_mprj_io_13 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
		reg_mprj_io_14 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
		reg_mprj_io_15 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
		reg_mprj_io_16 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
		reg_mprj_io_17 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
		reg_mprj_io_18 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
		reg_mprj_io_19 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
		reg_mprj_io_20 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
	}else {
		reg_mprj_io_5 = GPIO_MODE_MGMT_STD_OUTPUT;
		reg_mprj_io_6 = GPIO_MODE_MGMT_STD_OUTPUT;
		reg_mprj_io_7 = GPIO_MODE_MGMT_STD_OUTPUT;
		reg_mprj_io_8 = GPIO_MODE_MGMT_STD_OUTPUT;
		reg_mprj_io_9 = GPIO_MODE_MGMT_STD_OUTPUT;
		reg_mprj_io_10 = GPIO_MODE_MGMT_STD_OUTPUT;
		reg_mprj_io_11 = GPIO_MODE_MGMT_STD_OUTPUT;
		reg_mprj_io_12 = GPIO_MODE_MGMT_STD_OUTPUT;
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
	reg_mprj_io_23 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
	reg_mprj_io_24 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_25 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_26 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_27 = GPIO_MODE_MGMT_STD_INPUT_PULLUP;
	reg_mprj_io_28 = GPIO_MODE_MGMT_STD_INPUT_PULLUP;
	reg_mprj_io_29 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
	reg_mprj_io_30 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
	reg_mprj_io_31 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
	reg_mprj_io_32 = GPIO_MODE_MGMT_STD_INPUT_NOPULL;
	reg_mprj_io_33 = GPIO_MODE_MGMT_STD_INPUT_NOPULL;
	reg_mprj_io_34 = GPIO_MODE_MGMT_STD_INPUT_NOPULL;
	reg_mprj_io_35 = GPIO_MODE_MGMT_STD_INPUT_NOPULL;
	reg_mprj_io_36 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_37 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_datah = (1 << 4) | (1 << 5);
	
	reg_mprj_xfer = 1;
	while(reg_mprj_xfer == 1);
}

void configure_io_vliw() {
	reg_mprj_io_0 = GPIO_MODE_USER_STD_INPUT_NOPULL;
    reg_mprj_io_1 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
    reg_mprj_io_2 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_3 = GPIO_MODE_MGMT_STD_INPUT_PULLUP;
    reg_mprj_io_4 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_5 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_6 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_7 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_8 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_9 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_10 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_11 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_12 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
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
	reg_mprj_io_27 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_28 = GPIO_MODE_USER_STD_INPUT_PULLUP;
	reg_mprj_io_29 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_30 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_31 = GPIO_MODE_USER_STD_INPUT_PULLUP;
	reg_mprj_io_32 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_33 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_34 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_35 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_36 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_37 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	
	reg_mprj_xfer = 1;
	while(reg_mprj_xfer == 1);
}

#define LE_HI (1 << 21)
#define LE_LO (1 << 22)
#define OEB (1 << 24)
#define WEBLO (1 << 25)
#define WEBHI (1 << 26)

void main() {
	reg_spi_enable = 0;
    reg_gpio_mode1 = 1;
    reg_gpio_mode0 = 0;
    reg_gpio_ien = 1;
    reg_gpio_oe = 1;
    reg_gpio_out = 0;
    datal_shadow = OEB + WEBLO + WEBHI;
	(*(volatile uint32_t*)0x2d000000) = (1 << 31) | (2 << 16); //Less wait states
    reg_mprj_datal = datal_shadow;
    configure_io_mgmt(1);
    
    reg_uart_enable = 0;
    reg_wb_enable = 1;
    //reg_mprj_settings = 0b10001;
    reg_mprj_settings = 0b10001;
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
	delay(1000000);
	reg_mprj_proj_sel = 0b01111;
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
	
	configure_io_mgmt(0);
	uint32_t val;
	for(uint32_t i = 0; i < pgm_len; i++) {
		reg_gpio_out = (i & 16) != 0;
		val = pgm[i];
		datal_shadow &= ~(0xFFFF << 5);
		datal_shadow |= (i >> 16) << 5;
		datal_shadow |= LE_HI;
		reg_mprj_datal = datal_shadow;
		datal_shadow &= ~LE_HI;
		reg_mprj_datal = datal_shadow;
		datal_shadow &= ~(0xFFFF << 5);
		datal_shadow |= (i & 0xFFFF) << 5;
		datal_shadow |= LE_LO;
		reg_mprj_datal = datal_shadow;
		datal_shadow &= ~LE_LO;
		reg_mprj_datal = datal_shadow;
		datal_shadow &= ~(0xFFFF << 5);
		datal_shadow |= (val & 0xFFFF) << 5;
		datal_shadow &= ~(WEBLO + WEBHI);
		reg_mprj_datal = datal_shadow;
		datal_shadow |= WEBLO + WEBHI;
		reg_mprj_datal = datal_shadow;
	}
	reg_gpio_out = 0;
	configure_io_mgmt(0);
	configure_io_vliw();
	asm volatile("nop");
	delay(100000);
	asm volatile("nop");
	reg_mprj_proj_sel = 0b01101;
	reg_mprj_proj_sel = 0b01100;
    
    while(1) {
		reg_gpio_out = 1; //ON
		#ifdef BROKEN_CHIP
		delay(10000000);
		#else
		delay(50000000);
		#endif
		reg_gpio_out = 0; //OFF
		#ifdef BROKEN_CHIP
		delay(10000000);
		#else
		delay(50000000);
		#endif
	}
}
