module xnorifier(outs, ins1, ins0);
	output [63:0] outs;
	input [63:0] ins1, ins0;
	
		xnor  xoa7(outs[7], ins1[7], ins0[7]);
	xnor xoa6(outs[6], ins1[6], ins0[6]);
	xnor xoa5(outs[5], ins1[5], ins0[5]);
	xnor xoa4(outs[4], ins1[4], ins0[4]);
	xnor xoa3(outs[3], ins1[3], ins0[3]);
	xnor xoa2(outs[2], ins1[2], ins0[2]);
	xnor xoa1(outs[1], ins1[1], ins0[1]);
	xnor xoa0(outs[0], ins1[0], ins0[0]);
		xnor xoa15(outs[15], ins1[15], ins0[15]);
	xnor xoa14(outs[14], ins1[14], ins0[14]);
	xnor xoa13(outs[13], ins1[13], ins0[13]);
	xnor xoa12(outs[12], ins1[12], ins0[12]);
	xnor xoa11(outs[11], ins1[11], ins0[11]);
	xnor xoa10(outs[10], ins1[10], ins0[10]);
	xnor xoa9(outs[9], ins1[9], ins0[9]);
	xnor xoa8(outs[8], ins1[8], ins0[8]);
		xnor xoa23(outs[23], ins1[23], ins0[23]);
	xnor xoa22(outs[22], ins1[22], ins0[22]);
	xnor xoa21(outs[21], ins1[21], ins0[21]);
	xnor xoa20(outs[20], ins1[20], ins0[20]);
	xnor xoa19(outs[19], ins1[19], ins0[19]);
	xnor xoa18(outs[18], ins1[18], ins0[18]);
	xnor xoa17(outs[17], ins1[17], ins0[17]);
	xnor xoa16(outs[16], ins1[16], ins0[16]);
		xnor xoa31(outs[31], ins1[31], ins0[31]);
	xnor xoa30(outs[30], ins1[30], ins0[30]);
	xnor xoa29(outs[29], ins1[29], ins0[29]);
	xnor xoa28(outs[28], ins1[28], ins0[28]);
	xnor xoa27(outs[27], ins1[27], ins0[27]);
	xnor xoa26(outs[26], ins1[26], ins0[26]);
	xnor xoa25(outs[25], ins1[25], ins0[25]);
	xnor xoa24(outs[24], ins1[24], ins0[24]);
		xnor xoa39(outs[39], ins1[39], ins0[39]);
	xnor xoa38(outs[38], ins1[38], ins0[38]);
	xnor xoa37(outs[37], ins1[37], ins0[37]);
	xnor xoa36(outs[36], ins1[36], ins0[36]);
	xnor xoa35(outs[35], ins1[35], ins0[35]);
	xnor xoa34(outs[34], ins1[34], ins0[34]);
	xnor xoa33(outs[33], ins1[33], ins0[33]);
	xnor xoa32(outs[32], ins1[32], ins0[32]);
		xnor xoa47(outs[47], ins1[47], ins0[47]);
	xnor xoa46(outs[46], ins1[46], ins0[46]);
	xnor xoa45(outs[45], ins1[45], ins0[45]);
	xnor xoa44(outs[44], ins1[44], ins0[44]);
	xnor xoa43(outs[43], ins1[43], ins0[43]);
	xnor xoa42(outs[42], ins1[42], ins0[42]);
	xnor xoa41(outs[41], ins1[41], ins0[41]);
	xnor xoa40(outs[40], ins1[40], ins0[40]);
		xnor xoa55(outs[55], ins1[55], ins0[55]);
	xnor xoa54(outs[54], ins1[54], ins0[54]);
	xnor xoa53(outs[53], ins1[53], ins0[53]);
	xnor xoa52(outs[52], ins1[52], ins0[52]);
	xnor xoa51(outs[51], ins1[51], ins0[51]);
	xnor xoa50(outs[50], ins1[50], ins0[50]);
	xnor xoa49(outs[49], ins1[49], ins0[49]);
	xnor xoa48(outs[48], ins1[48], ins0[48]);
		xnor xoa63(outs[63], ins1[63], ins0[63]);
	xnor xoa62(outs[62], ins1[62], ins0[62]);
	xnor xoa61(outs[61], ins1[61], ins0[61]);
	xnor xoa60(outs[60], ins1[60], ins0[60]);
	xnor xoa59(outs[59], ins1[59], ins0[59]);
	xnor xoa58(outs[58], ins1[58], ins0[58]);
	xnor xoa57(outs[57], ins1[57], ins0[57]);
	xnor xoa56(outs[56], ins1[56], ins0[56]);
	
endmodule

module xnorifier_testbench;
	reg [63:0] ins1, ins0;
	wire [63:0] outs;
	
	xnorifier DUT(.outs, .ins1, .ins0);
	initial begin
	ins1 = 64'h 55_55__55_55__55_55__55_55;
	ins0 = 64'h 55_55__55_55__55_55__55_55;
	#250;
	ins1 = 64'h AA_AA__AA_AA__AA_AA__AA_AA;
	#250;
	ins0 = 64'h AA_AA__AA_AA__AA_AA__AA_AA;
	#250;
	ins1 = 64'h FF_FF__FF_FF__FF_FF__FF_FF;
	#250;
	ins0 = 64'h FF_FF__FF_FF__FF_FF__FF_FF;
	#250;
	ins1 = 64'h 00_00__00_00__00_00__00_00;
	#250;
	ins0 = 64'h 00_00__00_00__00_00__00_00;
	end
endmodule
