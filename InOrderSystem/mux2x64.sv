`timescale 1ns/10ps
module mux2x64(out, addr, muxIns);
	output logic [63:0] out;
	input logic [63:0][1:0] muxIns;
	input logic addr;
	
	genvar i;
	
	//generate a collection of 64 different 32x1 muxes
	generate
		for(i=0; i<64; i++) begin : eachSmallMux
			mux2_1 smallMux (.out(out[i]), .i0(muxIns[i][0]), .i1(muxIns[i][1]), .sel(addr));
		end
	endgenerate 
endmodule

module mux2x64_testbench();
	logic [63:0][1:0] muxIns;
	logic addr;
	logic [63:0] out;

	mux2x64 dut (.out, .addr, .muxIns);

	integer i;
	initial begin
		for(i=0; i<64; i++) begin
			muxIns[i][0] = 0; #1000;
		end
		for(i=0; i<64; i++) begin
			muxIns[i][1] = 1; #1000;
		end
		addr = 0; #1000;
		addr = 1; #1000;
		#10;
	end
endmodule 