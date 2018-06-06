`timescale 1ns/10ps
module ROBregs #(parameter ROBsize = 32, addrSize = $clog2(ROBsize)) 
(clk_i
,resets_i
,decodeReadAddr1_i
,decodeReadAddr2_i
,decodeWriteAddr_i
,decodeWriteEn_i
,decodeReadData1_o
,decodeReadData2_o
,decodeWriteData_i

,completionWriteAddr_i
,completionWriteEn_i
,completionWriteData_i


,commitReadAddr_i
,commitReadData_o);


	input logic	[addrSize - 1:0] 	decodeReadAddr1_i, decodeReadAddr2_i, decodeWriteAddr_i, completionWriteAddr_i, commitReadAddr_i;
  input logic [ROBsize - 1:0] resets_i;
	input logic [7:0]	decodeWriteData_i;
  input logic [69:0] completionWriteData_i;
	input logic 			decodeWriteEn_i, clk_i, completionWriteEn_i;
	output logic [69:0]	decodeReadData1_o, decodeReadData2_o;
  output logic [77:0] commitReadData_o;
	
  //decode stage behavior
  //management registers, handles what type of command this is and what arch reg gets written back too
	logic [ROBsize - 1:0] decodedManagement;
	logic [ROBsize - 1:0][6:0] managementDataOut;
	logic [7:0][ROBsize - 1:0] managementMuxIns;
  
	//the decode decoder
  integer a;
  always_comb begin
		for(a=0; a<ROBsize; a++) begin
      if(decodeWriteAddr_i == a & decodeWriteEn_i) begin
        decodedManagement[a] = 1'b1;
      end
      else begin
        decodedManagement[a] = 1'b0;
      end
		end
	end
  
	//decoder5x32 theManagementDecoder (.decodedManagement, .addr(decodeWriteAddr_i), .enable(decodeWriteEn_i));
	
	genvar k;
	
	//generate a collection of ROBsize different 7 bit registers each with their own enable and reset signal to hold the arch reg and what kind of command this is
	generate
		for(k=0; k<ROBsize; k++) begin : eachManagementReg
			wallOfDFFs #(.LENGTH(8)) managementReg (.q(managementDataOut[k][7:0]), .d(decodeWriteData_i[7:0]), .reset(resets_i[k]), .enable(decodedManagement[k]), .clk(clk_i));
		end
	endgenerate 
	
  
  logic [ROBsize - 1:0][69:0] completionDataOut;
  assign decodeReadData1_o = completionDataOut[decodeReadAddr1_i];
  assign decodeReadData2_o = completionDataOut[decodeReadAddr2_i];
  
  //completion stage behavior
  //value registers, holds values and valids for value and flags
	logic [ROBsize - 1:0] decodedCompletion;
	logic [69:0][ROBsize - 1:0] completionMuxIns;
  
	//the decode decoder
  integer b;
  always_comb begin
		for(b=0; b<ROBsize; b++) begin
      if(completionWriteAddr_i == b & completionWriteEn_i) begin
        decodedCompletion[b] = 1'b1;
      end
      else begin
        decodedCompletion[b] = 1'b0;
      end
		end
	end
  
	//decoder5x32 theCompletionDecoder (.decodedCompletion, .addr(decodeWriteAddr_i), .enable(decodeWriteEn_i));
	
	genvar l;
	
	//generate a collection of ROBsize different 70 bit registers each with their own enable and reset signal to holds values and valids for value and flags
	generate
		for(l=0; l<ROBsize; l++) begin : eachCompletionReg
			wallOfDFFs #(.LENGTH(70)) completionReg (.q(completionDataOut[l][69:0]), .d(completionWriteData_i[69:0]), .reset(resets_i[l]), .enable(decodedCompletion[l]), .clk(clk_i));
		end
	endgenerate 
	
  //commit behavior
  assign commitReadData_o[69:0] = completionDataOut[commitReadAddr_i];
  assign commitReadData_o[77:70] = managementDataOut[commitReadAddr_i];
	
endmodule

module ROBregs_testbench();
  //ROBsize = 8
  logic	[2:0] 	decodeReadAddr1_i, decodeReadAddr2_i, decodeWriteAddr_i, completionWriteAddr_i, commitReadAddr_i;
  logic [7:0] resets_i;
	logic [6:0]	decodeWriteData_i;
  logic [69:0] completionWriteData_i;
	logic 			decodeWriteEn_i, clk_i, completionWriteEn_i;
	logic [69:0]	decodeReadData1_o, decodeReadData2_o;
  logic [76:0] commitReadData_o;
  
  //the module
  ROBregs #(.ROBsize(8)) dut
  (.clk_i
  ,.resets_i
  ,.decodeReadAddr1_i
  ,.decodeReadAddr2_i
  ,.decodeWriteAddr_i
  ,.decodeWriteEn_i
  ,.decodeReadData1_o
  ,.decodeReadData2_o
  ,.decodeWriteData_i
  ,.completionWriteAddr_i
  ,.completionWriteEn_i
  ,.completionWriteData_i
  ,.commitReadAddr_i
  ,.commitReadData_o);
  
  parameter ClockDelay = 5000;
  initial begin // Set up the clock
		clk_i <= 0;
		forever #(ClockDelay/2) clk_i <= ~clk_i;
	end
  
  integer i;
  
  initial begin
    //set everything to zero
    decodeReadAddr1_i <= 0; decodeReadAddr2_i <= 0; decodeWriteAddr_i <= 0; completionWriteAddr_i <= 0; commitReadAddr_i <= 0;
    decodeWriteEn_i <= 0; completionWriteEn_i <= 0;
    decodeWriteData_i <= 0; completionWriteData_i <= 0;
    resets_i <= 8'b11111111;@(posedge clk_i);
    //flash reset
    resets_i <= 8'b00000000; @(posedge clk_i);
    
    //write stuff into decode
    for (i=0; i<8; i=i+1) begin
			decodeWriteEn_i <= 0;
			decodeReadAddr1_i <= i-1;
			decodeReadAddr2_i <= i;
			decodeWriteAddr_i <= i;
			decodeWriteData_i <= i*7'd1;
			@(posedge clk_i);
			
			decodeWriteEn_i <= 1;
			@(posedge clk_i);
		end
    
    //write stuff into completion
    for (i=0; i<8; i=i+1) begin
			completionWriteEn_i <= 0;
			completionWriteAddr_i <= i;
			completionWriteData_i <= i*70'd2;
			@(posedge clk_i);
			
			completionWriteEn_i <= 1;
			@(posedge clk_i);
		end
    
    // Go back and verify that the registers
		// retained the data.
		$display("%t Checking pattern.", $time);
		for (i=0; i<8; i=i+1) begin
			decodeWriteEn_i <= 0;
			decodeReadAddr1_i <= i-1;
			decodeReadAddr2_i <= i;
			decodeWriteAddr_i <= i;
			decodeWriteData_i <= i*7'd1;
			@(posedge clk_i);
		end
    
    // Go back and verify that the registers
		// retained the data.
		$display("%t Checking pattern.", $time);
		for (i=0; i<8; i=i+1) begin
			completionWriteEn_i <= 0;
			commitReadAddr_i <= i;
			@(posedge clk_i);
		end
    @(posedge clk_i);
    @(posedge clk_i);
    //do something from all three stages at the same time
    decodeWriteEn_i <= 1;
    decodeWriteAddr_i <= 3'd1;
    decodeWriteData_i <= 7'd23;
    
    completionWriteEn_i <= 1;
		completionWriteAddr_i <= 3'd2;
		completionWriteData_i <= 70'd50;
    
    resets_i[3] = 1'b1;
    
    @(posedge clk_i);
    decodeWriteEn_i <= 0;
    completionWriteEn_i <= 0;
    resets_i[3] = 1'b0;
    @(posedge clk_i);
    
    $stop;
  end

endmodule
	