module ALUStage (ALUSrc, valueToStore, dOrImm, dAddr9, 
						imm12, ALUOp, A, ReadData2, negative, zero, overflow, carry_out, result);
	input logic ALUSrc, valueToStore, dOrImm;
	input logic [8:0] dAddr9;
	input logic [11:0] imm12;
	input logic [2:0] ALUOp;
	input logic [63:0] A, ReadData2;
	output logic negative, zero, overflow, carry_out;
	output logic [63:0] result;
	
	//constant value to send
	logic [63:0] dAddrExtended, B, immExtended, dOrImmData;
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
	
	//actual value to send
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
	
	//the ALU
	alu theAlu (.A, .B, .cntrl(ALUOp), .result, .negative, .zero, .overflow, .carry_out);
endmodule