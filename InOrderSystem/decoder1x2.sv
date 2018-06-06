`timescale 1ns/10ps
module decoder1x2 (decoded, addr, enable);
	output logic [1:0] decoded;
	input logic addr, enable;
	
	logic notAddr;
	
	//when enable is true, set the correct output wire high based on the address
	not #5 flipAddr0 (notAddr, addr);
	and #5 d1(decoded[1], enable, addr);
	and #5 d0(decoded[0], enable, notAddr);
endmodule

module decoder1x2_testbench();
	logic [1:0] decoded;
	//logic [1:0] addr;
	//logic enable;
	
	logic [1:0] allInputs;

	decoder1x2 dut (.decoded, .addr(allInputs[0]), .enable(allInputs[1]));

	// Try all combinations of inputs.
	integer i;
	initial begin
		for(i = 0; i <4; i++) begin
			allInputs[1:0] = i; #100;
		end
	end
endmodule