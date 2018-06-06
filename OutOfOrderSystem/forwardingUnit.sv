module forwardingUnit (currentReg1, currentReg2, ALUreg, MEMreg, currentData1, currentData2,
								ALUdata, MEMdata, regA, regB, ALUforward, MEMforward);
	input logic [4:0] currentReg1, currentReg2, ALUreg, MEMreg;
	input logic [63:0] currentData1, currentData2, ALUdata, MEMdata;
	input logic ALUforward, MEMforward;
	output logic [63:0] regA, regB;
	
	//control logic for the forwarding
	logic sendALU1, sendALU2, sendMEM1, sendMEM2;
	
	always_comb begin
		if (currentReg1 == ALUreg && ALUreg != 31 && ALUforward == 1) begin
			sendALU1 = 1'b1;
			sendMEM1 = 1'bx;
		end else if(currentReg1 == MEMreg && MEMreg != 31 && MEMforward == 1) begin
			sendALU1 = 1'b0;
			sendMEM1 = 1'b1;
		end else begin
			sendALU1 = 1'b0;
			sendMEM1 = 1'b0;
		end
		
		if (currentReg2 == ALUreg && ALUreg != 31 && ALUforward == 1) begin
			sendALU2 = 1'b1;
			sendMEM2 = 1'bx;
		end else if(currentReg2 == MEMreg && MEMreg != 31 && MEMforward == 1) begin
			sendALU2 = 1'b0;
			sendMEM2 = 1'b1;
		end else begin
			sendALU2 = 1'b0;
			sendMEM2 = 1'b0;
		end
	end
	
	//mem vs reg1 mux
	logic [63:0][1:0] memReg1;
	logic [63:0] reg1Step;
	integer i, j;
	always_comb begin
		for(i=0; i<64; i++) begin
			memReg1[i][0] = currentData1[i];
		end
		for(j=0; j<64; j++) begin
			memReg1[j][1] = MEMdata[j];
		end
	end
	mux2x64 memReg1Mux (.out(reg1Step), .addr(sendMEM1), .muxIns(memReg1));
	
	//exec vs reg1 mux
	logic [63:0][1:0] execReg1;
	integer k, l;
	always_comb begin
		for(k=0; k<64; k++) begin
			execReg1[k][0] = reg1Step[k];
		end
		for(l=0; l<64; l++) begin
			execReg1[l][1] = ALUdata[l];
		end
	end
	mux2x64 execReg1Mux (.out(regA), .addr(sendALU1), .muxIns(execReg1));
	
	//mem vs reg2 mux
	logic [63:0][1:0] memReg2;
	logic [63:0] reg2Step;
	integer m, n;
	always_comb begin
		for(m=0; m<64; m++) begin
			memReg2[m][0] = currentData2[m];
		end
		for(n=0; n<64; n++) begin
			memReg2[n][1] = MEMdata[n];
		end
	end
	mux2x64 memReg2Mux (.out(reg2Step), .addr(sendMEM2), .muxIns(memReg2));
	
	//exec vs reg2 mux
	logic [63:0][1:0] execReg2;
	integer o, p;
	always_comb begin
		for(o=0; o<64; o++) begin
			execReg2[o][0] = reg2Step[o];
		end
		for(p=0; p<64; p++) begin
			execReg2[p][1] = ALUdata[p];
		end
	end
	mux2x64 execReg2Mux (.out(regB), .addr(sendALU2), .muxIns(execReg2));
endmodule

