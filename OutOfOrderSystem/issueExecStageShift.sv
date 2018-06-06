module issueExecStageShift #(parameter ROBsize = 16, ROBsizeLog = $clog2(ROBsize+1)) 
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
  
  //the shifter
  shifter theShifter
  (.out(executeVal_o)
  ,.shamt(storedValue2[5:0])
  ,.left(executeCommands[7])
  ,.sign(1'b0)
  ,.in(storedValue1));
  
  assign executeFlags_o = 0;
  
  //assign outputs
  assign executeTag_o = executeTag;
  assign executeCommands_o = executeCommands;
  assign stallRS_o = ~enableFlops;
  //assign valid_o = readyRS_i;
  
endmodule

