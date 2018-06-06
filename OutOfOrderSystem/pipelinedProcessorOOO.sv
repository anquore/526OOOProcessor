module pipelinedProcessorOOO
(clk
, reset
, imem_instruction_i
, imem_address_o
,dmem_readData
,dmem_WriteData
,dmem_addressLoad
,dmem_addressStore
,dmem_readEn
,dmem_writeEn);
	input clk, reset;
  
  //instruction memory
  input logic [31:0] imem_instruction_i;
  output logic [63:0] imem_address_o;
  
  //data memory
  input logic [63:0] dmem_readData;
  output logic [63:0] dmem_WriteData, dmem_addressLoad, dmem_addressStore;
  output logic dmem_readEn, dmem_writeEn;
	
	//the datapath
	logic uncondBr, brTaken, memWrite, memToReg, 
					ALUSrc, regWrite, reg2Loc, valueToStore, dOrImm, BRMI, saveCond, read_enable, needToForward, leftShift, mult, div, doingABranch;
  logic [1:0] whichMath;
	logic [2:0] ALUOp;
	logic [4:0] regRD;
	logic [17:0] instr;
	logic [3:0] flags;
  logic [3:0] commandType;
	logic commandZero, negative, overflow, whichFlags, zero, carry_out;
	completeDataPathPipelinedOutOfOrder theDataPath (.clk, .uncondBr, .brTaken, .memWrite, .memToReg, .reset, 
								.ALUOp, .ALUSrc, .regWrite, .reg2Loc, .valueToStore, .dOrImm, 
								.BRMI, .saveCond, .regRD, .instr, .flags, .commandZero, 
								.read_enable, .needToForward, .negative, .overflow, .whichFlags, .zero, .carry_out, .whichMath, .leftShift, .mult, .div, .commandType_i(commandType), .doingABranch_i(doingABranch)
                ,.imem_instruction_i
                ,.imem_address_o
                ,.dmem_readData
                ,.dmem_WriteData
                ,.dmem_addressLoad
                ,.dmem_addressStore
                ,.dmem_readEn
                ,.dmem_writeEn);
								
	//the control
	controlOOO theControl (.instr, .flags, .commandZero, .uncondBr, .brTaken, .memWrite, .memToReg,
								.ALUOp, .ALUSrc, .regWrite, .reg2Loc, .valueToStore, .dOrImm, 
								.BRMI, .saveCond, .regRD, .read_enable, .needToForward, .negative, .overflow, .whichFlags, .zero, .carry_out, .whichMath, .leftShift, .mult, .div, .commandType_o(commandType), .doingABranch_o(doingABranch));
endmodule
/*
module pipelinedProcessorOOO_testbench();
	logic clk, reset;
  //instruction memory
  logic [31:0] imem_instruction_i;
  logic [63:0] imem_address_o;
  
  //data memory
  logic [63:0] dmem_readData;
  logic [63:0] dmem_WriteData, dmem_addressLoad, dmem_addressStore;
  logic dmem_readEn, dmem_writeEn;

	pipelinedProcessorOOO dut 
  (.clk
  ,.reset
  ,.imem_instruction_i
  ,.imem_address_o
  ,.dmem_readData
  ,.dmem_WriteData
  ,.dmem_addressLoad
  ,.dmem_addressStore
  ,.dmem_readEn
  ,.dmem_writeEn);
  
  instructmem instrMem(.address(imem_address_o), .instruction(imem_instruction_i), .clk);
  
  datamem theDataMemory (.addressLoad(dmem_addressLoad), .addressStore(dmem_addressStore), .write_enable(dmem_writeEn), .read_enable(dmem_readEn), 
									.write_data(dmem_WriteData), .clk, .xfer_size(4'b1000), .read_data(dmem_readData));

	// Set up the clock
	parameter ClockDelay = 2000;
	initial begin ;
		clk <= 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end
	
	initial begin
				reset <= 1; 	@(posedge clk);
				reset <= 0; 	@(posedge clk);
			repeat(3000) begin	@(posedge clk); end				
				
		$stop(); // end the simulation
	end
endmodule*/

