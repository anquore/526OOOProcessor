`timescale 1ns/10ps
module decodeStage #(parameter ROBsize = 32, ROBsizeLog = $clog2(ROBsize+1), addrSize = $clog2(ROBsize)) 
(clk_i
,reset_i

//instruction and commands
,RDvalue_i
,RMvalue_i
,RNvalue_i
,dAddr9_i
,imm12_i

,commandType_i
,PCaddress_i

//,valueToStore_i
,reg2Loc_i
,memWrite_i
,memToReg_i
,ALUOp_i
,ALUSrc_i
,dOrImm_i
,saveCond_i
,read_enable_i
,whichMath_i
,regWrite_i
,needToForward_i
,leftShift_i

,decodeStall_o



//,decodeROBval1_i
//,decodeROBval2_i
//,decodeCommands_i

//map table connections
,mapReadData1_i
,mapReadData2_i
,mapWriteData_o
,mapReadAddr1_o
,mapReadAddr2_o
,mapWriteAddr_o
,mapRegWrite_o

//ROB connections
,robReadAddr1_o
,robReadAddr2_o
,robReadData1_i
,robReadData2_i

,robUpdateTail_o
,robWriteData_o
,robNextTail_i
,robStall_i

//reservation station connections
,RSROBTag1_o
,RSROBTag2_o
,RSROBTag_o
,RSWriteEn_o
,RSROBval1_o
,RSROBval2_o
,RSCommands_o
,RSstall_i

//regfile connections
,regfileReadRegister1_o
,regfileReadRegister2_o
,regfileReadData1_i
,regfileReadData2_i
);

  //inputs and outputs
  input logic clk_i, reset_i;
  input logic [4:0] RDvalue_i, RMvalue_i, RNvalue_i;
  input logic [2:0] commandType_i;
  input logic [63:0] PCaddress_i;
  input logic [8:0] dAddr9_i;
	input logic [11:0] imm12_i;
  //input logic valueToStore_i;
  input logic reg2Loc_i;
  input logic regWrite_i;
  input logic memWrite_i;
  input logic memToReg_i;
  input logic ALUOp_i;
  input logic ALUSrc_i;
  input logic dOrImm_i;
  input logic saveCond_i;
  input logic read_enable_i;
  input logic whichMath_i;
  input logic needToForward_i;
  input logic leftShift_i;
  output logic decodeStall_o;
  
  //map table
  output logic [4:0] mapReadAddr1_o, mapReadAddr2_o, mapWriteAddr_o;
	output logic [ROBsizeLog - 1:0]	mapWriteData_o;
	output logic 	mapRegWrite_o;
	input logic [ROBsizeLog - 1:0]	mapReadData1_i, mapReadData2_i;
  
  //ROB unit
  output logic	[addrSize:0] 	robReadAddr1_o, robReadAddr2_o;
	output logic [7:0]	robWriteData_o;
	output logic 	robUpdateTail_o;
	input logic [64:0]	robReadData1_i, robReadData2_i;
  input logic [addrSize:0] robNextTail_i;
  input logic robStall_i;
  
  //reservation station
  output logic	[3:0][ROBsizeLog - 1:0] 	RSROBTag1_o, RSROBTag2_o, RSROBTag_o;
  output logic [3:0][63:0] RSROBval1_o, RSROBval2_o;
	output logic [3:0] RSWriteEn_o;
  input logic [3:0] RSstall_i;
  output logic [3:0][9:0] RSCommands_o;
  
  //regfile
  output logic	[4:0] 	regfileReadRegister1_o, regfileReadRegister2_o;
	input logic [63:0]	regfileReadData1_i, regfileReadData2_i;
  
  //pick between RM and RD for the true RM value
  logic [4:0] trueRM;
	logic [4:0][1:0] addressDataToMux;
	integer i, j;
	always_comb begin
		for(i=0; i<5; i++) begin
			addressDataToMux[i][0] = RDvalue_i[i];
		end
		for(j=0; j<5; j++) begin
			addressDataToMux[j][1] = RMvalue_i[j];
		end
	end
	mux2x5 whatRegToRead (.out(trueRM), .addr(reg2Loc_i), .muxIns(addressDataToMux));
  
  //connect up the map table addresses
  assign mapReadAddr1_o = RNvalue_i;
  assign mapReadAddr2_o = trueRM;
  assign mapWriteAddr_o = RDvalue_i;
  
  //connect up the regfile and ROB addresses
  assign regfileReadRegister1_o = RNvalue_i;
  assign regfileReadRegister2_o = trueRM;
  assign robReadAddr1_o = mapReadData1_i;
  assign robReadAddr2_o = mapReadData2_i;
  
  //assembly the rob write values 
  assign robWriteData_o[7:5] = commandType_i;
  assign robWriteData_o[4:0] = RDvalue_i; //not true, needs to account for CBZ stuff
  assign robUpdateTail_o = 1;
  
  //determine if a stall in needed
  logic needAStall;
  assign needAStall = robStall_i | RSstall_i[0] | RSstall_i[1] | RSstall_i[2] | RSstall_i[3];
  assign decodeStall_o = needAStall;
  
  //finish the map table connections
  assign mapWriteData_o = robNextTail_i;
  assign mapRegWrite_o = regWrite_i & (~needAStall);//needs to account for loads
  
  
  //Reservation station

  
  //compare the two outputs of the map table to zero
  logic RMvalueInReg, RNvalueInReg;
  assign RNvalueInReg = (mapReadData1_i == 0);
  assign RMvalueInReg = (mapReadData2_i == 0);
  
  //determine which value to send to the RS for RN and RM, the rob or the reg
  logic [1:0][63:0] decisionROBorRegRN, decisionROBorRegRM;
  assign decisionROBorRegRN[0] = robReadData1_i[63:0];
  assign decisionROBorRegRN[1] = regfileReadData1_i;
  assign decisionROBorRegRM[0] = robReadData2_i[63:0];
  assign decisionROBorRegRM[1] = regfileReadData2_i;
  
  logic [63:0] RSRNdata, preBranchRSRM;
  assign RSRNdata = decisionROBorRegRN[RNvalueInReg];
  //assign RSROBval1_o = RSRNdata;
  assign preBranchRSRM = decisionROBorRegRM[RMvalueInReg];
  
  //determine if we are branching
  logic doingABranch, doingABranch_noBR;
  assign doingABranch = commandType_i[1] | commandType_i[2];
  assign doingABranch_noBR = doingABranch & ~(commandType_i == 6);
  
  
  //determine the tag to associate with the RN RS data
  logic [ROBsizeLog - 1:0] 	RSRNTag;
  always_comb begin
    if (doingABranch | RNvalueInReg | robReadData1_i[64])
      RSRNTag = 0;
    else
      RSRNTag = mapReadData1_i;
  end
  
  //choose between sending an address and data
  logic [1:0][63:0] decisionAddressOrDataRM;
  assign decisionAddressOrDataRM[0] = preBranchRSRM;
  assign decisionAddressOrDataRM[1] = PCaddress_i;

  logic [64:0] preImmRSRMdata;
  assign preImmRSRMdata = decisionAddressOrDataRM[doingABranch_noBR];
  
  //choose between sending an immediate and sending the data
  logic [63:0] dAddrExtended, RSRMdata, immExtended, dOrImmData;
  logic [63:0][1:0] aluDataToMux0, aluDataToMux1;
	signExtend9 dAddrExtender (.valueIn(dAddr9_i), .extendedOut(dAddrExtended));
	signExtend12 imm12Extender (.valueIn(imm12_i), .extendedOut(immExtended));
  integer q, r;
	always_comb begin
		for(q=0; q<64; q++) begin
			aluDataToMux0[q][0] = dAddrExtended[q];
		end
		for(r=0; r<64; r++) begin
			aluDataToMux0[r][1] = immExtended[r];
		end
	end
	mux2x64 choosingDOrImm (.out(dOrImmData), .addr(dOrImm_i), .muxIns(aluDataToMux0));
  
  //mux between shift value or not shift value
  logic [63:0] shiftValue, immediateData;
  assign shiftValue[63:6] = 0;
  assign shiftValue[5:0] = imm12_i[5:0];
  
  logic [1:0][63:0] finalConstant;
  assign finalConstant[0] = dOrImmData;
  assign finalConstant[1] = shiftValue;
  
  assign immediateData = finalConstant[(whichMath_i == 1)];
	
	//actual value to send
	integer k, l;
	always_comb begin
		for(k=0; k<64; k++) begin
			aluDataToMux1[k][0] = preImmRSRMdata[k];
		end
		for(l=0; l<64; l++) begin
			aluDataToMux1[l][1] = immediateData[l];
		end
	end	
	mux2x64 valueToAlu (.out(RSRMdata), .addr(ALUSrc_i), .muxIns(aluDataToMux1));
  
  //determine the tag to associate with the RM RS data
  logic [ROBsizeLog - 1:0] 	RSRMTag;
  always_comb begin
    if (doingABranch | RMvalueInReg | robReadData2_i[64] | ALUSrc_i)
      RSRMTag = 0;
    else
      RSRMTag = mapReadData2_i;
  end
  
  //setup the RS commands to send forward
  logic [9:0] RScommands;
  assign RScommands[0] = memWrite_i;
	assign RScommands[1] = memToReg_i;
	assign RScommands[4:2] = ALUOp_i;
	assign RScommands[5] = regWrite_i;
	assign RScommands[6] = needToForward_i;
	assign RScommands[7] = leftShift_i;
	assign RScommands[8] = saveCond_i;
	assign RScommands[9] = read_enable_i;
  
  //assign the 4 RS's
  integer g;
  always_comb begin
    for(g=0; g<4; g++) begin
			  //ROB tag is the next tail value
        RSROBTag_o[g] = robNextTail_i;
        RSROBTag1_o[g] = RSRNTag;
        RSROBTag2_o[g] = RSRMTag;
        RSROBval1_o[g] = RSRNdata; 
        RSROBval2_o[g] = RSRMdata;
        RSCommands_o[g] = RScommands;
		end
  end
    
  //assign each of the write enables
  assign RSWriteEn_o[0] = (whichMath_i == 0) & (~needAStall);
  assign RSWriteEn_o[1] = (whichMath_i == 1) & (~needAStall);
  assign RSWriteEn_o[2] = (whichMath_i == 2) & (~needAStall);
  assign RSWriteEn_o[3] = (whichMath_i == 3) & (~needAStall);

endmodule

module decodeStage_testbench();

  //inputs and outputs
  logic reset_i, clk_i, decodeStall_o;
   logic [4:0] RDvalue_i, RMvalue_i, RNvalue_i;
   logic [2:0] commandType_i;
   logic [63:0] PCaddress_i;
   logic [8:0] dAddr9_i;
	 logic [11:0] imm12_i;
  //input logic valueToStore_i;
   logic reg2Loc_i;
   logic regWrite_i;
   logic memWrite_i;
   logic memToReg_i;
   logic ALUOp_i;
   logic ALUSrc_i;
   logic dOrImm_i;
   logic saveCond_i;
   logic read_enable_i;
   logic whichMath_i;
   logic needToForward_i;
   logic leftShift_i;
  
  //map table
   logic [4:0] mapReadAddr1_o, mapReadAddr2_o, mapWriteAddr_o;
	 logic [3:0]	mapWriteData_o;
	 logic 	mapRegWrite_o;
	 logic [3:0]	mapReadData1_i, mapReadData2_i;
  
  //ROB unit
   logic	[3:0] 	robReadAddr1_o, robReadAddr2_o;
	 logic [7:0]	robWriteData_o;
	 logic 	robUpdateTail_o;
	 logic [64:0]	robReadData1_i, robReadData2_i;
   logic [3:0] robNextTail_i;
   logic robStall_i;
  
  //reservation station
   logic	[3:0][3:0] 	RSROBTag1_o, RSROBTag2_o, RSROBTag_o;
   logic [3:0][63:0] RSROBval1_o, RSROBval2_o;
	 logic [3:0] RSWriteEn_o;
   logic [3:0] RSstall_i;
   logic [3:0][9:0] RSCommands_o;
    logic	[4:0] 	regfileReadRegister1_o, regfileReadRegister2_o;
	 logic [63:0]	regfileReadData1_i, regfileReadData2_i;
  
  decodeStage #(.ROBsize(8)) dut
  (.clk_i
  ,.reset_i

  //instruction and commands
  ,.RDvalue_i
  ,.RMvalue_i
  ,.RNvalue_i
  ,.dAddr9_i
  ,.imm12_i

  ,.commandType_i
  ,.PCaddress_i

  //,valueToStore_i
  ,.reg2Loc_i
  ,.memWrite_i
  ,.memToReg_i
  ,.ALUOp_i
  ,.ALUSrc_i
  ,.dOrImm_i
  ,.saveCond_i
  ,.read_enable_i
  ,.whichMath_i
  ,.regWrite_i
  ,.needToForward_i
  ,.leftShift_i

  ,.decodeStall_o



  //,decodeROBval1_i
  //,decodeROBval2_i
  //,decodeCommands_i

  //map table connections
  ,.mapReadData1_i
  ,.mapReadData2_i
  ,.mapWriteData_o
  ,.mapReadAddr1_o
  ,.mapReadAddr2_o
  ,.mapWriteAddr_o
  ,.mapRegWrite_o

  //ROB connections
  ,.robReadAddr1_o
  ,.robReadAddr2_o
  ,.robReadData1_i
  ,.robReadData2_i

  ,.robUpdateTail_o
  ,.robWriteData_o
  ,.robNextTail_i
  ,.robStall_i

  //reservation station connections
  ,.RSROBTag1_o
  ,.RSROBTag2_o
  ,.RSROBTag_o
  ,.RSWriteEn_o
  ,.RSROBval1_o
  ,.RSROBval2_o
  ,.RSCommands_o
  ,.RSstall_i

  //regfile connections
  ,.regfileReadRegister1_o
  ,.regfileReadRegister2_o
  ,.regfileReadData1_i
  ,.regfileReadData2_i
  );
  
endmodule