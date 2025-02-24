`include "top.sv"

//`define debug

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
    repeat(2) @(posedge clk);
    forever begin
      @(posedge clk);
      $display("%h", instr);
    end
  end

  initial begin
    $dumpvars();
  end

  logic[31:0] instr;

  top dut(.clk(clk), .rst(rst), .instr1(instr), .regs(regs));

  initial begin
    wait (|instr == 1'b0 || (instr == 32'h00008067 && regs[1] == 'x));
    repeat(3) @(posedge clk); 
    $finish();
  end
  initial begin
    forever begin
      @(negedge clk); 
      #1;
      for (int i = 0; i < 15; i++) begin
        $display("x%-2d - %08h", i, (i == 0) ? 0 : regs[i]);
      end
      $display("\n");
    end
  end
endmodule