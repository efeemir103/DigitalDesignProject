module CPUv2(
	input clk,
	input res,
	input enable,
	
	// Instruction fetch pins (ROM)
	output reg [11:0] instructionAddr,
	input [31:0] instructionNow,
	output selInstruction,
	
	// Data load/str pins (RAM)
	output [11:0] dataAddr,
	input [15:0] dataIn,
	output [15:0] dataOut,
	output selData,
	output ldData,
	output clrData
);

	reg [31:0] instruction;

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
	wire ALUEnable;
	wire LD;
	wire STR;
	wire nextGroup;
	
	DEMUX1x4(
		1'b1,
		opSelect1,
		enable,
		{nextGroup, STR, LD, ALUEnable}
	);
	
	wire RES;
	wire COMP;
	wire JUMP;
	wire NOP;
	
	DEMUX1x4(
		nextGroup,
		opSelect2,
		enable,
		{NOP, JUMP, COMP, RES}
	);
	
	
	// Create inner CPU reset signal:
	wire reset;
	
	assign reset = res | RES;
	
	
	// ALU result will be connected to this wire:
	wire [15:0] ALUResult;
	
	
	// Setting up Register File
	wire [15:0] Rz0;
	MUX2x16(ALUResult, immediateValue, immediate, enable, Rz0);
	wire [15:0] Rz; // Read register value
	MUX2x16(Rz0, dataIn, LD, regWr, Rz);
	
	wire [3:0] xSelected;
	MUX2x4(x, z, STR, enable, xSelected);
	
	wire [15:0] Rx; // A input for ALU/Comparator
	wire [15:0] Ry; // B input for ALU/Comparator
	
	RegisterFile(
		regWr,
		enable,
		~clk,
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
		ALUResult,
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
	
	
	// Setting up data (RAM) connections:
	assign selData = LD | STR;
	MUX2x12(Ry[11:0], immediateAddr, immediate, selData, dataAddr);
	
	assign ldData = LD;
	assign clrData = reset;
	
	assign dataOut = Rx;
	
	reg [4:0] CPSR;
	reg [5:0] regCOMP;
	
	// Selecting jump conditions:
	wire jumpPC;
	MUX16x1(
		{
			~CPSR[4], // JNP
			~CPSR[3], // JNO
			~CPSR[2], // JNN
			~CPSR[1], // JNZ
			~CPSR[0], // JNC
			CPSR[4], // JP
			CPSR[3], // JO
			CPSR[2], // JN
			CPSR[1], // JZ
			CPSR[0], // JC
			regCOMP[5], // JL
			regCOMP[4], // JLE
			regCOMP[3], // JNE
			regCOMP[2], // JE
			regCOMP[1], // JGE
			regCOMP[0] // JG
		},
		condition,
		JUMP,
		jumpPC
	);
	
	
	// Setting up Program Counter:
	wire [11:0] addrPC;
	MUX2x12(Ry[11:0], immediateAddr, immediate, JUMP, addrPC);
	
	
	/*
	ProgramCounter(
		addrPC,
		jumpPC,
		enable,
		clk,
		reset,
		instructionAddr
	);
	*/
	
	
	// Setting up instruction (ROM) connections:
	assign selInstruction = enable;
	
	
	// Program Counter and Status/Comparison Registers:
	reg jumpFlag;
	reg [11:0] addr;
	initial begin
		jumpFlag <= 1'b0;
		addr <= 12'h000;
	end
	
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			instruction <= 32'h00000000;
			instructionAddr <= 12'h000;
			jumpFlag <= 1'b0;
			addr <= 12'h000;
		end
		else
		begin
			instruction <= instructionNow; // Fetch current instruction
			
			CPSR <= ALUEnable ? CPSRnow : CPSR; // Current Program Status Register
			
			regCOMP <= COMP ? {lt, lt | eq, ~eq, eq, eq | gt, gt} : regCOMP; // Comparison Registers
			
			if(jumpPC)
			begin
				instructionAddr <= enable ? instructionAddr + 12'h001 : instructionAddr;
			end
			else
			begin
				instructionAddr <= enable ? addrPC : instructionAddr;
			end
		end
	end

endmodule
