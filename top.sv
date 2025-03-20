//`include "riscv_ps.sv"
//`include "instrMem.sv"
//`include "dataMem.sv"

module top( input  logic clk, rst,
            output logic[31:0] reg5
            );
  
  logic [31:0]  readData, dataAdr, instr, PC, writeData;
  logic         memWrite;
  riscv_ps rvps(.clk(clk), .rst(rst), .instr(instr), .readData(readData), .PC(PC), .writeData(writeData), .memWriteM(memWrite), .dataAdr(dataAdr), .reg5(reg5));
  instrMem im(.adr(PC), .instr(instr));
  dataMem  dm(.clk(clk), .we(memWrite), .adr(dataAdr), .writeData(writeData), .readData(readData));

endmodule