`default_nettype none

module wrapped_as1802(
`ifdef USE_POWER_PINS
  inout vccd1,	// User area 1 1.8V supply
  inout vssd1,	// User area 1 digital ground
`endif
  input wb_clk_i, //Clock input (you can also use an input pin as a custom clock pin and ignore this)
  input rst_n, //Active low
  //Be careful with io_in/out/oeb[2:0] - these are assigned to the management controller on power-up
  //They may behave eratically until the firmware can assign them to your project
  //It is recommended to use them as outputs only
  input [35:0] io_in,
  output [35:0] io_out,
  output io_oeb, //Output Enable Bar ; 0 = Output, 1 = Input
  input [29:0] custom_settings //Custom settings register, settable over mgmt controller firmware
);

wire MWR;
wire TPA;
wire MRD;
assign io_out[22] = TPA;
assign io_out[19] = custom_settings[26] ? MRD | TPA : MRD;

wire MWR_p = custom_settings[27] ? MWR | TPA : MWR;
assign io_out[20] = custom_settings[25:24] == 1 ? MWR_p | wb_clk_i : (custom_settings[25:24] == 2 ? MWR_p | (~wb_clk_i) : MWR_p);
assign io_oeb = MWR;
assign io_out[29:25] = 0;

assign io_out[35:34] = custom_settings[29:28];

as1802 as1802(
  .rst(~rst_n),
  .clk(wb_clk_i),
  .address(io_out[10:3]),
  .data_in(io_in[18:11]),
  .data_out(io_out[18:11]),
  .MRD(MRD),
  .MWR(MWR),
  .Q(io_out[21]),
  .TPA(TPA),
  .SC0(io_out[23]),
  .SC1(io_out[24]),
  .intr(io_in[25]),
  .EF(io_in[29:26]),
  .reset_pc(custom_settings[15:0]),
  .reset_X(custom_settings[19:16]),
  .reset_P(custom_settings[23:20]),
  .IE(io_out[0]),
  .EXTEND(io_out[1]),
  .DF(io_out[2]),
  .N(io_out[32:30]),
  .idle(io_out[33])
);

endmodule
