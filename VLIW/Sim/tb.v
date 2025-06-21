`default_nettype wire
`define BENCH

module tb(
	input clk,
	input rst,
	output SDO,
	input SDI,
	output SCLK,
	output CSb
);

tri0 [35:0] chip_io;

wire M1 = chip_io[1];
wire [15:0] db_out = chip_io[18:3];
wire le_hi = chip_io[19];
wire le_lo = chip_io[20];
wire bdir = chip_io[21];
wire OEb = chip_io[22];
wire WEb_lo = chip_io[23];
wire WEb_hi = chip_io[24];
wire TXD = chip_io[25];
wire RXD = chip_io[26];
assign SCLK = chip_io[27];
assign SDO = chip_io[28];
//wire SDI = chip_io[29];

assign CSb = chip_io[35];
assign chip_io[29] = chip_io[35] ? 1'b1 : SDI;

reg [31:0] addr_latch;
wire [31:0] curr_addr = {le_hi ? db_out : addr_latch[31:16], le_lo ? db_out : addr_latch[15:0]};
reg [15:0] RAM [131071:0];

always @(negedge le_hi) addr_latch[31:16] <= db_out;
always @(negedge le_lo) addr_latch[15:0] <= db_out;
always @(negedge WEb_lo) if(curr_addr[23] == 0) RAM[curr_addr][7:0] <= db_out[7:0];
always @(negedge WEb_hi) if(curr_addr[23] == 0) RAM[curr_addr][15:8] <= db_out[15:8];

wire [15:0] db_in = curr_addr[23] ? 16'h0000 : RAM[curr_addr];
assign chip_io[18:3] = OEb ? 16'hzzzz : db_in; //Databus
assign chip_io[29] = 1'b0; //SDI

integer i;
initial begin
	for(i = 0; i < 131072; i=i+1) begin
		RAM[i] = 0;
	end
	$readmemh("../raminit.txt", RAM);
end

top top(
	.clk(clk),
	.rstn(!rst),
	.io(chip_io)
);

`ifdef TRACE_ON
initial begin
	$dumpfile("tb.vcd");
	$dumpvars();
end
`endif
endmodule
