module MUX8x1(
	input [7:0] data,
	input [2:0] sel,
	input enable,
	output out
);
	wire [1:0] w;
	
	MUX4x1({data[6], data[4], data[2], data[0]}, sel[2:1], 1'b1, w[0]);
	
	MUX4x1({data[7], data[5], data[3], data[1]}, sel[2:1], 1'b1, w[1]);
	
	MUX2x1(w, sel[0], enable, out);

endmodule
