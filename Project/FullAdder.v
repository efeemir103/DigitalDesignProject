module FullAdder(
	input A,
	input B,
	input Cin,
	output Sum,
	output Cout
);

	assign Sum = (A & ~B | ~A & B) & ~Cin | ~(A & ~B | ~A & B) & Cin;
	assign Cout = A & B | A & Cin | B & Cin | A & B & Cin;

endmodule
