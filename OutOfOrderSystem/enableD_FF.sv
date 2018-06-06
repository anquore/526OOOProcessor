module enableD_FF (q, d, reset, enable, clk);
	output logic q;
	input logic d, reset, enable, clk;
	
	logic valueToDFF;
	
	//use a mux to determine if the value of the DFF should change
	mux2_1 controlMux (.out(valueToDFF), .i0(q), .i1(d), .sel(enable));
	
	//the DFF
	D_FF theFlop (.q, .d(valueToDFF), .reset, .clk);
endmodule

/*
module enableD_FF_testbench();
	logic clk, reset, d, enable, q;
	
	enableD_FF dut (.q, .d, .reset, .enable, .clk); 
	
	// Set up the clock
	parameter ClockDelay = 100;
	initial begin ;
		clk <= 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end
	
	initial begin
	enable <= 0;	d <= 0; 
				reset <= 1; 	@(posedge clk);
				reset <= 0; 	@(posedge clk);
				d <= 1; 			@(posedge clk);
				d <= 0; 			@(posedge clk);
				enable <= 1;	@(posedge clk);
									@(posedge clk);
				d <= 1; 			@(posedge clk);
				d <= 0; 			@(posedge clk);
									@(posedge clk);
									@(posedge clk);
				d <= 1; 			@(posedge clk);
				enable <= 0;	@(posedge clk);
				d <= 0; 			@(posedge clk);
									@(posedge clk);
									@(posedge clk);
				d <= 1; 			@(posedge clk);
			enable <= 1;		@(posedge clk);
				d <= 0; 			@(posedge clk);
									@(posedge clk);
									@(posedge clk);
		$stop(); // end the simulation
	end
endmodule */

