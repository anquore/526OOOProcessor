module signExtend26(valueIn, extendedOut);
	input logic [25:0] valueIn;
	output logic [63:0] extendedOut;
	
	logic [37:0] inBetween;
	//copy the bottom bits
	assign extendedOut[25:0] = valueIn[25:0];
	assign extendedOut[63:26] = inBetween[37:0];
	integer i;
	
	always_comb begin
		for(i=0; i<38; i++) begin
			inBetween[i] = valueIn[25];
		end
	end
endmodule

module signExtend26_testbench();
	logic [25:0] valueIn;
	logic [63:0] extendedOut;

	signExtend26 dut (.valueIn, .extendedOut);

	initial begin
		valueIn = 14736; #10;
		valueIn = -514736; #10;
		valueIn = 0; #10;
	end
endmodule 