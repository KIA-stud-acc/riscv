module regFile( input  logic[4:0]  adrr1, adrr2, adrw, 
                input  logic[31:0] wd,
                input  logic       we, clk,
                output logic[31:0] rd1, rd2,
                output logic[31:0][31:0] regs);
  logic [31:0][31:0] rf;
  assign rd1 = (adrr1 != 0) ? rf[adrr1] : '0;
  assign rd2 = (adrr1 != 0) ? rf[adrr2] : '0;

  always_ff @(posedge clk) begin
    if (we) begin
      rf[adrw] <= wd;
    end
  end

  always_comb begin
    for (int i = 0; i < 32; i++) begin
      regs[i] = rf[i];
    end
  end

endmodule