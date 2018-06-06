module reservationStationForwardExtra #(parameter ROBsize = 16, ROBsizeLog = $clog2(ROBsize+1)) 
(clk_i
,reset_i
,decodeROBTag1_i
,decodeROBTag2_i
,decodeROBTag3_i
,decodeROBTag_i
,decodeWriteEn_i
,decodeROBval1_i
,decodeROBval2_i
,decodeROBval3_i
,decodeCommands_i

,issueROBTagCom_i
,issueROBvalCom_i
,stall_i

//forwarding
,issueROBTagExec_i
,issueROBvalExec_i
,issueROBMemAccessExec_i

,issueROBTagMem_i
,issueROBvalMem_i

,reservationStationVal1_o
,reservationStationVal2_o
,reservationStationVal3_o
,reservationStationCommands_o
,reservationStationTag_o
,busy_o
,ready_o);


	input logic	[ROBsizeLog - 1:0] 	decodeROBTag1_i, decodeROBTag2_i, decodeROBTag3_i/**/, decodeROBTag_i, issueROBTagCom_i, issueROBTagExec_i, issueROBTagMem_i;
  input logic [64:0] decodeROBval1_i, decodeROBval2_i, decodeROBval3_i/**/, issueROBvalCom_i, issueROBvalExec_i, issueROBvalMem_i;
	input logic 			decodeWriteEn_i, clk_i, reset_i, stall_i, issueROBMemAccessExec_i;
  input logic [9:0] decodeCommands_i;
  output logic [63:0] reservationStationVal1_o, reservationStationVal2_o, /**/reservationStationVal3_o;
  output logic [9:0] reservationStationCommands_o;
  output logic [ROBsizeLog-1:0] reservationStationTag_o;
  output logic ready_o, busy_o;
  
  logic [202+(4*ROBsizeLog):0] reservationStationVal;
	
  //decode stage behavior
	logic [202+(4*ROBsizeLog):0] decodedWriteVal;
  
	//assign the correct values to the decoded write value
  always_comb begin
    //check if the data from the ROB is valid, assign the tag based on this
    if(decodeROBval1_i[64] == 1'b1) begin
      decodedWriteVal[203+(ROBsizeLog) + (ROBsizeLog - 1):203+(ROBsizeLog)] = 0;
    end
    else begin
      decodedWriteVal[203+(ROBsizeLog) + (ROBsizeLog - 1):203+(ROBsizeLog)] = decodeROBTag1_i;
    end
    
    if(decodeROBval2_i[64] == 1'b1) begin
      decodedWriteVal[203 + (ROBsizeLog - 1):203] = 0;
    end
    else begin
      decodedWriteVal[203 + (ROBsizeLog - 1):203] = decodeROBTag2_i;
    end
    
    if(decodeROBval3_i[64] == 1'b1) begin
      decodedWriteVal[203+2*(ROBsizeLog) + (ROBsizeLog - 1):203+2*(ROBsizeLog)] = 0;
    end
    else begin
      decodedWriteVal[203+2*(ROBsizeLog) + (ROBsizeLog - 1):203+2*(ROBsizeLog)] = decodeROBTag3_i;
    end
    
    //assign the rest of the values
    decodedWriteVal[202] = decodeWriteEn_i;
    decodedWriteVal[201:192] = decodeCommands_i;
    decodedWriteVal[191:128] = decodeROBval3_i[63:0];
    decodedWriteVal[127:64] = decodeROBval1_i[63:0];
    decodedWriteVal[63:0] = decodeROBval2_i[63:0];
    decodedWriteVal[203+(3*ROBsizeLog) + (ROBsizeLog - 1):203+(3*ROBsizeLog)] = decodeROBTag_i;
	end
  
  //issue stage behavior
	logic [202+(4*ROBsizeLog):0] issueWriteVal;
  
	//assign the correct values to the issue write value
  logic ready;
  always_comb begin
    if(stall_i | (~ready)) begin
      //if we are stalling keep this unit as busy
      issueWriteVal[202] = 1'b1;
    end 
    else begin
      issueWriteVal[202] = 1'b0;
    end
    
    //check if the issue data tag matches the tags in the RS
    if(reservationStationVal[203+2*(ROBsizeLog) + (ROBsizeLog - 1):203+2*(ROBsizeLog)] == issueROBTagExec_i & issueROBTagExec_i != 0 & ~(issueROBMemAccessExec_i)) begin
      //set the tag to zero and the reservation station value to the incoming value
      issueWriteVal[203+2*(ROBsizeLog) + (ROBsizeLog - 1):203+2*(ROBsizeLog)] = 0;
      issueWriteVal[191:128] = issueROBvalExec_i[63:0];
    end
    else if(reservationStationVal[203+2*(ROBsizeLog) + (ROBsizeLog - 1):203+2*(ROBsizeLog)] == issueROBTagMem_i & issueROBTagMem_i != 0) begin
      //set the tag to zero and the reservation station value to the incoming value
      issueWriteVal[203+2*(ROBsizeLog) + (ROBsizeLog - 1):203+2*(ROBsizeLog)] = 0;
      issueWriteVal[191:128] = issueROBvalMem_i[63:0];
    end
    else if(reservationStationVal[203+2*(ROBsizeLog) + (ROBsizeLog - 1):203+2*(ROBsizeLog)] == issueROBTagCom_i & issueROBTagCom_i != 0) begin
      //set the tag to zero and the reservation station value to the incoming value
      issueWriteVal[203+2*(ROBsizeLog) + (ROBsizeLog - 1):203+2*(ROBsizeLog)] = 0;
      issueWriteVal[191:128] = issueROBvalCom_i[63:0];
    end
    else begin
      issueWriteVal[203+2*(ROBsizeLog) + (ROBsizeLog - 1):203+2*(ROBsizeLog)] = reservationStationVal[203+2*(ROBsizeLog) + (ROBsizeLog - 1):203+2*(ROBsizeLog)];
      issueWriteVal[191:128] = reservationStationVal[191:128];
    end
    
    
    //check if the issue data tag matches the tags in the RS
    if(reservationStationVal[203+(ROBsizeLog) + (ROBsizeLog - 1):203+(ROBsizeLog)] == issueROBTagExec_i & issueROBTagExec_i != 0 & ~(issueROBMemAccessExec_i)) begin
      //set the tag to zero and the reservation station value to the incoming value
      issueWriteVal[203+(ROBsizeLog) + (ROBsizeLog - 1):203+(ROBsizeLog)] = 0;
      issueWriteVal[127:64] = issueROBvalExec_i[63:0];
    end
    else if(reservationStationVal[203+(ROBsizeLog) + (ROBsizeLog - 1):203+(ROBsizeLog)] == issueROBTagMem_i & issueROBTagMem_i != 0) begin
      //set the tag to zero and the reservation station value to the incoming value
      issueWriteVal[203+(ROBsizeLog) + (ROBsizeLog - 1):203+(ROBsizeLog)] = 0;
      issueWriteVal[127:64] = issueROBvalMem_i[63:0];
    end
    else if(reservationStationVal[203+(ROBsizeLog) + (ROBsizeLog - 1):203+(ROBsizeLog)] == issueROBTagCom_i & issueROBTagCom_i != 0) begin
      //set the tag to zero and the reservation station value to the incoming value
      issueWriteVal[203+(ROBsizeLog) + (ROBsizeLog - 1):203+(ROBsizeLog)] = 0;
      issueWriteVal[127:64] = issueROBvalCom_i[63:0];
    end
    else begin
      issueWriteVal[203+(ROBsizeLog) + (ROBsizeLog - 1):203+(ROBsizeLog)] = reservationStationVal[203+(ROBsizeLog) + (ROBsizeLog - 1):203+(ROBsizeLog)];
      issueWriteVal[127:64] = reservationStationVal[127:64];
    end
    
    
    
    if(reservationStationVal[203 + (ROBsizeLog - 1):203] == issueROBTagExec_i & issueROBTagExec_i != 0 & ~(issueROBMemAccessExec_i)) begin
      //set the tag to zero and the reservation station value to the incoming value
      issueWriteVal[203 + (ROBsizeLog - 1):203] = 0;
      issueWriteVal[63:0] = issueROBvalExec_i[63:0];
    end
    else if(reservationStationVal[203 + (ROBsizeLog - 1):203] == issueROBTagMem_i & issueROBTagMem_i != 0) begin
      //set the tag to zero and the reservation station value to the incoming value
      issueWriteVal[203 + (ROBsizeLog - 1):203] = 0;
      issueWriteVal[63:0] = issueROBvalMem_i[63:0];
    end
    else if(reservationStationVal[203 + (ROBsizeLog - 1):203] == issueROBTagCom_i & issueROBTagCom_i != 0) begin
      //set the tag to zero and the reservation station value to the incoming value
      issueWriteVal[203 + (ROBsizeLog - 1):203] = 0;
      issueWriteVal[63:0] = issueROBvalCom_i[63:0];
    end
    else begin
      issueWriteVal[203 + (ROBsizeLog - 1):203] = reservationStationVal[203 + (ROBsizeLog - 1):203];
      issueWriteVal[63:0] = reservationStationVal[63:0];
    end
    
    //assign the rest of the values
    issueWriteVal[201:192] = reservationStationVal[201:192];
    issueWriteVal[203+(3*ROBsizeLog) + (ROBsizeLog - 1):203+(3*ROBsizeLog)] = reservationStationVal[203+(3*ROBsizeLog) + (ROBsizeLog - 1):203+(3*ROBsizeLog)];
	end
  
	//determine if this RS is ready to be read at this point
  always_comb begin
    if(issueWriteVal[203 + (ROBsizeLog - 1):203] == 0 & issueWriteVal[203+(ROBsizeLog) + (ROBsizeLog - 1):203+(ROBsizeLog)] == 0 & issueWriteVal[203+2*(ROBsizeLog) + (ROBsizeLog - 1):203+2*(ROBsizeLog)] == 0 & reservationStationVal[202]) begin
      ready = 1'b1;
    end 
    else begin
      ready = 1'b0;
    end
	end
	
	logic [202+(4*ROBsizeLog):0] reservationStationIn;
  
  //depending on busy signals write from decode/issue
	always_comb begin
    if(reservationStationVal[202]) begin
      //if we are stalling keep this unit as busy
      reservationStationIn = issueWriteVal;
    end 
    else begin
      reservationStationIn = decodedWriteVal;
    end
	end
  
	//the RS regs
  wallOfDFFsL223 RSregs (.q(reservationStationVal), .d(reservationStationIn), .reset(reset_i), .enable(reservationStationVal[202] | decodeWriteEn_i), .clk(clk_i));
	
  //assign outputs
  assign reservationStationVal3_o = reservationStationIn[191:128];
  assign reservationStationVal2_o = reservationStationIn[63:0];
  assign reservationStationVal1_o = reservationStationIn[127:64];
  assign reservationStationCommands_o = reservationStationIn[201:192];
  assign reservationStationTag_o = reservationStationIn[203+(3*ROBsizeLog) + (ROBsizeLog - 1):203+(3*ROBsizeLog)];
  assign busy_o = reservationStationVal[202];
  assign ready_o = ready;
	
endmodule

/*
module reservationStation_testbench();
  //ROBsize = 8
	logic	[3:0] 	decodeROBTag1_i, decodeROBTag2_i, decodeROBTag_i, issueROBTagCom_i;
  logic [64:0] decodeROBval1_i, decodeROBval2_i, issueROBvalCom_i;
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
  ,.issueROBTagCom_i
  ,.issueROBvalCom_i
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
    decodeROBTag1_i <= 0; decodeROBTag2_i <= 0; decodeROBTag_i <= 0; issueROBTagCom_i <= 0;
    decodeROBval1_i <= 0; decodeROBval2_i <= 0; issueROBvalCom_i <= 0;
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
    issueROBTagCom_i <= 3; issueROBvalCom_i <= 65'h100000000000000f0; @(posedge clk_i);
    issueROBTagCom_i <= 4; issueROBvalCom_i <= 65'h1000000000000000c; @(posedge clk_i);
    issueROBTagCom_i <= 5; issueROBvalCom_i <= 65'h1000000000000000d; @(posedge clk_i);
    @(posedge clk_i);
    @(posedge clk_i);
    decodeWriteEn_i <= 1; decodeROBTag1_i <= 7; decodeROBTag2_i <= 7; decodeROBTag_i <= 8; decodeROBval1_i <= 65'h0000000000000000a; 
    decodeROBval2_i <= 65'h0000000000000000b; decodeCommands_i <= 10; @(posedge clk_i);
    decodeROBTag1_i <= 9; decodeROBTag2_i <= 10; decodeROBTag_i <= 11; decodeROBval1_i <= 65'h100000000000000a0; 
    decodeROBval2_i <= 65'h000000000000000b0; decodeCommands_i <= 10;@(posedge clk_i);
    @(posedge clk_i);
    issueROBTagCom_i <= 7; issueROBvalCom_i <= 65'h1000000000000000d; @(posedge clk_i);
    @(posedge clk_i);
    @(posedge clk_i);
    @(posedge clk_i);
    stall_i <= 1;
    issueROBTagCom_i <= 9; issueROBvalCom_i <= 65'h1000000000000000d; @(posedge clk_i);
    issueROBTagCom_i <= 10; issueROBvalCom_i <= 65'h1000000000000000d; @(posedge clk_i);
    @(posedge clk_i);
    @(posedge clk_i);
    stall_i <= 0;
    @(posedge clk_i);
    @(posedge clk_i);
    
    
    $stop;
  end

endmodule */

