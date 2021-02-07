module MUX16x16(
	input [15:0] data0,
	input [15:0] data1,
	input [15:0] data2,
	input [15:0] data3,
	input [15:0] data4,
	input [15:0] data5,
	input [15:0] data6,
	input [15:0] data7,
	input [15:0] data8,
	input [15:0] data9,
	input [15:0] data10,
	input [15:0] data11,
	input [15:0] data12,
	input [15:0] data13,
	input [15:0] data14,
	input [15:0] data15,
	input [3:0] sel,
	input enable,
	output [15:0] out
);
	
	wire [15:0] data_transpose [15:0];
	
	assign data_transpose[0] = {data15[0], data14[0], data13[0], data12[0], data11[0], data10[0], data9[0], data8[0], data7[0], data6[0], data5[0], data4[0], data3[0], data2[0], data1[0], data0[0]};
	assign data_transpose[1] = {data15[1], data14[1], data13[1], data12[1], data11[1], data10[1], data9[1], data8[1], data7[1], data6[1], data5[1], data4[1], data3[1], data2[1], data1[1], data0[1]};
	assign data_transpose[2] = {data15[2], data14[2], data13[2], data12[2], data11[2], data10[2], data9[2], data8[2], data7[2], data6[2], data5[2], data4[2], data3[2], data2[2], data1[2], data0[2]};
	assign data_transpose[3] = {data15[3], data14[3], data13[3], data12[3], data11[3], data10[3], data9[3], data8[3], data7[3], data6[3], data5[3], data4[3], data3[3], data2[3], data1[3], data0[3]};
	assign data_transpose[4] = {data15[4], data14[4], data13[4], data12[4], data11[4], data10[4], data9[4], data8[4], data7[4], data6[4], data5[4], data4[4], data3[4], data2[4], data1[4], data0[4]};
	assign data_transpose[5] = {data15[5], data14[5], data13[5], data12[5], data11[5], data10[5], data9[5], data8[5], data7[5], data6[5], data5[5], data4[5], data3[5], data2[5], data1[5], data0[5]};
	assign data_transpose[6] = {data15[6], data14[6], data13[6], data12[6], data11[6], data10[6], data9[6], data8[6], data7[6], data6[6], data5[6], data4[6], data3[6], data2[6], data1[6], data0[6]};
	assign data_transpose[7] = {data15[7], data14[7], data13[7], data12[7], data11[7], data10[7], data9[7], data8[7], data7[7], data6[7], data5[7], data4[7], data3[7], data2[7], data1[7], data0[7]};
	assign data_transpose[8] = {data15[8], data14[8], data13[8], data12[8], data11[8], data10[8], data9[8], data8[8], data7[8], data6[8], data5[8], data4[8], data3[8], data2[8], data1[8], data0[8]};
	assign data_transpose[9] = {data15[9], data14[9], data13[9], data12[9], data11[9], data10[9], data9[9], data8[9], data7[9], data6[9], data5[9], data4[9], data3[9], data2[9], data1[9], data0[9]};
	assign data_transpose[10] = {data15[10], data14[10], data13[10], data12[10], data11[10], data10[10], data9[10], data8[10], data7[10], data6[10], data5[10], data4[10], data3[10], data2[10], data1[10], data0[10]};
	assign data_transpose[11] = {data15[11], data14[11], data13[11], data12[11], data11[11], data10[11], data9[11], data8[11], data7[11], data6[11], data5[11], data4[11], data3[11], data2[11], data1[11], data0[11]};
	assign data_transpose[12] = {data15[12], data14[12], data13[12], data12[12], data11[12], data10[12], data9[12], data8[12], data7[12], data6[12], data5[12], data4[12], data3[12], data2[12], data1[12], data0[12]};
	assign data_transpose[13] = {data15[13], data14[13], data13[13], data12[13], data11[13], data10[13], data9[13], data8[13], data7[13], data6[13], data5[13], data4[13], data3[13], data2[13], data1[13], data0[13]};
	assign data_transpose[14] = {data15[14], data14[14], data13[14], data12[14], data11[14], data10[14], data9[14], data8[14], data7[14], data6[14], data5[14], data4[14], data3[14], data2[14], data1[14], data0[14]};
	assign data_transpose[15] = {data15[15], data14[15], data13[15], data12[15], data11[15], data10[15], data9[15], data8[15], data7[15], data6[15], data5[15], data4[15], data3[15], data2[15], data1[15], data0[15]};
	
	
	MUX16x1(data_transpose[0], sel, enable, out[0]);
	MUX16x1(data_transpose[1], sel, enable, out[1]);
	MUX16x1(data_transpose[2], sel, enable, out[2]);
	MUX16x1(data_transpose[3], sel, enable, out[3]);
	MUX16x1(data_transpose[4], sel, enable, out[4]);
	MUX16x1(data_transpose[5], sel, enable, out[5]);
	MUX16x1(data_transpose[6], sel, enable, out[6]);
	MUX16x1(data_transpose[7], sel, enable, out[7]);
	MUX16x1(data_transpose[8], sel, enable, out[8]);
	MUX16x1(data_transpose[9], sel, enable, out[9]);
	MUX16x1(data_transpose[10], sel, enable, out[10]);
	MUX16x1(data_transpose[11], sel, enable, out[11]);
	MUX16x1(data_transpose[12], sel, enable, out[12]);
	MUX16x1(data_transpose[13], sel, enable, out[13]);
	MUX16x1(data_transpose[14], sel, enable, out[14]);
	MUX16x1(data_transpose[15], sel, enable, out[15]);
	
endmodule
