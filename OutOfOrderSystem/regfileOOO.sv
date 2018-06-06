module regfileOOO
(ReadData1
, ReadData2
, WriteData
, ReadRegister1
, ReadRegister2
, WriteRegister
, RegWrite
, clk
,regCommitReadData_o
,regCommitAddr_i
);
	input logic	[4:0] 	ReadRegister1, ReadRegister2, WriteRegister, regCommitAddr_i;
	input logic [63:0]	WriteData;
	input logic 			RegWrite, clk;
	output logic [63:0]	ReadData1, ReadData2, regCommitReadData_o;
	
	logic [31:0] decoded;
	logic reset;
  assign reset = 1'b0;
	logic [31:0][63:0] dataOut;
	logic [63:0][31:0] muxIns;
	//the decoder
	decoder5x32 theDecoder (.decoded, .addr(WriteRegister), .enable(RegWrite));
	
	//the bank of DFFs
	fullReg32x64 bankODFFs (.dataOut, .dataIn(WriteData), .reset, .enable(decoded), .clk);
	
	//flip dataOut around to send it to the muxes
	integer i,j;
	always_comb begin
		for(i=0; i<32; i++) begin
				for(j=0; j<64; j++) begin
					muxIns[j][i] = dataOut[i][j];
				end
		end
	end
	
	//the two muxes for the read outputs
	mux32x64 read1 (.out(ReadData1), .addr(ReadRegister1), .muxIns);
	mux32x64 read2 (.out(ReadData2), .addr(ReadRegister2), .muxIns);
  mux32x64 read3 (.out(regCommitReadData_o), .addr(regCommitAddr_i), .muxIns);
	
endmodule

// Test bench for Register file
/*
module regstim(); 		

	parameter ClockDelay = 5000;

	logic	[4:0] 	ReadRegister1, ReadRegister2, WriteRegister;
	logic [63:0]	WriteData;
	logic 			RegWrite, clk;
	logic [63:0]	ReadData1, ReadData2;

	integer i;

	// Your register file MUST be named "regfile".
	// Also you must make sure that the port declarations
	// match up with the module instance in this stimulus file.
	regfile dut (.ReadData1, .ReadData2, .WriteData, 
					 .ReadRegister1, .ReadRegister2, .WriteRegister,
					 .RegWrite, .clk);

	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);

	initial begin // Set up the clock
		clk <= 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end

	initial begin
		// Try to write the value 0xA0 into register 31.
		// Register 31 should always be at the value of 0.
		RegWrite <= 5'd0;
		ReadRegister1 <= 5'd0;
		ReadRegister2 <= 5'd0;
		WriteRegister <= 5'd31;
		WriteData <= 64'h00000000000000A0;
		@(posedge clk);
		
		$display("%t Attempting overwrite of register 31, which should always be 0", $time);
		RegWrite <= 1;
		@(posedge clk);

		// Write a value into each  register.
		$display("%t Writing pattern to all registers.", $time);
		for (i=0; i<31; i=i+1) begin
			RegWrite <= 0;
			ReadRegister1 <= i-1;
			ReadRegister2 <= i;
			WriteRegister <= i;
			WriteData <= i*64'h0000010204080001;
			@(posedge clk);
			
			RegWrite <= 1;
			@(posedge clk);
		end

		// Go back and verify that the registers
		// retained the data.
		$display("%t Checking pattern.", $time);
		for (i=0; i<32; i=i+1) begin
			RegWrite <= 0;
			ReadRegister1 <= i-1;
			ReadRegister2 <= i;
			WriteRegister <= i;
			WriteData <= i*64'h0000000000000100+i;
			@(posedge clk);
		end
		
		//my stuff
		@(posedge clk);
		//fill with ones
		for (i=0; i<32; i=i+1) begin
			RegWrite <= 1;
			ReadRegister1 <= i-1;
			ReadRegister2 <= i;
			WriteRegister <= i;
			WriteData <= 64'hffffffffffffffff;
			@(posedge clk);
		end
		
		//check it
		for (i=0; i<32; i=i+1) begin
			RegWrite <= 0;
			ReadRegister1 <= i-1;
			ReadRegister2 <= i;
			WriteRegister <= i;
			WriteData <= 64'h0000000000000000;
			@(posedge clk);
		end
		
		//fill with zeros
		for (i=0; i<32; i=i+1) begin
			RegWrite <= 1;
			ReadRegister1 <= i-1;
			ReadRegister2 <= i;
			WriteRegister <= i;
			WriteData <= 64'h0000000000000000;
			@(posedge clk);
		end
		
		//check it
		for (i=0; i<32; i=i+1) begin
			RegWrite <= 0;
			ReadRegister1 <= i-1;
			ReadRegister2 <= i;
			WriteRegister <= i;
			WriteData <= 64'hffffffffffffffff;
			@(posedge clk);
		end
		
		//set reg 16 
		RegWrite <= 1;
		ReadRegister1 <= 5'd16;
		ReadRegister2 <= 5'd16;
		WriteRegister <= 5'd16;
		WriteData <= 64'h1415111431181d1c;
		@(posedge clk);
		RegWrite <= 0;
		WriteData <= 64'h463ea1574938ef1c;
		@(posedge clk);
		
		//fire read during the middle of a clock cycle
		#2000;
		ReadRegister2 = 5'd15; 
		
		//fire write on and off in the middle of a clock cycle
		RegWrite = 1; #1500;
		RegWrite = 0; #1500;
		#5000;
		$stop;
	end
endmodule*/