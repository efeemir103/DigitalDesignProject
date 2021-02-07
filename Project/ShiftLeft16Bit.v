module ShiftLeft16Bit(
	input [15:0] A,
	input [3:0] B,
	output [15:0] C,
	output Cout
);

	wire [15:0] w [15:0];
	
	assign w[0] = A;
	assign w[1] = {A[14:0], 1'b0};
	assign w[2] = {A[13:0], 2'b00};
	assign w[3] = {A[12:0], 3'b000};
	assign w[4] = {A[11:0], 4'b0000};
	assign w[5] = {A[10:0], 5'b00000};
	assign w[6] = {A[9:0], 6'b000000};
	assign w[7] = {A[8:0], 7'b0000000};
	assign w[8] = {A[7:0], 8'b00000000};
	assign w[9] = {A[6:0], 9'b000000000};
	assign w[10] = {A[5:0], 10'b0000000000};
	assign w[11] = {A[4:0], 11'b00000000000};
	assign w[12] = {A[3:0], 12'b000000000000};
	assign w[13] = {A[2:0], 13'b0000000000000};
	assign w[14] = {A[1:0], 14'b00000000000000};
	assign w[15] = {A[0], 15'b000000000000000};
	
	wire [15:0] carry;
	assign carry[0] = 1'b0;
	assign carry[1] = A[15];
	assign carry[2] = A[15] | A[14];
	assign carry[3] = A[15] | A[14] | A[13];
	assign carry[4] = A[15] | A[14] | A[13] | A[12];
	assign carry[5] = A[15] | A[14] | A[13] | A[12] | A[11];
	assign carry[6] = A[15] | A[14] | A[13] | A[12] | A[11] | A[10];
	assign carry[7] = A[15] | A[14] | A[13] | A[12] | A[11] | A[10] | A[9];
	assign carry[8] = A[15] | A[14] | A[13] | A[12] | A[11] | A[10] | A[9] | A[8];
	assign carry[9] = A[15] | A[14] | A[13] | A[12] | A[11] | A[10] | A[9] | A[8] | A[7];
	assign carry[10] = A[15] | A[14] | A[13] | A[12] | A[11] | A[10] | A[9] | A[8] | A[7] | A[6];
	assign carry[11] = A[15] | A[14] | A[13] | A[12] | A[11] | A[10] | A[9] | A[8] | A[7] | A[6] | A[5];
	assign carry[12] = A[15] | A[14] | A[13] | A[12] | A[11] | A[10] | A[9] | A[8] | A[7] | A[6] | A[5] | A[4];
	assign carry[13] = A[15] | A[14] | A[13] | A[12] | A[11] | A[10] | A[9] | A[8] | A[7] | A[6] | A[5] | A[4] | A[3];
	assign carry[14] = A[15] | A[14] | A[13] | A[12] | A[11] | A[10] | A[9] | A[8] | A[7] | A[6] | A[5] | A[4] | A[3] | A[2];
	assign carry[15] = A[15] | A[14] | A[13] | A[12] | A[11] | A[10] | A[9] | A[8] | A[7] | A[6] | A[5] | A[4] | A[3] | A[2] | A[1];

	MUX16x16(w[0], w[1], w[2], w[3], w[4], w[5], w[6], w[7], w[8], w[9], w[10], w[11], w[12], w[13], w[14], w[15], B, 1'b1, C);
	MUX16x1(carry, B, 1'b1, Cout);

endmodule
