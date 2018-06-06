module adderC65 (val1, val2, Cin, valOut);
	input logic [64:0] val1, val2;
	input logic Cin;
	output logic [64:0] valOut; 
	
	logic [64:0] cinToCout;
	genvar i;
	//generate the top 63 full adders to calculate the result
	generate
		for(i=0; i<64; i++) begin : eachAdder
			full_adder adder(.S(valOut[i+1]), .Cout(cinToCout[i+1]), .A(val1[i+1]), .B(val2[i+1]), .Cin(cinToCout[i]));
		end
	endgenerate
	
	//create the starting addSlice
	full_adder startAdder(.S(valOut[0]), .Cout(cinToCout[0]), .A(val1[0]), .B(val2[0]), .Cin);
endmodule

module adderC64_testbench();
	logic[63:0] val1, val2;
	logic [63:0] valOut; 
	logic Cin;

	adderC65 dut (.val1, .val2, .Cin, .valOut);

	integer i;
	initial begin
		//general random testing
		Cin=1'b0;
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
endmodule 
