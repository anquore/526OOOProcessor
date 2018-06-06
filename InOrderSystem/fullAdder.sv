`timescale 1ns/10ps
module fullAdder(a, b, cin, cout, sum);
	input logic a, b, cin;
	output logic cout, sum;
	
	logic inBetween[2:0];
	
	//calculate the sum
	xor #5 findSum(sum, a, b, cin);
	
	//calculate the carry out
	and #5 input0(inBetween[0], a, b);
	and #5 input1(inBetween[1], a, cin);
	and #5 input2(inBetween[2], b, cin);
	or #5 theOutput(cout, inBetween[0], inBetween[1], inBetween[2]);
endmodule

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
endmodule 