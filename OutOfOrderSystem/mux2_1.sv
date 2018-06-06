module mux2_1(out, i0, i1, sel);
	output logic out;
	input logic i0, i1, sel;
 
	logic [2:0] inBetween;

	//assign out = (i1 & sel) | (i0 & ~sel);
	not flipSel (inBetween[0], sel);
	and input0 (inBetween[1], i0, inBetween[0]);
	and input1 (inBetween[2], i1, sel);
	or theOutput (out, inBetween[1], inBetween[2]);
endmodule

/*
module mux2_1_testbench();
	logic i0, i1, sel;
	logic out;

	mux2_1 dut (.out, .i0, .i1, .sel);

	 initial begin
		 sel=0; i0=0; i1=0; #100;
		 sel=0; i0=0; i1=1; #100;
		 sel=0; i0=1; i1=0; #100;
		 sel=0; i0=1; i1=1; #100;
		 sel=1; i0=0; i1=0; #100;
		 sel=1; i0=0; i1=1; #100;
		 sel=1; i0=1; i1=0; #100;
		 sel=1; i0=1; i1=1; #100;
	 end
endmodule */

