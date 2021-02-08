module DEMUX1x8(
	input data,
	input [2:0] sel,
	input en,
	output [7:0] out
);

	wire [1:0] w0;
	wire [7:0] w1;
	
	DEMUX1x2(data, sel[2], 1'b1, w0);
	
	DEMUX1x4(w0[0], sel[1:0], 1'b1, w1[3:0]);
	DEMUX1x4(w0[1], sel[1:0], 1'b1, w1[7:4]);
	
	assign out = en ? w1 : 8'b00000000;

endmodule
