module MUX2x1(
	input [1:0] data,
	input sel,
	input enable,
	output out
);
	
	wire selected;
	
	assign selected = data[0] & ~sel | data[1] & sel;
	
	assign out = enable ? selected : 1'b0;

endmodule
