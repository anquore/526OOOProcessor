module multiplier(out, valid_out, A, B, valid_in, rst, clk);
	output [63:0] out;
	output valid_out;
	input [63:0] A, B;
	input valid_in, rst, clk;
	
	//timing module and register, 5 cycle process
	//typedef enum logic[2:0] {waiting, s0, s1, s2, s3, done} cntrl_state;
	//cntrl_state state, next_state;
  localparam [2:0] waiting = 3'b000, s0 = 3'b001, s1 = 3'b010, s2 = 3'b011, s3 = 3'b100, done = 3'b101;
  logic [2:0] state, next_state;
	always_ff @(posedge clk) begin
		if(rst)
      state <= waiting;
    else
      state <= next_state;
  end
	always @(*) begin
		next_state=state;
		case(state)
		waiting:
			if(valid_in)
				next_state=s0;
		s0: next_state=s1;
		s1: next_state=s2;
		s2: next_state=s3;
		s3: next_state=done;
		done:
			if(valid_in)
				next_state=s0;
		endcase
	end
	wire [63:0] Ar, Br;
	registerX64 regA(.outs(Ar[63:0]), .ins(A[63:0]), .en(valid_in/*(state==waiting)|(state==done)*/), .rst(1'b0), .clk);
	registerX64 regB(.outs(Br[63:0]), .ins(B[63:0]), .en(valid_in/*(state==waiting)|(state==done)*/), .rst(1'b0), .clk);
	assign valid_out = (state==done);
  assign out = Ar*Br;
endmodule
  /*
	
	wire [1:0] wstate, inv_wstate;
	assign wstate[0] = ((state==s1)|(state==s3));
	assign wstate[1] = ((state==s2)|(state==s3));
	assign inv_wstate=~wstate;
	wire [15:0] muxed;
	wire [15:0][63:0] ands;
	wire [15:0][62:0] addeds;
	wire [15:0][62:0] carries;
	
		NAND_MUX_4x1 m7(.out(muxed[7]), .select(wstate), .invSelect(inv_wstate), .in({Ar[55], Ar[39], Ar[23], Ar[7]}));
	NAND_MUX_4x1 m6(.out(muxed[6]), .select(wstate), .invSelect(inv_wstate), .in({Ar[54], Ar[38], Ar[22], Ar[6]}));
	NAND_MUX_4x1 m5(.out(muxed[5]), .select(wstate), .invSelect(inv_wstate), .in({Ar[53], Ar[37], Ar[21], Ar[5]}));
	NAND_MUX_4x1 m4(.out(muxed[4]), .select(wstate), .invSelect(inv_wstate), .in({Ar[52], Ar[36], Ar[20], Ar[4]}));
	NAND_MUX_4x1 m3(.out(muxed[3]), .select(wstate), .invSelect(inv_wstate), .in({Ar[51], Ar[35], Ar[19], Ar[3]}));
	NAND_MUX_4x1 m2(.out(muxed[2]), .select(wstate), .invSelect(inv_wstate), .in({Ar[50], Ar[34], Ar[18], Ar[2]}));
	NAND_MUX_4x1 m1(.out(muxed[1]), .select(wstate), .invSelect(inv_wstate), .in({Ar[49], Ar[33], Ar[17], Ar[1]}));
	NAND_MUX_4x1 m0(.out(muxed[0]), .select(wstate), .invSelect(inv_wstate), .in({Ar[48], Ar[32], Ar[16], Ar[0]}));
		NAND_MUX_4x1 m15(.out(muxed[15]), .select(wstate), .invSelect(inv_wstate), .in({Ar[63], Ar[47], Ar[31], Ar[15]}));
	NAND_MUX_4x1 m14(.out(muxed[14]), .select(wstate), .invSelect(inv_wstate), .in({Ar[62], Ar[46], Ar[30], Ar[14]}));
	NAND_MUX_4x1 m13(.out(muxed[13]), .select(wstate), .invSelect(inv_wstate), .in({Ar[61], Ar[45], Ar[29], Ar[13]}));
	NAND_MUX_4x1 m12(.out(muxed[12]), .select(wstate), .invSelect(inv_wstate), .in({Ar[60], Ar[44], Ar[28], Ar[12]}));
	NAND_MUX_4x1 m11(.out(muxed[11]), .select(wstate), .invSelect(inv_wstate), .in({Ar[59], Ar[43], Ar[27], Ar[11]}));
	NAND_MUX_4x1 m10(.out(muxed[10]), .select(wstate), .invSelect(inv_wstate), .in({Ar[58], Ar[42], Ar[26], Ar[10]}));
	NAND_MUX_4x1 m9(.out(muxed[9]), .select(wstate), .invSelect(inv_wstate), .in({Ar[57], Ar[41], Ar[25], Ar[9]}));
	NAND_MUX_4x1 m8(.out(muxed[8]), .select(wstate), .invSelect(inv_wstate), .in({Ar[56], Ar[40], Ar[24], Ar[8]}));
	
		andifier a7(.outs(ands[7][63:0]), .ins1(Br[63:0]), .ins0({64{muxed[7]}}));
	andifier a6(.outs(ands[6][63:0]), .ins1(Br[63:0]), .ins0({64{muxed[6]}}));
	andifier a5(.outs(ands[5][63:0]), .ins1(Br[63:0]), .ins0({64{muxed[5]}}));
	andifier a4(.outs(ands[4][63:0]), .ins1(Br[63:0]), .ins0({64{muxed[4]}}));
	andifier a3(.outs(ands[3][63:0]), .ins1(Br[63:0]), .ins0({64{muxed[3]}}));
	andifier a2(.outs(ands[2][63:0]), .ins1(Br[63:0]), .ins0({64{muxed[2]}}));
	andifier a1(.outs(ands[1][63:0]), .ins1(Br[63:0]), .ins0({64{muxed[1]}}));
	andifier a0(.outs(ands[0][63:0]), .ins1(Br[63:0]), .ins0({64{muxed[0]}}));
		andifier a15(.outs(ands[15][63:0]), .ins1(Br[63:0]), .ins0({64{muxed[15]}}));
	andifier a14(.outs(ands[14][63:0]), .ins1(Br[63:0]), .ins0({64{muxed[14]}}));
	andifier a13(.outs(ands[13][63:0]), .ins1(Br[63:0]), .ins0({64{muxed[13]}}));
	andifier a12(.outs(ands[12][63:0]), .ins1(Br[63:0]), .ins0({64{muxed[12]}}));
	andifier a11(.outs(ands[11][63:0]), .ins1(Br[63:0]), .ins0({64{muxed[11]}}));
	andifier a10(.outs(ands[10][63:0]), .ins1(Br[63:0]), .ins0({64{muxed[10]}}));
	andifier a9(.outs(ands[9][63:0]), .ins1(Br[63:0]), .ins0({64{muxed[9]}}));
	andifier a8(.outs(ands[8][63:0]), .ins1(Br[63:0]), .ins0({64{muxed[8]}}));
	
	//full adders
	wire carbit, carbitm;
	wire [63:0] regAdd, regCar, muxedAdd, muxedCar;
	mux_2x1_X64 addMux(.outs(muxedAdd[63:0]), .select(state!=s0), .invSelect(state==s0), .ins({regAdd[63:0], 64'h0}));
	mux_2x1_X64 carMux(.outs(muxedCar[63:0]), .select(state!=s0), .invSelect(state==s0), .ins({regCar[63:0], 64'h0}));
	NAND_MUX_2x1 carmuxa(.out(carbitm), .select(state==s0), .invSelect(state!=s0), .in({1'b0, carbit}));
	fullAdderArray63 line0(.S(addeds[0][62:0]), .Cout(carries[0][62:0]), .A({carbitm, muxedAdd[62:1]}), .B(ands[0][62:0]), .Cin(muxedCar[62:0]));
	fullAdderArray63 line1(.S(addeds[1][62:0]), .Cout(carries[1][62:0]), .A({~ands[0][63], addeds[0][62:1]}), .B(ands[1][62:0]), .Cin(carries[0][62:0]));
	fullAdderArray63 line2(.S(addeds[2][62:0]), .Cout(carries[2][62:0]), .A({~ands[1][63], addeds[1][62:1]}), .B(ands[2][62:0]), .Cin(carries[1][62:0]));
	fullAdderArray63 line3(.S(addeds[3][62:0]), .Cout(carries[3][62:0]), .A({~ands[2][63], addeds[2][62:1]}), .B(ands[3][62:0]), .Cin(carries[2][62:0]));
	fullAdderArray63 line4(.S(addeds[4][62:0]), .Cout(carries[4][62:0]), .A({~ands[3][63], addeds[3][62:1]}), .B(ands[4][62:0]), .Cin(carries[3][62:0]));
	fullAdderArray63 line5(.S(addeds[5][62:0]), .Cout(carries[5][62:0]), .A({~ands[4][63], addeds[4][62:1]}), .B(ands[5][62:0]), .Cin(carries[4][62:0]));
	fullAdderArray63 line6(.S(addeds[6][62:0]), .Cout(carries[6][62:0]), .A({~ands[5][63], addeds[5][62:1]}), .B(ands[6][62:0]), .Cin(carries[5][62:0]));
		fullAdderArray63 line7(.S(addeds[7][62:0]), .Cout(carries[7][62:0]), .A({~ands[6][63], addeds[6][62:1]}), .B(ands[7][62:0]), .Cin(carries[6][62:0]));
	fullAdderArray63 line8(.S(addeds[8][62:0]), .Cout(carries[8][62:0]), .A({~ands[7][63], addeds[7][62:1]}), .B(ands[8][62:0]), .Cin(carries[7][62:0]));
	fullAdderArray63 line9(.S(addeds[9][62:0]), .Cout(carries[9][62:0]), .A({~ands[8][63], addeds[8][62:1]}), .B(ands[9][62:0]), .Cin(carries[8][62:0]));
	fullAdderArray63 line10(.S(addeds[10][62:0]), .Cout(carries[10][62:0]), .A({~ands[9][63], addeds[9][62:1]}), .B(ands[10][62:0]), .Cin(carries[9][62:0]));
	fullAdderArray63 line11(.S(addeds[11][62:0]), .Cout(carries[11][62:0]), .A({~ands[10][63], addeds[10][62:1]}), .B(ands[11][62:0]), .Cin(carries[10][62:0]));
	fullAdderArray63 line12(.S(addeds[12][62:0]), .Cout(carries[12][62:0]), .A({~ands[11][63], addeds[11][62:1]}), .B(ands[12][62:0]), .Cin(carries[11][62:0]));
	fullAdderArray63 line13(.S(addeds[13][62:0]), .Cout(carries[13][62:0]), .A({~ands[12][63], addeds[12][62:1]}), .B(ands[13][62:0]), .Cin(carries[12][62:0]));
	fullAdderArray63 line14(.S(addeds[14][62:0]), .Cout(carries[14][62:0]), .A({~ands[13][63], addeds[13][62:1]}), .B(ands[14][62:0]), .Cin(carries[13][62:0]));
	fullAdderArray63 line15(.S(addeds[15][62:0]), .Cout(carries[15][62:0]), .A({~ands[14][63], addeds[14][62:1]}), .B((state==s3)^(ands[15][62:0])), .Cin(carries[14][62:0]));
	registerX16 r0_15(.outs(out[15:0]), .ins({addeds[15][0], addeds[14][0], addeds[13][0], addeds[12][0], addeds[11][0], addeds[10][0], addeds[9][0],
		addeds[8][0], addeds[7][0], addeds[6][0], addeds[5][0], addeds[4][0], addeds[3][0], addeds[2][0], addeds[1][0], addeds[0][0]}), .en(state==s0), .rst, .clk);
	registerX16 r16_31(.outs(out[31:16]), .ins({addeds[15][0], addeds[14][0], addeds[13][0], addeds[12][0], addeds[11][0], addeds[10][0], addeds[9][0],
		addeds[8][0], addeds[7][0], addeds[6][0], addeds[5][0], addeds[4][0], addeds[3][0], addeds[2][0], addeds[1][0], addeds[0][0]}), .en(state==s1), .rst, .clk);
	registerX16 r32_47(.outs(out[47:32]), .ins({addeds[15][0], addeds[14][0], addeds[13][0], addeds[12][0], addeds[11][0], addeds[10][0], addeds[9][0],
		addeds[8][0], addeds[7][0], addeds[6][0], addeds[5][0], addeds[4][0], addeds[3][0], addeds[2][0], addeds[1][0], addeds[0][0]}), .en(state==s2), .rst, .clk);
	registerX16 r48_63(.outs(out[63:48]), .ins({addeds[15][0], addeds[14][0], addeds[13][0], addeds[12][0], addeds[11][0], addeds[10][0], addeds[9][0],
		addeds[8][0], addeds[7][0], addeds[6][0], addeds[5][0], addeds[4][0], addeds[3][0], addeds[2][0], addeds[1][0], addeds[0][0]}), .en(state==s3), .rst, .clk);
	D_FF carb(.q(carbit), .d(~ands[15][63]), .reset(rst), .clk);
	registerX64 added(.outs(regAdd[63:0]), .ins({1'b0, addeds[15][62:0]}), .en(1'b1), .rst, .clk);
	registerX64 carrys(.outs(regCar[63:0]), .ins({1'b0, carries[15][62:0]}), .en(1'b1), .rst, .clk);
endmodule

/*
module multiplier_testbench;
	wire [63:0] out;
	wire valid_out;
	reg [63:0] A, B;
	reg valid_in, rst, clk;
	multiplier DUT(.out, .valid_out, .A, .B, .valid_in, .rst, .clk);
	
	initial begin
	rst=1; clk=0;	#5;	clk=1;	#5;	rst=0;
	valid_in=0;
	clk=0;
	A = 64'h0000_0000_0000_0000;
	B = 64'h0000_0000_0000_0000;
	valid_in=1;	#5;	clk=1;	#5;	clk=0;	valid_in=0;	#5;	clk=1;	#5;	clk=0;	#5;
	clk=1;	#5;	clk=0;	#5;	clk=1;	#5;	clk=0;	#5;	clk=1;	#5;	clk=0;	#5;
	A = 64'h0000_0000_00A0_FFFF;
	B = 64'h0000_0000_0000_0000;
	valid_in=1;	#5;	clk=1;	#5;	clk=0;	valid_in=0;	#5;	clk=1;	#5;	clk=0;	#5;
	clk=1;	#5;	clk=0;	#5;	clk=1;	#5;	clk=0;	#5;	clk=1;	#5;	clk=0;	#5;
	A = 64'h0000_0000_0000_0001;
	B = 64'h0000_0000_0000_0001;
	valid_in=1;	#5;	clk=1;	#5;	clk=0;	valid_in=0;	#5;	clk=1;	#5;	clk=0;	#5;
	clk=1;	#5;	clk=0;	#5;	clk=1;	#5;	clk=0;	#5;	clk=1;	#5;	clk=0;	#5;
	A = 64'h0000_0000_0000_0002;
	B = 64'h0000_0000_0000_0001;
	valid_in=1;	#5;	clk=1;	#5;	clk=0;	valid_in=0;	#5;	clk=1;	#5;	clk=0;	#5;
	clk=1;	#5;	clk=0;	#5;	clk=1;	#5;	clk=0;	#5;	clk=1;	#5;	clk=0;	#5;
	A = 64'h0000_0000_0000_0001;
	B = 64'h0000_0000_0000_0002;
	valid_in=1;	#5;	clk=1;	#5;	clk=0;	valid_in=0;	#5;	clk=1;	#5;	clk=0;	#5;
	clk=1;	#5;	clk=0;	#5;	clk=1;	#5;	clk=0;	#5;	clk=1;	#5;	clk=0;	#5;
	A = 64'h0000_0000_0000_0010;
	B = 64'h0000_0000_0000_0010;
	valid_in=1;	#5;	clk=1;	#5;	clk=0;	valid_in=0;	#5;	clk=1;	#5;	clk=0;	#5;
	clk=1;	#5;	clk=0;	#5;	clk=1;	#5;	clk=0;	#5;	clk=1;	#5;	clk=0;	#5;
	A = 64'h0F02_0400_0654_1323;
	B = 64'h0000_0000_0000_0002;
	valid_in=1;	#5;	clk=1;	#5;	clk=0;	valid_in=0;	#5;	clk=1;	#5;	clk=0;	#5;
	clk=1;	#5;	clk=0;	#5;	clk=1;	#5;	clk=0;	#5;	clk=1;	#5;	clk=0;	#5;
	A = 64'h0F02_0400_1454_1323;
	B = 64'h0000_0000_0000_0003;
	valid_in=1;	#5;	clk=1;	#5;	clk=0;	valid_in=0;	#5;	clk=1;	#5;	clk=0;	#5;
	clk=1;	#5;	clk=0;	#5;	clk=1;	#5;	clk=0;	#5;	clk=1;	#5;	clk=0;	#5;
	A = 64'h0000_0000_5F72_AA7D;
	B = 64'h0000_0000_F29B_CF54;
	valid_in=1;	#5;	clk=1;	#5;	clk=0;	valid_in=0;	#5;	clk=1;	#5;	clk=0;	#5;
	clk=1;	#5;	clk=0;	#5;	clk=1;	#5;	clk=0;	#5;	clk=1;	#5;	clk=0;	#5;
	A = 64'hFFFF_FFFF_FFFF_FFFF;
	B = 64'hFFFF_FFFF_FFFF_FFFF;
	valid_in=1;	#5;	clk=1;	#5;	clk=0;	valid_in=0;	#5;	clk=1;	#5;	clk=0;	#5;
	clk=1;	#5;	clk=0;	#5;	clk=1;	#5;	clk=0;	#5;	clk=1;	#5;	clk=0;	#5;
	A = 64'h0000_0000_0000_0001;
	B = 64'hFFFF_FFFF_FFFF_FFFF;
	valid_in=1;	#5;	clk=1;	#5;	clk=0;	valid_in=0;	#5;	clk=1;	#5;	clk=0;	#5;
	clk=1;	#5;	clk=0;	#5;	clk=1;	#5;	clk=0;	#5;	clk=1;	#5;	clk=0;	#5;
	A = 64'hFFFF_FFFF_FFFF_FFFF;
	B = 64'h0000_0000_0000_0001;
	valid_in=1;	#5;	clk=1;	#5;	clk=0;	valid_in=0;	#5;	clk=1;	#5;	clk=0;	#5;
	clk=1;	#5;	clk=0;	#5;	clk=1;	#5;	clk=0;	#5;	clk=1;	#5;	clk=0;	#5;
	A = 64'h529A_8CE2_59F5_3AB9;
	B = 64'hFFFF_FFFF_FFFF_FFFF;
	valid_in=1;	#5;	clk=1;	#5;	clk=0;	valid_in=0;	#5;	clk=1;	#5;	clk=0;	#5;
	clk=1;	#5;	clk=0;	#5;	clk=1;	#5;	clk=0;	#5;	clk=1;	#5;	clk=0;	#5;
	A = 64'h0000_0000_0000_0001;
	B = 64'h0000_000b_3ae5_923f;
	valid_in=1;	#5;	clk=1;	#5;	clk=0;	valid_in=0;	#5;	clk=1;	#5;	clk=0;	#5;
	clk=1;	#5;	clk=0;	#5;	clk=1;	#5;	clk=0;	#5;	clk=1;	#5;	clk=0;	#5;
	/*#5;	valid_in=1;	#5;	clk=1;	#5;	clk=0; //testing valid_out (using the clock)
	#5;	clk=1;	#5;	clk=0;
	#5;	clk=1;	#5;	clk=0;
	#5;	clk=1;	#5;	clk=0;
	#5;	clk=1;	#5;	clk=0;
	valid_in=0;	#5;	clk=1;	#5;	clk=0;
	#5;	clk=1;	#5;	clk=0;
	#5;	clk=1;	#5;	clk=0;
	#5;	clk=1;	#5;	clk=0;
	#5;	clk=1;	#5;	clk=0;
	valid_in=1;	#5;	clk=1;	#5;	clk=0;
	#5;	clk=1;	#5;	clk=0;
	#5;	clk=1;	#5;	clk=0;
	valid_in=0;
	#5;	clk=1;	#5;	clk=0;
	#5;	clk=1;	#5;	clk=0;
	#5;	clk=1;	#5;	clk=0;
	valid_in=1;
	#5;	clk=1;	#5;	clk=0;
	#5;	clk=1;	#5;	clk=0;
	#5;	clk=1;	#5;	clk=0;
	#5;	clk=1;	#5;	clk=0;
	end
endmodule */

