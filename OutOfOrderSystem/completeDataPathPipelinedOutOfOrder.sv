module completeDataPathPipelinedOutOfOrder #(parameter ROBsize = 8, ROBsizeLog = $clog2(ROBsize+1))
(clk
, uncondBr
, brTaken
, memWrite
, memToReg
, reset
, ALUOp
, ALUSrc
, regWrite
, reg2Loc
, valueToStore
, dOrImm
, BRMI
, saveCond
, regRD
, instr
, flags
, commandZero
, read_enable
, needToForward
, negative
, overflow
, whichFlags
, zero
, carry_out
, whichMath
, leftShift
, mult
, div
, commandType_i
, doingABranch_i
, imem_instruction_i
, imem_address_o
,dmem_readData
,dmem_WriteData
,dmem_addressLoad
,dmem_addressStore
,dmem_readEn
,dmem_writeEn);
	input logic clk, uncondBr, brTaken, memWrite, memToReg, reset, 
					ALUSrc, regWrite, reg2Loc, valueToStore, dOrImm, BRMI, saveCond, read_enable, needToForward, leftShift, mult, div, doingABranch_i;
  input logic [1:0] whichMath;
	input logic [2:0] ALUOp;
	input logic [4:0] regRD;
  input logic [3:0] commandType_i;
	output logic [17:0] instr;
	output logic [3:0] flags;
	output logic commandZero, negative, overflow, whichFlags, zero, carry_out;
  
  //instruction memory
  input logic [31:0] imem_instruction_i;
  output logic [63:0] imem_address_o;
  
  //data memory
  input logic [63:0] dmem_readData;
  output logic [63:0] dmem_WriteData, dmem_addressLoad, dmem_addressStore;
  output logic dmem_readEn, dmem_writeEn;
	
  //stall logic setup
  //logic stallMult, stallDiv, theStall;
  //assign theStall = stallMult | stallDiv;
  logic decodeStall;
  
	//instruction fetch stage
	logic [63:0] regPC, address;
	logic [31:0] instruction;
  logic [32:0] firstWallIn, firstWallOut;
  logic needToRestore;
  logic [63:0] restorePoint;
	instructionFetch instructionGetter 
  (.clk
  , .reset
  , .uncondBr
  , .brTaken
  , .BRMI
  , .regPC
  , .instrToRead(firstWallOut[31:0])
  , .instruction
  , .address
  , .enablePC(~decodeStall)
  ,.needToRestore_i(needToRestore)
  ,.restorePoint_i(restorePoint)
  ,.imem_instruction_i
  ,.imem_address_o
  );
													
	//first wall

	assign firstWallIn[31:0] = instruction;
  assign firstWallIn[32] = 1;
	wallOfDFFsL33 firstWall (.q(firstWallOut), .d(firstWallIn), .reset(reset | needToRestore), .enable(~decodeStall), .clk);

	//reg read/decode stage
	//port the instructions out to the command module to produce all the commands
	assign instr[10:0] = firstWallOut[31:21];
	assign instr[11] = firstWallOut[22];
	assign instr[17:12] = firstWallOut[4:0];
  
  //the ROB unit
  //decode pieces
  logic	[ROBsizeLog - 1:0] 	robReadAddr1, robReadAddr2;
  logic [8:0]	robWriteData;
  logic 	robUpdateTail;
  logic [64:0]	robReadData1, robReadData2;
  logic [ROBsizeLog - 1:0] robNextTail;
  logic robStall;
  
  //completion pieces
  logic	[ROBsizeLog - 1:0] ROBWriteAddr;
  logic [69:0] ROBWriteData;
  logic ROBWriteEn;
  
  //commit pieces
  logic [78:0] ROBcommitReadData;
  logic [ROBsizeLog - 1:0] ROBhead;
  logic ROBupdateHead;
  
  //RS stalls
  logic [3:0] RSstall;
  logic ROBdontUpdate;
  ROB theROB
  (.clk_i(clk)
  ,.reset_i(reset | needToRestore)

  ,.decodeReadAddr1_i(robReadAddr1)
  ,.decodeReadAddr2_i(robReadAddr2)
  ,.decodeReadData1_o(robReadData1)
  ,.decodeReadData2_o(robReadData2)

  ,.updateTail_i(firstWallOut[32] & ~ROBdontUpdate)
  ,.decodeWriteData_i(robWriteData)
  ,.nextTail_o(robNextTail)
  ,.stall_o(robStall)

  ,.completionWriteAddr_i(ROBWriteAddr)
  ,.completionWriteEn_i(ROBWriteEn)
  ,.completionWriteData_i(ROBWriteData)

  ,.updateHead_i(ROBupdateHead)
  ,.head_o(ROBhead)
  ,.commitReadData_o(ROBcommitReadData));

	//the map table
  //decode pieces
  logic [4:0] mapReadAddr1, mapReadAddr2, mapWriteAddr;
  logic [ROBsizeLog - 1:0]	mapWriteData;
  logic 	mapRegWrite;
  logic [ROBsizeLog - 1:0]	mapReadData1, mapReadData2;
  
  //commit pieces
  logic [ROBsizeLog - 1:0]	mapCommitReadData;
  logic	[4:0] mapCommitReadAddr;
  logic [31:0] mapResets;
  
  mapTable theMapTable 
  (.decodeReadData1(mapReadData1), 
  .decodeReadData2(mapReadData2), 
  .decodeWriteData(mapWriteData), 
  .decodeReadAddr1(mapReadAddr1), 
  .decodeReadAddr2(mapReadAddr2), 
  .decodeWriteAddr(mapWriteAddr),
  .decodeRegWrite(mapRegWrite), 
  .clk(clk), 
  .reset(reset | needToRestore)
  
  ,.resets_i(mapResets)
  ,.commitReadAddr_i(mapCommitReadAddr)
  ,.commitReadData(mapCommitReadData));
  
  //the regfile
  //decode pieces
  logic	[4:0] 	regfileReadRegister1, regfileReadRegister2;
  logic [63:0]	regfileReadData1, regfileReadData2;
  
  //commit pieces
  logic [63:0] regCommitRead;
  logic	[4:0] WriteRegister, regCommitAddr;
  logic [63:0]	WriteData;
  logic 			RegWrite;
  
  regfileOOO theRegfile
  (.ReadData1(regfileReadData1)
  ,.ReadData2(regfileReadData2)
  ,.ReadRegister1(regfileReadRegister1)
  ,.ReadRegister2(regfileReadRegister2)
  
  ,.WriteData(WriteData)
  ,.WriteRegister(WriteRegister)
  ,.RegWrite(RegWrite)
  ,.clk(clk)
  
  ,.regCommitReadData_o(regCommitRead)
  ,.regCommitAddr_i(regCommitAddr)
  );
  
  //the decode stage wiring unit
  //reservation station wires
  logic	[3:0][ROBsizeLog - 1:0] 	RSROBTag1, RSROBTag2, RSROBTag;
  logic [3:0][64:0] RSROBval1, RSROBval2;
  logic [3:0] RSWriteEn;
  logic [3:0][9:0] RSCommands;

  //from the completion stage
  logic	[ROBsizeLog - 1:0] 	completionRSROBTag;
  logic [64:0] completionRSROBval;
  
  //LSQ
  logic LSQstall, LSQifNew, LSQstoreOrLoad;
  decodeStage dut
  (.clk_i(clk)
  ,.reset_i(reset | needToRestore)

  //instruction and commands
  ,.RDvalue_i(regRD)
  ,.RMvalue_i(firstWallOut[20:16])
  ,.RNvalue_i(firstWallOut[9:5])
  ,.dAddr9_i(firstWallOut[20:12])
  ,.imm12_i(firstWallOut[21:10])

  ,.commandType_i(commandType_i)
  ,.PCaddress_i(address)

  //,valueToStore_i
  ,.reg2Loc_i(reg2Loc)
  ,.memWrite_i(memWrite)
  ,.memToReg_i(memToReg)
  ,.ALUOp_i(ALUOp)
  ,.ALUSrc_i(ALUSrc)
  ,.dOrImm_i(dOrImm)
  ,.saveCond_i(saveCond)
  ,.read_enable_i(read_enable)
  ,.whichMath_i(whichMath)
  ,.regWrite_i(regWrite)
  ,.needToForward_i(needToForward)
  ,.leftShift_i(leftShift)
  ,.doingABranch_i(doingABranch_i)

  ,.decodeStall_o(decodeStall)



  //,decodeROBval1_i
  //,decodeROBval2_i
  //,decodeCommands_i

  //map table connections
  ,.mapReadData1_i(mapReadData1)
  ,.mapReadData2_i(mapReadData2)
  ,.mapWriteData_o(mapWriteData)
  ,.mapReadAddr1_o(mapReadAddr1)
  ,.mapReadAddr2_o(mapReadAddr2)
  ,.mapWriteAddr_o(mapWriteAddr)
  ,.mapRegWrite_o(mapRegWrite)

  //ROB connections
  ,.robReadAddr1_o(robReadAddr1)
  ,.robReadAddr2_o(robReadAddr2)
  ,.robReadData1_i(robReadData1)
  ,.robReadData2_i(robReadData2)

  ,.robUpdateTail_o(robUpdateTail)
  ,.robWriteData_o(robWriteData)
  ,.robNextTail_i(robNextTail)
  ,.robStall_i(robStall)
  ,.robWriteEn_i(ROBWriteEn)

  //reservation station connections
  ,.RSROBTag1_o(RSROBTag1)
  ,.RSROBTag2_o(RSROBTag2)
  ,.RSROBTag_o(RSROBTag)
  ,.RSWriteEn_o(RSWriteEn)
  ,.RSROBval1_o(RSROBval1)
  ,.RSROBval2_o(RSROBval2)
  ,.RSCommands_o(RSCommands)
  ,.RSstall_i(RSstall)
  ,.ROBdontUpdate_o(ROBdontUpdate)

  //regfile connections
  ,.regfileReadRegister1_o(regfileReadRegister1)
  ,.regfileReadRegister2_o(regfileReadRegister2)
  ,.regfileReadData1_i(regfileReadData1)
  ,.regfileReadData2_i(regfileReadData2)
  
  ,.completionRSROBTag_i(completionRSROBTag)
  ,.completionRSROBval_i(completionRSROBval)
  
  //LSQ
  ,.LSQstall_i(LSQstall)
  ,.LSQifNew_o(LSQifNew)
  ,.LSQstoreOrLoad_o(LSQstoreOrLoad)
  );
  
  //the LSQ
  logic [4:0] LSQROBdecode, LSQmemTag;
  logic [63:0] LSQmemAddr, LSQPC;
  logic LSQaddrWrite, LSQretire, LSQflush;
  assign LSQROBdecode[ROBsizeLog - 1:0] = RSROBTag;
  assign LSQROBdecode[4] = 0;
  
  logic [3:0] commandsAfterALU;
  loadStoreQueue theLSQ
  (.full(LSQstall)
  ,.flush(LSQflush)
  ,.PCout(LSQPC)
  ,.loadOrStore(LSQstoreOrLoad)
  ,.PCin(address)
  ,.ROBin(LSQROBdecode)
  ,.ifNew(LSQifNew)
  ,.addrWrite(LSQmemAddr)
  ,.addrWriteROB(LSQmemTag)
  ,.ifAddrWrite(LSQaddrWrite)
  ,.LSretire(LSQretire)
  ,.ifValWrite(1'b0)
  ,.valWriteROB(5'b0)
  ,.valWrite(64'b0)
  ,.reset(reset | needToRestore)
  ,.clk(clk));
  
  
	assign regPC = RSROBval2[0];
  
  //logic [64:0] RSROBVal1_1, RSROBVal2_1;
  //assign RSROBVal1_1[63:0] = RSROBVal1;
  //assign RSROBVal1_1[64] = 0;
  //assign RSROBVal2_1[63:0] = RSROBVal2;
  //assign RSROBVal2_1[64] = 0;
  
  //the issue stage
  //stamp down four reservation stations
  //to the execution units
  logic [3:0] executionStall;
  logic [3:0][63:0] reservationStationVal1, reservationStationVal2;
  logic [3:0][9:0] reservationStationCommands;
  logic [3:0][ROBsizeLog-1:0] reservationStationTag;
  logic [3:0] executionReady;
  
  logic [64:0] issueExecVal, issueMemVal;
  logic [ROBsizeLog - 1:0] tagToMem, tagToCom;
  
  genvar i;
  generate
		for(i=0; i < 4; i++) begin : eachEnDff
			reservationStationx2Forward theRS
      (.clk_i(clk)
      ,.reset_i(reset | needToRestore)
      ,.decodeROBTag1_i(RSROBTag1[i])
      ,.decodeROBTag2_i(RSROBTag2[i])
      ,.decodeROBTag_i(RSROBTag[i])
      ,.decodeWriteEn_i(firstWallOut[32] & RSWriteEn[i])
      ,.decodeROBval1_i(RSROBval1[i])
      ,.decodeROBval2_i(RSROBval2[i])
      ,.decodeCommands_i(RSCommands[i])
      ,.stall_o(RSstall[i])

      ,.issueROBTagCom_i(completionRSROBTag)
      ,.issueROBvalCom_i(completionRSROBval)

      //forwarding
      ,.issueROBTagExec_i(tagToMem)
      ,.issueROBvalExec_i(issueExecVal)
      ,.issueROBMemAccessExec_i(commandsAfterALU[1])

      ,.issueROBTagMem_i(tagToCom)
      ,.issueROBvalMem_i(issueMemVal)
      
      ,.stall_i(executionStall[i])//executionStall[i] & firstWallOut[32] & ~decodeStall
      ,.reservationStationVal1_o(reservationStationVal1[i])
      ,.reservationStationVal2_o(reservationStationVal2[i])
      ,.reservationStationCommands_o(reservationStationCommands[i])
      ,.reservationStationTag_o(reservationStationTag[i])
      ,.ready_o(executionReady[i]));
		end
	endgenerate 
  
  //the execution stage
  
  //the ALU unit
  //ports to execution out
  logic [3:0][63:0] executeVal;
  logic [3:0][9:0] executeCommands;
  logic [3:0][ROBsizeLog-1:0] executeTag;
  logic [3:0][3:0] executeFlags;
  logic [3:0] valid_execute;
  logic [3:0] canGo;
  
  issueExecStageALU theALU
  (.clk_i(clk)
  ,.reset_i(reset)

  //RS inouts
  ,.stallRS_o(executionStall[0])
  ,.reservationStationVal1_i(reservationStationVal1[0])
  ,.reservationStationVal2_i(reservationStationVal2[0])
  ,.reservationStationCommands_i(reservationStationCommands[0])
  ,.reservationStationTag_i(reservationStationTag[0])
  ,.readyRS_i(executionReady[0])

  //inouts to continue through execute stage
  ,.canGo_i(canGo[0])
  ,.executeTag_o(executeTag[0])
  ,.executeCommands_o(executeCommands[0])
  ,.executeVal_o(executeVal[0])
  ,.executeFlags_o(executeFlags[0])
  ,.valid_o(valid_execute[0])
  );
  
  issueExecStageShift theShifter
  (.clk_i(clk)
  ,.reset_i(reset)

  //RS inouts
  ,.stallRS_o(executionStall[1])
  ,.reservationStationVal1_i(reservationStationVal1[1])
  ,.reservationStationVal2_i(reservationStationVal2[1])
  ,.reservationStationCommands_i(reservationStationCommands[1])
  ,.reservationStationTag_i(reservationStationTag[1])
  ,.readyRS_i(executionReady[1])

  //inouts to continue through execute stage
  ,.canGo_i(canGo[1])
  ,.executeTag_o(executeTag[1])
  ,.executeCommands_o(executeCommands[1])
  ,.executeVal_o(executeVal[1])
  ,.executeFlags_o(executeFlags[1])
  ,.valid_o(valid_execute[1])
  );
  
  issueExecStageMult theMultiplier
  (.clk_i(clk)
  ,.reset_i(reset | needToRestore)

  //RS inouts
  ,.stallRS_o(executionStall[2])
  ,.reservationStationVal1_i(reservationStationVal1[2])
  ,.reservationStationVal2_i(reservationStationVal2[2])
  ,.reservationStationCommands_i(reservationStationCommands[2])
  ,.reservationStationTag_i(reservationStationTag[2])
  ,.readyRS_i(executionReady[2])

  //inouts to continue through execute stage
  ,.canGo_i(canGo[2])
  ,.executeTag_o(executeTag[2])
  ,.executeCommands_o(executeCommands[2])
  ,.executeVal_o(executeVal[2])
  ,.executeFlags_o(executeFlags[2])
  ,.valid_o(valid_execute[2])
  );
  
  issueExecStageDiv theDivider
  (.clk_i(clk)
  ,.reset_i(reset | needToRestore)

  //RS inouts
  ,.stallRS_o(executionStall[3])
  ,.reservationStationVal1_i(reservationStationVal1[3])
  ,.reservationStationVal2_i(reservationStationVal2[3])
  ,.reservationStationCommands_i(reservationStationCommands[3])
  ,.reservationStationTag_i(reservationStationTag[3])
  ,.readyRS_i(executionReady[3])

  //inouts to continue through execute stage
  ,.canGo_i(canGo[3])
  ,.executeTag_o(executeTag[3])
  ,.executeCommands_o(executeCommands[3])
  ,.executeVal_o(executeVal[3])
  ,.executeFlags_o(executeFlags[3])
  ,.valid_o(valid_execute[3])
  );
  
  
  

  //the execution output unit
  //to memory
   logic [63:0] dataToMem;
   logic [9:0] commandsToMem;
   logic [3:0] flagsToMem;
   logic validToMem;
  
  executeOutput execOut
  (.clk_i(clk)
  ,.reset_i(reset)

  //inouts to continue through execute stage
  ,.canGo_o(canGo)
  ,.executeTag_i(executeTag)
  ,.executeCommands_i(executeCommands)
  ,.executeVal_i(executeVal)
  ,.executeFlags_i(executeFlags)
  ,.valid_i(valid_execute)

  //stuff to continue to memory
  ,.dataToMem_o(dataToMem)
  ,.tagToMem_o(tagToMem)
  ,.commandsToMem_o(commandsToMem)
  ,.flagsToMem_o(flagsToMem)
  ,.valid_o(validToMem)
  );
  

  assign issueExecVal[64] = validToMem;
  assign issueExecVal[63:0] = dataToMem;
  
	
	//gather up the commands to be moved along
	assign commandsAfterALU[0] = commandsToMem[8];
	assign commandsAfterALU[1] = commandsToMem[1];
	assign commandsAfterALU[2] = commandsToMem[0];
	assign commandsAfterALU[3] = commandsToMem[9];
	
	//break out bits for forwarding
	//assign ALUreg[4:0] = secondWallOut[142:138];
	//assign ALUforward = secondWallOut[171];
	
	logic [73+ (ROBsizeLog - 1):0] thirdWallOut, thirdWallIn;
	assign thirdWallIn[3:0] = commandsAfterALU[3:0];
	assign thirdWallIn[67:4] = dataToMem;
  assign thirdWallIn[68] = validToMem;
  assign thirdWallIn[72:69] = flagsToMem;
	assign thirdWallIn[73 + (ROBsizeLog - 1):73] = tagToMem;
	//assign thirdWallIn[138] = secondWallOut[171];
	wallOfDFFsL77 thirdWall (.q(thirdWallOut), .d(thirdWallIn), .reset(reset | needToRestore), .enable(1'b1), .clk);
	
  //memory stage
  logic writeEnMem;
  logic [63:0] writeAddrMem, writeDataMem, mightSendToReg;
	memStage thatMem (.clk, .memWrite(writeEnMem), .read_enable(thirdWallOut[3]), .memToReg(thirdWallOut[1]),
							.ReadData2(writeDataMem), .addressLoad(thirdWallOut[67:4]), .addressStore(writeAddrMem), .mightSendToReg
              ,.dmem_readData
              ,.dmem_WriteData
              ,.dmem_addressLoad
              ,.dmem_addressStore
              ,.dmem_readEn
              ,.dmem_writeEn);
              
  assign LSQmemAddr = thirdWallOut[67:4];
  assign LSQmemTag[ROBsizeLog - 1:0] = thirdWallOut[73 + (ROBsizeLog - 1):73];
  assign LSQmemTag[4] = 0;
  assign LSQaddrWrite = thirdWallOut[2] | thirdWallOut[3];
							
	//break out bits for forwarding
	//assign MEMreg[4:0] = thirdWallOut[136:132];
	//assign MEMforward = thirdWallOut[138];
	assign tagToCom = thirdWallOut[73 + (ROBsizeLog - 1):73];
  assign issueMemVal[64] = thirdWallOut[68];
  assign issueMemVal[63:0] = mightSendToReg;
	logic [70 + (ROBsizeLog - 1):0] finalWallIn, finalWallOut;
	assign finalWallIn[63:0] = mightSendToReg;
  assign finalWallIn[64] = thirdWallOut[68];
	assign finalWallIn[65] = thirdWallOut[0];
	assign finalWallIn[69:66] = thirdWallOut[72:69];
	assign finalWallIn[70 + (ROBsizeLog - 1):70] = thirdWallOut[73 + (ROBsizeLog - 1):73];
	wallOfDFFsL74 finalWall (.q(finalWallOut), .d(finalWallIn), .reset(reset | needToRestore), .enable(1'b1), .clk);
  
  //single delay stage
  //logic [70 + (ROBsizeLog - 1):0] finalWallIn1, finalWallOut1;
  //assign finalWallIn1 = finalWallOut;
  //wallOfDFFs #(.LENGTH(71 + (ROBsizeLog - 1))) finalWall1 (.q(finalWallOut1), .d(finalWallIn1), .reset(reset | needToRestore), .enable(1'b1), .clk);
  
  
  //the completion stage
  completionStage theCompletion
  (.clk_i(clk)
  ,.reset_i(reset)

  //data from memory stage
  ,.dataFromMem_i(finalWallOut[64:0])
  ,.flagsFromMem_i(finalWallOut[69:66])
  ,.ROBTagFromMem_i(finalWallOut[70 + (ROBsizeLog - 1):70])
  ,.save_cond_i(finalWallOut[65])

  //to reservation station
  ,.RSROBTag_o(completionRSROBTag)
  ,.RSROBval_o(completionRSROBval)

  //to ROB
  ,.ROBWriteAddr_o(ROBWriteAddr)
  ,.ROBWriteEn_o(ROBWriteEn)
  ,.ROBWriteData_o(ROBWriteData)
  );
  
  //the commit stage
  commitStage theCommit
  (.clk_i(clk)
  ,.reset_i(reset)

  //ROB links
  ,.ROBupdateHead_o(ROBupdateHead)
  ,.ROBhead_i(ROBhead)
  ,.ROBcommitReadData_i(ROBcommitReadData)

  //to map table
  ,.mapResets_o(mapResets)
  ,.mapCommitReadAddr_o(mapCommitReadAddr)
  ,.mapCommitReadData_i(mapCommitReadData)

  //to regfile
  ,.regCommitRead_i(regCommitRead)
  ,.regCommitAddr_o(regCommitAddr)
  ,.WriteRegister_o(WriteRegister)
  ,.WriteData_o(WriteData)
  ,.RegWrite_o(RegWrite)
  
  //to instr fetch
  ,.needToRestore_o(needToRestore)
  ,.restorePoint_o(restorePoint)
  
  //to memory
  ,.writeAddrMem_o(writeAddrMem)
  ,.writeDataMem_o(writeDataMem)
  ,.writeEnMem_o(writeEnMem)
  
  //to LSQ
  ,.LSQflush_i(LSQflush)
  ,.LSQPC_i(LSQPC)
  ,.LSQretire_o(LSQretire)
  );
  

	
endmodule

/*
module completeDataPathPipelined_testbench();
	logic clk, uncondBr, brTaken, memWrite, memToReg, reset, 
					ALUSrc, regWrite, reg2Loc, valueToStore, dOrImm, BRMI, saveCond, read_enable;
	logic [2:0] ALUOp;
	logic [4:0] regRD;
	logic [11:0] instr;
	logic [3:0] flags;
	logic commandZero;

	completeDataPathPipelined dut (.clk, .uncondBr, .brTaken, .memWrite, .memToReg, .reset, 
								.ALUOp, .ALUSrc, .regWrite, .reg2Loc, .valueToStore, .dOrImm,
								.BRMI, .saveCond, .regRD, .instr, .flags, .commandZero, .read_enable,
.needToForward(1'b1), .negative, .overflow, .whichFlags, .zero, .carry_out, .whichMath(2'h0), .leftShift(1'b0), .mult(1'b0), .div(1'b0)); //fake inputs and dead outputs to make ports match, fix later
		wire negative, overflow, whichFlags, zero, carry_out; //dead wires, fix later
	assign regRD = instr[4:0]; 

	// Set up the clock
	parameter ClockDelay = 1000;
	initial begin ;
		clk <= 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end
	
	initial begin
	uncondBr <= 0; brTaken <= 0; memWrite <= 0;	memToReg <= 0; 
	regWrite <= 0; ALUSrc <= 0; reg2Loc <= 0; valueToStore <= 0;
	BRMI <= 0; saveCond <= 0; ALUOp <= 0; dOrImm <= 0; read_enable <= 0;
				reset <= 1; 	@(posedge clk);
				reset <= 0; regWrite <= 1;	dOrImm <= 1; ALUSrc <= 1; ALUOp <= 2;@(posedge clk);
									@(posedge clk);
									@(posedge clk);
									@(posedge clk);
									@(posedge clk);
									regWrite <= 0; uncondBr <= 1; brTaken <= 1;@(posedge clk);
									@(posedge clk);				
				
		$stop(); // end the simulation
	end
endmodule*/

