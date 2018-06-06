module bitSlice(a, b, cin, addr, cout, bitVal);
	input logic a, b, cin;
	input logic [2:0] addr;
	output logic cout, bitVal;
	
	logic flipB, sendToFullAdder, fAdderToMux, andToMux, orToMux, xorToMux; 
	
	//create a mux to control subtract vs add
	not aNot (flipB, b);
	mux2_1 addSub (.out(sendToFullAdder), .i0(b), .i1(flipB), .sel(addr[0]));
	
	//plug values into the full adder
	fullAdder theAdder(.a, .b(sendToFullAdder), .cin, .cout, .sum(fAdderToMux));
	
	//do the three gate values
	and theAnd (andToMux, a, b);
	or theOr(orToMux, a, b);
	xor theXor(xorToMux, a, b);
	
	logic [7:0] muxIns;
	
	//link the values to muxIns
	always_comb begin
		muxIns[7] = 1'b0;
		muxIns[6] = xorToMux;
		muxIns[5] = orToMux;
		muxIns[4] = andToMux;
		muxIns[3] = fAdderToMux;
		muxIns[2] = fAdderToMux;
		muxIns[1] = 1'b0;
		muxIns[0] = b;
	end
	
	//link all the bits to a mux to determine which should be sent out
	mux8x1 outputMux (.out(bitVal), .addr, .muxIns);
endmodule

/*
module bitSlice_testbench();
	logic a, b, cin;
	logic [2:0] addr;
	logic cout, bitVal;

	bitSlice dut (.a, .b, .cin, .addr, .cout, .bitVal);

	integer i;
	initial begin
		for(i=0; i<64; i++) begin
			{addr, a, b, cin} = i; #1000;
		end
	end
endmodule */

