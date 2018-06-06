//5 nand

module NAND_MUX_4x1(out, select, invSelect, in);
	output out;
	input [1:0] select, invSelect;
	input [3:0] in;
	wire three, two, one, zero;
	
	nand zeroNand(zero, in[0], invSelect[1], invSelect[0]);
	nand oneNand(one, in[1], invSelect[1], select[0]);
	nand twoNand(two, in[2], select[1], invSelect[0]);
	nand threeNand(three, in[3], select[1], select[0]);

	nand sumNand(out, three, two, one, zero);
endmodule

/*
module NAND_MUX_4x1_testbench;
	wire out;
	reg [1:0] selects;
	wire [1:0] invSelects;
	reg [3:0] ins;
	assign invSelects = ~selects;
	NAND_MUX_4x1 dut(.out, .select(selects), .invSelect(invSelects), .in(ins));
	
	initial begin
	selects[1:0] = 2'b00;
	ins[3:0] = 4'b0101;
	#200;
	selects[1:0] = 2'b01;
	#200;
	selects[1:0] = 2'b10;
	#200;
	selects[1:0] = 2'b11;
	#200;
	ins[3:0] = 4'b1010;
	#200;
	end
endmodule */

