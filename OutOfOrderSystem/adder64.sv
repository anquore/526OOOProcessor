module adder64 (val1, val2, valOut);
	input logic [63:0] val1, val2;
	output logic [63:0] valOut; 
	
	logic [63:0] cinToCout;
	genvar i;
	//generate the top 63 full adders to calculate the result
	generate
		for(i=0; i<63; i++) begin : eachAdder
			fullAdder adder(.a(val1[i+1]), .b(val2[i+1]), .cin(cinToCout[i]), .cout(cinToCout[i+1]), .sum(valOut[i+1]));
		end
	endgenerate
	
	//create the starting addSlice
	fullAdder startAdder (.a(val1[0]), .b(val2[0]), .cin(1'b0), .cout(cinToCout[0]), .sum(valOut[0]));
endmodule

/*
module adder64_testbench();
	logic[63:0] val1, val2;
	logic [63:0] valOut; 

	adder64 dut (.val1, .val2, .valOut);

	integer i;
	initial begin
		//general random testing
		for (i=0; i<100; i++) begin
			val1 = $random(); val2 = $random();
			#(1000);
			assert(valOut == (val1+val2));
		end
		
		//special cases
		val1 = 0; val2 = 0;
		#(1000);
		assert(valOut == (val1+val2));
		val1 = 64'h8000000000000000; val2 = 64'hffffffffffff4ab3;
		#(1000);
		assert(valOut == (val1+val2));
		val1 = 64'h7fffffffffffffff; val2 = 64'h00111111;
		#(1000);
		assert(valOut == (val1+val2));
		val1 = 64'hffffffffffffffff; val2 = 1;
		#(1000);
		assert(valOut == (val1+val2));
		val1 = 64'h2dab324f789f34ff; val2 = -val1;
		#(1000);
		assert(valOut == (val1+val2));
	end
endmodule */

