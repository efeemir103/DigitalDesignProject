module VGATester(
	// 50 Mhz clock
	input clk,
	 
	output [2:0] rgbOut,
	output hsync,
	output vsync,
	input rst
);
	// Dual Port RAM data lines:
	wire [15:0] data_a;
	wire [15:0] data_b;

	RAMTestInitializer(clk, data_b, addr_b, we_b, q_b);

	VGAController(clk, hsync, vsync, rgbOut, rst, ROMAddr, ROMOut, addr_a, q_a);

	
	// ASCII Character ROM
	wire [13:0] ROMAddr;
	reg ROM [16383:0];
	reg ROMOut;

	initial begin
		$readmemb("glyph.bin", ROM);
	end

	always @(posedge clk)
	begin
		ROMOut <= ROM[ROMAddr];
	end

	// TEXT Character RAM

	wire [11:0] addr_a;
	wire [11:0] addr_b;
	wire we_a, we_b;
	reg [15:0] q_a, q_b;
	assign data_a = 16'h0000;
	assign we_a = 1'b0;

	// Declare the RAM variable
	reg [15:0] RAM [4095:0];

	// Port A for VGA Controller Only Read
	always @ (posedge clk)
	begin
		if (we_a) 
		begin
			RAM[addr_a] <= data_a;
			q_a <= data_a;
		end
		else 
		begin
			q_a <= RAM[addr_a];
		end 
	end 

	// Port B for CPU Read/Write
	always @ (posedge clk)
	begin
		if (we_b) 
		begin
			RAM[addr_b] <= data_b;
			q_b <= data_b;
		end
		else 
		begin
			q_b <= RAM[addr_b];
		end 
	end
	
endmodule