`timescale 1ns/10ps
module decoder4x16 (decoded, addr, enable);
	output logic [15:0] decoded;
	input logic [3:0] addr;
	input logic enable;
	
	logic [3:0] middleEn;
	
	//using five 2x4 decoders, construct the larger 4x16
	decoder2x4 leadD(.decoded(middleEn[3:0]), .addr(addr[3:2]), .enable);
	decoder2x4 lines12to15(.decoded(decoded[15:12]), .addr(addr[1:0]), .enable(middleEn[3]));
	decoder2x4 lines8to11(.decoded(decoded[11:8]), .addr(addr[1:0]), .enable(middleEn[2]));
	decoder2x4 lines4to7(.decoded(decoded[7:4]), .addr(addr[1:0]), .enable(middleEn[1]));
	decoder2x4 lines0to(.decoded(decoded[3:0]), .addr(addr[1:0]), .enable(middleEn[0]));
endmodule

module decoder4x16_testbench();
	logic [15:0] decoded;
	//logic [1:0] addr;
	//logic enable;
	
	logic [4:0] allInputs;

	decoder4x16 dut (.decoded, .addr(allInputs[3:0]), .enable(allInputs[4]));

	// Try all combinations of inputs.
	integer i;
	initial begin
		for(i = 0; i <32; i++) begin
			allInputs[4:0] = i; #1000;
		end
	end
endmodule