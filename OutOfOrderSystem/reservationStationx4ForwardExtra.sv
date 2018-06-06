module reservationStationx4ForwardExtra #(parameter ROBsize = 16, ROBsizeLog = $clog2(ROBsize+1)) 
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
  logic [3:0] RSwriteEns;
  logic [3:0] RSstalls;
  logic [3:0] RS_busy;
  logic [3:0] RS_ready;
  logic [3:0][63:0] RS_val1, RS_val2, RS_val3;
  logic [3:0][9:0] RS_commands;
  logic [3:0][ROBsizeLog-1:0] RS_tag;
  
	generate
		for(k=0; k<4; k++) begin : eachRS
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
  assign stall_o = RS_busy[0] & RS_busy[1] & RS_busy[2] & RS_busy[3];
  
	//use a priority encoder to select which RS to write to
  logic [3:0] busyFlipped, writeEncoder;
  assign busyFlipped[3] = ~RS_busy[3];
  assign busyFlipped[2] = ~RS_busy[2];
  assign busyFlipped[1] = ~RS_busy[1];
  assign busyFlipped[0] = ~RS_busy[0];
  
  //bsg_priority_encode_one_hot_out2 writeEncoderUnit
  //(.i(busyFlipped)
  //,.o(writeEncoder));
  always_comb begin
    if(busyFlipped[0])
      writeEncoder = 4'b0001;
    else if(busyFlipped[1])
      writeEncoder = 4'b0010;
    else if(busyFlipped[2])
      writeEncoder = 4'b0100;
    else if(busyFlipped[3])
      writeEncoder = 4'b1000;
    else
      writeEncoder = 4'b0000;
  end
  /*
  logic empty, full;
  logic [3:0] headOfList;
  fifo aFifo
  (.clk(clk_i)
  ,.rst(reset_i)
  ,.data_in(writeEncoder)
  ,.rd_en(~stall_i & (readyToListenToo!=0))
  ,.wr_en(decodeWriteEn_i & (writeEncoder!=0))
  ,.empty(empty)
  ,.full(full)
  ,.data_out(headOfList)
  );*/
  logic [3:0][1:0] howLongReady;
  integer i;
  
  always_ff @(posedge clk_i) begin
    for(i=0; i<4; i++) begin
      if(~RS_ready[i])
        howLongReady[i] <= 0;
      else if(RS_ready[i] & howLongReady == 3)
        howLongReady[i] <= 3;
      else
        howLongReady[i] <= howLongReady[i] + 1;
    end
  end
  
  //combine the input write enable with the priority ones
  assign RSwriteEns[3] = writeEncoder[3] & decodeWriteEn_i;
  assign RSwriteEns[2] = writeEncoder[2] & decodeWriteEn_i;
  assign RSwriteEns[1] = writeEncoder[1] & decodeWriteEn_i;
  assign RSwriteEns[0] = writeEncoder[0] & decodeWriteEn_i;
  
  //issue stage behavior
  //use a priority encoder to select which RS ready to send
  //bsg_priority_encode_one_hot_out2 outEncoderUnit
  //(.i(RS_ready)
  //,.o(readyToListenToo));
  /*always_comb begin
    if(RS_ready[0] & (headOfList == 1 | (headOfList & RS_ready)==0))
      readyToListenToo = 4'b0001;
    else if(RS_ready[1] & (headOfList == 2 | (headOfList & RS_ready)==0))
      readyToListenToo = 4'b0010;
    else if(RS_ready[2] & (headOfList == 4 | (headOfList & RS_ready)==0))
      readyToListenToo = 4'b0100;
    else if(RS_ready[3])
      readyToListenToo = 4'b1000;
    else
      readyToListenToo = 4'b0000;
  end*/
  logic [3:0] readyToListenToo;
  always_comb begin
    if(RS_ready[0] & (howLongReady[0] >= howLongReady[1] | ~RS_ready[1]) & (howLongReady[0] >= howLongReady[2] | ~RS_ready[2]) & (howLongReady[0] >= howLongReady[3] | ~RS_ready[3]))
      readyToListenToo = 4'b0001;
    else if(RS_ready[1] & (howLongReady[1] >= howLongReady[0] | ~RS_ready[0]) & (howLongReady[1] >= howLongReady[2] | ~RS_ready[2]) & (howLongReady[1] >= howLongReady[3] | ~RS_ready[3]))
      readyToListenToo = 4'b0010;
    else if(RS_ready[2] & (howLongReady[2] >= howLongReady[1] | ~RS_ready[1]) & (howLongReady[2] >= howLongReady[0] | ~RS_ready[0]) & (howLongReady[2] >= howLongReady[3] | ~RS_ready[3]))
      readyToListenToo = 4'b0100;
    else if(RS_ready[3])
      readyToListenToo = 4'b1000;
    else
      readyToListenToo = 4'b0000;
  end
  
  //combine the stall and the ready signal
  assign RSstalls[3] = (~readyToListenToo[3]) | stall_i;
  assign RSstalls[2] = (~readyToListenToo[2]) | stall_i;
  assign RSstalls[1] = (~readyToListenToo[1]) | stall_i;
  assign RSstalls[0] = (~readyToListenToo[0]) | stall_i;
  
  //the mux to pick between which RS to read out
  always_comb begin
    if(readyToListenToo[3]) begin
      reservationStationVal1_o = RS_val1[3];
      reservationStationVal2_o = RS_val2[3];
      reservationStationVal3_o = RS_val3[3];
      reservationStationCommands_o = RS_commands[3];
      reservationStationTag_o = RS_tag[3];
    end 
    else if(readyToListenToo[2]) begin
      reservationStationVal1_o = RS_val1[2];
      reservationStationVal2_o = RS_val2[2];
      reservationStationVal3_o = RS_val3[2];
      reservationStationCommands_o = RS_commands[2];
      reservationStationTag_o = RS_tag[2];
    end 
    else if(readyToListenToo[1]) begin
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
  
  assign ready_o = RS_ready[1] | RS_ready[0] | RS_ready[3] | RS_ready[2];
	
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

