module divider(out, valid_out, A, B, valid_in, rst, clk);
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
  assign out = Ar/Br;
endmodule