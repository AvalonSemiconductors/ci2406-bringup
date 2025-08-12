#include "Vtb.h"
#include "verilated.h"
#include <iostream>
#include <fstream>

static Vtb top;

double sc_time_stamp() { return 0; }

int lastSclk = 0;
int lastCsb = 0;

bool sd_acmd = false;
bool sd_initialized = false;
bool sd_idle = false;
bool sd_cmd_entry = false;
bool sd_data_entry = false;
bool sd_in_write = false;
int sd_data_len;
int sd_data_pos;
int sd_data[520];
int byte_ctr = 0;
int rec_byte;
int sd_curr_cmd = 0;
int sd_resp_len = 0;
int sd_resp_pos = 0;
int sd_send_byte_ctr = 0;
int sd_send_byte = 0xFF;
unsigned long sd_targ_addr;

std::fstream sd_image;
unsigned int sector_count;

void sd_next_bit() {
	if((sd_send_byte&128) != 0) top.SDI = 1;
	else top.SDI = 0;
	//if(sd_send_byte_ctr == 0) std::cout << sd_send_byte << std::endl;
	sd_send_byte <<= 1;
	sd_send_byte_ctr++;
	if(sd_send_byte_ctr == 8) {
		sd_send_byte_ctr = 0;
		if(sd_resp_pos < sd_resp_len) sd_send_byte = sd_data[sd_resp_pos++];
		else sd_send_byte = 0xFF;
	}
}

char temp[512];

