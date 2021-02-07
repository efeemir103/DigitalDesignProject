module Register16Bit(
	input [15:0] D,
	input clk,
	input en,
	input clr,
	output reg [15:0] Q
);
	
	initial begin
		Q <= 16'h0000;
	end
	
	always @(posedge clk or posedge clr)
	begin
		if(clr) begin
			Q <= 16'h0000;
		end
		else begin
			Q <= en ? D: Q;
		end
	end

endmodule
