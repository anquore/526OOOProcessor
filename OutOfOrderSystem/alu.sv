module alu(A, B, cntrl, result, negative, zero, overflow, carry_out);
	input logic [63:0] A, B;
	input logic	[2:0] cntrl;
	output logic [63:0] result;
	output logic negative, zero, overflow, carry_out;
	
	logic [62:0] cinToCout;
	
	genvar i;
	
	//generate the middle 62 bitSlices to calculate most of the result
	generate
		for(i=0; i<62; i++) begin : eachSlice
			bitSlice slice (.a(A[i+1]), .b(B[i+1]), .cin(cinToCout[i]), .addr(cntrl), .cout(cinToCout[i+1]), .bitVal(result[i+1]));
		end
	endgenerate 
	
	//create the starting bitSlice
	bitSlice startSlice (.a(A[0]), .b(B[0]), .cin(cntrl[0]), .addr(cntrl), .cout(cinToCout[0]), .bitVal(result[0]));
	
	//create the ending slice
	bitSlice endSlice (.a(A[63]), .b(B[63]), .cin(cinToCout[62]), .addr(cntrl), .cout(carry_out), .bitVal(result[63]));
	
	//link up the remaining flags
	assign negative = result[63];
	xor (overflow, cinToCout[62], carry_out);
	
	logic [3:0] norIns;
	
	//determine if the value is zero using with a 64 input nor gate, made out of 4 16 bit or gates, and a 4 bit nor gate
	orGate16 bigOr0 (.inVals(result[15:0]), .outVal(norIns[0]));
	orGate16 bigOr1 (.inVals(result[31:16]), .outVal(norIns[1]));
	orGate16 bigOr2 (.inVals(result[47:32]), .outVal(norIns[2]));
	orGate16 bigOr3 (.inVals(result[63:48]), .outVal(norIns[3]));
	nor aNor (zero, norIns[3], norIns[2], norIns[1], norIns[0]);
endmodule

// Test bench for ALU

// Meaning of signals in and out of the ALU:

// Flags:
// negative: whether the result output is negative if interpreted as 2's comp.
// zero: whether the result output was a 64-bit zero.
// overflow: on an add or subtract, whether the computation overflowed if the inputs are interpreted as 2's comp.
// carry_out: on an add or subtract, whether the computation produced a carry-out.

// cntrl			Operation						Notes:
// 000:			result = B						value of overflow and carry_out unimportant
// 010:			result = A + B
// 011:			result = A - B
// 100:			result = bitwise A & B		value of overflow and carry_out unimportant
// 101:			result = bitwise A | B		value of overflow and carry_out unimportant
// 110:			result = bitwise A XOR B	value of overflow and carry_out unimportant

