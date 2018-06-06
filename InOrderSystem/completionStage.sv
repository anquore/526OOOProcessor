module completionStage #(parameter ROBsize = 32, ROBsizeLog = $clog2(ROBsize+1), addrSize = $clog2(ROBsize)) 
(clk_i
,reset_i

//data from memory stage
,dataFromMem_i
,flagsFromMem_i
,ROBTagFromMem_i
,save_cond_i

//to reservation station
,RSROBTag_o
,RSROBval_o

//to ROB
,ROBWriteAddr_o
,ROBWriteEn_o
,ROBWriteData_o
)

  //ins and outs
  input logic [63:0] dataFromMem_i;
  input logic [3:0] flagsFromMem_i;
  input logic [ROBsizeLog - 1:0] ROBTagFromMem_i;
  input logic save_cond_i;
  
  output logic	[ROBsizeLog - 1:0] 	RSROBTag_o;
  output logic [64:0] RSROBval_o;
  
  output logic	[addrSize:0] ROBWriteAddr_o;
  output logic [69:0] ROBWriteData_o;
  output logic ROBWriteEn_o;
  
  //determine the value of valid for the flags and data
  logic ROBIsZero, dataIsValid, flagsAreValid;
  assign ROBIsZero = (ROBTagFromMem_i == 0);
  assign dataIsValid = ~ROBIsZero;
  assign flagsAreValid = ~ROBIsZero & save_cond_i;
  
  
  //hook the inputs directly to the outputs for the RS
  assign RSROBval_o[63:0] = dataFromMem_i;
  assign RSROBval_o[64] = dataIsValid;
  assign RSROBTag_o = ROBTagFromMem_i;
  
  //connect the ROB outputs
  assign ROBWriteAddr_o = ROBTagFromMem_i;
  assign ROBWriteData_o[63:0] = dataFromMem_i;
  assign ROBWriteData_o[64] = dataIsValid;
  assign ROBWriteData_o[68:64] = flagsFromMem_i;
  assign ROBWriteData_o[69] = flagsAreValid;
  
endmodule