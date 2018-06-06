module reservationStationx2ForwardExtra #(parameter ROBsize = 16, ROBsizeLog = $clog2(ROBsize+1)) 
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
,stall_o

,issueROBTagCom_i
,issueROBvalCom_i

//forwarding
,issueROBTagExec_i
,issueROBvalExec_i
,issueROBMemAccessExec_i

,issueROBTagMem_i
,issueROBvalMem_i

,stall_i
,reservationStationVal1_o
,reservationStationVal2_o
,reservationStationVal3_o
,reservationStationCommands_o
,reservationStationTag_o
,ready_o);


	input logic	[ROBsizeLog - 1:0] 	decodeROBTag1_i, decodeROBTag2_i, decodeROBTag3_i, decodeROBTag_i, issueROBTagCom_i, issueROBTagExec_i, issueROBTagMem_i;
  input logic [64:0] decodeROBval1_i, decodeROBval2_i, decodeROBval3_i, issueROBvalCom_i, issueROBvalExec_i, issueROBvalMem_i;
	input logic 			decodeWriteEn_i, clk_i, reset_i, stall_i, issueROBMemAccessExec_i;
  input logic [9:0] decodeCommands_i;
  output logic [63:0] reservationStationVal1_o, reservationStationVal2_o, reservationStationVal3_o;
  output logic [9:0] reservationStationCommands_o;
  output logic [ROBsizeLog-1:0] reservationStationTag_o;
  output logic ready_o, stall_o;
	
  //the two reservation stations
  genvar k;
  logic [1:0] RSwriteEns;
  logic [1:0] RSstalls;
  logic [1:0] RS_busy;
  logic [1:0] RS_ready;
  logic [1:0][63:0] RS_val1, RS_val2, RS_val3;
  logic [1:0][9:0] RS_commands;
  logic [1:0][ROBsizeLog-1:0] RS_tag;
  
	generate
		for(k=0; k<2; k++) begin : eachManagementReg
			reservationStationForwardExtra aRS 
      (.clk_i
      ,.reset_i
      ,.decodeROBTag1_i
      ,.decodeROBTag2_i
      ,.decodeROBTag3_i
      ,.decodeROBTag_i
      ,.decodeWriteEn_i(RSwriteEns[k])
      ,.decodeROBval1_i
      ,.decodeROBval2_i
      ,.decodeROBval3_i
      ,.decodeCommands_i

      ,.issueROBTagCom_i
      ,.issueROBvalCom_i
      ,.stall_i(RSstalls[k])
      
      ,.issueROBTagExec_i
      ,.issueROBvalExec_i
      ,.issueROBMemAccessExec_i

      ,.issueROBTagMem_i
      ,.issueROBvalMem_i

      ,.reservationStationVal1_o(RS_val1[k])
      ,.reservationStationVal2_o(RS_val2[k])
      ,.reservationStationVal3_o(RS_val3[k])
      ,.reservationStationCommands_o(RS_commands[k])
      ,.reservationStationTag_o(RS_tag[k])
      ,.busy_o(RS_busy[k])
      ,.ready_o(RS_ready[k]));
		end
	endgenerate
  
  
  //decode stage behavior
  //if all the RS's are busy set stall high
  assign stall_o = RS_busy[0] & RS_busy[1];
  
	//use a priority encoder to select which RS to write to
  logic [1:0] busyFlipped, writeEncoder;
  assign busyFlipped[1] = ~RS_busy[1];
  assign busyFlipped[0] = ~RS_busy[0];
  
  //bsg_priority_encode_one_hot_out2 writeEncoderUnit
  //(.i(busyFlipped)
  //,.o(writeEncoder));
  always_comb begin
    if(busyFlipped[0])
      writeEncoder = 2'b01;
    else if(busyFlipped[1])
      writeEncoder = 2'b10;
    else
      writeEncoder = 2'b00;
  end
  
  //combine the input write enable with the priority ones
  assign RSwriteEns[1] = writeEncoder[1] & decodeWriteEn_i;
  assign RSwriteEns[0] = writeEncoder[0] & decodeWriteEn_i;
  
  //issue stage behavior
  //use a priority encoder to select which RS ready to send
  logic [1:0] readyToListenToo;
  //bsg_priority_encode_one_hot_out2 outEncoderUnit
  //(.i(RS_ready)
  //,.o(readyToListenToo));
  always_comb begin
    if(RS_ready[0])
      readyToListenToo = 2'b01;
    else if(RS_ready[1])
      readyToListenToo = 2'b10;
    else
      readyToListenToo = 2'b00;
  end
  
  //combine the stall and the ready signal
  assign RSstalls[1] = (~readyToListenToo[1]) | stall_i;
  assign RSstalls[0] = (~readyToListenToo[0]) | stall_i;
  
  //the mux to pick between which RS to read out
  always_comb begin
    if(readyToListenToo[1]) begin
      reservationStationVal1_o = RS_val1[1];
      reservationStationVal2_o = RS_val2[1];
      reservationStationVal3_o = RS_val3[1];
      reservationStationCommands_o = RS_commands[1];
      reservationStationTag_o = RS_tag[1];
    end 
    else begin
      reservationStationVal1_o = RS_val1[0];
      reservationStationVal2_o = RS_val2[0];
      reservationStationVal3_o = RS_val3[0];
      reservationStationCommands_o = RS_commands[0];
      reservationStationTag_o = RS_tag[0];
    end
	end
  
  assign ready_o = RS_ready[1] | RS_ready[0];
	
