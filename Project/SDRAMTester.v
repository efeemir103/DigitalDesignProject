module SDRAMTester(
	input clk,
	input reset,
	input [3:0] btns,
	output reg [3:0] leds,
	output reg clkLed,
	output clkLed2,
	
	// SDRAM Control Signals
	output sCLK,
	output CKE,
	output notCS,
	output [1:0] BA,
	output [11:0] A,
	output notRAS,
	output notCAS,
	output notWE,
	output UDQM,
	output LDQM,
	inout [15:0] DQ	
);
	wire [15:0] preValues [15:0];
	
	assign preValues[0] = 16'h0001;
	assign preValues[1] = 16'h0002;
	assign preValues[2] = 16'h0003;
	assign preValues[3] = 16'h0004;
	assign preValues[4] = 16'h0005;
	assign preValues[5] = 16'h0006;
	assign preValues[6] = 16'h0007;
	assign preValues[7] = 16'h0008;
	assign preValues[8] = 16'h0009;
	assign preValues[9] = 16'h000A;
	assign preValues[10] = 16'h000B;
	assign preValues[11] = 16'h000C;
	assign preValues[12] = 16'h000D;
	assign preValues[13] = 16'h000E;
	assign preValues[14] = 16'h000F;
	assign preValues[15] = 16'h0010;
	
	assign clkLed2 = 1'b0;
	
	
	wire busy;				// SDRAM Ready for New Command or Not
		
	reg WrReq;				// Write Request Signal
	wire WrGnt;				// Write Granted Signal
	reg [11:0] WrAddr;	// Write Address 11-bit
	reg [15:0] WrData;	// Write Address 16-bit
		
	reg RdReq;				// Read Request Signal
	wire RdGnt;				// Read Granted Signal
	reg [11:0] RdAddr;	// Read Address 11-bit
	wire [15:0] RdData;	// Write Address 16-bit
	wire RdDataValid;		// Read Data Valid Signal
	
	// Frequency Multiplication 50Mhz to 143MHz
	wire fastclk, locked;
	PLL(1'b0, clk, fastclk, locked);
	
	SDRAMController(
		// Interface
		fastclk,				// 143 Mhz clock
		busy,				// SDRAM Ready for New Command or Not
		
		WrReq,			// Write Request Signal
		WrGnt,			// Write Granted Signal
		WrAddr,			// Write Address 11-bit
		WrData,			// Write Address 16-bit
		
		RdReq,			// Read Request Signal
		RdGnt,			// Read Granted Signal
		RdAddr,			// Read Address 11-bit
		RdData,			// Write Address 16-bit
		RdDataValid,	// Read Data Valid Signal
		
		// SDRAM Control Signals
		sCLK,
		CKE,
		notCS,
		BA,
		A,
		notRAS,
		notCAS,
		notWE,
		UDQM,
		LDQM,
		DQ
	);
	
	reg [31:0] timer;
	reg [4:0] counter;
	reg writeDone;
	
	/*
	reg slowClock;
	always @(posedge clk)
	begin
		if(timer < 32'h00007FFF) begin
			clkLed <= 1'b0;
			slowClock <= 1'b0;
		end
		if(timer >= 32'h00007FFF) begin
			clkLed <= 1'b1;
			slowClock <= 1'b1;
		end
		if(timer == 32'h0000FFFF) begin
			timer <= 32'h00000000;
		end
		else begin
			timer <= timer + 32'h00000001;
		end
		
		if(~reset) begin
			timer <= 32'h00000000;
		end
	end
	*/
	
	initial begin
		writeDone <= 1'b0;
		counter <= 3'h0;
		timer <= 32'h00000000;
	end
	
	always @(posedge clk) begin
		clkLed <= ~clkLed;
		if(writeDone) begin
			WrReq <= 1'b0;
		end
		if(~reset) begin
			writeDone <= 1'b0;
			counter <= 3'h0;
			WrReq <= 1'b0;
			RdReq <= 1'b0;
		end
		if(~writeDone & counter == 5'h10) begin
			writeDone <= 1'b1;
			WrReq <= 1'b0;
		end
		if(~writeDone & ~busy) begin
			WrReq <= 1'b1;
		end
		if(WrGnt) begin
			WrAddr <= counter;
			WrData <= preValues[counter];
			counter <= counter + 1'b1;
		end
		if(writeDone & ~busy) begin
			RdReq <= 1'b1;
		end
		if(RdGnt) begin
			RdAddr <= {8'h000, ~btns};
		end
	end
	
	always @(posedge RdDataValid) begin
		leds <= ~RdData[3:0];
	end

endmodule
