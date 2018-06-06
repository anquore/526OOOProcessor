module memStage (clk, memWrite, read_enable, memToReg, ReadData2, addressLoad, addressStore, mightSendToReg
,dmem_readData
,dmem_WriteData
,dmem_addressLoad
,dmem_addressStore
,dmem_readEn
,dmem_writeEn);
	input logic clk, memWrite, read_enable, memToReg;
	input logic [63:0] ReadData2, addressLoad, addressStore;
	output logic [63:0] mightSendToReg;
  
  //data memory
  input logic [63:0] dmem_readData;
  output logic [63:0] dmem_WriteData, dmem_addressLoad, dmem_addressStore;
  output logic dmem_readEn, dmem_writeEn;
  
	
	//the memory block
	logic [63:0] read_data;
	logic [63:0][1:0] regBackDataToMux;
  
  assign dmem_addressLoad = addressLoad;
  assign dmem_addressStore = addressStore;
  assign dmem_readEn = read_enable;
  assign dmem_writeEn = memWrite;
  assign dmem_WriteData = ReadData2;
  assign read_data = dmem_readData;
	//datamem theDataMemory (.addressLoad, .addressStore, .write_enable(memWrite), .read_enable, 
									//.write_data(ReadData2), .clk, .xfer_size(4'b1000), .read_data);
									
	//decides who gets sent to the reg
	integer m, n;
	always_comb begin
		for(m=0; m<64; m++) begin
			regBackDataToMux[m][0] = addressLoad[m];
		end
		for(n=0; n<64; n++) begin
			regBackDataToMux[n][1] = read_data[n];
		end
	end
	mux2x64 sendToFinalMux (.out(mightSendToReg), .addr(memToReg), .muxIns(regBackDataToMux));
endmodule

