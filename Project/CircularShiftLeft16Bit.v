module CircularShiftLeft16Bit(
	input [15:0] A,
	input [3:0] B,
	output [15:0] C
);

	wire [15:0] w [15:0];
	
	assign w[0] = A;
	assign w[1] = {A[14:0], A[15]};
	assign w[2] = {A[13:0], A[15:14]};
	assign w[3] = {A[12:0], A[15:13]};
	assign w[4] = {A[11:0], A[15:12]};
	assign w[5] = {A[10:0], A[15:11]};
	assign w[6] = {A[9:0], A[15:10]};
	assign w[7] = {A[8:0], A[15:9]};
	assign w[8] = {A[7:0], A[15:8]};
	assign w[9] = {A[6:0], A[15:7]};
	assign w[10] = {A[5:0], A[15:6]};
	assign w[11] = {A[4:0], A[15:5]};
	assign w[12] = {A[3:0], A[15:4]};
	assign w[13] = {A[2:0], A[15:3]};
	assign w[14] = {A[1:0], A[15:2]};
	assign w[15] = {A[0], A[15:1]};

	MUX16x16(w[0], w[1], w[2], w[3], w[4], w[5], w[6], w[7], w[8], w[9], w[10], w[11], w[12], w[13], w[14], w[15], B, 1'b1, C);

endmodule
