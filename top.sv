module top( input  logic clk, rst,
            output logic[31:0] instr1,
            output logic[31:0][31:0] regs );

  logic [31:0]  readData, dataAdr, instr, PC, writeData;
  logic         memWrite;
  assign instr1 = instr;
  riscv_ps rvps(.clk(clk), .rst(rst), .instr(instr), .readData(readData), .PC(PC), .writeData(writeData), .memWrite(memWrite), .dataAdr(dataAdr), .regs(regs));
  instrMem im(.adr(PC), .instr(instr));
  dataMem  dm(.clk(clk), .we(memWrite), .adr(dataAdr), .writeData(writeData), .readData(readData));

endmodule