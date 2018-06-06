`timescale 1ns/10ps
module instructionFetch(clk, reset, uncondBr, brTaken, BRMI, regPC, instrToRead, instruction, address, enablePC);
	input logic clk, reset, uncondBr, brTaken, BRMI, enablePC;
	input logic [63:0] regPC;
	input logic [31:0] instrToRead;
	output logic [31:0] instruction;
	output logic [63:0] address;
	
	logic [63:0] newAddress, value19Extend, value26Extend;
	
	//the instruction memory
	instructmem instrMem(.address, .instruction, .clk);
	
	//PC value
	individualReg64 PC(.q(address), .d(newAddress), .reset, .enable(enablePC), .clk);
	
	//sign extenders
	signExtend19 extend19(.valueIn(instrToRead[23:5]), .extendedOut(value19Extend));
	signExtend26 extend26(.valueIn(instrToRead[25:0]), .extendedOut(value26Extend));
	
	//rearrange values to send to mux
	logic [63:0][1:0] extendDataToMux;
	integer i, j;
	always_comb begin
		for(i=0; i<64; i++) begin
			extendDataToMux[i][0] = value19Extend[i];
		end
		for(j=0; j<64; j++) begin
			extendDataToMux[j][1] = value26Extend[j];
		end
	end
	
	//choose between the two sign extends
	logic [63:0] toShifter;
	mux2x64 extendMux (.out(toShifter), .addr(uncondBr), .muxIns(extendDataToMux));
	
	//shift the value left by 2
	logic [63:0] shifted;
	shiftLeft2 datShift (.unShifted(toShifter), .shifted);
	
	//get the old PC value
	logic [63:0] oldAddress;
	adder64 getOld (.val1(address), .val2(64'hfffffffffffffffc), .valOut(oldAddress));
	
	//add shifted value to the address
	logic [63:0] branchAddress;
	adder64 branchAdder (.val1(oldAddress), .val2(shifted), .valOut(branchAddress));
	
	//add four to the address
	logic [63:0] basicAddress;
	adder64 basicAdder (.val1(address), .val2(64'd4), .valOut(basicAddress));
	
	//choose between the two new addresses
	logic [63:0][1:0] newAddressToDo;
	logic [63:0] couldBeNewAddress; 
	integer k, l;
	always_comb begin
		for(k=0; k<64; k++) begin
			newAddressToDo[k][0] = basicAddress[k];
		end
		for(l=0; l<64; l++) begin
			newAddressToDo[l][1] = branchAddress[l];
		end
	end
	mux2x64 adderBranchesMux (.out(couldBeNewAddress), .addr(brTaken), .muxIns(newAddressToDo));
	
	//decide if one of the calculated values should be used or a reg value
	logic [63:0][1:0] finalNewAddressToDo; 
	integer m, n;
	always_comb begin
		for(m=0; m<64; m++) begin
			finalNewAddressToDo[m][0] = couldBeNewAddress[m];
		end
		for(n=0; n<64; n++) begin
			finalNewAddressToDo[n][1] = regPC[n];
		end
	end
	mux2x64 finalChoiceMux (.out(newAddress), .addr(BRMI), .muxIns(finalNewAddressToDo));	
endmodule

module instructionFetch_testbench();
	logic clk, reset, uncondBr, brTaken, BRMI;
	logic [63:0] regPC;
	logic [31:0] instruction;
	logic [63:0] basicAddress;

	instructionFetch dut (.clk, .reset, .uncondBr, .brTaken, .BRMI, .regPC, .instruction, .basicAddress);

	// Set up the clock
	parameter ClockDelay = 1000;
	initial begin ;
		clk <= 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end
	
	initial begin
	uncondBr <= 0;	brTaken <= 0; BRMI <= 0;
				reset <= 1; 	@(posedge clk);
				reset <= 0; 	@(posedge clk);
									@(posedge clk);
									@(posedge clk);
									@(posedge clk);
									@(posedge clk);
				brTaken <= 1;	@(posedge clk);
									@(posedge clk);
									@(posedge clk);				
				
		$stop(); // end the simulation
	end
endmodule