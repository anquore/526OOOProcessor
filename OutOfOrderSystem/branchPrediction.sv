module branchPrediction
(clk_i
,reset_i
,brTaken_i
,branchAddrWrite_i
,branchAddrRead_i
,anUpdate_i
,whatToDoBranch_o
);
	input logic	[4:0] 	branchAddrRead_i, branchAddrWrite_i;
	input logic brTaken_i;
	input logic 			anUpdate_i, clk_i, reset_i;
	output logic whatToDoBranch_o;
	
	logic [31:0] decoded;
	logic reset;
  assign reset = 1'b0;
	logic [31:0] dataOut;
	//the decoder
	decoder5x32 theDecoder (.decoded, .addr(branchAddrWrite_i), .enable(anUpdate_i));
	
	//generate 32 branch predication state machines
  genvar i;
	generate
		for(i=0; i<32; i++) begin : BRstateMachine
      branchPredictionSM brPredict
      (.clk_i(clk_i)
      ,.reset_i(reset_i)
      ,.brTaken_i(brTaken_i)
      ,.update_i(decoded[i])

      ,.branchPred_o(dataOut[i])
      );
		end
	endgenerate
	
	//the mux for reading output
	mux32x1 read1 (.out(whatToDoBranch_o), .addr(branchAddrRead_i), .muxIns(dataOut));
	
endmodule

/*
module branchPrediction_testbench();
	logic	[4:0] 	branchAddrRead_i, branchAddrWrite_i;
	logic brTaken_i;
	logic 			anUpdate_i, clk_i, reset_i;
	logic whatToDoBranch_o;
	
	branchPrediction dut
  (.clk_i
  ,.reset_i
  ,.brTaken_i
  ,.branchAddrWrite_i
  ,.branchAddrRead_i
  ,.anUpdate_i
  ,.whatToDoBranch_o
  );
	
	// Set up the clock
	parameter ClockDelay = 2000;
	initial begin ;
		clk_i <= 0;
		forever #(ClockDelay/2) clk_i <= ~clk_i;
	end
	
	initial begin
				reset_i <= 1; 	branchAddrRead_i <= 0; branchAddrWrite_i <=0;
        brTaken_i <= 0; anUpdate_i <=0; @(posedge clk_i);
				reset_i <= 0; 	@(posedge clk_i);
        
        //go up and down a chain
        anUpdate_i <= 1; brTaken_i <= 0; branchAddrRead_i <= 0; branchAddrWrite_i <=0;@(posedge clk_i);
        @(posedge clk_i);
        @(posedge clk_i);
        brTaken_i <= 1; @(posedge clk_i);
        @(posedge clk_i);
        @(posedge clk_i);
        anUpdate_i <= 0;@(posedge clk_i);
        
        anUpdate_i <= 1; brTaken_i <= 0; branchAddrRead_i <= 4; branchAddrWrite_i <=4;@(posedge clk_i);
        @(posedge clk_i);
        @(posedge clk_i);
        brTaken_i <= 1; @(posedge clk_i);
        @(posedge clk_i);
        @(posedge clk_i);
        anUpdate_i <= 0;@(posedge clk_i);
        
        anUpdate_i <= 1; brTaken_i <= 0; branchAddrRead_i <= 15; branchAddrWrite_i <=15;@(posedge clk_i);
        @(posedge clk_i);
        @(posedge clk_i);
        brTaken_i <= 1; @(posedge clk_i);
        @(posedge clk_i);
        @(posedge clk_i);
        anUpdate_i <= 0;@(posedge clk_i);
        
        anUpdate_i <= 1; brTaken_i <= 0; branchAddrRead_i <= 27; branchAddrWrite_i <=27;@(posedge clk_i);
        @(posedge clk_i);
        @(posedge clk_i);
        brTaken_i <= 1; @(posedge clk_i);
        @(posedge clk_i);
        @(posedge clk_i);
        anUpdate_i <= 0;@(posedge clk_i);
        
        anUpdate_i <= 1; brTaken_i <= 0; branchAddrRead_i <= 6; branchAddrWrite_i <=23;@(posedge clk_i);
        @(posedge clk_i);
        @(posedge clk_i);
        brTaken_i <= 1; @(posedge clk_i);
        @(posedge clk_i);
        @(posedge clk_i);
        anUpdate_i <= 0;@(posedge clk_i);
			repeat(10) begin	@(posedge clk_i); end				
				
		$stop(); // end the simulation
	end
	
endmodule*/