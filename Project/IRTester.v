module IRTester(
	input clk,
	input res,
	input ir,
	input btnSel,
	output [7:0] seg,
	output reg [3:0] dig
); 

	wire [31:0] code;
	wire dataValid;

	IRController(
		clk,
		~res,
		ir,
		code,
		dataValid
	);
	
	reg clock1KHz;
	reg [15:0] pulseCount;
	
	reg [2:0] counter;
	reg [15:0] hexSel;
	reg [31:0] hex8;
	
	reg [6:0] hexEncoding;
	
	initial begin
		clock1KHz <= 1'b0;
		pulseCount <= 16'd0;
		
		dig <= 4'b0111;
		counter <= 3'b000;
		hexSel <= 16'h0000;
		hex8 <= 32'h00000000;
	end
	
	always @(posedge dataValid or negedge res)
	begin
		hex8 <= code;
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
			hexSel <= ~btnSel ? hex8[31:16] : hex8[15:0];
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
	
 
	assign seg[7] = ir;
	assign seg[6] = ~hexEncoding[6];
	assign seg[5] = ~hexEncoding[5];
	assign seg[4] = ~hexEncoding[4];
	assign seg[3] = ~hexEncoding[3];
	assign seg[2] = ~hexEncoding[2];
	assign seg[1] = ~hexEncoding[1];
	assign seg[0] = ~hexEncoding[0];
	
endmodule
