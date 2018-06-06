module executeOutput #(parameter ROBsize = 32, ROBsizeLog = $clog2(ROBsize+1)) 
(clk_i
,reset_i

//inouts to continue through execute stage
,canGo_o
,executeTag_i
,executeCommands_i
,executeVal_i
,executeFlags_i
,valid_i

//stuff to continue to memory
,dataToMem_o
,tagToMem_o
,commandsToMem_o
,flagsToMem_o
);
  input logic reset_i, clk_i;
  
  //ports from execution units
  input logic [3:0][63:0] executeVal_i;
  input logic [3:0][9:0] executeCommands_i;
  input logic [3:0][ROBsizeLog-1:0] executeTag_i;
  input logic [3:0][3:0] executeFlags_i;
  input logic [3:0] valid_i;
  output logic canGo_o;
  
  //to memory
  output logic [63:0] dataToMem_o;
  output logic [9:0] commandsToMem_o;
  output logic [ROBsizeLog-1:0] tagToMem_o;
  output logic [3:0] flagsToMem_o;
  
  //use a priority encoder to choose between which data get sent onwards
  bsg_priority_encode_one_hot_out #(.width_p(4), .lo_to_hi_p(1)) outEncoderUnit
  (.i(valid_i)
  ,.o(canGo_o));
  
  always_comb begin
    if(canGo_o[3]) begin
      dataToMem_o = executeVal_i[3];
      commandsToMem_o = executeCommands_i[3];
      tagToMem_o = executeTag_i[3];
      flagsToMem_o = executeFlags_i[3];
    end
    else if(canGo_o[2]) begin
      dataToMem_o = executeVal_i[2];
      commandsToMem_o = executeCommands_i[2];
      tagToMem_o = executeTag_i[2];
      flagsToMem_o = executeFlags_i[2];
    end
    else if(canGo_o[1]) begin
      dataToMem_o = executeVal_i[1];
      commandsToMem_o = executeCommands_i[1];
      tagToMem_o = executeTag_i[1];
      flagsToMem_o = executeFlags_i[1];
    end
    else begin
      dataToMem_o = executeVal_i[0];
      commandsToMem_o = executeCommands_i[0];
      tagToMem_o = executeTag_i[0];
      flagsToMem_o = executeFlags_i[0];
    end
endmodule

module execOutput_testbench();
  input logic reset_i, clk_i;
  
  //ports from execution units
   logic [3:0][63:0] executeVal_i;
   logic [3:0][9:0] executeCommands_i;
   logic [3:0][ROBsizeLog-1:0] executeTag_i;
   logic [3:0][3:0] executeFlags_i;
   logic [3:0] valid_i;
   logic canGo_o;
  
  //to memory
   logic [63:0] dataToMem_o;
   logic [9:0] commandsToMem_o;
   logic [3:0] tagToMem_o;
   logic [3:0] flagsToMem_o;
  
  executeOutput #(.ROBsize(8)) dut
  (clk_i
  ,reset_i

  //inouts to continue through execute stage
  ,canGo_o
  ,executeTag_i
  ,executeCommands_i
  ,executeVal_i
  ,executeFlags_i
  ,valid_i

  //stuff to continue to memory
  ,dataToMem_o
  ,tagToMem_o
  ,commandsToMem_o
  ,flagsToMem_o
  );
  
  parameter ClockDelay = 5000;
  initial begin // Set up the clock
		clk_i <= 0;
		forever #(ClockDelay/2) clk_i <= ~clk_i;
	end
  
endmodule
  
  