module MUX2x12(
	input [11:0] data0,
	input [11:0] data1,
	input sel,
	input enable,
	output [11:0] out
);
	
	MUX2x1({data1[0], data0[0]}, sel, enable, out[0]);
	MUX2x1({data1[1], data0[1]}, sel, enable, out[1]);
	MUX2x1({data1[2], data0[2]}, sel, enable, out[2]);
	MUX2x1({data1[3], data0[3]}, sel, enable, out[3]);
	MUX2x1({data1[4], data0[4]}, sel, enable, out[4]);
	MUX2x1({data1[5], data0[5]}, sel, enable, out[5]);
	MUX2x1({data1[6], data0[6]}, sel, enable, out[6]);
	MUX2x1({data1[7], data0[7]}, sel, enable, out[7]);
	MUX2x1({data1[8], data0[8]}, sel, enable, out[8]);
	MUX2x1({data1[9], data0[9]}, sel, enable, out[9]);
	MUX2x1({data1[10], data0[10]}, sel, enable, out[10]);
	MUX2x1({data1[11], data0[11]}, sel, enable, out[11]);
	
	
endmodule