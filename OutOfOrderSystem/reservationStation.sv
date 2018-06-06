module reservationStation #(parameter ROBsize = 32, ROBsizeLog = $clog2(ROBsize+1)) 
(clk_i
,reset_i
,decodeROBTag1_i
,decodeROBTag2_i
,decodeROBTag_i
,decodeWriteEn_i
,decodeROBval1_i
,decodeROBval2_i
,decodeCommands_i

,issueROBTag_i
,issueROBval_i
,stall_i

,reservationStationVal1_o
,reservationStationVal2_o
,reservationStationCommands_o
,reservationStationTag_o
,busy_o
,ready_o);


	input logic	[ROBsizeLog - 1:0] 	decodeROBTag1_i, decodeROBTag2_i, decodeROBTag_i, issueROBTag_i;
  input logic [64:0] decodeROBval1_i, decodeROBval2_i, issueROBval_i;
	input logic 			decodeWriteEn_i, clk_i, reset_i, stall_i;
  input logic [9:0] decodeCommands_i;
  output logic [63:0] reservationStationVal1_o, reservationStationVal2_o;
  output logic [9:0] reservationStationCommands_o;
  output logic [ROBsizeLog-1:0] reservationStationTag_o;
  output logic ready_o, busy_o;
  
  logic [138+(3*ROBsizeLog):0] reservationStationVal;
	
  //decode stage behavior
	logic [138+(3*ROBsizeLog):0] decodedWriteVal;
  
	//assign the correct values to the decoded write value
  always_comb begin
    //check if the data from the ROB is valid, assign the tag based on this
    if(decodeROBval1_i[64] == 1'b1) begin
      decodedWriteVal[139+(ROBsizeLog) + (ROBsizeLog - 1):139+(ROBsizeLog)] = 0;
    end
    else begin
      decodedWriteVal[139+(ROBsizeLog) + (ROBsizeLog - 1):139+(ROBsizeLog)] = decodeROBTag1_i;
    end
    
    if(decodeROBval2_i[64] == 1'b1) begin
      decodedWriteVal[139 + (ROBsizeLog - 1):139] = 0;
    end
    else begin
      decodedWriteVal[139 + (ROBsizeLog - 1):139] = decodeROBTag2_i;
    end
    
    //assign the rest of the values
    decodedWriteVal[138] = decodeWriteEn_i;
    decodedWriteVal[137:128] = decodeCommands_i;
    decodedWriteVal[127:64] = decodeROBval1_i[63:0];
    decodedWriteVal[63:0] = decodeROBval2_i[63:0];
    decodedWriteVal[139+(2*ROBsizeLog) + (ROBsizeLog - 1):139+(2*ROBsizeLog)] = decodeROBTag_i;
	end
  
  //issue stage behavior
	logic [138+(3*ROBsizeLog):0] issueWriteVal;
  
	//assign the correct values to the issue write value
  logic ready;
  always_comb begin
    if(stall_i | (~ready)) begin
      //if we are stalling keep this unit as busy
      issueWriteVal[138] = 1'b1;
    end 
    else begin
      issueWriteVal[138] = 1'b0;
    end
    
    //check if the issue data tag matches the tags in the RS
    if(reservationStationVal[139+(ROBsizeLog) + (ROBsizeLog - 1):139+(ROBsizeLog)] == issueROBTag_i & issueROBTag_i != 0) begin
      //set the tag to zero and the reservation station value to the incoming value
      issueWriteVal[139+(ROBsizeLog) + (ROBsizeLog - 1):139+(ROBsizeLog)] = 0;
      issueWriteVal[127:64] = issueROBval_i[63:0];
    end
    else begin
      issueWriteVal[139+(ROBsizeLog) + (ROBsizeLog - 1):139+(ROBsizeLog)] = reservationStationVal[139+(ROBsizeLog) + (ROBsizeLog - 1):139+(ROBsizeLog)];
      issueWriteVal[127:64] = reservationStationVal[127:64];
    end
    
    if(reservationStationVal[139 + (ROBsizeLog - 1):139] == issueROBTag_i & issueROBTag_i != 0) begin
      //set the tag to zero and the reservation station value to the incoming value
      issueWriteVal[139 + (ROBsizeLog - 1):139] = 0;
      issueWriteVal[63:0] = issueROBval_i[63:0];
    end
    else begin
      issueWriteVal[139 + (ROBsizeLog - 1):139] = reservationStationVal[139 + (ROBsizeLog - 1):139];
      issueWriteVal[63:0] = reservationStationVal[63:0];
    end
    
    //assign the rest of the values
    issueWriteVal[137:128] = reservationStationVal[137:128];
    issueWriteVal[139+(2*ROBsizeLog) + (ROBsizeLog - 1):139+(2*ROBsizeLog)] = reservationStationVal[139+(2*ROBsizeLog) + (ROBsizeLog - 1):139+(2*ROBsizeLog)];
	end
  
	//determine if this RS is ready to be read at this point
  always_comb begin
    if(issueWriteVal[139 + (ROBsizeLog - 1):139] == 0 & issueWriteVal[139+(ROBsizeLog) + (ROBsizeLog - 1):139+(ROBsizeLog)] == 0 & reservationStationVal[138]) begin
      ready = 1'b1;
    end 
    else begin
      ready = 1'b0;
    end
	end
	
	logic [138+(3*ROBsizeLog):0] reservationStationIn;
  
  //depending on busy signals write from decode/issue
	always_comb begin
    if(reservationStationVal[138]) begin
      //if we are stalling keep this unit as busy
      reservationStationIn = issueWriteVal;
    end 
    else begin
      reservationStationIn = decodedWriteVal;
    end
	end
  
	//the RS regs
  wallOfDFFsL151 RSregs (.q(reservationStationVal), .d(reservationStationIn), .reset(reset_i), .enable(reservationStationVal[138] | decodeWriteEn_i), .clk(clk_i));
	
  //assign outputs
  assign reservationStationVal2_o = reservationStationIn[63:0];
  assign reservationStationVal1_o = reservationStationIn[127:64];
  assign reservationStationCommands_o = reservationStationIn[137:128];
  assign reservationStationTag_o = reservationStationIn[139+(2*ROBsizeLog) + (ROBsizeLog - 1):139+(2*ROBsizeLog)];
  assign busy_o = reservationStationVal[138];
  assign ready_o = ready;
	
endmodule

/*
module reservationStation_testbench();
  //ROBsize = 8
	logic	[3:0] 	decodeROBTag1_i, decodeROBTag2_i, decodeROBTag_i, issueROBTag_i;
  logic [64:0] decodeROBval1_i, decodeROBval2_i, issueROBval_i;
	logic 			decodeWriteEn_i, clk_i, reset_i, stall_i;
  logic [9:0] decodeCommands_i;
  logic [63:0] reservationStationVal1_o, reservationStationVal2_o;
  logic [9:0] reservationStationCommands_o;
  logic [3:0] reservationStationTag_o;
  logic ready_o, busy_o;
  
  reservationStation #(.ROBsize(8)) dut
  (.clk_i
  ,.reset_i
  ,.decodeROBTag1_i
  ,.decodeROBTag2_i
  ,.decodeROBTag_i
  ,.decodeWriteEn_i
  ,.decodeROBval1_i
  ,.decodeROBval2_i
  ,.decodeCommands_i
  ,.issueROBTag_i
  ,.issueROBval_i
  ,.stall_i
  ,.reservationStationVal1_o
  ,.reservationStationVal2_o
  ,.reservationStationCommands_o
  ,.reservationStationTag_o
  ,.ready_o
  ,.busy_o);
  
  parameter ClockDelay = 5000;
  initial begin // Set up the clock
		clk_i <= 0;
		forever #(ClockDelay/2) clk_i <= ~clk_i;
	end
  
  integer i;
  
  initial begin
    //set everything to zero
    decodeROBTag1_i <= 0; decodeROBTag2_i <= 0; decodeROBTag_i <= 0; issueROBTag_i <= 0;
    decodeROBval1_i <= 0; decodeROBval2_i <= 0; issueROBval_i <= 0;
    decodeWriteEn_i <= 0; stall_i <= 0;
    decodeCommands_i <= 0;
    reset_i <= 1'b1;@(posedge clk_i);
    //flash reset
    reset_i <= 1'b0; @(posedge clk_i);
    
    //send in a value to decode
    decodeWriteEn_i <= 1; decodeROBTag1_i <= 1; decodeROBTag2_i <= 2; decodeROBTag_i <= 3; decodeROBval1_i <= 65'h10f0f0f0f0f0f0f0f; 
    decodeROBval2_i <= 65'h1f0f0f0f0f0f0f0f0; decodeCommands_i <= 10; @(posedge clk_i);
    decodeWriteEn_i <= 0; @(posedge clk_i);
    @(posedge clk_i);
    @(posedge clk_i);
    @(posedge clk_i);
    decodeWriteEn_i <= 1; decodeROBTag1_i <= 4; decodeROBTag2_i <= 5; decodeROBTag_i <= 6; decodeROBval1_i <= 65'h0000000000000000a; 
    decodeROBval2_i <= 65'h0000000000000000b; decodeCommands_i <= 10; @(posedge clk_i);
    decodeWriteEn_i <= 0; @(posedge clk_i);
    @(posedge clk_i);
    issueROBTag_i <= 3; issueROBval_i <= 65'h100000000000000f0; @(posedge clk_i);
    issueROBTag_i <= 4; issueROBval_i <= 65'h1000000000000000c; @(posedge clk_i);
    issueROBTag_i <= 5; issueROBval_i <= 65'h1000000000000000d; @(posedge clk_i);
    @(posedge clk_i);
    @(posedge clk_i);
    decodeWriteEn_i <= 1; decodeROBTag1_i <= 7; decodeROBTag2_i <= 7; decodeROBTag_i <= 8; decodeROBval1_i <= 65'h0000000000000000a; 
    decodeROBval2_i <= 65'h0000000000000000b; decodeCommands_i <= 10; @(posedge clk_i);
    decodeROBTag1_i <= 9; decodeROBTag2_i <= 10; decodeROBTag_i <= 11; decodeROBval1_i <= 65'h100000000000000a0; 
    decodeROBval2_i <= 65'h000000000000000b0; decodeCommands_i <= 10;@(posedge clk_i);
    @(posedge clk_i);
    issueROBTag_i <= 7; issueROBval_i <= 65'h1000000000000000d; @(posedge clk_i);
    @(posedge clk_i);
    @(posedge clk_i);
    @(posedge clk_i);
    stall_i <= 1;
    issueROBTag_i <= 9; issueROBval_i <= 65'h1000000000000000d; @(posedge clk_i);
    issueROBTag_i <= 10; issueROBval_i <= 65'h1000000000000000d; @(posedge clk_i);
    @(posedge clk_i);
    @(posedge clk_i);
    stall_i <= 0;
    @(posedge clk_i);
    @(posedge clk_i);
    
    
    $stop;
  end

endmodule */

