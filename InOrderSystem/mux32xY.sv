`timescale 1ns/10ps
module mux32xY #(parameter Y = 64) (out, addr, muxIns);
	output logic [Y-1:0] out;
	input logic [Y-1:0][31:0] muxIns;
	input logic [4:0] addr;
	
	genvar i;
	
	//generate a collection of 64 different 32x1 muxes
	generate
		for(i=0; i<Y; i++) begin : eachBigMux
			mux32x1 bigMux (.out(out[i]), .addr, .muxIns(muxIns[i][31:0]));
		end
	endgenerate 
endmodule