module orGate16 (inVals, outVal);
	input logic [15:0] inVals;
	output logic outVal;
	
	logic [3:0] inBetween;
	
	//the ors
	or or0 (inBetween[0], inVals[3], inVals[2], inVals[1], inVals[0]);
	or or1 (inBetween[1], inVals[7], inVals[6], inVals[5], inVals[4]);
	or or2 (inBetween[2], inVals[11], inVals[10], inVals[9], inVals[8]);
	or or3 (inBetween[3], inVals[15], inVals[14], inVals[13], inVals[12]);
	or or4 (outVal, inBetween[3], inBetween[2], inBetween[1], inBetween[0]);
endmodule

/*
module orGate16_testbench();
	logic [15:0] inVals;
	logic outVal;

	orGate16 dut (.inVals, .outVal);

	integer i;
	initial begin
		for(i=0; i<65536; i++) begin
			{inVals} = i; #1000;
		end
	end
endmodule */

