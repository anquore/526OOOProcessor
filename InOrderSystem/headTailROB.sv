`timescale 1ns/10ps
module headTailROB #(parameter ROBsize = 32, addrSize = $clog2(ROBsize)) 
(clk_i
,reset_i
,updateHead_i
,updateTail_i

,stall_o
,head_o
,tail_o
,tailReset_o);
  //ins and outs
	input logic reset_i, clk_i, updateHead_i, updateTail_i;
	output logic [addrSize-1:0]	head_o, tail_o;
  output logic stall_o, tailReset_o;
  
  //some logic
  logic [addrSize-1:0]	head, tail, headNext, tailNext;
  logic headReset, tailReset, stall;
  
  //add 1 to the head and the tail
  assign headNext = head + 1;
  assign tailNext = tail + 1;
  
  //tail logic
  always_ff @(posedge clk_i) begin
		if (reset_i) begin
			//on reset go to zero
      tail <= 0;
      tailReset <= 0;
    end
    else if (updateTail_i & (tailReset == 1'b0)) begin
      //when the first value comes in link it to the tail
      tail <= 0;
      tailReset <= 1;
    end
    else if(updateTail_i & (tailNext == head)) begin
      //if the tail will overwrite the head dont' update, maintain tail
      tail <= tail;
      tailReset <= 1;
    end
    else if (updateTail_i & (tailNext != head)) begin
      //update tail
      tail <= tailNext;
      tailReset <= 1;
    end
		else begin
      //else case
      tail <= tail;
      tailReset <= tailReset;
    end
  end
  
  //stall logic
  assign stall = updateTail_i & (tailNext == head);
  
  //head logic
  always_ff @(posedge clk_i) begin
		if (reset_i) begin
			//on reset go to zero
      head <= 0;
      headReset <= 0;
    end
    else if (updateTail_i & (headReset == 1'b0)) begin
      //when the first value comes in link it to the head
      head <= 0;
      headReset <= 1;
    end
    else if (updateHead_i) begin
      //update head
      head <= headNext;
      headReset <= 1;
    end
		else begin
      //else case
      head <= head;
      headReset <= headReset;
    end
  end
  
  //assign outs
  assign head_o = head;
  assign tail_o = tail;
  assign stall_o = stall;
  assign tailReset_o = tailReset;
endmodule

module headTailROB_testbench();
  //ROBsize = 8
  logic reset_i, clk_i, updateHead_i, updateTail_i;
	logic [2:0]	head_o, tail_o;
  logic stall_o;
  
  //the module
  headTailROB #(.ROBsize(8)) dut 
  (clk_i
  ,reset_i
  ,updateHead_i
  ,updateTail_i
  ,stall_o
  ,head_o
  ,tail_o);
  
  parameter ClockDelay = 5000;
  initial begin // Set up the clock
		clk_i <= 0;
		forever #(ClockDelay/2) clk_i <= ~clk_i;
	end
  
  integer i;
  
  initial begin
    //set everything to zero
    updateTail_i <= 0; updateHead_i <= 0;
    reset_i <= 1'b1;@(posedge clk_i);
    //flash reset
    reset_i <= 1'b0; @(posedge clk_i);
    
    //flash the first tail
    updateTail_i <= 1; @(posedge clk_i);
    updateTail_i <= 0; @(posedge clk_i);
    
    //send in a few tails
    repeat(3) begin updateTail_i <= 1; @(posedge clk_i);
    updateTail_i <= 0; @(posedge clk_i); end
    
    //send in a head
    updateHead_i <= 1; @(posedge clk_i);
    updateHead_i <= 0; @(posedge clk_i);
    
    //update tail till we stall
    repeat(8) begin updateTail_i <= 1; @(posedge clk_i);
    updateTail_i <= 0; @(posedge clk_i); end
    
    //update head
    updateHead_i <= 1; @(posedge clk_i);
    updateHead_i <= 0; @(posedge clk_i);
    updateHead_i <= 1; @(posedge clk_i);
    updateHead_i <= 0; @(posedge clk_i);
    
    //send a tail
    updateTail_i <= 1; @(posedge clk_i);
    updateTail_i <= 0; @(posedge clk_i);
    
    
    $stop;
  end

endmodule