module ALU16Bit(
	input [15:0] A,
	input [15:0] B,
	input [3:0] opcode,
	input enable,
	output [15:0] Y,
	output [4:0] status
);

	wire [15:0] opResult [15:0];
	
	wire [15:0] opCarry;
	
	// ADD - A, B, Cin, Result, Cout
	Adder16Bit(A, B, 1'b0, opResult[0], opCarry[0]);
	
	// SUB - A, B, Bin, Result, Bout
	Subtractor16Bit(A, B, 1'b0, opResult[1], opCarry[1]);
	
	// NEG - A, Result
	Negator16Bit(A, opResult[2]);
	assign opCarry[2] = 1'b0;
	
	// INC - A, 1, Cin, Result, Cout
	Adder16Bit(A, 1'b1, 1'b0, opResult[3], opCarry[3]);
	
	// DEC - A, 1, Bin, Result, Bout
	Subtractor16Bit(A, 1'b1, 1'b0, opResult[4], opCarry[4]);
	
	// MOV (Pass-through) - A, Result
	assign opResult[5] = A;
	assign opCarry[5] = 1'b0;
	
	// AND - A, B, Result
	assign opResult[6] = A & B;
	assign opCarry[6] = 1'b0;
	
	// OR - A, B, Result
	assign opResult[7] = A | B;
	assign opCarry[7] = 1'b0;
	
	// XOR - A, B, Result
	assign opResult[8] = A ^ B;
	assign opCarry[8] = 1'b0;
	
	// NOT - A, Result
	assign opResult[9] = ~A;
	assign opCarry[9] = 1'b0;
	
	// ASR - A, B, Result
	ArithmeticShiftRight16Bit(A, B[3:0], opResult[10]);
	assign opCarry[10] = 1'b0;
	
	// ASL - A, B, Result, Cout
	ShiftLeft16Bit(A, B[3:0], opResult[11], opCarry[11]);
	
	// LSR - A, B, Result
	LogicalShiftRight16Bit(A, B[3:0], opResult[12]);
	assign opCarry[12] = 1'b0;
	
	// LSL - A, B, Result, Cout
	ShiftLeft16Bit(A, B[3:0], opResult[13], opCarry[13]);
	
	// CSR - A, B, Result
	CircularShiftRight16Bit(A, B[3:0], opResult[14]);
	assign opCarry[14] = 1'b0;

	// CSL - A, B, Result
	CircularShiftLeft16Bit(A, B[3:0], opResult[15]);
	assign opCarry[15] = 1'b0;
	
	
	// Decide the operation
	wire [15:0] result;
	MUX16x16(opResult[0], opResult[1], opResult[2], opResult[3], opResult[4], opResult[5], opResult[6], opResult[7], opResult[8], opResult[9], opResult[10], opResult[11], opResult[12], opResult[13], opResult[14], opResult[15], opcode, 1'b1, result);
	
	// Decide the flags
	wire [4:0] flags;
	
	MUX16x1(opCarry, opcode, 1'b1, flags[0]); // Carry-Out
	
	assign flags[1] = ~(result[0] | result[1] | result[2] | result[3] | result[4] | result[5] | result[6] | result[7] | result[8] | result[9] | result[10] | result[11] | result[12] | result[13] | result[14] | result[15]); // Zero
	
	assign flags[2] = result[15]; // Negative
	
	wire OV;
	assign OV = flags[0] ^ flags[2];
	MUX16x1({11'b000000000, OV, OV, 1'b0, OV, OV}, opcode, 1'b1, flags[3]); // Overflow
	
	OddParity16Bit(result, flags[4]); // Parity
	
	// Add tri-state buffer at end
	assign Y = enable ? result : 16'bZZZZZZZZZZZZZZZZ;
	assign status = enable ? flags : 5'bZZZZZ;
	
endmodule
