module MUX2x4(
	input [3:0] data0,
	input [3:0] data1,
	input sel,
	input enable,
	output [3:0] out
);
	
	MUX2x1({data1[0], data0[0]}, sel, enable, out[0]);
	MUX2x1({data1[1], data0[1]}, sel, enable, out[1]);
	MUX2x1({data1[2], data0[2]}, sel, enable, out[2]);
	MUX2x1({data1[3], data0[3]}, sel, enable, out[3]);
	
endmodule