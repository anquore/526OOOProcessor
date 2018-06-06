`timescale 1ns/10ps
module regReadAndWriteStage (clk, regWrite, reg2Loc, valueToStore, readAddr1, readAddr2, writeAddr, branchReadAddr, address, 
										WriteData, ReadData1, ReadData2, addr2);
	input logic clk, regWrite, reg2Loc, valueToStore;
	input logic [4:0] readAddr1, readAddr2, writeAddr, branchReadAddr;
	input logic [63:0] address, WriteData;
	output logic [63:0] ReadData1, ReadData2;
	output logic [4:0] addr2;
	
	//read and decode part
	//choose what value to readAddr
	logic [4:0] sendToReadAddr2;
	logic [4:0][1:0] addressDataToMux;
	integer i, j;
	always_comb begin
		for(i=0; i<5; i++) begin
			addressDataToMux[i][0] = branchReadAddr[i];
		end
		for(j=0; j<5; j++) begin
			addressDataToMux[j][1] = readAddr2[j];
		end
	end
	mux2x5 whatRegToRead (.out(sendToReadAddr2), .addr(reg2Loc), .muxIns(addressDataToMux));
	
	//negedge the clk
	logic notClk;
	not #5 (notClk, clk);
	
	//the regfile
	logic [63:0] mightSendToALU;
	regfile theReg (.ReadData1, .ReadData2(mightSendToALU), .WriteData, 
					.ReadRegister1(readAddr1), .ReadRegister2(sendToReadAddr2), .WriteRegister(writeAddr), 
					.RegWrite(regWrite), .clk(notClk));
	
	//final choice mux
	logic [63:0][1:0] outToALUMux;
	integer o, p;
	always_comb begin
		for(o=0; o<64; o++) begin
			outToALUMux[o][0] = mightSendToALU[o];
		end
		for(p=0; p<64; p++) begin
			outToALUMux[p][1] = address[p];
		end
	end
	mux2x64 valueToWrite (.out(ReadData2), .addr(valueToStore), .muxIns(outToALUMux));
	
	assign addr2 = sendToReadAddr2;
endmodule