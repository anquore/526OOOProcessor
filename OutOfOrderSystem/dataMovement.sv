module dataMovement(clk, memWrite, memToReg, ALUSrc, regWrite, reg2Loc, ALUOp, valueToStore, dOrImm,
							readAddr1, readAddr2, writeAddr, dAddr9, imm12, basicAddress, negative, 
							zero, overflow, carry_out, WriteData, read_enable);
	input logic clk, memWrite, memToReg, ALUSrc, regWrite, reg2Loc, valueToStore, dOrImm, read_enable;
	input logic [4:0] readAddr1, readAddr2, writeAddr;
	input logic [8:0] dAddr9;
	input logic [11:0] imm12;
	input logic [2:0] ALUOp;
	input logic [63:0] basicAddress;
	output logic negative, zero, overflow, carry_out;
	output logic [63:0] WriteData;
	
	//choose what value to readAddr
	logic [4:0] sendToReadAddr2;
	logic [4:0][1:0] addressDataToMux;
	integer i, j;
	always_comb begin
		for(i=0; i<5; i++) begin
			addressDataToMux[i][0] = writeAddr[i];
		end
		for(j=0; j<5; j++) begin
			addressDataToMux[j][1] = readAddr2[j];
		end
	end
	mux2x5 whatRegToRead (.out(sendToReadAddr2), .addr(reg2Loc), .muxIns(addressDataToMux));
	
	//the regfile
	logic [63:0] ReadData1, ReadData2;
	regfile theReg (.ReadData1, .ReadData2, .WriteData, 
					.ReadRegister1(readAddr1), .ReadRegister2(sendToReadAddr2), .WriteRegister(writeAddr), 
					.RegWrite(regWrite), .clk);
					
	//value to send as second ALU input
	logic [63:0] dAddrExtended, B, result, immExtended, dOrImmData;
	logic [63:0][1:0] aluDataToMux0, aluDataToMux1;
	signExtend9 dAddrExtender (.valueIn(dAddr9), .extendedOut(dAddrExtended));
	signExtend12 imm12Extender (.valueIn(imm12), .extendedOut(immExtended));
	integer q, r;
	always_comb begin
		for(q=0; q<64; q++) begin
			aluDataToMux0[q][0] = dAddrExtended[q];
		end
		for(r=0; r<64; r++) begin
			aluDataToMux0[r][1] = immExtended[r];
		end
	end
	mux2x64 choosingDOrImm (.out(dOrImmData), .addr(dOrImm), .muxIns(aluDataToMux0));
	integer k, l;
	always_comb begin
		for(k=0; k<64; k++) begin
			aluDataToMux1[k][0] = ReadData2[k];
		end
		for(l=0; l<64; l++) begin
			aluDataToMux1[l][1] = dOrImmData[l];
		end
	end	
	mux2x64 valueToAlu (.out(B), .addr(ALUSrc), .muxIns(aluDataToMux1));
	alu theAlu (.A(ReadData1), .B, .cntrl(ALUOp), .result, .negative, .zero, .overflow, .carry_out);
	
	//the memory block
	logic [63:0] read_data, mightSendToReg;
	logic [63:0][1:0] regBackDataToMux;
	datamem theDataMemory (.address(result), .write_enable(memWrite), .read_enable, 
									.write_data(ReadData2), .clk, .xfer_size(4'b1000), .read_data);
	integer m, n;
	always_comb begin
		for(m=0; m<64; m++) begin
			regBackDataToMux[m][0] = result[m];
		end
		for(n=0; n<64; n++) begin
			regBackDataToMux[n][1] = read_data[n];
		end
	end
	mux2x64 sendToFinalMux (.out(mightSendToReg), .addr(memToReg), .muxIns(regBackDataToMux));
	
	//final choice mux
	logic [63:0][1:0] finalRegBackDataToMux;
	integer o, p;
	always_comb begin
		for(o=0; o<64; o++) begin
			finalRegBackDataToMux[o][0] = mightSendToReg[o];
		end
		for(p=0; p<64; p++) begin
			finalRegBackDataToMux[p][1] = basicAddress[p];
		end
	end
	mux2x64 valueToWrite (.out(WriteData), .addr(valueToStore), .muxIns(finalRegBackDataToMux));
	
endmodule

/*
module dataMovement_testbench();
	logic clk, memWrite, memToReg, ALUSrc, regWrite, reg2Loc, valueToStore, dOrImm;
	logic [4:0] readAddr1, readAddr2, writeAddr;
	logic [8:0] dAddr9;
	logic [11:0] imm12;
	logic [2:0] ALUOp;
	logic [63:0] basicAddress;
	logic negative, zero, overflow, carry_out;
	logic [63:0] WriteData;

	dataMovement dut (.clk, .memWrite, .memToReg, .ALUSrc, .regWrite, .reg2Loc, .ALUOp, .valueToStore, .dOrImm,
							.readAddr1, .readAddr2, .writeAddr, .dAddr9, .imm12, .basicAddress, .negative, 
							.zero, .overflow, .carry_out, .WriteData, .read_enable(1'b1)); //read_enable assigned fake input value to make ports match, fix later

	// Set up the clock
	parameter ClockDelay = 1000;
	initial begin ;
		clk <= 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end
	
	initial begin
	memWrite <= 0;	memToReg <= 0; regWrite <= 0; ALUSrc <= 0;
	reg2Loc <= 0; valueToStore <= 0; dAddr9 <= 0; ALUOp <= 0;
	basicAddress <= 0; imm12 <= 0;
									@(posedge clk);
									@(posedge clk);
									@(posedge clk);
									@(posedge clk);
									@(posedge clk);
									@(posedge clk);
									@(posedge clk);				
				
		$stop(); // end the simulation
	end
endmodule */

