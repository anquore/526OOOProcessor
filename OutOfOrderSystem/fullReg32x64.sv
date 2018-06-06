module fullReg32x64(dataOut, dataIn, reset, enable, clk);
	output logic [31:0][63:0] dataOut;
	input logic [63:0] dataIn;
	input logic [31:0] enable;
	input logic reset, clk;
	
	genvar i;
	
	//generate a collection of 31 different 64 bit registers each with
	//their own enable signal
	generate
		for(i=0; i<31; i++) begin : eachIndiReg
			individualReg64 indiReg (.q(dataOut[i][63:0]), .d(dataIn[63:0]), .reset, .enable(enable[i]), .clk);
		end
	endgenerate 
	
	//the zero register
	individualReg64 special (.q(dataOut[31][63:0]), .d(dataIn[63:0]), .reset(1'b1), .enable(enable[31]), .clk);
	//integer j;
	//always_comb begin
		//for(j=0;j<64;j++) begin
		  //dataOut[31][j] = 0;
		//end
	//end
endmodule

/*
module fullReg32x64_testbench();
	logic [31:0][63:0] dataOut; 
	logic [63:0] dataIn;
	logic [31:0] enable;
	logic clk, reset;
	
	fullReg32x64 dut (.dataOut, .dataIn, .reset, .enable, .clk); 
	
	// Set up the clock
	parameter ClockDelay = 100;
	initial begin ;
		clk <= 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end
	
	initial begin
	enable <= 0;	dataIn <= 0; 
				reset <= 1; 	@(posedge clk);
				reset <= 0; 	@(posedge clk);
									@(posedge clk);
									@(posedge clk);
				dataIn <= 64'h1f;	@(posedge clk);
									@(posedge clk);
				dataIn <= 0;			@(posedge clk);
				enable <= 1;	@(posedge clk);
				dataIn <= 64'h1f;	@(posedge clk);
				repeat(31) begin enable <= enable * 2; @(posedge clk); end
									@(posedge clk);
									@(posedge clk);
									@(posedge clk);
				enable <= 1;
				dataIn <= 0;	@(posedge clk);
				repeat(31) begin enable <= enable * 2; @(posedge clk); end
									@(posedge clk);
									@(posedge clk);
									@(posedge clk);									
				
		$stop(); // end the simulation
	end
endmodule */

