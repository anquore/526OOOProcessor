module shiftLeft2 (unShifted, shifted);
	input logic [63:0] unShifted;
	output logic [63:0] shifted;
	
	//do the shift
	assign shifted[63:2] = unShifted[61:0];
	assign shifted[1:0] = 2'b00;
endmodule

module shiftLeft2_testbench();
	logic [63:0] unShifted;
	logic [63:0] shifted;

	 shiftLeft2 dut (.unShifted, .shifted);

	integer i;
	initial begin
		unShifted = 64'h34ce589123be64ac; #10;
	end
endmodule 