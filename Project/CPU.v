module CPU(
	input clk,
	input res,
	input enable,
	
	// Instruction fetch pins (ROM)
	output [11:0] instructionAddr,
	input [31:0] instruction,
	output selInstruction,
	
	// Data load/str pins (RAM)
	output [11:0] dataAddr,
	inout [15:0] data,
	output selData,
	output ldData,
	output clrData
);

	// DECODE THE RECEIVED INSTRUCTION:
	
	wire [1:0] opSelect1;
	wire [1:0] opSelect2;
	wire [3:0] ALUOpcode;
	wire [3:0] z;
	wire [3:0] x;
	wire [3:0] y;
	wire [11:0] immediateAddr;
	wire [15:0] immediateValue;
	wire [3:0] condition;
	wire regWr;
	wire immediate;
	
	assign opSelect1 = instruction[1:0];
	assign opSelect2 = instruction[3:2];
	assign ALUOpcode = instruction[5:2];
	assign z = instruction[9:6];
	assign x = instruction[13:10];
	assign y = instruction[17:14];
	assign immediateAddr = instruction[21:10];
	assign immediateValue = instruction[25:10];
	assign condition = instruction[29:26];
	assign regWr = instruction[30];
	assign immediate = instruction[31];
	
	
	// Create CPU operation group selectors:
	wire [3:0] opEnable1;
	
	wire ALUEnable;
	wire LD;
	wire STR;
	wire nextGroup;
	
	DEMUX1x4(
		1'b1,
		opSelect1,
		enable,
		opEnable1
	);
	
	assign ALUEnable = opEnable1[0];
	assign LD = opEnable1[1];
	assign STR = opEnable1[2];
	assign nextGroup = opEnable1[3];
	
	wire [3:0] opEnable2;
	
	wire RES;
	wire COMP;
	wire JUMP;
	wire NOP;
	
	DEMUX1x4(
		nextGroup,
		opSelect2,
		enable,
		opEnable2
	);
	
	assign RES = opEnable2[0];
	assign COMP = opEnable2[1];
	assign JUMP = opEnable2[2];
	assign NOP = opEnable2[3];
	
	
	// Create inner CPU reset signal:
	wire reset;
	
	assign reset = res & RES;
	
	
	// ALU result will be connected to this wire:
	wire [15:0] Y;
	
	
	// Setting up Register File
	wire [15:0] Rz0;
	MUX2x16(Y, immediateValue, immediate, enable, Rz0);
	wire [15:0] Rz; // Read register
	MUX2x16(Rz0, data, immediate, enable, Rz);
	
	wire [3:0] xSelected;
	MUX2x4(x, z, STR, enable, xSelected);
	
	wire [15:0] Rx; // A input for ALU/Comparator
	wire [15:0] Ry; // B input for ALU/Comparator
	RegisterFile(
		regWr,
		enable,
		clk,
		reset,
		z,
		xSelected,
		y,
		Rz,
		Rx,
		Ry
	);
	
	// Setting up ALU
	wire [4:0] CPSRnow;
	ALU16Bit(
		Rx,
		Ry,
		ALUOpcode,
		ALUEnable,
		Y,
		CPSRnow
	);
	
	
	// Setting up Comparator:
	wire gt;
	wire eq;
	wire lt;
	Comparator16Bit(
		Rx,
		Ry,
		gt,
		eq,
		lt
	);
	
	
	// Setting up CPSR:
	wire [4:0] CPSR;
	Register5Bit(
		CPSRnow,
		clk,
		enable,
		reset,
		CPSR
	);
	
	
	// Setting up Comparison registers:
	wire [5:0] regCOMP;
	Register6Bit(
		{lt, lt & eq, ~eq, eq, eq & gt, gt},
		~clk,
		COMP,
		reset,
		regCOMP
	);
	
	
	// Setting up data (RAM) connections:
	assign selData = LD & STR;
	MUX2x12(Ry[11:0], immediateAddr, immediate, selData, dataAddr);
	
	assign ldData = LD;
	assign clrData = reset;
	
	assign data = STR ? Rx : data; // Simulates the tristate buffer between RAM.
	
	
	// Selecting jump conditions:
	wire jumpPC;
	wire selectedCondition;
	MUX16x1(
		{
			~CPSR[4],
			~CPSR[3],
			~CPSR[2],
			~CPSR[1],
			~CPSR[0],
			CPSR[4],
			CPSR[3],
			CPSR[2],
			CPSR[1],
			CPSR[0],
			regCOMP[5],
			regCOMP[4],
			regCOMP[3],
			regCOMP[2],
			regCOMP[1],
			regCOMP[0],
		},
		condition,
		1'b1,
		selectedCondition
	);
	
	assign jumpPC = JUMP ? selectedCondition : 1'b0;
	
	
	// Setting up Program Counter:
	wire [11:0] addrPC0;
	MUX2x12(Ry[11:0], immediateAddr, immediate, 1'b1, addrPC0);
	wire [11:0] addrPC;
	assign addrPC = JUMP ? addrPC0 : 12'h000;
	
	ProgramCounter(
		addrPC,
		jumpPC,
		enable,
		clk,
		reset,
		instructionAddr
	);
	
	
	// Setting up instruction (ROM) connections:
	assign selInstruction = enable;

endmodule
