`timescale 1ns/10ps
module issueExecStageDiv #(parameter ROBsize = 32, ROBsizeLog = $clog2(ROBsize+1)) 
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
  
  //control logic state machine
  typedef enum {eWaiting, eStalling} state_e;

  state_e state_r, state_n;

  //update the state on the clock edge
  always_ff @(posedge clk_i) begin
    state_r <= reset_i ? eWaiting : state_n;
  end
  
  //depending on the current state and control logic decide what the next state is
  always_comb begin
    unique case (state_r)
      eWaiting: state_n = readyRS_i ? eStalling : eWaiting;
      eStalling: state_n = valid_o & canGo_i & (~readyRS_i) ? eWaiting : eStalling;
    endcase
  end

  logic stallStart;
  //based on the current state set the control logic
  always_comb begin
    unique case (state_r)
      eWaiting: begin
        stallStart = 1;
      end eStalling: begin
        stallStart = 0;
      end 
    endcase
  end
  
  //determine when we can bring in new data
  logic valid_in;
  assign valid_in = (valid_o & readyRS_i & canGo_i) | (stallStart & readyRS_i);
  
  //the divider
  divider div 
  (.quotient(executeVal_o)
  ,.valid_out(valid_o)
  ,.divisor(reservationStationVal2_i)
  ,.dividend(reservationStationVal1_i)
  ,.valid_in(valid_in)
  ,.rst(reset_i)
  ,.clk(clk_i));
  
  //save the commands and tag when valid_in is high
  wallOfDFFs #(.LENGTH(10)) commandsWall
  (.q(executeCommands_o)
  ,.d(reservationStationCommands_i)
  ,.reset(reset_i)
  ,.enable(valid_in)
  ,.clk(clk_i));
  
  wallOfDFFs #(.LENGTH(ROBsizeLog)) tagWall
  (.q(executeTag_o)
  ,.d(reservationStationTag_i)
  ,.reset(reset_i)
  ,.enable(valid_in)
  ,.clk(clk_i));
  
  assign executeFlags_o = 0;
  assign stallRS_o = ~valid_in;
  
endmodule
  
module issueExecStageDiv_testbench();
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
  
  
  issueExecStageDiv #(.ROBsize(8)) dut
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