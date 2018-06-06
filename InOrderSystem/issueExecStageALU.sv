`timescale 1ns/10ps
module issueExecStageALU #(parameter ROBsize = 32, ROBsizeLog = $clog2(ROBsize+1)) 
(clk_i
,reset_i

//RS inouts
,stallRS_o
,reservationStationVal1_i
,reservationStationVal2_i
,reservationStationCommands_i
,reservationStationTag_i
,readyRS_i

//inouts to continue through execute stage
,canGo_i
,executeTag_o
,executeCommands_o
,executeVal_o
,executeFlags_o
,valid_o
);
  input reset_i, clk_i;
  
  //Reservation station inouts
  input logic [63:0] reservationStationVal1_i, reservationStationVal2_i;
  input logic [9:0] reservationStationCommands_i;
  input logic [ROBsizeLog-1:0] reservationStationTag_i;
  input logic readyRS_i;
  output logic stallRS_o;
  
  //from the execution decision unit
  input logic canGo_i;
  output logic [63:0] executeVal_o;
  output logic [9:0] executeCommands_o;
  output logic [ROBsizeLog-1:0] executeTag_o;
  output logic [3:0] executeFlags_o;
  output logic valid_o;
  
  //save the incoming data and tag when valid_in is high
  logic [9:0] executeCommands;
  wallOfDFFs #(.LENGTH(10)) commandsWall
  (.q(executeCommands)
  ,.d(reservationStationCommands_i)
  ,.reset(reset_i)
  ,.enable(~canGo_i)
  ,.clk(clk_i));
  
  wallOfDFFs #(.LENGTH(ROBsizeLog)) tagWall
  (.q(executeTag)
  ,.d(reservationStationTag_i)
  ,.reset(reset_i)
  ,.enable(canGo_i)
  ,.clk(clk_i));
  
  logic [63:0] storedValue1;
  wallOfDFFs #(.LENGTH(64)) storedWall1
  (.q(storedValue1)
  ,.d(reservationStationVal1_i)
  ,.reset(reset_i)
  ,.enable(canGo_i)
  ,.clk(clk_i));
  
  logic [63:0] storedValue2;
  wallOfDFFs #(.LENGTH(64)) storedWall2
  (.q(storedValue2)
  ,.d(reservationStationVal2_i)
  ,.reset(reset_i)
  ,.enable(canGo_i)
  ,.clk(clk_i));
  
  //ready signal
  logic storedReady;
  enableD_FF readyStorage
  (.q(storedReady)
  ,.d(readyRS_i)
  ,.reset(reset_i)
  ,.enable(canGo_i)
  ,.clk(clk_i);

  
  //the ALU
  alu theALU 
  (.A(storedValue1)
  ,.B(storedValue2)
  ,.cntrl(executeCommands[4:2])
  ,.result(executeVal_o)
  ,.negative(executeFlags_o[0])
  ,.zero(executeFlags_o[1])
  ,.overflow(executeFlags_o[2])
  ,.carry_out(executeFlags_o[3]));
  

  //assign outputs
  assign executeTag_o = executeTag;
  assign executeCommands_o = executeCommands;
  assign stallRS_o = ~canGo_i;
  assign valid_o = storedReady;
  
endmodule

module issueExecStageALU_testbench();
  //Reservation station inouts
  logic clk_i, reset_i;
  logic [63:0] reservationStationVal1_i, reservationStationVal2_i;
  logic [9:0] reservationStationCommands_i;
  logic [3:0] reservationStationTag_i;
  logic readyRS_i;
  logic stallRS_o;
  
  //from the execution decision unit
  logic canGo_i;
  logic [63:0] executeVal_o;
  logic [9:0] executeCommands_o;
  logic [3:0] executeTag_o;
  logic valid_o;
  
  
  issueExecStageALU (#(.ROBsize(8)) dut
  (.clk_i
  ,.reset_i

  //RS inouts
  ,.stallRS_o
  ,.reservationStationVal1_i
  ,.reservationStationVal2_i
  ,.reservationStationCommands_i
  ,.reservationStationTag_i
  ,.readyRS_i

  //inouts to continue through execute stage
  ,.canGo_i
  ,.executeTag_o
  ,.executeCommands_o
  ,.executeVal_o
  ,.valid_o
  );
  
  parameter ClockDelay = 5000;
  initial begin // Set up the clock
		clk_i <= 0;
		forever #(ClockDelay/2) clk_i <= ~clk_i;
	end
  
  integer i;
  
  initial begin
    //set everything to zero
    reservationStationVal1_i <= 0; reservationStationVal2_i <= 0; reservationStationCommands_i <= 0; reservationStationTag_i <= 0;
    readyRS_i <= 0; canGo_i <= 0;
    reset_i <= 1'b1;@(posedge clk_i);
    //flash reset
    reset_i <= 1'b0; @(posedge clk_i);
    
    @(posedge clk_i);
    @(posedge clk_i);
    @(posedge clk_i);
    reservationStationVal1_i <= 15; reservationStationVal2_i <= 3; reservationStationCommands_i <= 10; reservationStationTag_i <= 3;
    readyRS_i <= 1;
    
    repeat(10) begin @(posedge clk_i); end

  end
endmodule