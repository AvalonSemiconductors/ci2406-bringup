module disp(
	input [3:0] nibble,
	output [6:0] segments
);

reg [6:0] rom;
always @(*) begin
	case(nibble)
		0: rom = 7'b1111110;
		1: rom = 7'b0110000;
		2: rom = 7'b1101101;
		3: rom = 7'b1111001;
		4: rom = 7'b0110011;
		5: rom = 7'b1011011;
		6: rom = 7'b1011111;
		7: rom = 7'b1110000;
		8: rom = 7'b1111111;
		9: rom = 7'b1111011;
		10: rom = 7'b1110111;
		11: rom = 7'b0011111;
		12: rom = 7'b0001101;
		13: rom = 7'b0111101;
		14: rom = 7'b1001111;
		15: rom = 7'b1000111;
	endcase
end
assign segments = rom;

endmodule
