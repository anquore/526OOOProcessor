module norifier(outs, ins1, ins0);
	output [63:0] outs;
	input [63:0] ins1, ins0;
	
		nor oa7(outs[7], ins1[7], ins0[7]);
	nor oa6(outs[6], ins1[6], ins0[6]);
	nor oa5(outs[5], ins1[5], ins0[5]);
	nor oa4(outs[4], ins1[4], ins0[4]);
	nor oa3(outs[3], ins1[3], ins0[3]);
	nor oa2(outs[2], ins1[2], ins0[2]);
	nor oa1(outs[1], ins1[1], ins0[1]);
	nor oa0(outs[0], ins1[0], ins0[0]);
		nor oa15(outs[15], ins1[15], ins0[15]);
	nor oa14(outs[14], ins1[14], ins0[14]);
	nor oa13(outs[13], ins1[13], ins0[13]);
	nor oa12(outs[12], ins1[12], ins0[12]);
	nor oa11(outs[11], ins1[11], ins0[11]);
	nor oa10(outs[10], ins1[10], ins0[10]);
	nor oa9(outs[9], ins1[9], ins0[9]);
	nor oa8(outs[8], ins1[8], ins0[8]);
		nor oa23(outs[23], ins1[23], ins0[23]);
	nor oa22(outs[22], ins1[22], ins0[22]);
	nor oa21(outs[21], ins1[21], ins0[21]);
	nor oa20(outs[20], ins1[20], ins0[20]);
	nor oa19(outs[19], ins1[19], ins0[19]);
	nor oa18(outs[18], ins1[18], ins0[18]);
	nor oa17(outs[17], ins1[17], ins0[17]);
	nor oa16(outs[16], ins1[16], ins0[16]);
		nor oa31(outs[31], ins1[31], ins0[31]);
	nor oa30(outs[30], ins1[30], ins0[30]);
	nor oa29(outs[29], ins1[29], ins0[29]);
	nor oa28(outs[28], ins1[28], ins0[28]);
	nor oa27(outs[27], ins1[27], ins0[27]);
	nor oa26(outs[26], ins1[26], ins0[26]);
	nor oa25(outs[25], ins1[25], ins0[25]);
	nor oa24(outs[24], ins1[24], ins0[24]);
		nor oa39(outs[39], ins1[39], ins0[39]);
	nor oa38(outs[38], ins1[38], ins0[38]);
	nor oa37(outs[37], ins1[37], ins0[37]);
	nor oa36(outs[36], ins1[36], ins0[36]);
	nor oa35(outs[35], ins1[35], ins0[35]);
	nor oa34(outs[34], ins1[34], ins0[34]);
	nor oa33(outs[33], ins1[33], ins0[33]);
	nor oa32(outs[32], ins1[32], ins0[32]);
		nor oa47(outs[47], ins1[47], ins0[47]);
	nor oa46(outs[46], ins1[46], ins0[46]);
	nor oa45(outs[45], ins1[45], ins0[45]);
	nor oa44(outs[44], ins1[44], ins0[44]);
	nor oa43(outs[43], ins1[43], ins0[43]);
	nor oa42(outs[42], ins1[42], ins0[42]);
	nor oa41(outs[41], ins1[41], ins0[41]);
	nor oa40(outs[40], ins1[40], ins0[40]);
		nor oa55(outs[55], ins1[55], ins0[55]);
	nor oa54(outs[54], ins1[54], ins0[54]);
	nor oa53(outs[53], ins1[53], ins0[53]);
	nor oa52(outs[52], ins1[52], ins0[52]);
	nor oa51(outs[51], ins1[51], ins0[51]);
	nor oa50(outs[50], ins1[50], ins0[50]);
	nor oa49(outs[49], ins1[49], ins0[49]);
	nor oa48(outs[48], ins1[48], ins0[48]);
		nor oa63(outs[63], ins1[63], ins0[63]);
	nor oa62(outs[62], ins1[62], ins0[62]);
	nor oa61(outs[61], ins1[61], ins0[61]);
	nor oa60(outs[60], ins1[60], ins0[60]);
	nor oa59(outs[59], ins1[59], ins0[59]);
	nor oa58(outs[58], ins1[58], ins0[58]);
	nor oa57(outs[57], ins1[57], ins0[57]);
	nor oa56(outs[56], ins1[56], ins0[56]);
	
endmodule

/*
module norifier_testbench;
	reg [63:0] ins1, ins0;
	wire [63:0] outs;
	
	norifier DUT(.outs, .ins1, .ins0);
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
endmodule */

