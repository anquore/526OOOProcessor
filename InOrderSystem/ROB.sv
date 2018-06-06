`timescale 1ns/10ps
module ROB #(parameter ROBsize = 32, addrSize = $clog2(ROBsize)) 
(clk_i
,reset_i

,decodeReadAddr1_i
,decodeReadAddr2_i
,decodeReadData1_o
,decodeReadData2_o

,updateTail_i
,decodeWriteData_i
,nextTail_o
,stall_o

,completionWriteAddr_i
,completionWriteEn_i
,completionWriteData_i

,updateHead_i
,head_o
,commitReadData_o);

  input logic	[addrSize:0] 	decodeReadAddr1_i, decodeReadAddr2_i, completionWriteAddr_i;
	input logic [7:0]	decodeWriteData_i;
  input logic [69:0] completionWriteData_i;
	input logic 			reset_i, clk_i, completionWriteEn_i, updateHead_i, updateTail_i;
	output logic [64:0]	decodeReadData1_o, decodeReadData2_o;
  output logic [77:0] commitReadData_o;
  output logic [addrSize:0] nextTail_o, head_o;
  output logic stall_o;
  
  //set up some logic
  logic [addrSize-1:0]	head, tail, headNext, tailNext;
  logic stall, decodeWriteEn, tailReset;
  
  //add 2 to the head and the tail
  assign headNext = head + 1;
  assign tailNext = tailReset ? (tail+1) : tail;
  
  headTailROB #(.ROBsize(ROBsize)) headTailManager
  (.clk_i
  ,.reset_i
  ,.updateHead_i(updateHead_i)
  ,.updateTail_i(updateTail_i)
  ,.stall_o(stall)
  ,.head_o(head)
  ,.tail_o(tail)
  ,.tailReset_o(tailReset));
  
  //assign decode write enable
  assign decodeWriteEn = ~stall & updateTail_i;
  
  //set up some logic
  logic [addrSize - 1:0] 	decodeReadAddr1sub1, decodeReadAddr2sub1;
  assign decodeReadAddr1sub1 = decodeReadAddr1_i - 1;
  assign decodeReadAddr2sub1 = decodeReadAddr2_i - 1;
  
  logic [69:0] decodeReadData1, decodeReadData2;
  logic [ROBsize - 1:0] resets;
  logic [addrSize:0] completionWriteAddrsub1;
  assign completionWriteAddrsub1 = completionWriteAddr_i - 1;
  
  ROBregs #(.ROBsize(ROBsize)) theRegs
  (.clk_i
  ,.resets_i(resets)
  ,.decodeReadAddr1_i(decodeReadAddr1sub1[addrSize-1:0])
  ,.decodeReadAddr2_i(decodeReadAddr2sub1[addrSize-1:0])
  ,.decodeWriteAddr_i(tailNext)
  ,.decodeWriteEn_i(decodeWriteEn)
  ,.decodeReadData1_o(decodeReadData1)
  ,.decodeReadData2_o(decodeReadData2)
  ,.decodeWriteData_i(decodeWriteData_i)

  ,.completionWriteAddr_i(completionWriteAddrsub1[addrSize - 1:0])
  ,.completionWriteEn_i(completionWriteEn_i)
  ,.completionWriteData_i(completionWriteData_i)


  ,.commitReadAddr_i(head)
  ,.commitReadData_o(commitReadData_o));
  
  //define resets
  integer a;
  always_comb begin
		for(a=0; a<ROBsize; a++) begin
      if((head == a & updateHead_i) | reset_i) begin
        resets[a] = 1'b1;
      end
      else begin
        resets[a] = 1'b0;
      end
		end
	end
  
  //assign outputs
  assign decodeReadData1_o = decodeReadData1[64:0];
  assign decodeReadData2_o = decodeReadData2[64:0];
  assign nextTail_o = tailNext + 1;
  assign head_o = head + 1;
  assign stall_o = stall;
endmodule

module ROB_testbench();
  //ROBsize = 8
  logic	[3:0] 	decodeReadAddr1_i, decodeReadAddr2_i, completionWriteAddr_i;
	logic [7:0]	decodeWriteData_i;
  logic [69:0] completionWriteData_i;
	logic 			reset_i, clk_i, completionWriteEn_i, updateHead_i, updateTail_i;
	logic [64:0]	decodeReadData1_o, decodeReadData2_o;
  logic [77:0] commitReadData_o;
  logic [3:0] nextTail_o, head_o;
  logic stall_o;
  
  //the module
  ROB #(.ROBsize(8)) dut
  (.clk_i
  ,.reset_i
  ,.decodeReadAddr1_i
  ,.decodeReadAddr2_i
  ,.decodeReadData1_o
  ,.decodeReadData2_o
  ,.updateTail_i
  ,.decodeWriteData_i
  ,.nextTail_o
  ,.stall_o
  ,.completionWriteAddr_i
  ,.completionWriteEn_i
  ,.completionWriteData_i
  ,.updateHead_i
  ,.head_o
  ,.commitReadData_o);
  
  parameter ClockDelay = 5000;
  initial begin // Set up the clock
		clk_i <= 0;
		forever #(ClockDelay/2) clk_i <= ~clk_i;
	end
  
  integer i;
  
  initial begin
    //set everything to zero
    decodeReadAddr1_i <= 0; decodeReadAddr2_i <= 0; completionWriteAddr_i <= 0;
    decodeWriteData_i <= 0; completionWriteData_i <= 0;
    completionWriteEn_i <= 0; updateHead_i <= 0; updateTail_i <= 0;
    reset_i <= 1'b1;@(posedge clk_i);
    //flash reset
    reset_i <= 1'b0; @(posedge clk_i);
    
    //write stuff into decode
    for (i=1; i<5; i=i+1) begin
      updateTail_i <= 1;
			decodeReadAddr1_i <= i;
			decodeReadAddr2_i <= i + 1;
			decodeWriteData_i <= i*7'd1;
			@(posedge clk_i);
			
		end
    
    
    updateTail_i <= 0; @(posedge clk_i);
    //write stuff into completion
    for (i=1; i<5; i=i+1) begin
			completionWriteEn_i <= 1;
			completionWriteAddr_i <= i;
			completionWriteData_i <= i*70'd2;
			@(posedge clk_i);
		end
    
    completionWriteEn_i <= 0;@(posedge clk_i);
    // Go back and verify that the registers
		// retained the data.
		$display("%t Checking pattern.", $time);
		for (i=1; i<5; i=i+1) begin
			decodeReadAddr1_i <= i;
			decodeReadAddr2_i <= i + 1;
			@(posedge clk_i);
		end
    
    // Go back and verify that the registers
		// retained the data.
		$display("%t Checking pattern.", $time);
		for (i=0; i<2; i=i+1) begin
			updateHead_i <= 1;
			@(posedge clk_i);
		end
    updateHead_i <= 0; @(posedge clk_i);
    @(posedge clk_i);
    
    //write values to tail till it over flows
    for (i=1; i<8; i=i+1) begin
      updateTail_i <= 1;
			decodeWriteData_i <= i*7'd1;
			@(posedge clk_i);	
		end
    updateTail_i <= 0; @(posedge clk_i);
    
    
    //take off some heads
    for (i=0; i<4; i=i+1) begin
			updateHead_i <= 1;
			@(posedge clk_i);
		end
    updateHead_i <= 0; @(posedge clk_i);
    //writes some more at tail
    for (i=1; i<3; i=i+1) begin
      updateTail_i <= 1;
			decodeWriteData_i <= i*7'd1;
			@(posedge clk_i);	
		end
    updateTail_i <= 0; @(posedge clk_i);
     
    //update tail and head at the same time
    for (i=1; i<3; i=i+1) begin
      updateTail_i <= 1;
      updateHead_i <= 1;
			decodeWriteData_i <= i*7'd1;
			@(posedge clk_i);	
		end
    @(posedge clk_i);	
    $stop;
  end

endmodule