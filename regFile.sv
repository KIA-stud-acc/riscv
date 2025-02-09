module regFile( input  logic[31:0] adrr1, adrr2, adrw, wd,
                input  logic       we, clk,
                output logic[31:0] rd1, rd2);
  logic [31:0] rf [32];
  assign rd1 = rf[adrr1];
  assign rd2 = rf[adrr2];

  always_ff @(posedge clk) begin
    if (we) begin
      rf[adrw] <= wd;
    end
  end

endmodule