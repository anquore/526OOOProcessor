`timescale 1ns/10ps
module decoder2x4 (decoded, addr, enable);
	output logic [3:0] decoded;
	input logic [1:0] addr;
	input logic enable;
	
	logic [1:0] notAddr;
	
	//when enable is true, set the correct output wire high based on the address
	not #5 flipAddr0 (notAddr[0], addr[0]);
	not #5 flipAddr1 (notAddr[1], addr[1]);	
	and #5 d3(decoded[3], enable, addr[1], addr[0]);
	and #5 d2(decoded[2], enable, addr[1], notAddr[0]);
	and #5 d1(decoded[1], enable, notAddr[1], addr[0]);
	and #5 d0(decoded[0], enable, notAddr[1], notAddr[0]);
endmodule

module decoder2x4_testbench();
	logic [3:0] decoded;
	//logic [1:0] addr;
	//logic enable;
	
	logic [2:0] allInputs;

	decoder2x4 dut (.decoded, .addr(allInputs[1:0]), .enable(allInputs[2]));

	// Try all combinations of inputs.
	integer i;
	initial begin
		for(i = 0; i <8; i++) begin
			allInputs[2:0] = i; #100;
		end
	end
endmodule