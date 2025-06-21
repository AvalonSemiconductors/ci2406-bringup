#include "Vtb.h"
#include "verilated.h"
#include <iostream>
#include <fstream>

static Vtb top;

double sc_time_stamp() { return 0; }

int main(int argc, char** argv, char** env) {
#ifdef TRACE_ON
	printf("Warning: tracing is ON!\r\n");
	Verilated::traceEverOn(true);
#endif
	top.clk = 0;
	top.rst = 1;
	int ctr = 0;
	while(!Verilated::gotFinish() && ctr < 65536) {
		Verilated::timeInc(1);
		top.eval();
		top.clk = !top.clk;
		if(ctr > 16) top.rst = 0;
		ctr++;
	}
	top.final();
	return 0;
}
