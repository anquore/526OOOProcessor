/****************************************************************************************************************
 
    STAMATIS POULIOS, 28/07/2015
 
    File name: fifo.sv
    
    Description: Generalized fifo. Stores 'IN_BUS_WIDTH'-wide words. The depth of the fifo is defined by the value
                 of the 'FIFO_DEPTH' variable.
 
****************************************************************************************************************/
 
`ifndef FIFO__SV
`define FIFO__SV
 
//***************************************************************************************************************
// Defines section
//***************************************************************************************************************
`define FIFO_DEPTH      4
`define IN_BUS_WIDTH    4
`define FIFO_CNT_WIDTH  2
 
//***************************************************************************************************************
// Module declaration: fifo
//***************************************************************************************************************
module fifo
(
    input logic clk,
    input logic rst,
    input logic [`IN_BUS_WIDTH-1:0] data_in,
    input logic rd_en,
    input logic wr_en,
    output logic empty,
    output logic full,
    output logic [`IN_BUS_WIDTH-1:0] data_out
);
 
logic [`FIFO_DEPTH-1:0][`IN_BUS_WIDTH-1:0] buff_mem;
logic [`FIFO_CNT_WIDTH-1:0] rd_ptr, wr_ptr;
logic [`FIFO_DEPTH-1:0] status;
// The 'status' signal indicates the status of the Nth memory position. Value '1' indicates new data is stored
// in the Nth memory position, but not yet read. Value '0' indicates that the data from that memory position is
// read and the memory position is available for writing new data.
 
 
always@(data_out)
begin
    assign empty = (status == 0);
    assign full = (status == {(`FIFO_DEPTH){1'b1}});
end
 
always@(posedge clk or posedge rst)
begin
    if(rst)
    begin
        data_out <= 0;
        buff_mem <= 0;
        status <= 0;
        rd_ptr <= 0;
        wr_ptr <= 0;
    end
    else
    begin
        data_out <= buff_mem[rd_ptr][`IN_BUS_WIDTH-1:0];
        buff_mem[wr_ptr] <= buff_mem[wr_ptr];
        rd_ptr <= rd_ptr;
        wr_ptr <= wr_ptr;
        if( rd_en && !empty )
        begin
            //data_out <= buff_mem[rd_ptr][`IN_BUS_WIDTH-1:0];
            status[rd_ptr] <= 1'b0;
            rd_ptr <= rd_ptr + 1;
        end
        if( wr_en && !full )
        begin
            buff_mem[wr_ptr] <= {data_in};
            status[wr_ptr] <= 1'b1;
            wr_ptr <= wr_ptr + 1;
        end
    end
end
 
 
endmodule
 
`endif