module memStage (clk, memWrite, read_enable, memToReg, ReadData2, address, mightSendToReg, reset);
	input logic clk, memWrite, read_enable, memToReg, reset;
	input logic [63:0] ReadData2, address;
	output logic [63:0] mightSendToReg;
	
	//the memory block
	logic [63:0] read_data;
	logic [63:0][1:0] regBackDataToMux;
	datamem theDataMemory (.address, .write_enable(memWrite), .read_enable, 
									.write_data(ReadData2), .clk, .xfer_size(4'b1000), .read_data, .reset);
									
	//decides who gets sent to the reg
	integer m, n;
	always_comb begin
		for(m=0; m<64; m++) begin
			regBackDataToMux[m][0] = address[m];
		end
		for(n=0; n<64; n++) begin
			regBackDataToMux[n][1] = read_data[n];
		end
	end
	mux2x64 sendToFinalMux (.out(mightSendToReg), .addr(memToReg), .muxIns(regBackDataToMux));
endmodule