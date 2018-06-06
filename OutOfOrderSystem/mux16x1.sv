module mux16x1(out, addr, muxIns);
	output logic out;
	input logic [3:0] addr;
	input logic [15:0] muxIns;

	logic [3:0] midVal;
	
	//using 5 4x1 muxes, construct a 16x1 mux
	mux4x1 mux12to15(.out(midVal[3]), .addr(addr[1:0]), .muxIns(muxIns[15:12]));
	mux4x1 mux8to11(.out(midVal[2]), .addr(addr[1:0]), .muxIns(muxIns[11:8]));
	mux4x1 mux4to7(.out(midVal[1]), .addr(addr[1:0]), .muxIns(muxIns[7:4]));
	mux4x1 mux0to3(.out(midVal[0]), .addr(addr[1:0]), .muxIns(muxIns[3:0]));
	mux4x1 muxFinal(.out, .addr(addr[3:2]), .muxIns(midVal[3:0]));
endmodule

/*
module mux16x1_testbench();
	logic [15:0] muxIns;
	logic [3:0] addr;
	logic out;

	mux16x1 dut (.out, .addr, .muxIns);

	integer i;
	initial begin
		for(i=0; i<1048576; i++) begin
			{muxIns, addr} = i; #1000;
		end
	end
endmodule */

