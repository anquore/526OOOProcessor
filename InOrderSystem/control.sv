module control(instr, flags, commandZero, uncondBr, brTaken, memWrite, memToReg,
								ALUOp, ALUSrc, regWrite, reg2Loc, valueToStore, dOrImm, 
								BRMI, saveCond, regRD, read_enable, needToForward, negative, overflow, whichFlags, zero, carry_out, whichMath, leftShift, mult, div);
	input logic [17:0] instr;
	input logic [3:0] flags;
	input logic commandZero, negative, overflow, whichFlags, zero, carry_out;
	output logic uncondBr, brTaken, memWrite, memToReg, 
					ALUSrc, regWrite, reg2Loc, valueToStore, dOrImm, BRMI, saveCond, read_enable, needToForward, leftShift, mult, div;
  output logic [1:0] whichMath;
	output logic [2:0] ALUOp;
	output logic [4:0] regRD;
	
	//the control logic
	always_comb begin
		//ADDI
		if(instr[10:1] == 10'b1001000100) begin //addi
			reg2Loc = 1'bx;
			regWrite = 1;
			dOrImm = 1;
			ALUSrc = 1;
			ALUOp = 2;
			memWrite = 0;
			memToReg = 0;
			valueToStore = 0; 
			uncondBr = 1'bx; 
			brTaken = 0;
			BRMI = 0;
			saveCond = 0;
			regRD = instr[17:12];
			read_enable = 0;
			needToForward = 1;
      whichMath = 0;
      leftShift = 1'bx;
      mult = 1'b0;
      div = 1'b0;
		end
		else if (instr[10:0] == 11'b11101011000) begin //subs
			reg2Loc = 1;
			regWrite = 1;
			dOrImm = 0;
			ALUSrc = 0;
			ALUOp = 3;
			memWrite = 0;
			memToReg = 0;
			valueToStore = 0; 
			uncondBr = 1'bx; 
			brTaken = 0;
			BRMI = 0;
			saveCond = 1;
			regRD = instr[17:12];
			read_enable = 0;
			needToForward = 1;
      whichMath = 0;
      leftShift = 1'bx;
      mult = 1'b0;
      div = 1'b0;
		end
    else if (instr[10:0] == 11'b11001011000) begin //sub
			reg2Loc = 1;
			regWrite = 1;
			dOrImm = 0;
			ALUSrc = 0;
			ALUOp = 3;
			memWrite = 0;
			memToReg = 0;
			valueToStore = 0; 
			uncondBr = 1'bx; 
			brTaken = 0;
			BRMI = 0;
			saveCond = 0;
			regRD = instr[17:12];
			read_enable = 0;
			needToForward = 1;
      whichMath = 0;
      leftShift = 1'bx;
      mult = 1'b0;
      div = 1'b0;
		end
		else if (instr[10:0] == 11'b10101011000) begin //adds
			reg2Loc = 1;
			regWrite = 1;
			dOrImm = 0;
			ALUSrc = 0;
			ALUOp = 2;
			memWrite = 0;
			memToReg = 0;
			valueToStore = 0; 
			uncondBr = 1'bx; 
			brTaken = 0;
			BRMI = 0;
			saveCond = 1;
			regRD = instr[17:12];
			read_enable = 0;
			needToForward = 1;
      whichMath = 0;
      leftShift = 1'bx;
      mult = 1'b0;
      div = 1'b0;
		end
    else if (instr[10:0] == 11'b10001011000) begin //add
			reg2Loc = 1;
			regWrite = 1;
			dOrImm = 0;
			ALUSrc = 0;
			ALUOp = 2;
			memWrite = 0;
			memToReg = 0;
			valueToStore = 0; 
			uncondBr = 1'bx; 
			brTaken = 0;
			BRMI = 0;
			saveCond = 0;
			regRD = instr[17:12];
			read_enable = 0;
			needToForward = 1;
      whichMath = 0;
      leftShift = 1'bx;
      mult = 1'b0;
      div = 1'b0;
		end
    else if (instr[10:0] == 11'b10001010000) begin //and
			reg2Loc = 1;
			regWrite = 1;
			dOrImm = 0;
			ALUSrc = 0;
			ALUOp = 4;
			memWrite = 0;
			memToReg = 0;
			valueToStore = 0; 
			uncondBr = 1'bx; 
			brTaken = 0;
			BRMI = 0;
			saveCond = 0;
			regRD = instr[17:12];
			read_enable = 0;
			needToForward = 1;
      whichMath = 0;
      leftShift = 1'bx;
      mult = 1'b0;
      div = 1'b0;
		end
    else if (instr[10:0] == 11'b10101010000) begin //orr
			reg2Loc = 1;
			regWrite = 1;
			dOrImm = 0;
			ALUSrc = 0;
			ALUOp = 5;
			memWrite = 0;
			memToReg = 0;
			valueToStore = 0; 
			uncondBr = 1'bx; 
			brTaken = 0;
			BRMI = 0;
			saveCond = 0;
			regRD = instr[17:12];
			read_enable = 0;
			needToForward = 1;
      whichMath = 0;
      leftShift = 1'bx;
      mult = 1'b0;
      div = 1'b0;
		end
    else if (instr[10:0] == 11'b11001010000) begin //eor
			reg2Loc = 1;
			regWrite = 1;
			dOrImm = 0;
			ALUSrc = 0;
			ALUOp = 6;
			memWrite = 0;
			memToReg = 0;
			valueToStore = 0; 
			uncondBr = 1'bx; 
			brTaken = 0;
			BRMI = 0;
			saveCond = 0;
			regRD = instr[17:12];
			read_enable = 0;
			needToForward = 1;
      whichMath = 0;
      leftShift = 1'bx;
      mult = 1'b0;
      div = 1'b0;
		end
		else if (instr[10:5] == 6'b000101) begin //branch
			reg2Loc = 1'bx;
			regWrite = 0;
			dOrImm = 1'bx;
			ALUSrc = 1'bx;
			ALUOp = 3'bxxx;
			memWrite = 0;
			memToReg = 0;
			valueToStore = 1'bx; 
			uncondBr = 1; 
			brTaken = 1;
			BRMI = 0;
			saveCond = 0;
			regRD = instr[17:12];
			read_enable = 0;
			needToForward = 0;
      whichMath = 0;
      leftShift = 1'bx;
      mult = 1'b0;
      div = 1'b0;
		end
		else if (instr[10:3] == 8'b10110100) begin //cbz
			reg2Loc = 0;
			regWrite = 0;
			dOrImm = 1'bx;
			ALUSrc = 0;
			ALUOp = 0;
			memWrite = 0;
			memToReg = 1'bx;
			valueToStore = 0; 
			uncondBr = 0; 
			brTaken = commandZero;
			BRMI = 0;
			saveCond = 0;
			regRD = instr[17:12];
			read_enable = 0;
			needToForward = 0;
      whichMath = 0;
      leftShift = 1'bx;
      mult = 1'b0;
      div = 1'b0;
		end
		else if (instr[10:3] == 8'b01010100) begin //B.COND
			reg2Loc = 1'bx;
			regWrite = 0;
			dOrImm = 1'bx;
			ALUSrc = 0;
			ALUOp = 3'bxxx;
			memWrite = 0;
			memToReg = 1'bx;
			valueToStore = 0; 
			uncondBr = 0;
      if(instr[17:12] == 5'b0000) begin //B.EQ
        if(whichFlags == 1)
          brTaken = (zero);
        else
          brTaken = (flags[1]);
      end 
      else if(instr[17:12] == 5'b0001) begin //B.NE
        if(whichFlags == 1)
          brTaken = (~zero);
        else
          brTaken = (~flags[1]);
      end 
      else if(instr[17:12] == 5'b01010) begin //B.GE
        if(whichFlags == 1)
          brTaken = (~(negative ^ overflow));
        else
          brTaken = (~(flags[0] ^ flags[2]));
      end 
      else if(instr[17:12] == 5'b01011) begin//B.LT
        if(whichFlags == 1)
          brTaken = (negative ^ overflow);
        else
          brTaken = (flags[0] ^ flags[2]);
      end 
      else if(instr[17:12] == 5'b01100) begin //B.GT
        if(whichFlags == 1)
          brTaken = (~zero & ~(negative ^ overflow));
        else
          brTaken = (~flags[1] & ~(flags[0] ^ flags[2]));
      end 
      else begin
        if(whichFlags == 1)
          brTaken = (zero | (negative ^ overflow));
        else
          brTaken = (flags[1] | (flags[0] ^ flags[2]));
      end
			BRMI = 0;
			saveCond = 0;
			regRD = instr[17:12];
			read_enable = 0;
			needToForward = 0;
      whichMath = 0;
      leftShift = 1'bx;
      mult = 1'b0;
      div = 1'b0;
		end
		else if (instr[10:0] == 11'b11111000000) begin //memory management
      reg2Loc = 0;
      regWrite = 0;
      dOrImm = 0;
      ALUSrc = 1;
      ALUOp = 2;
      memWrite = 1;
      memToReg = 1'bx;
      valueToStore = 0; 
      uncondBr = 1'bx; 
      brTaken = 0;
      BRMI = 0;
      saveCond = 0;
      regRD = instr[17:12];
      read_enable = 0;
      needToForward = 0;
      whichMath = 0;
      leftShift = 1'bx;
      mult = 1'b0;
      div = 1'b0;
		end
		else if (instr[10:0] == 11'b11111000010) begin //LDUR
      reg2Loc = 1'bx;
      regWrite = 1;
      dOrImm = 0;
      ALUSrc = 1;
      ALUOp = 2;
      memWrite = 0;
      memToReg = 1;
      valueToStore = 0; 
      uncondBr = 1'bx; 
      brTaken = 0;
      BRMI = 0;
      saveCond = 0;
      regRD = instr[17:12];
      read_enable = 1;
      needToForward = 1;
      whichMath = 0;
      leftShift = 1'bx;
      mult = 1'b0;
      div = 1'b0;
		end
		else if (instr[10:5] == 6'b100101) begin //BL
			reg2Loc = 1'bx;
			regWrite = 1;
			dOrImm = 1'bx;
			ALUSrc = 0;
			ALUOp = 0;
			memWrite = 0;
			memToReg = 0;
			valueToStore = 1;
			uncondBr = 1; 
			brTaken = 1;
			BRMI = 0;
			saveCond = 0;
			regRD = 5'b11110;
			read_enable = 0;
			needToForward = 1;
      whichMath = 0;
      leftShift = 1'bx;
      mult = 1'b0;
      div = 1'b0;
		end
		else if (instr[10:0] == 11'b11010110000) begin //BR
			reg2Loc = 0;
			regWrite = 0;
			dOrImm = 1'bx;
			ALUSrc = 0;
			ALUOp = 0;
			memWrite = 0;
			memToReg = 0;
			valueToStore = 0; 
			uncondBr = 1'bx; 
			brTaken = 1'bx;
			BRMI = 1;
			saveCond = 0;
			regRD = instr[17:12];
			read_enable = 0;
			needToForward = 0;
      whichMath = 0;
      leftShift = 1'bx;
      mult = 1'b0;
      div = 1'b0;
		end
    else if(instr[10:0] == 11'b11010011010) begin //LSR
      reg2Loc = 1;
			regWrite = 1;
			dOrImm = 0;
			ALUSrc = 0;
			ALUOp = 2;
			memWrite = 0;
			memToReg = 0;
			valueToStore = 0; 
			uncondBr = 1'bx; 
			brTaken = 0;
			BRMI = 0;
			saveCond = 0;
			regRD = instr[17:12];
			read_enable = 0;
			needToForward = 1;
      whichMath = 1;
      leftShift = 0;
      mult = 1'b0;
      div = 1'b0;
    end
    else if(instr[10:0] == 11'b11010011011) begin //LSL
      reg2Loc = 1;
			regWrite = 1;
			dOrImm = 0;
			ALUSrc = 0;
			ALUOp = 2;
			memWrite = 0;
			memToReg = 0;
			valueToStore = 0; 
			uncondBr = 1'bx; 
			brTaken = 0;
			BRMI = 0;
			saveCond = 0;
			regRD = instr[17:12];
			read_enable = 0;
			needToForward = 1;
      whichMath = 1;
      leftShift = 1;
      mult = 1'b0;
      div = 1'b0;
    end
    else if (instr[10:0] == 11'b10011011000) begin //mult
			reg2Loc = 1;
			regWrite = 1;
			dOrImm = 0;
			ALUSrc = 0;
			ALUOp = 3;
			memWrite = 0;
			memToReg = 0;
			valueToStore = 0; 
			uncondBr = 1'bx; 
			brTaken = 0;
			BRMI = 0;
			saveCond = 0;
			regRD = instr[17:12];
			read_enable = 0;
			needToForward = 1;
      whichMath = 2;
      leftShift = 1'bx;
      mult = 1'b1;
      div = 1'b0;
		end
    else if (instr[10:0] == 11'b10011010110) begin //div
			reg2Loc = 1;
			regWrite = 1;
			dOrImm = 0;
			ALUSrc = 0;
			ALUOp = 3;
			memWrite = 0;
			memToReg = 0;
			valueToStore = 0; 
			uncondBr = 1'bx; 
			brTaken = 0;
			BRMI = 0;
			saveCond = 0;
			regRD = instr[17:12];
			read_enable = 0;
			needToForward = 1;
      whichMath = 3;
      leftShift = 1'bx;
      mult = 1'b0;
      div = 1'b1;
		end
		else begin //do nothing
			reg2Loc = 1'bx;
			regWrite = 0;
			dOrImm = 1'bx;
			ALUSrc = 1'bx;
			ALUOp = 1'bx;
			memWrite = 0;
			memToReg = 1'bx;
			valueToStore = 1'bx; 
			uncondBr = 1'bx; 
			brTaken = 0;
			BRMI = 0;
			saveCond = 0;
			regRD = instr[17:12];
			read_enable = 0;
			needToForward = 0;
      whichMath = 0;
      leftShift = 1'bx;
      mult = 1'b0;
      div = 1'b0;
		end
	end	
endmodule

module control_testbench();
	logic [11:0] instr;
	logic [3:0] flags;
	logic commandZero;
	logic uncondBr, brTaken, memWrite, memToReg, 
					ALUSrc, regWrite, reg2Loc, valueToStore, dOrImm, BRMI, saveCond, needToForward;
	logic [2:0] ALUOp;
	logic [4:0] regRD;

	control dut (.instr, .flags, .commandZero, .uncondBr, .brTaken, .memWrite, .memToReg,
								.ALUOp, .ALUSrc, .regWrite, .reg2Loc, .valueToStore, .dOrImm, 
								.BRMI, .saveCond, .regRD, .needToForward);

	
	initial begin
	instr = 0; flags = 0; commandZero = 0; #10;

		$stop(); // end the simulation
	end
endmodule