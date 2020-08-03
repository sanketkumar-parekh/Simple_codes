`include asyn_fifo.sv
module tb();
  logic r_clk, w_clk, rstN;
  logic [DATA_WIDTH-1 : 0] Data_in;
  logic in_Valid, read_en;
  logic [DATA_WIDTH-1 : 0] Data_out;
  logic out_valid;
  logic full, empty;
  Async_fifo dut(.*);
  
  initial begin 
    r_clk = 0;
    forever #5 r_clk = !r_clk;
  end
  initial begin
      w_clk = 0;
      forever #7 w_clk = ~w_clk;
  end

  initial begin
      in_Valid = 0;
      repeat(16) begin
      @(posedge w_clk);
        Data_in = 8'haa;
        in_Valid = 1;
      end

  end
  
  
endmodule 