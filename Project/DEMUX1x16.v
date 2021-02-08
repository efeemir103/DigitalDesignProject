module DEMUX1x16(
	input data,
	input [3:0] sel,
	input en,
	output [15:0] out
);

	wire [1:0] w0;
	wire [15:0] w1;
	
	DEMUX1x2(data, sel[3], 1'b1, w0);
	
	DEMUX1x8(w0[0], sel[2:0], 1'b1, w1[7:0]);
	DEMUX1x8(w0[1], sel[2:0], 1'b1, w1[15:8]);
	
	assign out = en ? w1 : 16'b0000000000000000;

endmodule
