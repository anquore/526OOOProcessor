module commitStage #(parameter ROBsize = 16, ROBsizeLog = $clog2(ROBsize+1), addrSize = $clog2(ROBsize)) 
(clk_i
,reset_i

//ROB links
,ROBupdateHead_o
,ROBhead_i
,ROBcommitReadData_i

//to map table
,mapResets_o
,mapCommitReadAddr_o
,mapCommitReadData_i

//to regfile
,regCommitRead_i
,regCommitAddr_o
,WriteRegister_o
,WriteData_o
,RegWrite_o

//to instr fetch
,needToRestore_o
,restorePoint_o

//to memory
,writeAddrMem_o
,writeDataMem_o
,writeEnMem_o

//to LSQ
,LSQflush_i
,LSQPC_i
,LSQretire_o

//to branch predictor
,correctBranch_o
,updateBranch_o
);

  //ins and outs
  input logic clk_i, reset_i;
  
  //ROB ports
  input logic [78:0] ROBcommitReadData_i;
  input logic [ROBsizeLog - 1:0] ROBhead_i;
  output logic ROBupdateHead_o;
  
  //map table
  input logic [ROBsizeLog - 1:0]	mapCommitReadData_i;
  output logic	[4:0] mapCommitReadAddr_o;
  output logic [31:0] mapResets_o;
  
  //regfile ports
  input logic [63:0] regCommitRead_i;
  output logic	[4:0] WriteRegister_o, regCommitAddr_o;
	output logic [63:0]	WriteData_o;
	output logic 			RegWrite_o;
  
  //instruction fetch ports
  output logic needToRestore_o;
  output logic [63:0] restorePoint_o;
  
  //memory ports
  output logic writeEnMem_o;
  output logic [63:0] writeAddrMem_o, writeDataMem_o;
  
  //LSQ
  output logic LSQretire_o;
  input logic LSQflush_i;
  input logic [63:0] LSQPC_i;
  
  //to branch predictor
  output logic correctBranch_o, updateBranch_o;

  
  //break up the ROB data
  logic [3:0] commandType;
  logic [4:0] RDvalue;
  logic flagValid;
  logic [3:0] flagData;
  logic dataValid;
  logic [63:0] theData;
  
  assign commandType = ROBcommitReadData_i[78:75];
  assign RDvalue = ROBcommitReadData_i[74:70];
  assign flagValid = ROBcommitReadData_i[69];
  assign flagData = ROBcommitReadData_i[68:65];
  assign dataValid = ROBcommitReadData_i[64];
  assign theData = ROBcommitReadData_i[63:0];
  
  //the map table behavior
  //assign the read address to RDvalue
  assign mapCommitReadAddr_o = RDvalue;
  
  //check if the value in map table and the head of the ROB match
  logic headMatch;
  assign headMatch = (ROBhead_i == mapCommitReadData_i);
  
  //determine if we want to try and reset the map table line
  integer i;
  logic [31:0] mapResets;
  logic regWrite;
	always_comb begin
		for(i=0; i<32; i++) begin
      if(i == RDvalue & headMatch & dataValid & regWrite)
        mapResets[i] = 1;
      else
        mapResets[i] = 0;
		end
	end
  assign mapResets_o = mapResets;
  
  //the ROB
  assign ROBupdateHead_o = dataValid;
  
  //the flags
  logic negative, zero, overflow, carry_out;
  enableD_FF nDFF (.d(flagData[0]), .q(negative), .reset(reset_i), .enable(flagValid), .clk(clk_i));
	enableD_FF zDFF (.d(flagData[1]), .q(zero), .reset(reset_i), .enable(flagValid), .clk(clk_i));
	enableD_FF oDFF (.d(flagData[2]), .q(overflow), .reset(reset_i), .enable(flagValid), .clk(clk_i));
	enableD_FF cDFF (.d(flagData[3]), .q(carry_out), .reset(reset_i), .enable(flagValid), .clk(clk_i));
  
  //determine what branch should have done
  logic correctBranch;
  always_comb begin
		if(RDvalue == 5'b0000) begin //B.EQ
        correctBranch = (zero);
      end 
      else if(RDvalue == 5'b0001) begin //B.NE
        correctBranch = (~zero);
      end 
      else if(RDvalue == 5'b01010) begin //B.GE
        correctBranch = (~(negative ^ overflow));
      end 
      else if(RDvalue == 5'b01011) begin//B.LT
        correctBranch = (negative ^ overflow);
      end 
      else if(RDvalue == 5'b01100) begin //B.GT
        correctBranch = (~zero & ~(negative ^ overflow));
      end 
      else begin
        correctBranch = (zero | (negative ^ overflow));
      end
	end
  
  
  //restore functionality
  //determine if a mistake was made, if it was get back to the correct point
  logic needToRestore, memWrite, updateBranch;
  logic [63:0] restorePoint;
  always_comb begin
		if(commandType == 0) begin
      //this is a math command don't need to restore
      needToRestore = 0;
      restorePoint = 0;
      //we are writing to the reg
      regWrite = 1;
      memWrite = 0;
      LSQretire_o = 0;
      updateBranch = 0;
    end
    else if(commandType == 1) begin
      //this is a store command, will be updated at a later point
      needToRestore = LSQflush_i;
      restorePoint = LSQPC_i;
      //we are not writing to the reg
      regWrite = 0;
      memWrite = 1;
      LSQretire_o = dataValid;
      updateBranch = 0;
    end
    else if (commandType == 2 | commandType == 3) begin
      //this is either a B.COND
      //if the branches don't match we need to restore
      needToRestore = correctBranch ^ commandType[0];
      restorePoint = theData;
      //we are not writing to the reg
      regWrite = 0;
      memWrite = 0;
      LSQretire_o = 0;
      updateBranch = 1;
    end
    else if(commandType == 4) begin
      //this is a CBZ we didn't take
      needToRestore = (regCommitRead_i == 0);
      restorePoint = theData;
      //we are not writing to the reg
      regWrite = 0;
      memWrite = 0;
      LSQretire_o = 0;
      updateBranch = 1;
    end
    else if(commandType == 5) begin
      //this is a CBZ we take
      needToRestore = (regCommitRead_i != 0);
      restorePoint = theData;
      //we are not writing to the reg
      regWrite = 0;
      memWrite = 0;
      LSQretire_o = 0;
      updateBranch = 1;
    end
    else if(commandType == 6) begin
      //a BR
      needToRestore = (regCommitRead_i != theData);
      restorePoint = regCommitRead_i;
      //we are not writing to the reg
      regWrite = 0;
      memWrite = 0;
      LSQretire_o = 0;
      updateBranch = 0;
    end
    else if(commandType == 7) begin
      //a BL
      needToRestore = 0;
      restorePoint = regCommitRead_i;
      //we are writing to the reg
      regWrite = 1;
      memWrite = 0;
      LSQretire_o = 0;
      updateBranch = 0;
    end
    else if(commandType == 8) begin
      //a branch 
      needToRestore = 0;
      restorePoint = 0;
      //we are not writing to the reg
      regWrite = 0;
      memWrite = 0;
      LSQretire_o = 0;
      updateBranch = 0;
    end
    else if(commandType == 9) begin
      //this is a load don't need to restore
      needToRestore = 0;
      restorePoint = 0;
      //we are writing to the reg
      regWrite = 1;
      memWrite = 0;
      LSQretire_o = dataValid;
      updateBranch = 0;
    end
    else begin
      needToRestore = 0;
      restorePoint = 0;
      //we are not writing to the reg
      regWrite = 0;
      memWrite = 0;
      LSQretire_o = 0;
      updateBranch = 0;
    end
	end
  
  //the regfile
  assign WriteRegister_o = RDvalue;
	assign WriteData_o = theData;
	assign RegWrite_o = regWrite & dataValid;
  assign regCommitAddr_o = RDvalue;
  
  assign restorePoint_o = restorePoint;
  assign needToRestore_o = needToRestore & dataValid;
  
  assign writeAddrMem_o = theData;
  assign writeEnMem_o = memWrite & dataValid;
  assign writeDataMem_o = regCommitRead_i;
  
  assign updateBranch_o = updateBranch & dataValid;
  assign correctBranch_o = correctBranch;
  
endmodule

