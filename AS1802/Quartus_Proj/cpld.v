module as1802_cs(
	output int_b,
	output [3:0] EF_b,
	input [2:0] N,
	input xclk,
	input [2:0] addr,
	input A15,
	input MRD_b,
	input MWR_b,
	output LED = 0,
	inout [7:0] D,
	output reg [7:0] PORTA = 0,
	input [7:0] PORTB,
	output TXD,
	input RXD,
	output SCK,
	output SDO,
	input SDI
);

assign LED = PORTA[7];

reg [7:0] ior;
always @(*) begin
	case(addr)
		default: ior = 8'hxx;
		0: ior = PORTA;
		1: ior = PORTB;
		2: ior = uart_dout;
		3: ior = spi_dout;
		4: ior = timer[7:0];
		5: ior = timer[15:8];
	endcase
end
assign D = read_cond ? ior : 8'hzz;

assign int_b = (t_flag || !tmr_int_en) && (!uart_int_en || !uart_has_byte);

reg [15:0] timer = 0;
reg [15:0] ttop = 0;

reg t_flag = 1;
assign EF_b = ~{uart_busy, spi_busy, uart_has_byte, t_flag};

wire write_cond = !MWR_b && A15;
wire read_cond = !MRD_b && A15 && !write_cond;

reg timer_on = 0;
reg [2:0] tdiv = 0;
reg uart_int_en = 0;
reg tmr_int_en = 0;

always @(posedge xclk) begin
	tdiv <= tdiv + 1;
	if(tdiv == 0 && timer_on) timer <= timer + 1;
	if(timer == ttop) begin
		timer <= 0;
		t_flag <= ttop == 0 || !timer_on;
	end
	if(write_cond) case(addr)
		0: PORTA  <= D;
		1: begin
			if(D[7]) t_flag <= 1;
			else begin
				timer_on <= D[0];
				uart_int_en <= D[1];
				tmr_int_en <= D[2];
			end
		end
		4: timer[7:0]  <= D;
		5: timer[15:8] <= D;
		6: ttop[7:0]   <= D;
		7: ttop[15:8]  <= D;
	endcase
end

wire [7:0] uart_dout;
wire uart_busy;
wire uart_has_byte;
uart uart(
	.divisor(235), //max 4095
	.din(D),
	.dout(uart_dout),
	.TX(TXD),
	.RX(RXD),
	.start(write_cond && addr == 2),
	.busy(uart_busy),
	.has_byte(uart_has_byte),
	.clr_hb(read_cond && addr == 2),
	.clk(xclk)
);

wire [7:0] spi_dout;
wire spi_busy;
vliw_spi spi(
	.divisor(3), //max 15
	.din(D),
	.dout(spi_dout),
	.SCLK(SCK),
	.DO(SDO),
	.DI(SDI),
	.start(write_cond && addr == 3),
	.busy(spi_busy),
	.clk(xclk)
);

endmodule

module uart(
	input [15:0] divisor,
	input [7:0] din,
	
	output reg [7:0] dout = 0,
	
	output reg TX = 1,
	input RX,
	
	input start,
	output reg busy = 0,
	output reg has_byte = 0,
	input clr_hb,
	
	input clk
);

reg [9:0] data_buff = 0;
reg [11:0] div_counter = 0;
reg [3:0] counter = 0;

reg receiving = 0;
reg [7:0] receive_buff = 0;
reg [3:0] receive_counter = 0;
reg [11:0] receive_div_counter = 0;

always @(posedge clk) begin
	if(clr_hb) has_byte <= 0;
	if(start) begin
		counter <= 4'b1011;
		div_counter <= 0;
		data_buff <= {1'b1, din, 1'b0};
		busy <= 1;
	end
	if(counter != 0) begin
		div_counter <= div_counter + 1;
		if(div_counter == divisor) begin
			div_counter <= 0;
			counter <= counter - 1;
			TX <= data_buff[0];
			data_buff <= {1'b1, data_buff[9:1]};
		end
	end else begin
		TX <= 1;
		busy <= start;
	end

	if(!receiving && !RX) begin
		receiving <= 1;
		receive_counter <= 4'b1000;
		receive_buff <= 0;
		receive_div_counter <= 0;
	end
	if(receiving) begin
		receive_div_counter <= receive_div_counter + 1;
		if(receive_div_counter == divisor) begin
			receive_div_counter <= 0;
			receive_counter <= receive_counter - 1;
			if(receive_counter == 0) begin
				receiving <= 0;
				dout <= receive_buff;
				has_byte <= 1;
			end else begin
				receive_buff <= {RX, receive_buff[7:1]};
			end
		end
	end
end

endmodule

module vliw_spi(
	input [7:0] divisor,
	input [7:0] din,
	
	output reg [7:0] dout = 0,
	
	output reg SCLK = 0,
	output reg DO = 0,
	input DI,
	
	input start,
	output reg busy = 0,
	
	input clk
);

reg [7:0] data_out_buff = 0;
reg [7:0] data_in_buff = 0;
reg [3:0] div_counter = 0;
reg [4:0] counter = 5'b11111;

always @(posedge clk) begin
	if(start) begin
		counter <= 5'b10000;
		div_counter <= 0;
		data_out_buff <= din;
		data_in_buff <= 1;
		SCLK <= 0;
	end
	if(counter != 5'b11111) begin
		busy <= 1;
		div_counter <= div_counter + 1;
		if(div_counter == divisor) begin
			div_counter <= 0;
			counter <= counter - 1;
			if(!counter[0]) begin
				DO <= data_out_buff[7];
				data_out_buff <= {data_out_buff[6:0], 1'b0};
				SCLK <= 0;
			end else begin
				SCLK <= 1;
				data_in_buff <= {data_in_buff[6:0], DI};
			end
		end
	end else begin
		SCLK <= 0;
		DO <= 0;
		busy <= 0;
		dout <= data_in_buff;
	end
end

endmodule
