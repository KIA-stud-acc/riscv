module riscv_ps(input   logic         clk, rst,
                input   logic [31:0]  instr, readData,
                output  logic         PC, writeData, memWrite,
                output  logic [31:0]  dataAdr
                );

  datapath    dp();
  controller  c();
  
endmodule