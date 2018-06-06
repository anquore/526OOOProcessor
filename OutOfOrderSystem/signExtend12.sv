module signExtend12(valueIn, extendedOut);
	input logic [11:0] valueIn;
	output logic [63:0] extendedOut;
	
	logic [51:0] inBetween;
	//copy the bottom bits
	assign extendedOut[11:0] = valueIn[11:0];
	assign extendedOut[63:12] = inBetween[51:0];
	integer i;
	
	always_comb begin
		for(i=0; i<52; i++) begin
			inBetween[i] = valueIn[11];
		end
	end
endmodule

/*
module signExtend12_testbench();
	logic [11:0] valueIn;
	logic [63:0] extendedOut;

	signExtend12 dut (.valueIn, .extendedOut);

	initial begin
		valueIn = 14736; #10;
		valueIn = -14736; #10;
		valueIn = 0; #10;
	end
endmodule */