void sd_update() {
	if(top.CSb == 1) return;
	if(lastCsb == 1) {
		sd_cmd_entry = true;
		sd_data_entry = false;
		byte_ctr = 0;
		top.SDI = 1;
		sd_resp_len = 0;
		sd_resp_pos = 0;
		sd_send_byte = 0xFF;
		sd_in_write = false;
	}
	if(lastSclk == 0 && top.SCLK == 1) {
		rec_byte <<= 1;
		if(top.SDO) rec_byte |= 1;
		byte_ctr++;
	}
	if(lastSclk == 1 && top.SCLK == 0) sd_next_bit();
	if(byte_ctr == 8) {
		byte_ctr = 0;
		rec_byte &= 0xFF;
		if(sd_cmd_entry) {
			sd_curr_cmd = rec_byte&0xBF;
			sd_cmd_entry = false;
			switch(sd_curr_cmd) {
				case 0xBF:
					sd_cmd_entry = true;
					break;
				case 0:
				case 8:
				case 58:
				case 55:
				case 59:
				case 16:
				case 9:
				case 17:
				case 24:
					sd_data_entry = true;
					sd_data_len = 5; //Argument + CRC
					sd_data_pos = 0;
					break;
				case 41:
					if(!sd_acmd) std::cout << "ACMD without preceding CMD55!" << std::endl;
					sd_data_entry = true;
					sd_data_len = 5; //Argument + CRC
					sd_data_pos = 0;
					sd_acmd = false;
					break;
				default:
					std::cout << "Unknown SD command " << sd_curr_cmd << std::endl;
					break;
			}
		}
		else if(sd_data_entry) {
			sd_data[sd_data_pos++] = rec_byte;
			if(sd_data_pos >= sd_data_len) {
				sd_data_entry = false;
				sd_resp_len = 0;
				sd_resp_pos = 0;
				sd_send_byte_ctr = 0;
				if(sd_in_write) {
					sd_in_write = false;
					sd_send_byte = 0xFF;
					if(sd_data[0] != 0xFE) {
						std::cout << "Illegal SD write start token (" << sd_data[0] << ")" << std::endl;
						sd_data[0] = 0b00001101;
						sd_data[1] = 0xFF;
						sd_resp_len = 2;
					}else {
						sd_image.seekg(sd_targ_addr, std::ios::beg);
						sd_image.write(temp, 512);
						for(unsigned int a = 0; a < 512; a++) sd_data[a + 1] = (unsigned char)temp[a];
						sd_data[0] = 0b00000101;
						sd_data[1] = 0xFF;
						sd_resp_len = 2;
					}
				}else {
					unsigned int arg = sd_data[3];
					arg |= sd_data[2] << 8;
					arg |= sd_data[1] << 16;
					arg |= sd_data[0] << 24;
					switch(sd_curr_cmd) {
						default:
							break;
						case 0:
							sd_idle = true;
							sd_send_byte = 0x01;
							break;
						case 8:
							sd_data[0] = sd_data[1] = 0;
							sd_data[2] = 0x01;
							//sd_data[3] = sd_data[3]; //echo
							sd_send_byte = sd_idle ? 0x01 : 0x00;
							sd_resp_len = 4;
							break;
						case 58:
							sd_data[3] = 0;
							sd_data[2] = 0;
							sd_data[1] = 0b00110000;
							sd_data[0] = sd_initialized ? 0xC0 : 0x00;
							sd_send_byte = sd_idle ? 0x01 : 0x00;
							sd_resp_len = 4;
							break;
						case 55:
							sd_acmd = true;
							sd_send_byte = sd_idle ? 0x01 : 0x00;
							break;
						case 41:
							sd_initialized = true;
							sd_idle = false;
							sd_send_byte = 0x00;
						case 59:
							sd_send_byte = sd_idle ? 0x01 : 0x00;
							break;
						case 16:
							if(arg != 512) std::cout << "Invalid SD block size specified in CMD16 (" << arg << ")" << std::endl;
							sd_send_byte = sd_idle ? 0x01 : 0x00;
							break;
						case 9:
							sd_send_byte = 0x01;
							sd_data[0] = 0xFF;
							sd_data[1] = 0xFE;
							sd_data[2] = 1 << 6;
							sd_data[3] = sd_data[4] = sd_data[5] = sd_data[6] = sd_data[7] = sd_data[8] = 0;
							arg = (sector_count >> 10) - 1;
							sd_data[9] = (arg >> 16) & 63;
							sd_data[10] = (arg >> 8) & 255;
							sd_data[11] = arg & 255;
							sd_data[12] = sd_data[13] = sd_data[14] = sd_data[15] = sd_data[16] = sd_data[17] = 0;
							sd_resp_len = 18;
							break;
						case 17:
							sd_targ_addr = (unsigned long)arg * 512UL;
							sd_image.seekg(sd_targ_addr, std::ios::beg);
							sd_image.read(temp, 512);
							sd_data[0] = 0xFF;
							sd_data[1] = 0xFF;
							sd_data[2] = 0xFE;
							for(arg = 0; arg < 512; arg++) sd_data[arg + 3] = (unsigned char)temp[arg];
							sd_resp_len = 515;
							sd_send_byte = sd_idle ? 0x01 : 0x00;
							//std::cout << "Reading SD block " << arg << std::endl;
							break;
						case 24:
							sd_in_write = true;
							sd_targ_addr = (unsigned long)arg * 512UL;
							sd_data_len = 513; //start token + data
							sd_data_entry = true;
							sd_data_pos = 0;
							break;
					}
				}
			}
		}
	}
}

int main(int argc, char** argv, char** env) {
#ifdef TRACE_ON
	printf("Warning: tracing is ON!\r\n");
	Verilated::traceEverOn(true);
#endif
	sd_image = std::fstream("../disk.img", std::ios::binary | std::ios::in | std::ios::out | std::ios::ate);
	if(!sd_image.is_open()) {
		std::cout << "Disk image did NOT open!" << std::endl;
		return 1;
	}else std::cout << "Disk image opened." << std::endl;
	std::cout << sd_image.tellg() << std::endl;
	sector_count = sd_image.tellg() / 512;
	if(sector_count < 1024) {
		std::cout << "Disk image too small!" << std::endl;
		return 1;
	}
	
	top.clk = 0;
	top.rst = 1;
	int ctr = 0;
	while(!Verilated::gotFinish() && ctr < 1048576*44) {
		Verilated::timeInc(1);
		top.eval();
		top.clk = !top.clk;
		if(ctr > 16) top.rst = 0;
		ctr++;
		if(top.SCLK != lastSclk || top.CSb != lastCsb) {
			sd_update();
		}
		lastSclk = top.SCLK;
		lastCsb = top.CSb;
	}
	sd_image.close();
	top.final();
	return 0;
}
