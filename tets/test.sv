module test;

localparam clog2depth = 5;
typedef struct packed {
    logic                      valid;
    logic[30-clog2depth-1 : 0] tag;
    logic[              1 : 0] predBits;
    logic[             31 : 0] destAdr;
  } cacheLine;

  typedef struct packed {
    logic          lruBit;
    cacheLine[1:0] line;
  } cacheSet;

  cacheSet[$pow(2, clog2depth)-1 : 0] btb; //branch table buffer 

logic[31:0][31:0] mem1;
logic clk;
initial begin
  clk = 1;
  forever #5 clk = ~clk;
end

cacheSet tmp;
assign tmp = btb[n[5:0]];
always_ff @(posedge clk) begin
  btb[n[4:0]][0] <= n;
end
int n;
initial begin
  n = 0;
  forever begin
    @(posedge clk);
    n++;
    if (n>32) begin
      $finish;
    end
    for (int i = 0; i < 32; i++) begin
      $display("%h", mem1[i]);
      $display("%h", btb[i].lruBit);
    end
  end
end
endmodule