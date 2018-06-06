`timescale 1ns/10ps
module decoder5x32 (decoded, addr, enable);
	output logic [31:0] decoded;
	input logic [4:0] addr;
	input logic enable;
	
	logic [1:0] middleEn;
	
	//using two 4x16 decoders and a 1x2 decoder, construct the larger 5x32
	decoder1x2 leadD(.decoded(middleEn[1:0]), .addr(addr[4]), .enable);
	decoder4x16 lines16to31(.decoded(decoded[31:16]), .addr(addr[3:0]), .enable(middleEn[1]));
	decoder4x16 lines0to15(.decoded(decoded[15:0]), .addr(addr[3:0]), .enable(middleEn[0]));
endmodule

module decoder5x32_testbench();
	logic [31:0] decoded;
	//logic [1:0] addr;
	//logic enable;
	
	logic [5:0] allInputs;

	decoder5x32 dut (.decoded, .addr(allInputs[4:0]), .enable(allInputs[5]));

	// Try all combinations of inputs.
	integer i;
	initial begin
		for(i = 0; i <64; i++) begin
			allInputs[5:0] = i; #1000;
		end
	end
endmodule