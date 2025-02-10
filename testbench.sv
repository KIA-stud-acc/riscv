module testbench;

  logic clk, rst;
  logic[31:0][31:0] regs;

  initial begin
    clk = 1'b0;
    forever begin
      #5 clk = ~clk;
    end
  end
  
  initial begin
    rst = 1'b1;
    repeat(3) @(posedge clk);
    rst = 1'b0;
  end

  initial begin
    forever begin
      @(posedge clk);
      if (~rst) $display("%h", instr);
    end
  end

  initial begin
    $dumpvars();
  end

  logic[31:0] instr;

  top dut(.clk(clk), .rst(rst), .instr1(instr), .regs(regs));

  always_comb begin
    if (|instr == 1'b0) begin
      for (int i = 0; i < 32; i++) begin
        $display("x%-2d - %08h", i, (i == 0) ? 0 : regs[i]);
      end
      $finish();
    end
  end

endmodule