module instructionFetch(clk, reset, uncondBr, brTaken, BRMI, regPC, instrToRead, instruction, address, enablePC, needToRestore_i, restorePoint_i
,imem_address_o
,imem_instruction_i
,couldBeNewAddress_o);
	input logic clk, reset, uncondBr, brTaken, BRMI, enablePC, needToRestore_i;
	input logic [63:0] regPC;
	input logic [31:0] instrToRead, imem_instruction_i;
  input logic [63:0] restorePoint_i;
	output logic [31:0] instruction;
	output logic [63:0] address, imem_address_o, couldBeNewAddress_o;
	
	logic [63:0] newAddress, newAddress1, value19Extend, value26Extend;
	
	//the instruction memory
  assign instruction = imem_instruction_i;
  assign imem_address_o = address;
	//instructmem instrMem(.address, .instruction, .clk);
	
	//PC value
	individualReg64 PC(.q(address), .d(newAddress1), .reset, .enable(enablePC | needToRestore_i), .clk);
	
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
  assign couldBeNewAddress_o = branchAddress;
	
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
  
  
  
  logic [63:0][1:0] finalNewAddressToDo1; 
	integer p, q;
	always_comb begin
		for(p=0; p<64; p++) begin
			finalNewAddressToDo1[p][0] = newAddress[p];
		end
		for(q=0; q<64; q++) begin
			finalNewAddressToDo1[q][1] = restorePoint_i[q];
		end
	end
	mux2x64 finalChoiceMux1 (.out(newAddress1), .addr(needToRestore_i), .muxIns(finalNewAddressToDo1));	
  
  
endmodule

/*
module instructionFetch_testbench();
	logic clk, reset, uncondBr, brTaken, BRMI;
	logic [63:0] regPC;
	logic [31:0] instruction;
	logic [63:0] basicAddress;

	instructionFetch dut (.clk, .reset, .uncondBr, .brTaken, .BRMI, .regPC, .instrToRead(32'h0), .instruction, .address(basicAddress), .enablePC(1'b1)); //fake inputs added to match port, fix later

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
endmodule */

