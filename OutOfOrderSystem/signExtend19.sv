module signExtend19(valueIn, extendedOut);
	input logic [18:0] valueIn;
	output logic [63:0] extendedOut;
	
	logic [44:0] inBetween;
	//copy the bottom bits
	assign extendedOut[18:0] = valueIn[18:0];
	assign extendedOut[63:19] = inBetween[44:0];
	integer i;
	
	always_comb begin
		for(i=0; i<45; i++) begin
			inBetween[i] = valueIn[18];
		end
	end
endmodule

/*
module signExtend19_testbench();
	logic [18:0] valueIn;
	logic [63:0] extendedOut;

	signExtend19 dut (.valueIn, .extendedOut);

	initial begin
		valueIn = 14736; #10;
		valueIn = -14736; #10;
		valueIn = 0; #10;
	end
endmodule */

