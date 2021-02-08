module Register6Bit(
	input [5:0] D,
	input clk,
	input en,
	input clr,
	output reg [5:0] Q
);
	
	initial begin
		Q <= 6'h000;
	end
	
	always @(posedge clk or posedge clr)
	begin
		if(clr) begin
			Q <= 6'h000;
		end
		else begin
			Q <= en ? D: Q;
		end
	end

endmodule