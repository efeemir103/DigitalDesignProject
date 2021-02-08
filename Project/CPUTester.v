module CPUTester(
	input clk,
	input res,
	input enable,
	input [1:0] btn,
	output reg [3:0] dig,
	output [7:0] seg
);

	// ROM:
	wire [11:0] ROMaddr;
	reg [31:0] ROMdata;
	wire ROMsel; // cs
	
	
	// RAM:
	wire [11:0] RAMaddr;
	wire [15:0] RAMdata;
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
		RAMdata,
		RAMsel,
		RAMld,
		RAMclr
	);
	
	
	// Define ROM functionality:
	reg [31:0] ROM [4095:0];
	
	initial begin
		$readmemh("ROM.hex", ROM);
	end
	
	always @(posedge clk)
	begin
		ROMdata <= ROMsel ? ROM[ROMaddr] : 32'hxxxxxxxx;
	end
	
	
	// Define RAM functionality:
	reg [15:0] RAMdataOut;
	reg [15:0] RAM [4095:0];
	
	integer i;
	always @(posedge clk or posedge RAMclr)
	begin
		if(RAMclr == 1'b1)
		begin
			for(i = 0; i < 4096; i = i + 1) 
			begin
				RAM[i] <= 16'b0000;
			end
		end
		else
		begin
			// Bind buttons to RAM:
			RAM[0] <= {14'b11111111111111, btn};
	
			if(RAMsel)
			begin
				if(RAMld)
				begin
					RAMdataOut <= RAM[RAMaddr];
				end
				else
				begin
					RAM[RAMaddr] <= RAMdata;
				end
			end
			else
			begin
				RAMdataOut <= 16'hxxxx;
			end
		end
	end
	
	assign RAMdata = RAMld & RAMsel ? RAMdataOut : 16'hzzzz;
	
	
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
			hexSel <= RAM[1]; // set RAM[1] as digital tube
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