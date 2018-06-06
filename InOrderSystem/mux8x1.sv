`timescale 1ns/10ps
module mux8x1(out, addr, muxIns);
	output logic out;
	input logic [2:0] addr;
	input logic [7:0] muxIns;

	logic [1:0] midVal;
	
	//using 2 4x1 muxes and a 2x1 mux, construct a 8x1 mux
	mux4x1 mux4to7(.out(midVal[1]), .addr(addr[1:0]), .muxIns(muxIns[7:4]));
	mux4x1 mux0to3(.out(midVal[0]), .addr(addr[1:0]), .muxIns(muxIns[3:0]));
	mux2_1 muxFinal(.out, .i0(midVal[0]), .i1(midVal[1]), .sel(addr[2]));
endmodule

module mux8x1_testbench();
	logic [7:0] muxIns;
	logic [2:0] addr;
	logic out;

	mux8x1 dut (.out, .addr, .muxIns);

	integer i;
	initial begin
		for(i=0; i<2048; i++) begin
			{muxIns, addr} = i; #1000;
		end
	end
endmodule 