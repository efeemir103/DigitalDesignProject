module MUX16x1(
	input [15:0] data,
	input [3:0] sel,
	input enable,
	output out
);
	wire [1:0] w;
	
	MUX8x1({data[14], data[12], data[10], data[8], data[6], data[4], data[2], data[0]}, sel[3:1], 1'b1, w[0]);
	
	MUX8x1({data[15], data[13], data[11], data[9], data[7], data[5], data[3], data[1]}, sel[3:1], 1'b1, w[1]);
	
	MUX2x1(w, sel[0], enable, out);

endmodule