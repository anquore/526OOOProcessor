module issueExecStageMult #(parameter ROBsize = 16, ROBsizeLog = $clog2(ROBsize+1)) 
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
  //typedef enum {eWaiting, eStalling, eDone} state_e;
  localparam [1:0] eWaiting = 2'b00, eStalling = 2'b01, eDone = 2'b10;
  logic [1:0] state_r, state_n;

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
  logic valid_out;
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
        if(valid_out)
          state_n = eDone;
        else
          state_n = eStalling;
      end
      eDone: begin
        if(canGo_i)
          state_n = eWaiting;
        else
          state_n = eDone;
      end
      default: state_n = eWaiting;
    endcase
  end

  logic stallStart;
  //based on the current state set the control logic
  always_comb begin
    //removed unique
    case (state_r)
      eWaiting: begin
        stallStart = 1;
        valid_o = 0;
      end eStalling: begin
        stallStart = 0;
        valid_o = 0;
      end eDone: begin
        stallStart = 0;
        valid_o = 1;
      end
      default: begin
        stallStart = 1;
        valid_o = 0;
      end
    endcase
  end
  
  //determine when we can bring in new data
  logic valid_in;
  assign valid_in = stallStart & readyRS_i;
  
  //the divider
  multiplier mult 
  (.out(executeVal_o)
  ,.valid_out(valid_out)
  ,.B(reservationStationVal2_i)
  ,.A(reservationStationVal1_i)
  ,.valid_in(valid_in)
  ,.rst(reset_i)
  ,.clk(clk_i));
  
  //assign valid_o = valid_out & (state_r == eStalling);
  
  //save the commands and tag when valid_in is high
  wallOfDFFsL10 commandsWall
  (.q(executeCommands_o)
  ,.d(reservationStationCommands_i)
  ,.reset(reset_i)
  ,.enable(valid_in)
  ,.clk(clk_i));
  
  wallOfDFFsL5 tagWall
  (.q(executeTag_o)
  ,.d(reservationStationTag_i)
  ,.reset(reset_i)
  ,.enable(valid_in)
  ,.clk(clk_i));
  
  assign executeFlags_o = 0;
  assign stallRS_o = ~valid_in;
  
endmodule
