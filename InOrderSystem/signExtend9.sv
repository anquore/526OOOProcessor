module signExtend9(valueIn, extendedOut);
	input logic [8:0] valueIn;
	output logic [63:0] extendedOut;
	
	logic [54:0] inBetween;
	//copy the bottom bits
	assign extendedOut[8:0] = valueIn[8:0];
	assign extendedOut[63:9] = inBetween[54:0];
	integer i;
	
	always_comb begin
		for(i=0; i<55; i++) begin
			inBetween[i] = valueIn[8];
		end
	end
endmodule

module signExtend9_testbench();
	logic [8:0] valueIn;
	logic [63:0] extendedOut;

	signExtend9 dut (.valueIn, .extendedOut);

	initial begin
		valueIn = 14736; #10;
		valueIn = -14736; #10;
		valueIn = 0; #10;
	end
endmodule 