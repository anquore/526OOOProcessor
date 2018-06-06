module FF_en(q, d, en, reset, clk);
	output q;
	input d, en, reset, clk;
	wire dat;
	D_FF ff(.q, .d(dat), .reset, .clk);
	NAND_MUX_2x1 muxs(.out(dat), .select(en), .invSelect(~en), .in({d, q}));
endmodule
