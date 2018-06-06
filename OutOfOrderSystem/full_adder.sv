//4 nand, 1 xor

module full_adder(S, Cout, A, B, Cin);
	output S, Cout;
	input A, B, Cin;
	wire AB, AC, BC;
	
	//sum
	xor sum(S, A, B, Cin);
	
	//carry
	nand ab(AB, A, B);
	nand ac(AC, A, Cin);
	nand bc(BC, B, Cin);
	nand abc(Cout, AB, AC, BC);
endmodule

/*
module full_adder_testbench;
	wire S, Cout;
	reg A, B, Cin;
	full_adder DUT(.S, .Cout, .A, .B, .Cin);
	
	initial begin
		A = 0;	B = 0;	Cin = 0;
		#250;
		A = 1;
		#250;
		A = 0;	B = 1;
		#250;
					B = 0;	Cin=1;
		#250;
		A = 1;	B = 1;	Cin = 0;
		#250;
					B = 0;	Cin = 1;
		#250;
		A = 0;	B = 1;
		#250;
		A = 1;
		#250;
	end
endmodule */

