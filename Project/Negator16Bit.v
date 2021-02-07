module Negator16Bit(
	input [15:0] X,
	output [15:0] Y
);

	wire w;
	Adder16Bit(~X, 16'h0001, 1'b0, Y, w);

endmodule
