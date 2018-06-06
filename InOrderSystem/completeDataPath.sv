`timescale 1ns/10ps
module completeDataPath(clk, uncondBr, brTaken, memWrite, memToReg, reset, 
								ALUOp, ALUSrc, regWrite, reg2Loc, valueToStore, dOrImm, 
								BRMI, saveCond, regRD, instr, flags, commandZero, read_enable);
	input logic clk, uncondBr, brTaken, memWrite, memToReg, reset, 
					ALUSrc, regWrite, reg2Loc, valueToStore, dOrImm, BRMI, saveCond, read_enable;
	input logic [2:0] ALUOp;
	input logic [4:0] regRD;
	output logic [11:0] instr;
	output logic [3:0] flags;
	output logic commandZero;
	
	//instruction fetch
	logic [63:0] regPC, basicAddress;
	logic [31:0] instruction;
	instructionFetch instructionGetter (.clk, .reset, .uncondBr, .brTaken, .BRMI, 
													.regPC, .instruction, .basicAddress);
	assign instr[5:0] = instruction[31:26];
	assign instr[6] = instruction[22];
	assign instr[11:7] = instruction[4:0];
	
	//data movement
	logic negative, zero, overflow, carry_out;
	dataMovement dataMover (.clk, .memWrite, .memToReg, .ALUSrc, .regWrite, .reg2Loc, .ALUOp, 
									.valueToStore, .dOrImm, .readAddr1(instruction[9:5]), .readAddr2(instruction[20:16]), 
									.writeAddr(regRD), .dAddr9(instruction[20:12]), .imm12(instruction[21:10]), .basicAddress, 
									.negative, .zero, .overflow, .carry_out, .WriteData(regPC), .read_enable);
	assign commandZero = zero;
	
	//condition flip flops
	enableD_FF nDFF (.q(flags[0]), .d(negative), .reset(1'b0), .enable(saveCond), .clk);
	enableD_FF zDFF (.q(flags[1]), .d(zero), .reset(1'b0), .enable(saveCond), .clk);
	enableD_FF oDFF (.q(flags[2]), .d(overflow), .reset(1'b0), .enable(saveCond), .clk);
	enableD_FF cDFF (.q(flags[3]), .d(carry_out), .reset(1'b0), .enable(saveCond), .clk);
	
endmodule

module completeDataPath_testbench();
	logic clk, uncondBr, brTaken, memWrite, memToReg, reset, 
					ALUSrc, regWrite, reg2Loc, valueToStore, dOrImm, BRMI, saveCond;
	logic [2:0] ALUOp;
	logic [4:0] regRD;
	logic [11:0] instr;
	logic [3:0] flags;
	logic commandZero;

	completeDataPath dut (.clk, .uncondBr, .brTaken, .memWrite, .memToReg, .reset, 
								.ALUOp, .ALUSrc, .regWrite, .reg2Loc, .valueToStore, .dOrImm,
								.BRMI, .saveCond, .regRD, .instr, .flags, .commandZero);
	assign regRD = instr[4:0]; 

	// Set up the clock
	parameter ClockDelay = 1000;
	initial begin ;
		clk <= 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end
	
	initial begin
	uncondBr <= 0; brTaken <= 0; memWrite <= 0;	memToReg <= 0; 
	regWrite <= 0; ALUSrc <= 0; reg2Loc <= 0; valueToStore <= 0;
	BRMI <= 0; saveCond <= 0; ALUOp <= 0; dOrImm <= 0;
				reset <= 1; 	@(posedge clk);
				reset <= 0; regWrite <= 1;	dOrImm <= 1; ALUSrc <= 1; ALUOp <= 2;@(posedge clk);
									@(posedge clk);
									@(posedge clk);
									@(posedge clk);
									@(posedge clk);
									regWrite <= 0; uncondBr <= 1; brTaken <= 1;@(posedge clk);
									@(posedge clk);				
				
		$stop(); // end the simulation
	end
endmodule