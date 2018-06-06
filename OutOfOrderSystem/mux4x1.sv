module mux4x1(out, addr, muxIns);
	output logic out;
	input logic [1:0] addr;
	input logic [3:0] muxIns;

	logic [1:0] midVal;
	
	//using 3 2x1 muxes, construct a 4x1 mux
	mux2_1 m0(.out(midVal[0]), .i0(muxIns[0]), .i1(muxIns[1]), .sel(addr[0]));
	mux2_1 m1(.out(midVal[1]), .i0(muxIns[2]), .i1(muxIns[3]), .sel(addr[0]));
	mux2_1 m (.out, .i0(midVal[0]), .i1(midVal[1]), .sel(addr[1]));
endmodule

/*
module mux4x1_testbench();
	logic [3:0] muxIns;
	logic [1:0] addr;
	logic out;

	mux4x1 dut (.out, .addr, .muxIns);

	integer i;
	initial begin
		for(i=0; i<64; i++) begin
			{muxIns, addr} = i; #100;
		end
	end
endmodule */

