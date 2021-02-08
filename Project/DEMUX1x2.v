module DEMUX1x2(
	input data,
	input sel,
	input en,
	output [1:0] out
);

	wire [1:0] w;
	
	assign w[0] = ~sel & data;
	assign w[1] = sel & data;
	
	assign out = en ? w : 2'b00;

endmodule
