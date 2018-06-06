module issueExecStageALU #(parameter ROBsize = 16, ROBsizeLog = $clog2(ROBsize+1)) 
(clk_i
,reset_i

//RS inouts
,stallRS_o
,reservationStationVal1_i
,reservationStationVal2_i
,reservationStationCommands_i
,reservationStationTag_i
,readyRS_i
,RSVal3_i

//inouts to continue through execute stage
,canGo_i
,executeTag_o
,executeCommands_o
,executeVal_o
,executeFlags_o
,valid_o
,RSVal3_o
);
  input reset_i, clk_i;
  
  //Reservation station inouts
  input logic [63:0] reservationStationVal1_i, reservationStationVal2_i, RSVal3_i;
  input logic [9:0] reservationStationCommands_i;
  input logic [ROBsizeLog-1:0] reservationStationTag_i;
  input logic readyRS_i;
  output logic stallRS_o;
  
  //from the execution decision unit
  input logic canGo_i;
  output logic [63:0] executeVal_o, RSVal3_o;
  output logic [9:0] executeCommands_o;
  output logic [ROBsizeLog-1:0] executeTag_o;
  output logic [3:0] executeFlags_o;
  output logic valid_o;
  
  localparam eWaiting = 1'b0, eStalling = 1'b1;
  logic state_r, state_n;

  //state_e state_r, state_n;

  //update the state on the clock edge
  //always_ff @(posedge clk_i) begin
    //state_r <= reset_i ? eWaiting : state_n;
  //end
  always_ff @(posedge clk_i) begin
    if(reset_i)
      state_r <= eWaiting;
    else
      state_r <= state_n;   
  end
  
  //depending on the current state and control logic decide what the next state is
  always_comb begin
    //removed unique
    case (state_r)
      eWaiting: begin
        if(readyRS_i)
          state_n = eStalling;
        else
          state_n = eWaiting;
      end
      eStalling: begin
        if(canGo_i & (~readyRS_i))
          state_n = eWaiting;
        else
          state_n = eStalling;
      end
    endcase
  end

  //logic dataValid;
  //based on the current state set the control logic
  always_comb begin
    //removed unique
    case (state_r)
      eWaiting: begin
        valid_o = 0;
      end eStalling: begin
        valid_o = 1;
      end
    endcase
  end
  
  logic enableFlops;
  assign enableFlops = (state_r == eWaiting) | (state_r == eStalling & canGo_i & readyRS_i);
  
  //save the incoming data and tag when valid_in is high
  
  logic [9:0] executeCommands;
  wallOfDFFsL10 commandsWall
  (.q(executeCommands)
  ,.d(reservationStationCommands_i)
  ,.reset(reset_i)
  ,.enable(enableFlops)
  ,.clk(clk_i));
  
  logic [ROBsizeLog-1:0] executeTag;
  wallOfDFFsL5 tagWall
  (.q(executeTag)
  ,.d(reservationStationTag_i)
  ,.reset(reset_i)
  ,.enable(enableFlops)
  ,.clk(clk_i));
  
  logic [63:0] storedValue1;
  wallOfDFFsL64 storedWall1
  (.q(storedValue1)
  ,.d(reservationStationVal1_i)
  ,.reset(reset_i)
  ,.enable(enableFlops)
  ,.clk(clk_i));
  
  logic [63:0] storedValue2;
  wallOfDFFsL64 storedWall2
  (.q(storedValue2)
  ,.d(reservationStationVal2_i)
  ,.reset(reset_i)
  ,.enable(enableFlops)
  ,.clk(clk_i));
  
  
  wallOfDFFsL64 storedWall3
  (.q(RSVal3_o)
  ,.d(RSVal3_i)
  ,.reset(reset_i)
  ,.enable(enableFlops)
  ,.clk(clk_i));

  
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
  assign stallRS_o = ~enableFlops;
  //assign valid_o = readyRS_i;
  
endmodule

/*
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
  
  
  issueExecStageALU #(.ROBsize(8)) dut
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
endmodule*/

