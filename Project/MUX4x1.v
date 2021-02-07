module MUX4x1(
	input [3:0] data,
	input [1:0] sel,
	input enable,
	output out
);
	wire [1:0] w;
	
	MUX2x1({data[2], data[0]}, sel[1], 1'b1, w[0]);
	
	MUX2x1({data[3], data[1]}, sel[1], 1'b1, w[1]);
	
	MUX2x1(w, sel[0], enable, out);

endmodule
