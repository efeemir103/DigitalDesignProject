module ProgramCounter(
	input [11:0] addr,
	input jump,
	input en,
	input clk,
	input reset,
	output [11:0] PC
);

	Counter12Bit(
		addr,
		jump,
		en,
		clk,
		reset,
		PC
	);

endmodule
