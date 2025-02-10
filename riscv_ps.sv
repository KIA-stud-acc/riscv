module riscv_ps(input   logic         clk, rst,
                input   logic [31:0]  instr, readData,
                output  logic         PC, writeData, memWrite,
                output  logic [31:0]  dataAdr
                );

  logic      zero, negative, overflow, carry;
  logic[1:0] immSrc, resultSrc, ALUsrcA;
  logic[3:0] ALUcontrol;
  logic regWrite, PCsrc, ALUsrcB, Jsrc;

  datapath    dp(.clk(clk), .rst(rst), .regWrite(regWrite), .PCsrc(PCsrc), .ALUsrcB(ALUsrcB), .Jsrc(Jsrc), .ALUcontrol(ALUcontrol), .immSrc(immSrc), .resultSrc(resultSrc), .ALUsrcA(ALUsrcA), .instr(instr), .readData(readData), .zero(zero), .negative(negative), .overflow(overflow), .carry(carry), .dataAdr(dataAdr), .writeData(writeData), .PC(PC));
  controller  c(.op(instr[6:0]), .funct3(instr[14:12]), .funct7(instr[30]), .zero(zero), .negative(negative), .overflow(overflow), .carry(carry), .PCsrc(PCsrc), .memWrite(memWrite), .ALUsrcB(AUUsrcB), .regWrite(regWrite), .Jsrc(Jsrc), .resultSrc(resultSrc), .ALUsrcA(ALUsrcA), .immSrc(immSrc), .ALUcontrol(ALUcontrol));
  
endmodule