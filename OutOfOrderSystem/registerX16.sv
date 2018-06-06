module registerX16(outs, ins, en, rst, clk);
	output [15:0] outs;
	input [15:0] ins;
	input en, rst, clk;
	
		FF_en r7(.q(outs[7]), .d(ins[7]), .en, .reset(rst), .clk);
	FF_en r6(.q(outs[6]), .d(ins[6]), .en, .reset(rst), .clk);
	FF_en r5(.q(outs[5]), .d(ins[5]), .en, .reset(rst), .clk);
	FF_en r4(.q(outs[4]), .d(ins[4]), .en, .reset(rst), .clk);
	FF_en r3(.q(outs[3]), .d(ins[3]), .en, .reset(rst), .clk);
	FF_en r2(.q(outs[2]), .d(ins[2]), .en, .reset(rst), .clk);
	FF_en r1(.q(outs[1]), .d(ins[1]), .en, .reset(rst), .clk);
	FF_en r0(.q(outs[0]), .d(ins[0]), .en, .reset(rst), .clk);
		FF_en r15(.q(outs[15]), .d(ins[15]), .en, .reset(rst), .clk);
	FF_en r14(.q(outs[14]), .d(ins[14]), .en, .reset(rst), .clk);
	FF_en r13(.q(outs[13]), .d(ins[13]), .en, .reset(rst), .clk);
	FF_en r12(.q(outs[12]), .d(ins[12]), .en, .reset(rst), .clk);
	FF_en r11(.q(outs[11]), .d(ins[11]), .en, .reset(rst), .clk);
	FF_en r10(.q(outs[10]), .d(ins[10]), .en, .reset(rst), .clk);
	FF_en r9(.q(outs[9]), .d(ins[9]), .en, .reset(rst), .clk);
	FF_en r8(.q(outs[8]), .d(ins[8]), .en, .reset(rst), .clk);
endmodule
