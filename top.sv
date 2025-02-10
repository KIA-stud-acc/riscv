module top(input logic clk, rst);
  logic [31:0]  instr, readData, dataAdr;
  logic         PC, writeData, memWrite;
  riscv_ps rvps(.clk(clk), .rst(rst), .instr(instr), .readData(readData), .PC(PC), .writeData(writeData), .memWrite(memWrite), .dataAdr(dataAdr));
  instrMem im(.adr(PC), .instr(instr));
  dataMem  dm(.clk(clk), .we(memWrite), .adr(dataAdr), .writeData(writeData), .readData(readData));
endmodule