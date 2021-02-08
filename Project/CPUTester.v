module CPUTester(
	input clk,
	input res,
	input enable,
	input [1:0] btn,
	output reg [3:0] dig,
	output [7:0] seg
);

	// Block ROM:
	wire [11:0] ROMaddr;
	reg [31:0] ROMdata;
	wire ROMsel; // cs
	
	
	// Block RAM:
	wire [11:0] RAMaddr;
	wire [15:0] RAMdataIn;
	reg [15:0] RAMdataOut;
	wire RAMsel; // cs
	wire RAMld; // ~we
	wire RAMclr;
	
	// Define CPU connections:
	CPU(
		clk,
		~res,
		enable,
		
		// Instruction fetch pins (ROM)
		ROMaddr,
		ROMdata,
		ROMsel,
		
		// Data load/str pins (RAM)
		RAMaddr,
		RAMdataOut,
		RAMdataIn,
		RAMsel,
		RAMld,
		RAMclr
	);
	
	
	// Define ROM functionality:
	reg [31:0] ROM [63:0];
	
	initial begin
		$readmemh("ROM.hex", ROM);
	end
	
	always @(posedge clk)
	begin
		ROMdata <= ROMsel ? ROM[ROMaddr[7:0]] : 32'h00000000;
	end
	
	// Digital Tube value register:
	reg [15:0] hex4;
	
	// Define RAM functionality:
	reg [15:0] RAM [63:0];
	
	integer i;
	always @(posedge clk or posedge RAMclr)
	begin
		if(RAMclr == 1'b1)
		begin
			for(i = 0; i < 64; i = i + 1) 
			begin
				RAM[i] <= 16'b0000;
			end
		end
		else
		begin
			if(RAMsel)
			begin
				if(RAMld)
				begin
					if(RAMaddr == 12'd0)
					begin
						// Bind buttons to RAM:
						RAMdataOut <= {14'b00000000000000, ~btn};
					end
					else
					begin
						RAMdataOut <= RAM[RAMaddr];
					end
				end
				else
				begin
					if(RAMaddr == 12'd1)
					begin
						// Bind RAM[1] as digital tube:
						hex4 <= RAMdataIn;
					end
					else
					begin
						RAM[RAMaddr] <= RAMdataIn;
					end
				end
			end
			else
			begin
				RAMdataOut <= 16'h0000;
			end
		end
	end
	
	
	// Now bind digital tube to RAM:
	reg clock1KHz;
	reg [15:0] pulseCount;
	
	reg [2:0] counter;
	reg [15:0] hexSel;
	
	reg [6:0] hexEncoding;
	
	initial begin
		clock1KHz <= 1'b0;
		pulseCount <= 16'd0;
		
		dig <= 4'b0111;
		counter <= 3'b000;
		hexSel <= 16'h0000;
	end
	
	always @(posedge clk)
	begin
		if(~res)
		begin
			clock1KHz <= 1'b0;
			pulseCount <= 16'd0;
		end
		
		// 50000 clock cycles are needed to count for 1KHz clock (50000 division):
		if(pulseCount == 16'd50000)
		begin
			pulseCount <= 16'd0;
			clock1KHz <= 1'b0;
		end
		else 
		begin
			if(pulseCount == 16'd25000)
			begin
				clock1KHz <= 1'b1;
			end
			
			pulseCount <= pulseCount + 16'd1;
		end
	end
	
	always @(posedge clock1KHz)
	begin
		if(~res)
		begin
			dig <= 4'b0111;
			counter <= 3'b000;
			hexSel <= 16'h0000;
		end
			
		if(counter == 3'b100)
		begin
			dig <= 4'b0111;
			hexSel <= hex4;
			counter <= 3'b000;
		end
		else
		begin
			dig <= {dig[2:0], dig[3]};
			
			// Set digital tube to show recieved code:
			case (hexSel[3:0])
				4'b0000 : hexEncoding <= 7'h3f;
				4'b0001 : hexEncoding <= 7'h06;
				4'b0010 : hexEncoding <= 7'h5b;
				4'b0011 : hexEncoding <= 7'h4f;
				4'b0100 : hexEncoding <= 7'h66;          
				4'b0101 : hexEncoding <= 7'h6d;
				4'b0110 : hexEncoding <= 7'h7d;
				4'b0111 : hexEncoding <= 7'h07;
				4'b1000 : hexEncoding <= 7'h7f;
				4'b1001 : hexEncoding <= 7'h6f;
				4'b1010 : hexEncoding <= 7'h77;
				4'b1011 : hexEncoding <= 7'h7c;
				4'b1100 : hexEncoding <= 7'h39;
				4'b1101 : hexEncoding <= 7'h5e;
				4'b1110 : hexEncoding <= 7'h79;
				4'b1111 : hexEncoding <= 7'h71;
			endcase
			
			hexSel <= {4'b0000, hexSel[15:4]};
			counter <= counter + 3'b001;
		end
	end
	
 
	assign seg[7] = 1'b1;
	assign seg[6] = ~hexEncoding[6];
	assign seg[5] = ~hexEncoding[5];
	assign seg[4] = ~hexEncoding[4];
	assign seg[3] = ~hexEncoding[3];
	assign seg[2] = ~hexEncoding[2];
	assign seg[1] = ~hexEncoding[1];
	assign seg[0] = ~hexEncoding[0];
	
endmodule
