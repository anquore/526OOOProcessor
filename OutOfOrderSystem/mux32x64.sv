module mux32x64(out, addr, muxIns);
	output logic [63:0] out;
	input logic [63:0][31:0] muxIns;
	input logic [4:0] addr;
	
	genvar i;
	
	//generate a collection of 64 different 32x1 muxes
	generate
		for(i=0; i<64; i++) begin : eachBigMux
			mux32x1 bigMux (.out(out[i]), .addr, .muxIns(muxIns[i][31:0]));
		end
	endgenerate 
endmodule

/*
module mux32x64_testbench();
	logic [63:0][31:0] muxIns;
	logic [4:0] addr;
	logic [63:0] out;

	mux32x64 dut (.out, .addr, .muxIns);

	integer i;
	initial begin
		for(i=0; i<32; i++) begin
			muxIns[2*i][31:0] = 16'h0; #1000;
		end
		for(i=0; i<32; i++) begin
			muxIns[2*i + 1][31:0] = 16'hffff; #1000;
		end
		addr = 0; #1000;
		addr = 1; #1000;
		addr = 2; #1000;
		addr = 30; #1000;
		addr = 31; #1000;
		#10;
	end
endmodule */

