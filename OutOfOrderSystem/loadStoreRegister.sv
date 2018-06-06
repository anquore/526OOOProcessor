//reg structure: LoadStore (load 1, store 0)[200], valid_PC[199], PC (64 bit)[198:135], ROBid (5 bit) [134:130], valid_addr[129], addr (64 bit)[128:65], valid_val[64], val (64 bit)[63:0]

module loadStoreRegister(out, newIn, enNew, addrIn, enAddr, valIn, enVal, reset, clk);
	output logic [200:0] out;
	input logic [70:0] newIn;
	input logic enNew;
	input logic [64:0] addrIn;
	input logic enAddr;
	input logic [64:0] valIn;
	input logic enVal;
	input logic reset, clk;
	
	wallOfDFFsX71 regNew(.q(out[200:130]), .d(newIn), .enable(enNew), .reset, .clk);
	wallOfDFFsX65 regAddr(.q(out[129:65]), .d(addrIn), .enable(enAddr), .reset, .clk);
	wallOfDFFsX65 regVal(.q(out[64:0]), .d(valIn), .enable(enVal), .reset, .clk);
endmodule

