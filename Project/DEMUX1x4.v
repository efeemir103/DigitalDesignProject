module DEMUX1x4(
	input data,
	input [1:0] sel,
	input en,
	output [3:0] out
);

	wire [1:0] w0;
	wire [3:0] w1;
	
	DEMUX1x2(data, sel[1], 1'b1, w0);
	
	DEMUX1x2(w0[0], sel[0], 1'b1, w1[1:0]);
	DEMUX1x2(w0[1], sel[0], 1'b1, w1[3:2]);
	
	assign out = en ? w1 : 4'b0000;

endmodule
