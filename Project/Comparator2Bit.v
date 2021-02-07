module Comparator2Bit(
	input [1:0] A,
	input [1:0] B,
	input M_gt,
	input M_eq,
	input M_lt,
	output gt,
	output eq,
	output lt
);

	assign lt = M_lt | M_eq & (~A[1] & ~A[0] & B[0] | ~A[1] & B[1] | ~A[0] & B[1] & B[0]);
	assign gt = M_gt | M_eq & (A[0] & ~B[1] & ~B[0] | A[1] & ~B[1] | A[1] & A[0] & ~B[0]);
	assign eq = ~(lt | gt);

endmodule