/*
module alustim();

	parameter delay = 100000;

	logic		[63:0]	A, B;
	logic		[2:0]		cntrl;
	logic		[63:0]	result;
	logic					negative, zero, overflow, carry_out ;

	parameter ALU_PASS_B=3'b000, ALU_ADD=3'b010, ALU_SUBTRACT=3'b011, ALU_AND=3'b100, ALU_OR=3'b101, ALU_XOR=3'b110;
	

	alu dut (.A, .B, .cntrl, .result, .negative, .zero, .overflow, .carry_out);

	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);

	integer i;
	logic [63:0] test_val;
	initial begin
	
		$display("%t testing PASS_B operations", $time);
		cntrl = ALU_PASS_B;
		
		//general random testing
		for (i=0; i<100; i++) begin
			A = $random(); B = $random();
			#(delay);
			assert(result == B && negative == B[63] && zero == (B == '0));
		end
		
		//special cases
		B = 0; #(delay);
		assert(result == B && negative == B[63] && zero == (B == '0));
		
		$display("%t testing addition", $time);
		cntrl = ALU_ADD;
		
		//general random testing
		for (i=0; i<100; i++) begin
			A = $random(); B = $random();
			#(delay);
			assert(result == (A+B) && negative == result[63] && zero == (result == '0));
		end
		
		//special cases
		A = 0; B = 0;
		#(delay);
		assert(result == (A+B) && negative == result[63] && zero == (result == '0));
		A = 64'h8000000000000000; B = 64'hffffffffffff4ab3;
		#(delay);
		assert(result == (A+B) && negative == result[63] && zero == (result == '0));
		A = 64'h7fffffffffffffff; B = 64'h00111111;
		#(delay);
		assert(result == (A+B) && negative == result[63] && zero == (result == '0));
		A = 64'hffffffffffffffff; B = 1;
		#(delay);
		assert(result == (A+B) && negative == result[63] && zero == (result == '0));
		A = 64'h2dab324f789f34ff; B = -A;
		#(delay);
		assert(result == (A+B) && negative == result[63] && zero == (result == '0));
		
		//assert(result == 64'h0000000000000002 && carry_out == 0 && overflow == 0 && negative == 0 && zero == 0);
		
		$display("%t testing subtraction", $time);
		cntrl = ALU_SUBTRACT;
		
		//general random testing
		for (i=0; i<100; i++) begin
			A = $random(); B = $random();
			#(delay);
			assert(result == (A-B) && negative == result[63] && zero == (result == '0));
		end
		
		//special cases
		A = 0; B = 0;
		#(delay);
		assert(result == (A-B) && negative == result[63] && zero == (result == '0));
		A = 64'h45bde73621; B = A;
		#(delay);
		assert(result == (A-B) && negative == result[63] && zero == (result == '0));
		A = 64'h8000000000000000; B = 64'h00111111;
		#(delay);
		assert(result == (A-B) && negative == result[63] && zero == (result == '0));
		A = 64'h7fffffffffffffff; B = 64'hffffffffffff4ab3;
		#(delay);
		assert(result == (A-B) && negative == result[63] && zero == (result == '0));
		A = 64'h2dab324f789f34ff; B = A;
		#(delay);
		assert(result == (A-B) && negative == result[63] && zero == (result == '0));
		
		//assert(result == 64'h0000000000000002 && carry_out == 0 && overflow == 0 && negative == 0 && zero == 0);
		
		$display("%t testing anding", $time);
		cntrl = ALU_AND;
		
		//general random testing
		for (i=0; i<100; i++) begin
			A = $random(); B = $random();
			#(delay);
			assert(result == (A&B) && negative == result[63] && zero == (result == '0));
		end
		
		//special cases
		A = 0; B = 0;
		#(delay);
		assert(result == (A&B) && negative == result[63] && zero == (result == '0));
		A = 64'hffffffffffffffff; B = A;
		#(delay);
		assert(result == (A&B) && negative == result[63] && zero == (result == '0));
		A = 64'hffffffffffffffff; B = 0;
		#(delay);
		assert(result == (A&B) && negative == result[63] && zero == (result == '0));
		
		$display("%t testing oring", $time);
		cntrl = ALU_OR;
		
		//general random testing
		for (i=0; i<100; i++) begin
			A = $random(); B = $random();
			#(delay);
			assert(result == (A|B) && negative == result[63] && zero == (result == '0));
		end
		
		//special cases
		A = 0; B = 0;
		#(delay);
		assert(result == (A|B) && negative == result[63] && zero == (result == '0));
		A = 64'hffffffffffffffff; B = A;
		#(delay);
		assert(result == (A|B) && negative == result[63] && zero == (result == '0));
		A = 64'hffffffffffffffff; B = 0;
		#(delay);
		assert(result == (A|B) && negative == result[63] && zero == (result == '0));
		
		$display("%t testing xoring", $time);
		cntrl = ALU_XOR;
		
		//general random testing
		for (i=0; i<100; i++) begin
			A = $random(); B = $random();
			#(delay);
			assert(result == (A^B) && negative == result[63] && zero == (result == '0));
		end
		
		//special cases
		A = 0; B = 0;
		#(delay);
		assert(result == (A^B) && negative == result[63] && zero == (result == '0));
		A = 64'hffffffffffffffff; B = A;
		#(delay);
		assert(result == (A^B) && negative == result[63] && zero == (result == '0));
		A = 64'hffffffffffffffff; B = 0;
		#(delay);
		assert(result == (A^B) && negative == result[63] && zero == (result == '0));
		
	end
endmodule */

