module Adder16Bit(
	input [15:0] A,
	input [15:0] B,
	input Cin,
	output [15:0] Result,
	output Cout
);
	wire [14:0] w;
	
	FullAdder(A[0], B[0], Cin, Result[0], w[0]);
	FullAdder(A[1], B[1], w[0], Result[1], w[1]);
	FullAdder(A[2], B[2], w[1], Result[2], w[2]);
	FullAdder(A[3], B[3], w[2], Result[3], w[3]);
	FullAdder(A[4], B[4], w[3], Result[4], w[4]);
	FullAdder(A[5], B[5], w[4], Result[5], w[5]);
	FullAdder(A[6], B[6], w[5], Result[6], w[6]);
	FullAdder(A[7], B[7], w[6], Result[7], w[7]);
	FullAdder(A[8], B[8], w[7], Result[8], w[8]);
	FullAdder(A[9], B[9], w[8], Result[9], w[9]);
	FullAdder(A[10], B[10], w[9], Result[10], w[10]);
	FullAdder(A[11], B[11], w[10], Result[11], w[11]);
	FullAdder(A[12], B[12], w[11], Result[12], w[12]);
	FullAdder(A[13], B[13], w[12], Result[13], w[13]);
	FullAdder(A[14], B[14], w[13], Result[14], w[14]);
	FullAdder(A[15], B[15], w[14], Result[15], Cout);

endmodule
