module SDRAMController(
	// Interface
	input clk,				// Global clock
	output reg busy,			// SDRAM Ready for New Command or Not
	
	input WrReq,			// Write Request Signal
	output reg WrGnt,			// Write Granted Signal
	input [11:0] WrAddr,	// Write Address 11-bit
	input [15:0] WrData,	// Write Address 16-bit
	
	input RdReq,			// Read Request Signal
	output reg RdGnt,			// Read Granted Signal
	input [11:0] RdAddr,	// Read Address 11-bit
	output reg [15:0] RdData,// Write Address 16-bit
	output reg RdDataValid,	// Read Data Valid Signal
	
	// SDRAM Control Signals
	output sCLK,
	output reg CKE,
	output reg  notCS,
	output reg [1:0] BA,
	output reg [11:0] A,
	output reg notRAS,
	output reg notCAS,
	output reg notWE,
	output reg UDQM,
	output reg LDQM,
	inout reg [15:0] DQ
);
	reg [2:0] state;
	reg ReadSelected;
	reg [7:0] waitCycles;
	reg [3:0] countCycles;
	
	assign sCLK = clk;
	
	initial begin
		state <= 2'h0;
		CKE <= 1'b1;
		waitCycles <= 8'h00;
		countCycles <= 4'h0;
	end
	
	always @(posedge sCLK)
	begin
		if(waitCycles != 8'h00) begin
			waitCycles <= waitCycles - 8'h01;
			if(waitCycles == 8'h00)
			begin
				if(state == 3'h4) begin
					if(ReadSelected) begin
						RdDataValid <= ReadSelected;
						RdData <= DQ;
					end
					else begin
						DQ <= WrData;
					end
				end
			end
		end
		else begin
			case(state)
				3'h0: begin // MODE Register set
					CKE <= 1'b1;
					notCS <= 1'b0;
					notRAS <= 1'b0;
					notCAS <= 1'b0;
					notWE <= 1'b0;
					UDQM <= RdReq;
					LDQM <= WrReq;
					
					// Opcode
					BA <= 2'b00;
					// 2. OPCode2, 4. CAS Latency, 5. Burst Type, 6. Burst Length
					A <= {2'b00, 1'b0, 2'b00, 3'b001, 1'b0, 3'b000};
					state <= 3'h1;
					busy <= 1'b1;
					waitCycles <= 8'h03;
				end
				3'h1: begin // IDLE | REFRESH | ACTIVATE
					if(RdReq | WrReq) begin  // Idle to Next State (Activate)
						CKE <= 1'b1;
						notCS <= 1'b0;
						notRAS <= 1'b0;
						notCAS <= 1'b1;
						notWE <= 1'b1;
						UDQM <= RdReq;
						LDQM <= WrReq;
						A <= RdReq ? RdAddr : WrAddr;
						BA <= 2'b00;
						
						RdGnt <= RdReq;
						WrGnt <= WrReq;
						ReadSelected <= RdReq;
						state <= 3'h2;
						busy <= 1'b1;
						waitCycles <= 8'h03;
					end
					else if(countCycles == 4'h2) begin // Refresh
						CKE <= 1'b1;
						notCS <= 1'b0;
						notRAS <= 1'b1;
						notCAS <= 1'b1;
						notWE <= 1'b1;
						UDQM <= RdReq;
						LDQM <= WrReq;
						A <= 12'bxxxxxxxxxxxx;
						BA <= 2'b00;
						
						state <= 3'h6;
						busy <= 1'b1;
						waitCycles <= 8'h03;
					end
					else
					begin // NOP
						CKE <= 1'b1;
						notCS <= 1'b0;
						notRAS <= 1'b1;
						notCAS <= 1'b1;
						notWE <= 1'b1;
						UDQM <= RdReq;
						LDQM <= WrReq;
						A <= 12'bxxxxxxxxxxxx;
						BA <= 2'b00;
						
						state <= 3'h1;
						busy <= 1'b0;
					end
				end
				3'h2: begin // NOP after opening row (Activate)
					CKE <= 1'b1;
					notCS <= 1'b0;
					notRAS <= 1'b1;
					notCAS <= 1'b0;
					notWE <= 1'b0;
					UDQM <= 1'b0;
					LDQM <= 1'b1;
					A <= {A[11], 1'b0, A[9:0]};
					BA <= 2'b00;
					
					state <= 3'h3;
					waitCycles <= 8'h03;
				end
				3'h3: begin // READ | WRITE
					if(ReadSelected) begin // No Precharge Read
						CKE <= 1'b1;
						notCS <= 1'b0;
						notRAS <= 1'b1;
						notCAS <= 1'b0;
						notWE <= 1'b1;
						UDQM <= 1'b0;
						LDQM <= 1'b1;
						A <= {A[11], 1'b0, A[9:0]};
						BA <= 2'b00;
						
						RdData <= DQ;
					end
					else begin // No Precharge Write
						CKE <= 1'b1;
						notCS <= 1'b0;
						notRAS <= 1'b1;
						notCAS <= 1'b0;
						notWE <= 1'b0;
						UDQM <= 1'b0;
						LDQM <= 1'b1;
						A <= {A[11], 1'b0, A[9:0]};
						BA <= 2'b00;
						
						DQ <= WrData;
					end
					
					state <= 3'h4;
					waitCycles <= 8'h03;
				end
				3'h4: begin // Precharge
					CKE <= 1'b1;
					notCS <= 1'b0;
					notRAS <= 1'b0;
					notCAS <= 1'b1;
					notWE <= 1'b0;
					UDQM <= 0;
					LDQM <= 0;
					A <= {1'bx, 1'b0,10'bxxxxxxxxxx};
					BA <= 2'b00;
					
					state <= 3'h5;
					waitCycles <= 8'h03;
				end
				3'h5: begin // NOP after READ/WRITE
					CKE <= 1'b1;
					notCS <= 1'b0;
					notRAS <= 1'b1;
					notCAS <= 1'b0;
					notWE <= 1'b0;
					UDQM <= 1'b0;
					LDQM <= 1'b1;
					A <= {A[11], 1'b0, A[9:0]};
					BA <= 2'b00;
					
					state <= 3'h1;
					waitCycles <= 8'h03;
				end
				3'h6: begin // NOP after REFRESH
					CKE <= 1'b1;
					notCS <= 1'b0;
					notRAS <= 1'b1;
					notCAS <= 1'b0;
					notWE <= 1'b0;
					UDQM <= 1'b0;
					LDQM <= 1'b1;
					A <= {A[11], 1'b0, A[9:0]};
					BA <= 2'b00;
					
					state <= 3'h1;
					waitCycles <= 8'h03;
				end
			endcase
		end
		
		if(countCycles == 4'h4) begin
			countCycles <= 4'h0;
		end
		countCycles <= countCycles + 4'h1;
	end

endmodule
