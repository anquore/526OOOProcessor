//3 nand

module NAND_MUX_2x1(out, select, invSelect, in);
	output out;
	input select, invSelect;
	input [1:0] in;
	wire one, zero;
	
	nand oneNand(one, select, in[1]);
	nand zeroNand(zero, invSelect, in[0]);
	
	nand sumNand(out, one, zero);
endmodule

module NAND_MUX_2x1_testbench;
	wire out;
	reg select;
	wire invSelect;
	reg [1:0] ins;
	assign invSelect=~select;
	NAND_MUX_2x1 dut(.out, .select, .invSelect, .in(ins));
	
	initial begin
	select=0;
	ins[1:0] = 2'b00;
	#200;
	ins[1:0] = 2'b01;
	#200;
	select=1;
	#200;
	ins[1:0] = 2'b11;
	#200;
	select=0;
	#200;
	end
endmodule
