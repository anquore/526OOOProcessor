module fullAdder(a, b, cin, cout, sum);
	input logic a, b, cin;
	output logic cout, sum;
	
	logic inBetween[2:0];
	
	//calculate the sum
	xor findSum(sum, a, b, cin);
	
	//calculate the carry out
	and input0(inBetween[0], a, b);
	and input1(inBetween[1], a, cin);
	and input2(inBetween[2], b, cin);
	or theOutput(cout, inBetween[0], inBetween[1], inBetween[2]);
endmodule

/*
module fullAdder_testbench();
	logic a, b, cin;
	logic cout, sum;

	fullAdder dut (.a, .b, .cin, .cout, .sum);

	integer i;
	initial begin
		for(i=0; i<8; i++) begin
			{a, b, cin} = i; #1000;
		end
	end
endmodule */

