module ArithmeticShiftRight16Bit(
	input [15:0] A,
	input [3:0] B,
	output [15:0] C
);

	wire [15:0] w [15:0];
	
	assign w[0] = A;
	assign w[1] = {A[15], A[15:1]};
	assign w[2] = {A[15], 1'b0, A[15:2]};
	assign w[3] = {A[15], 2'b00, A[15:3]};
	assign w[4] = {A[15], 3'b000, A[15:4]};
	assign w[5] = {A[15], 4'b0000, A[15:5]};
	assign w[6] = {A[15], 5'b00000, A[15:6]};
	assign w[7] = {A[15], 6'b000000, A[15:7]};
	assign w[8] = {A[15], 7'b00000000, A[15:8]};
	assign w[9] = {A[15], 8'b000000000, A[15:9]};
	assign w[10] = {A[15], 9'b000000000, A[15:10]};
	assign w[11] = {A[15], 10'b0000000000, A[15:11]};
	assign w[12] = {A[15], 11'b00000000000, A[15:12]};
	assign w[13] = {A[15], 12'b000000000000, A[15:13]};
	assign w[14] = {A[15], 13'b0000000000000, A[15:14]};
	assign w[15] = {A[15], 14'b00000000000000, A[15]};

	MUX16x16(w[0], w[1], w[2], w[3], w[4], w[5], w[6], w[7], w[8], w[9], w[10], w[11], w[12], w[13], w[14], w[15], B, 1'b1, C);

endmodule