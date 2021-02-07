module Counter12Bit(
	input [11:0] D,
	input load,
	input en,
	input clk,
	input reset,
	output reg [11:0] Q
);

	initial begin
		Q <= 12'h000;
	end
	
	always @(posedge clk or posedge load or posedge reset)
	begin
		if(reset)
		begin
			Q <= 12'h000;
		end
		else if(load)
		begin
			Q <= en ? D : Q;
		end
		else
		begin
			Q <= en ? Q + 12'h001 : Q;
		end
	end

endmodule