endmodule

/*
module reservationStationx2_testbench();
  //ROBsize = 8
  logic	[3:0] 	decodeROBTag1_i, decodeROBTag2_i, decodeROBTag_i, issueROBTag_i;
  logic [64:0] decodeROBval1_i, decodeROBval2_i, issueROBval_i;
	logic 			decodeWriteEn_i, clk_i, reset_i, stall_i;
  logic [9:0] decodeCommands_i;
  logic [63:0] reservationStationVal1_o, reservationStationVal2_o;
  logic [9:0] reservationStationCommands_o;
  logic [3:0] reservationStationTag_o;
  logic ready_o, stall_o;
  
  reservationStationx2 #(.ROBsize(8)) dut
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
  ,.stall_o
  ,.ready_o);
  
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
    
    //send 5 ready values to decode
    decodeWriteEn_i <= 1; decodeROBTag1_i <= 1; decodeROBTag2_i <= 2; decodeROBTag_i <= 3; decodeROBval1_i <= 65'h1000000000000000a; 
    decodeROBval2_i <= 65'h1000000000000000b; decodeCommands_i <= 10; @(posedge clk_i);
    
    decodeWriteEn_i <= 1; decodeROBTag1_i <= 4; decodeROBTag2_i <= 5; decodeROBTag_i <= 6; decodeROBval1_i <= 65'h1000000000000000c; 
    decodeROBval2_i <= 65'h1000000000000000d; decodeCommands_i <= 10; @(posedge clk_i);
    
    decodeWriteEn_i <= 1; decodeROBTag1_i <= 7; decodeROBTag2_i <= 8; decodeROBTag_i <= 9; decodeROBval1_i <= 65'h1000000000000000e; 
    decodeROBval2_i <= 65'h1000000000000000f; decodeCommands_i <= 10; @(posedge clk_i);
    
    decodeWriteEn_i <= 1; decodeROBTag1_i <= 10; decodeROBTag2_i <= 11; decodeROBTag_i <= 12; decodeROBval1_i <= 65'h100000000000000a0; 
    decodeROBval2_i <= 65'h100000000000000b0; decodeCommands_i <= 10; @(posedge clk_i);
    
    decodeWriteEn_i <= 1; decodeROBTag1_i <= 13; decodeROBTag2_i <= 14; decodeROBTag_i <= 15; decodeROBval1_i <= 65'h100000000000000c0; 
    decodeROBval2_i <= 65'h100000000000000d0; decodeCommands_i <= 10; @(posedge clk_i);
    
    decodeWriteEn_i <= 0; @(posedge clk_i);
    @(posedge clk_i);
    @(posedge clk_i);
    @(posedge clk_i);
    
    //write in some non-ready values
    decodeWriteEn_i <= 1; decodeROBTag1_i <= 1; decodeROBTag2_i <= 2; decodeROBTag_i <= 3; decodeROBval1_i <= 65'h0000000000000000a; 
    decodeROBval2_i <= 65'h0000000000000000b; decodeCommands_i <= 10; @(posedge clk_i);
    
    decodeWriteEn_i <= 1; decodeROBTag1_i <= 4; decodeROBTag2_i <= 5; decodeROBTag_i <= 6; decodeROBval1_i <= 65'h0000000000000000c; 
    decodeROBval2_i <= 65'h0000000000000000d; decodeCommands_i <= 10; @(posedge clk_i);
    
    decodeWriteEn_i <= 1; decodeROBTag1_i <= 7; decodeROBTag2_i <= 8; decodeROBTag_i <= 9; decodeROBval1_i <= 65'h0000000000000000e; 
    decodeROBval2_i <= 65'h0000000000000000f; decodeCommands_i <= 10; @(posedge clk_i);
    @(posedge clk_i);
    issueROBTag_i <= 1; issueROBval_i <= 65'h100000000000000a0; @(posedge clk_i);
    issueROBTag_i <= 2; issueROBval_i <= 65'h100000000000000b0; @(posedge clk_i);
    issueROBTag_i <= 4; issueROBval_i <= 65'h100000000000000c0; @(posedge clk_i);
    decodeWriteEn_i <= 0; issueROBTag_i <= 5; issueROBval_i <= 65'h100000000000000d0; @(posedge clk_i);
    issueROBTag_i <= 7; issueROBval_i <= 65'h100000000000000e0; @(posedge clk_i);
    issueROBTag_i <= 8; issueROBval_i <= 65'h100000000000000f0; @(posedge clk_i);
    @(posedge clk_i);
    @(posedge clk_i);
    
    //testing what happens when we send out two instructions at the same time
    decodeWriteEn_i <= 1; decodeROBTag1_i <= 10; decodeROBTag2_i <= 10; decodeROBTag_i <= 11; decodeROBval1_i <= 65'h0000000000000000a; 
    decodeROBval2_i <= 65'h0000000000000000b; decodeCommands_i <= 10; @(posedge clk_i);
    decodeWriteEn_i <= 1; decodeROBTag1_i <= 10; decodeROBTag2_i <= 10; decodeROBTag_i <= 11; decodeROBval1_i <= 65'h0000000000000000a; 
    decodeROBval2_i <= 65'h0000000000000000b; decodeCommands_i <= 10; @(posedge clk_i);

    decodeWriteEn_i <= 0;@(posedge clk_i);
    issueROBTag_i <= 10; issueROBval_i <= 65'h1000000000000000d; @(posedge clk_i);
    @(posedge clk_i);
    @(posedge clk_i);
    @(posedge clk_i);
    stall_i <= 1;
    decodeWriteEn_i <= 1; decodeROBTag1_i <= 1; decodeROBTag2_i <= 2; decodeROBTag_i <= 3; decodeROBval1_i <= 65'h1000000000000000a; 
    decodeROBval2_i <= 65'h1000000000000000b; decodeCommands_i <= 10; @(posedge clk_i);
    
    decodeWriteEn_i <= 1; decodeROBTag1_i <= 4; decodeROBTag2_i <= 5; decodeROBTag_i <= 6; decodeROBval1_i <= 65'h1000000000000000c; 
    decodeROBval2_i <= 65'h1000000000000000d; decodeCommands_i <= 10; @(posedge clk_i);
    decodeWriteEn_i <= 0;@(posedge clk_i);
    stall_i <= 0;
    @(posedge clk_i);
    @(posedge clk_i);
    @(posedge clk_i);
    
    $stop;
  end

endmodule */

