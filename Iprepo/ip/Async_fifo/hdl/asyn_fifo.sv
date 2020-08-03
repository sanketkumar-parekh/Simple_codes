module Async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)(
    input r_clk, w_clk, rstN,
    input [DATA_WIDTH-1 : 0] Data_in,
    input in_Valid, read_en,
    output logic[DATA_WIDTH-1 : 0] Data_out,
    output reg out_valid,
    output reg full, empty
);
localparam DEPTH = 2**ADDR_WIDTH;
logic [DATA_WIDTH-1:0] mem [2**ADDR_WIDTH];
logic [ADDR_WIDTH : 0] rptr,rptr_q1, rptr_q2, rptr_w, rptr_g, rptr_s_b;
logic [ADDR_WIDTH : 0] wptr,wptr_q1, wptr_q2, wptr_r, wptr_g, wptr_s_b;

// creat full signal with synchronized read pointer
    assign full = ((wptr[ADDR_WIDTH-1:0] == rptr_s_b[ADDR_WIDTH-1:0]) &&
                 (wptr[ADDR_WIDTH] != rptr_w[ADDR_WIDTH])) ? 1'b1: 1'b0;

//create empty signal eith synchronized write pointer
    assign empty = ((wptr_s_b == rptr)) ? 1'b1:1'b0;
  
// convert binary data to grey code for synchronization
    assign wptr_g = bin2grey(wptr); 
    assign rptr_g = bin2grey(rptr); 
  
// convert grey code to binery for full and empty detection
    assign wptr_s_b = grey2bin(wptr_r);
    assign rptr_s_b = grey2bin(rptr_w); 
  
    
    always_ff @(posedge w_clk) begin // write cycle
        if(!rstN) begin
            wptr <= 0;
        end
        else begin
            if(!full && in_Valid) begin
              mem[wptr[ADDR_WIDTH-1:0]] = Data_in;
                wptr <= wptr + 1;
            end
        end
    end
    always_ff @(posedge r_clk) begin // read cycle
        if (!rstN) begin
            rptr <= 0;
        end
        else begin 
            if(!empty && read_en) begin
              Data_out <= mem[rptr[ADDR_WIDTH-1:0]];
              	out_valid <= 1;
                rptr <= rptr + 1;
            end
          	else begin
            	out_valid <= 0;
              	out_valid <= 0;
            end
          
        end
    end
    
    always_ff @(posedge w_clk) begin  // read pointer synchronized to write clock
        if(!rstN) begin
            rptr_q2 <= 0;
            rptr_q1 <= 0;
            rptr_w <= 0;
        end
        else begin
          {rptr_q2, rptr_q1} <= {rptr_q1, rptr_g};
            rptr_w <= rptr_q2;
        end
    end

    always_ff @(posedge r_clk) begin // write pointer synchronized to read clock 
        if (!rstN) begin
            wptr_q1 <= 0;
            wptr_q2 <= 0;
            wptr_r <= 0;
        end
        else begin
          {wptr_q2, wptr_q1} <= {wptr_q1, wptr_g};
            wptr_r <= wptr_q2;
        end
    end
  
//function bin2grey
    function logic [ADDR_WIDTH:0] bin2grey(logic [ADDR_WIDTH:0] bin);
        logic [ADDR_WIDTH:0] grey, tmp;
        tmp = bin ^ ( bin << 1);
        grey = {bin[ADDR_WIDTH], tmp[ADDR_WIDTH:1]};
        return grey;
    endfunction
//function
    function logic [ADDR_WIDTH:0]  grey2bin(logic [ADDR_WIDTH:0] grey);
        logic [ADDR_WIDTH:0] bin;
        bin = '0;
        for (int i = 0; i<=ADDR_WIDTH; i++) begin
            bin = bin ^ grey>>i;
        end
        return bin;
    endfunction
endmodule