module D_FF (q, d, reset, clk);
	output logic q;
	input logic d, reset, clk;
	
	always_ff @(posedge clk)
		if (reset)
			q <= 0; // On reset, set to 0
		else
			q <= d; // Otherwise out = d
endmodule

/*
module D_FF_testbench();
	logic clk, reset, d, q;
	
	D_FF dut (.q, .d, .reset, .clk); 
	
	// Set up the clock
	parameter ClockDelay = 100;
	initial begin ;
		clk <= 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end
	
	initial begin
		d <= 0; reset <= 1;  @(posedge clk);
				reset <= 0; 	@(posedge clk);
				d <= 1; 			@(posedge clk);
				d <= 0; 			@(posedge clk);
									@(posedge clk);
									@(posedge clk);
		$stop(); // end the simulation
	end
endmodule */

