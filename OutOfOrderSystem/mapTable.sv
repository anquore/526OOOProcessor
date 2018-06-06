module mapTable #(parameter ROBsize = 16, mapValueSize = $clog2(ROBsize+1)) 
(clk
,reset
,decodeReadData1
,decodeReadData2
,decodeWriteData
,decodeReadAddr1
,decodeReadAddr2
,decodeWriteAddr
,decodeRegWrite

,resets_i
,commitReadAddr_i
,commitReadData
);
	input logic	[4:0] 	decodeReadAddr1, decodeReadAddr2, decodeWriteAddr, commitReadAddr_i;
	input logic [mapValueSize - 1:0]	decodeWriteData;
	input logic 			decodeRegWrite, clk, reset;
  input logic [31:0] resets_i;
	output logic [mapValueSize - 1:0]	decodeReadData1, decodeReadData2, commitReadData;
	
	logic [31:0] decoded, doAReset;
	logic [31:0][mapValueSize - 1:0] dataOut;
	logic [mapValueSize - 1:0][31:0] muxIns;
	//the decoder
	decoder5x32 theDecoder (.decoded, .addr(decodeWriteAddr), .enable(decodeRegWrite));
	
	genvar k;
	
	//generate a collection of 32 different mapValueSize bit registers each with
	//their own enable signal
	generate
		for(k=0; k<32; k++) begin : eachIndiReg
			wallOfDFFsL5 indiReg (.q(dataOut[k][mapValueSize - 1:0]), .d(decodeWriteData[mapValueSize - 1:0]), .reset(doAReset[k]), .enable(decoded[k]), .clk);
		end
	endgenerate 
	
	//flip dataOut around to send it to the muxes
	integer i,j;
	always_comb begin
		for(i=0; i<31; i++) begin
				for(j=0; j<mapValueSize; j++) begin
					muxIns[j][i] = dataOut[i][j];
				end
		end
    //31 is always zeros
    for(j=0; j<mapValueSize; j++) begin
      muxIns[j][31] = 0;
    end
	end
	
	//the two muxes for the read outputs
	mux32xY read1 (.out(decodeReadData1), .addr(decodeReadAddr1), .muxIns);
	mux32xY read2 (.out(decodeReadData2), .addr(decodeReadAddr2), .muxIns);
  
  //commit read out
  mux32xY commitRead (.out(commitReadData), .addr(commitReadAddr_i), .muxIns);
  
  //compare the decode write and read commit addr
  logic addrMatch;
  assign addrMatch = (decodeWriteAddr == commitReadAddr_i) & decodeRegWrite;
  
  //assign reset behavior
  integer l;
	always_comb begin
		for(l=0; l<32; l++) begin
      if(reset | (resets_i[l] & (~addrMatch)))
        doAReset[l] = 1;
      else
        doAReset[l] = 0;
		end
	end
	
endmodule

// Test bench for Register file
/*
module mapTable_testbench(); 		

	parameter ClockDelay = 5000;

	logic	[4:0] 	decodeReadAddr1, decodeReadAddr2, decodeWriteAddr, commitReadAddr_i;
	logic [3:0]	decodeWriteData;
	logic 			decodeRegWrite, clk, reset;
  logic [31:0] resets_i;
	logic [3:0]	decodeReadData1, decodeReadData2, commitReadData;

	integer i;

	// Your register file MUST be named "regfile".
	// Also you must make sure that the port declarations
	// match up with the module instance in this stimulus file.
	mapTable #(.ROBsize(8)) dut 
  (.decodeReadData1, 
  .decodeReadData2, 
  .decodeWriteData, 
  .decodeReadAddr1, 
  .decodeReadAddr2, 
  .decodeWriteAddr,
  .decodeRegWrite, 
  .clk, 
  .reset
  ,.resets_i
  ,.commitReadAddr_i
  ,.commitReadData);

	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);

	initial begin // Set up the clock
		clk <= 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end

	initial begin
		// Write a value into each  register.
    reset <= 1; resets_i <= 0; commitReadAddr_i <= 0; decodeRegWrite <= 0;@(posedge clk);
    reset <= 0; @(posedge clk);
		$display("%t Writing pattern to all registers.", $time);
		for (i=0; i<31; i=i+1) begin
			decodeRegWrite <= 0;
			decodeReadAddr1 <= i-1;
			decodeReadAddr2 <= i;
			decodeWriteAddr <= i;
			decodeWriteData <= i*4'd1;
			@(posedge clk);
			
			decodeRegWrite <= 1;
			@(posedge clk);
		end

		// Go back and verify that the registers
		// retained the data.
		$display("%t Checking pattern.", $time);
		for (i=0; i<32; i=i+1) begin
			decodeRegWrite <= 0;
			decodeReadAddr1 <= i-1;
			decodeReadAddr2 <= i;
			decodeWriteAddr <= i;
			decodeWriteData <= i*4'd1;
			@(posedge clk);
		end
		
		//my stuff
		@(posedge clk);
		//fill with ones
		for (i=0; i<32; i=i+1) begin
			decodeRegWrite <= 1;
			decodeReadAddr1 <= i-1;
			decodeReadAddr2 <= i;
			decodeWriteAddr <= i;
			decodeWriteData <= 4'hf;
			@(posedge clk);
		end
		
		//check it
		for (i=0; i<32; i=i+1) begin
			decodeRegWrite <= 0;
			decodeReadAddr1 <= i-1;
			decodeReadAddr2 <= i;
			decodeWriteAddr <= i;
			decodeWriteData <= 4'h0;
			@(posedge clk);
		end
		
		//fill with zeros
		for (i=0; i<32; i=i+1) begin
			decodeRegWrite <= 1;
			decodeReadAddr1 <= i-1;
			decodeReadAddr2 <= i;
			decodeWriteAddr <= i;
			decodeWriteData <= 4'h0;
			@(posedge clk);
		end
		
		//check it
		for (i=0; i<32; i=i+1) begin
			decodeRegWrite <= 0;
			decodeReadAddr1 <= i-1;
			decodeReadAddr2 <= i;
			decodeWriteAddr <= i;
			decodeWriteData <= 4'hf;
			@(posedge clk);
		end
    
    //play with the resets pin
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    resets_i <= 5; commitReadAddr_i <= 5; @(posedge clk);
    resets_i <= 6; commitReadAddr_i <= 6; decodeWriteAddr <= 6; decodeWriteData <= 4'h2; decodeRegWrite <= 1;@(posedge clk);
    resets_i <= 0;@(posedge clk);
    @(posedge clk);
    @(posedge clk);
    
    
		$stop;
	end
endmodule */

