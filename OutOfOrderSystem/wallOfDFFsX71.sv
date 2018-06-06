module wallOfDFFsX71 #(parameter LENGTH=71) (q, d, reset, enable, clk);
	output logic [LENGTH-1:0] q;
	input logic [LENGTH-1:0] d;
	input logic reset, enable, clk;
	
	genvar i;
	
	//generate 64 enable DFFs all linked to one enable signal
	generate
		for(i=0; i < LENGTH; i++) begin : eachEnDff
			enableD_FF enDff (.q(q[i]), .d(d[i]), .reset, .enable, .clk);
		end
	endgenerate 
endmodule

/*
module wallOfDFFs_testbench();
	logic [63:0] q, d;
	logic clk, reset, enable;
	
	wallOfDFFs #(.LENGTH(64)) dut (.q, .d, .reset, .enable, .clk); 
	
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
				d <= 64'h1f;	@(posedge clk);
									@(posedge clk);
				d <= 0;			@(posedge clk);
				enable <= 1;	@(posedge clk);
				d <= 64'h1f;	@(posedge clk);
				d <= 0;			@(posedge clk);
				d <= 64'h1f;	//@(posedge clk);
				enable <= 0;	@(posedge clk);
				d <= 0;			@(posedge clk);
									@(posedge clk);
									@(posedge clk);				
		$stop(); // end the simulation
	end
endmodule */

