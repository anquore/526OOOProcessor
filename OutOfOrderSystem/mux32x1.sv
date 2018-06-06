module mux32x1(out, addr, muxIns);
	output logic out;
	input logic [4:0] addr;
	input logic [31:0] muxIns;

	logic [1:0] midVal;
	
	//using 2 16x1 muxes and a 2x1 mux, construct a 32x1 mux
	mux16x1 mux16to31(.out(midVal[1]), .addr(addr[3:0]), .muxIns(muxIns[31:16]));
	mux16x1 mux0to15(.out(midVal[0]), .addr(addr[3:0]), .muxIns(muxIns[15:0]));
	mux2_1 muxFinal(.out, .i0(midVal[0]), .i1(midVal[1]), .sel(addr[4]));
endmodule

/*
module mux32x1_testbench();
	logic [31:0] muxIns;
	logic [4:0] addr;
	logic out;

	mux32x1 dut (.out, .addr, .muxIns);

	integer i;
	initial begin
		for(i=0; i<12048576; i++) begin
			{muxIns, addr} = i; #1000;
		end
	end
endmodule */

