module Subtractor16Bit(
	input [15:0] A,
	input [15:0] B,
	input Bin, // Borrow in
	output [15:0] Result,
	output Bout // Borrow out
);

	wire Cout;
	Adder16Bit(A, ~B, ~Bin, Result, Cout);
	
	assign Bout = ~Cout;

endmodule
