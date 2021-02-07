module RegisterFile(
	input WR,
	input RD,
	input clk,
	input reset,
	input [3:0] z,
	input [3:0] x,
	input [3:0] y,
	input [15:0] Rz,
	output [15:0] Rx,
	output [15:0] Ry
);

	// Select which register to enable (Select Rz)
	wire [15:0] read;
	DEMUX1x16(WR, z, 1'b1, read);
	
	
	// Define the registers
	wire [15:0] regNet [15:0];
	
	// R0
	Register16Bit(Rz, clk, read[0], reset, regNet[0]);
	
	// R1
	Register16Bit(Rz, clk, read[1], reset, regNet[1]);
	
	// R2
	Register16Bit(Rz, clk, read[2], reset, regNet[2]);

	// R3
	Register16Bit(Rz, clk, read[3], reset, regNet[3]);
	
	// R4
	Register16Bit(Rz, clk, read[4], reset, regNet[4]);
	
	// R5
	Register16Bit(Rz, clk, read[5], reset, regNet[5]);
	
	// R6
	Register16Bit(Rz, clk, read[6], reset, regNet[6]);
	
	// R7
	Register16Bit(Rz, clk, read[7], reset, regNet[7]);
	
	// R8
	Register16Bit(Rz, clk, read[8], reset, regNet[8]);
	
	// R9
	Register16Bit(Rz, clk, read[9], reset, regNet[9]);
	
	// R10
	Register16Bit(Rz, clk, read[10], reset, regNet[10]);
	
	// R11
	Register16Bit(Rz, clk, read[11], reset, regNet[11]);
	
	// ACC0
	Register16Bit(Rz, clk, read[12], reset, regNet[12]);
	
	// ACC1
	Register16Bit(Rz, clk, read[13], reset, regNet[13]);
	
	// ACC2
	Register16Bit(Rz, clk, read[14], reset, regNet[14]);
	
	// ACC3
	Register16Bit(Rz, clk, read[15], reset, regNet[15]);
	
	
	// Select which registers to read (Select Rx and Ry)
	
	// Rx
	MUX16x16(regNet[0], regNet[1], regNet[2], regNet[3],
		regNet[4], regNet[5], regNet[6], regNet[7],
		regNet[8], regNet[9], regNet[10], regNet[11],
		regNet[12], regNet[13], regNet[14], regNet[15],
		x, RD, Rx
	);
	
	// Ry
	MUX16x16(regNet[0], regNet[1], regNet[2], regNet[3],
		regNet[4], regNet[5], regNet[6], regNet[7],
		regNet[8], regNet[9], regNet[10], regNet[11],
		regNet[12], regNet[13], regNet[14], regNet[15],
		y, RD, Ry
	);
	
	
endmodule
