module Comparator16Bit(
	input [15:0] A,
	input [15:0] B,
	output gt,
	output eq,
	output lt
);

	wire [2:0] flags [7:0];
	
	Comparator2Bit(
		{1'b0, A[14]},
		{1'b0, B[14]},
		1'b0,
		1'b1,
		1'b0,
		flags[0][0],
		flags[0][1],
		flags[0][2]
	);
	
	Comparator2Bit(
		A[13:12],
		B[13:12],
		flags[0][0],
		flags[0][1],
		flags[0][2],
		flags[1][0],
		flags[1][1],
		flags[1][2]
	);
	
	Comparator2Bit(
		A[11:10],
		B[11:10],
		flags[1][0],
		flags[1][1],
		flags[1][2],
		flags[2][0],
		flags[2][1],
		flags[2][2]
	);
	
	Comparator2Bit(
		A[9:8],
		B[9:8],
		flags[2][0],
		flags[2][1],
		flags[2][2],
		flags[3][0],
		flags[3][1],
		flags[3][2]
	);
	
	Comparator2Bit(
		A[7:6],
		B[7:6],
		flags[3][0],
		flags[3][1],
		flags[3][2],
		flags[4][0],
		flags[4][1],
		flags[4][2]
	);
	
	Comparator2Bit(
		A[5:4],
		B[5:4],
		flags[4][0],
		flags[4][1],
		flags[4][2],
		flags[5][0],
		flags[5][1],
		flags[5][2]
	);
	
	Comparator2Bit(
		A[3:2],
		B[3:2],
		flags[5][0],
		flags[5][1],
		flags[5][2],
		flags[6][0],
		flags[6][1],
		flags[6][2]
	);
	
	Comparator2Bit(
		A[1:0],
		B[1:0],
		flags[6][0],
		flags[6][1],
		flags[6][2],
		flags[7][0],
		flags[7][1],
		flags[7][2]
	);
	
	assign gt = ~A[15] & B[15] | ~(A[15] ^ B[15]) & flags[7][0];
	assign eq = ~(A[15] ^ B[15]) & flags[7][1];
	assign lt = A[15] & ~B[15] | ~(A[15] ^ B[15]) & flags[7][2];

endmodule