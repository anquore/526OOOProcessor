`timescale 1ns/10ps
module individualReg64(q, d, reset, enable, clk);
	output logic [63:0] q;
	input logic [63:0] d;
	input logic reset, enable, clk;
	
	genvar i;
	
	//generate 64 enable DFFs all linked to one enable signal
	generate
		for(i=0; i<64; i++) begin : eachEnDff
			enableD_FF enDff (.q(q[i]), .d(d[i]), .reset, .enable, .clk);
		end
	endgenerate 
endmodule

module individualReg64_testbench();
	logic [63:0] q, d;
	logic clk, reset, enable;
	
	individualReg64 dut (.q, .d, .reset, .enable, .clk); 
	
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
endmodule