module decodeStageExtra #(parameter ROBsize = 16, ROBsizeLog = $clog2(ROBsize+1), addrSize = $clog2(ROBsize)) 
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
,doingABranch_i

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
,robWriteEn_i

//reservation station connections
,RSROBTag1_o
,RSROBTag2_o
,RSROBTag3_o
,RSROBTag_o
,RSWriteEn_o
,RSROBval1_o
,RSROBval2_o
,RSROBval3_o
,RSCommands_o
,RSstall_i
,ROBdontUpdate_o

//regfile connections
,regfileReadRegister1_o
,regfileReadRegister2_o
,regfileReadData1_i
,regfileReadData2_i

//from the completion stage
,completionRSROBTag_i
,completionRSROBval_i

//from LSQ
,LSQstall_i
,LSQifNew_o
,LSQstoreOrLoad_o
);

  //inputs and outputs
  input logic clk_i, reset_i;
  input logic [4:0] RDvalue_i, RMvalue_i, RNvalue_i;
  input logic [3:0] commandType_i;
  input logic [63:0] PCaddress_i;
  input logic [8:0] dAddr9_i;
	input logic [11:0] imm12_i;
  //input logic valueToStore_i;
  input logic reg2Loc_i;
  input logic regWrite_i;
  input logic memWrite_i;
  input logic memToReg_i;
  input logic [2:0] ALUOp_i;
  input logic ALUSrc_i;
  input logic dOrImm_i;
  input logic saveCond_i;
  input logic read_enable_i;
  input logic [1:0] whichMath_i;
  input logic needToForward_i;
  input logic leftShift_i, doingABranch_i;
  output logic decodeStall_o;
  
  //map table
  output logic [4:0] mapReadAddr1_o, mapReadAddr2_o, mapWriteAddr_o;
	output logic [ROBsizeLog - 1:0]	mapWriteData_o;
	output logic 	mapRegWrite_o;
	input logic [ROBsizeLog - 1:0]	mapReadData1_i, mapReadData2_i;
  
  //ROB unit
  output logic	[addrSize:0] 	robReadAddr1_o, robReadAddr2_o;
	output logic [8:0]	robWriteData_o;
	output logic 	robUpdateTail_o;
	input logic [64:0]	robReadData1_i, robReadData2_i;
  input logic [addrSize:0] robNextTail_i;
  input logic robStall_i, robWriteEn_i;
  output logic ROBdontUpdate_o;
  
  //reservation station
  output logic	[3:0][ROBsizeLog - 1:0] 	RSROBTag1_o, RSROBTag2_o, RSROBTag_o, RSROBTag3_o;
  output logic [3:0][64:0] RSROBval1_o, RSROBval2_o, RSROBval3_o;
	output logic [3:0] RSWriteEn_o;
  input logic [3:0] RSstall_i;
  output logic [3:0][9:0] RSCommands_o;
  
  //regfile
  output logic	[4:0] 	regfileReadRegister1_o, regfileReadRegister2_o;
	input logic [63:0]	regfileReadData1_i, regfileReadData2_i;
  
  //completion stage
  input logic [64:0] completionRSROBval_i;
  input logic [ROBsizeLog - 1:0] completionRSROBTag_i;
  
  //from LSQ
  input logic LSQstall_i;
  output logic LSQifNew_o, LSQstoreOrLoad_o;
  
  //pick between RM and RD for the true RM value
  logic [4:0] trueRM;
	logic [1:0][4:0] addressDataToMux;
	/*integer i, j;
	always_comb begin
		for(i=0; i<5; i++) begin
			addressDataToMux[i][0] = RDvalue_i[i];
		end
		for(j=0; j<5; j++) begin
			addressDataToMux[j][1] = RMvalue_i[j];
		end
	end
	mux2x5 whatRegToRead (.out(trueRM), .addr(reg2Loc_i), .muxIns(addressDataToMux));*/
  assign addressDataToMux[0] = RDvalue_i;
  assign addressDataToMux[1] = RMvalue_i;
  assign trueRM = addressDataToMux[reg2Loc_i];
  
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
  assign robWriteData_o[8:5] = commandType_i;
  assign robWriteData_o[4:0] = RDvalue_i; //not true, needs to account for CBZ stuff
  assign robUpdateTail_o = 1;
  
  //determine if a stall in needed
  logic needAStall, ROBdontUpdate;
  logic [3:0] RSWriteEn;
  assign ROBdontUpdate = (RSstall_i[0] & RSWriteEn[0]) | (RSstall_i[1] & RSWriteEn[1]) | (RSstall_i[2] & RSWriteEn[2]) | (RSstall_i[3] & RSWriteEn[3]) | LSQstall_i;
  assign needAStall = robStall_i | ROBdontUpdate | LSQstall_i;
  assign decodeStall_o = needAStall;
  assign ROBdontUpdate_o = ROBdontUpdate;
  
  //finish the map table connections
  assign mapWriteData_o = robNextTail_i;
  assign mapRegWrite_o = regWrite_i & (~needAStall);//needs to account for loads
  
  
  //Reservation station

  
  //compare the two outputs of the map table to zero
  logic RMvalueInReg, RNvalueInReg;
  assign RNvalueInReg = (mapReadData1_i == 0);
  assign RMvalueInReg = (mapReadData2_i == 0);
  
  //check if the data is in the completion stage
  logic RMvalueInCom, RNvalueInCom;
  assign RNvalueInCom = (mapReadData1_i == completionRSROBTag_i) & robWriteEn_i;
  assign RMvalueInCom = (mapReadData2_i == completionRSROBTag_i) & robWriteEn_i;
  
  //determine if the ROB value is in the completion stage or ROB
  logic [1:0][63:0] decisionROBorComRN, decisionROBorComRM;
  assign decisionROBorComRN[0] = robReadData1_i[63:0];
  assign decisionROBorComRN[1] = completionRSROBval_i;
  assign decisionROBorComRM[0] = robReadData2_i[63:0];
  assign decisionROBorComRM[1] = completionRSROBval_i;
  
  //pick between them
  logic [63:0] ROBRNcom, ROBRMcom;
  assign ROBRNcom = decisionROBorComRN[RNvalueInCom];
  //assign RSROBval1_o = RSRNdata;
  assign ROBRMcom = decisionROBorComRM[RMvalueInCom];
  
  //determine which value to send to the RS for RN and RM, the rob or the reg
  logic [1:0][63:0] decisionROBorRegRN, decisionROBorRegRM;
  assign decisionROBorRegRN[0] = ROBRNcom;
  assign decisionROBorRegRN[1] = regfileReadData1_i;
  assign decisionROBorRegRM[0] = ROBRMcom;
  assign decisionROBorRegRM[1] = regfileReadData2_i;
  
  logic [63:0] RSRNdata, preBranchRSRM;
  assign RSRNdata = decisionROBorRegRN[RNvalueInReg];
  //assign RSROBval1_o = RSRNdata;
  assign preBranchRSRM = decisionROBorRegRM[RMvalueInReg];
  
  //determine the store tag
  logic [ROBsizeLog - 1:0] 	RSRDTag;
  always_comb begin
    if (commandType_i == 1 & ~ (RMvalueInReg | robReadData2_i[64] | RMvalueInCom))
      RSRDTag = mapReadData2_i;
    else
      RSRDTag = 0;
  end
  
  //determine if we are branching
  logic doingABranch, doingABranch_noBR;
  assign doingABranch = doingABranch_i;
  assign doingABranch_noBR = doingABranch & ~(commandType_i == 6);
  
  
  //determine the tag to associate with the RN RS data
  logic [ROBsizeLog - 1:0] 	RSRNTag;
  always_comb begin
    if (doingABranch | RNvalueInReg | robReadData1_i[64] | RNvalueInCom)
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
    if (doingABranch | RMvalueInReg | robReadData2_i[64] | ALUSrc_i | RMvalueInCom)
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
        RSROBTag3_o[g] = RSRDTag;
        RSROBval1_o[g][63:0] = RSRNdata;
        RSROBval1_o[g][64] = 0; 
        RSROBval2_o[g][63:0] = RSRMdata;
        RSROBval2_o[g][64] = 0;
        RSROBval3_o[g][63:0] = preBranchRSRM;
        RSROBval3_o[g][64] = 0;
        RSCommands_o[g] = RScommands;
		end
  end
  

  //assign each of the write enables
  assign RSWriteEn[0] = (whichMath_i == 0);// & (~robStall_i);
  assign RSWriteEn[1] = (whichMath_i == 1);// & (~robStall_i);
  assign RSWriteEn[2] = (whichMath_i == 2);// & (~robStall_i);
  assign RSWriteEn[3] = (whichMath_i == 3);// & (~robStall_i);
  
  assign RSWriteEn_o[0] = RSWriteEn[0] & (~(robStall_i | LSQstall_i));
  assign RSWriteEn_o[1] = RSWriteEn[1] & (~(robStall_i | LSQstall_i));
  assign RSWriteEn_o[2] = RSWriteEn[2] & (~(robStall_i | LSQstall_i));
  assign RSWriteEn_o[3] = RSWriteEn[3] & (~(robStall_i | LSQstall_i));
  
  //LSQ
  assign LSQifNew_o = (~decodeStall_o) & (commandType_i == 9 | commandType_i == 1);
  assign LSQstoreOrLoad_o = commandType_i == 9;

endmodule

