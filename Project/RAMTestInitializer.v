module RAMTestInitializer(
	input clk,
	output [15:0] data_b,
	output [11:0] addr_b,
	output we_b,
	input [15:0] q_b
);
	/*
	assign we_b = 1;
	assign data_b =  {8'd68, 6'b111010, 8'd77, 10'b1010010000};
	always @(posedge clk)
	begin
	addr_b = addr_b + 1;
	end
	*/

	reg [7:0] dataC;
	reg [11:0] addrC;

	assign addr_b = addrC[11:0];
	assign data_b = {dataC[7:0], 8'b11101000};
	assign we_b = 1'b1;

	always @(posedge clk)
	begin
		addrC <= addrC + 1;
		dataC <= dataC + 1;
	end

endmodule
