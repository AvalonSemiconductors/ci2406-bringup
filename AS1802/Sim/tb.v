`default_nettype wire
`define BENCH

module tb(
	input clk,
	input rst
);

reg [7:0] RAM [32767:0];

integer i;
initial begin
	for(i = 0; i < 32768; i=i+1) begin
		RAM[i] = 0;
	end
	$readmemh("../raminit.txt", RAM);
end

wire io_oeb;
wire [35:0] chip_in;
wire [35:0] chip_out;

wire IE_state = chip_out[0];
wire EXT_state = chip_out[1];
wire DF_state = chip_out[2];
wire [7:0] addr = chip_out[10:3];
wire [7:0] D_out = io_oeb ? 8'hFF : chip_out[18:11];
wire MRD = chip_out[19];
wire MWR = chip_out[20];
wire Q_state = chip_out[21];
wire TPA = chip_out[22];
wire [1:0] SC_state = chip_out[24:23];
wire [2:0] N = chip_out[32:30];
wire IDLE_state = chip_out[33];
wire [1:0] CS_state = chip_out[35:34];

reg [7:0] addr_latch = 0;
always @(negedge TPA) addr_latch <= addr;
wire [7:0] addr_latch_state = TPA ? addr : addr_latch;
wire [15:0] full_addr = {addr_latch_state, addr};
assign chip_in[18:11] = io_oeb && !MRD ? (addr_latch_state[7] ? cpld_D : RAM[full_addr]) : 8'hFF;

always @(negedge clk) begin
	if(!MWR && !io_oeb) RAM[full_addr] <= D_out;
end

wrapped_as1802 wrapped_as1802(
	.wb_clk_i(clk),
	.rst_n(!rst),
	.io_in(chip_in),
	.io_out(chip_out),
	.io_oeb(io_oeb),
	.custom_settings(30'h0C010000)
);

wire [7:0] cpld_D;
assign cpld_D = io_oeb ? 8'hzz : D_out;
as1802_cs cpld(
	.int_b(chip_in[25]),
	.EF_b(chip_in[29:26]),
	.N(N),
	.xclk(clk),
	.addr(addr[3:0]),
	.A15(addr_latch_state[7]),
	.MRD_b(MRD),
	.MWR_b(MWR),
	.LED(),
	.D(cpld_D),
	.PORTA(),
	.PORTB(),
	.TXD(),
	.RXD(1'b1),
	.SCK(),
	.SDO(),
	.SDI(0)
);

`ifdef TRACE_ON
initial begin
	$dumpfile("tb.vcd");
	$dumpvars();
end
`endif
endmodule
