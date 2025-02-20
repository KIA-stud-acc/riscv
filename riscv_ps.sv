`include "datapath.sv"
`include "controller.sv"
`include "hazard.sv"
`include "branch_prediction.sv"

module riscv_ps(input   logic         clk, rst,
                input   logic [31:0]  instr, readData,
                output  logic         memWriteM,
                output  logic [31:0]  dataAdr, PC, writeData,
                output  logic[31:0][31:0] regs );

  logic[1 :0] resultSrc, ALUsrcA;
  logic[2 :0] immSrc;
  logic[3 :0] ALUcontrol;
  logic[31:0] instrD, PCE, PCtargetE;
  logic       regWrite, branch, ALUsrcB, Jsrc, memWriteD;

  datapath    dp( .clk(clk), .rst(rst), .regWriteD(regWrite), .jumpD(jumpD), .branchD(branch), .ALUsrcBD(ALUsrcB), 
                  .JsrcD(Jsrc), .ALUcontrolD(ALUcontrol), .immSrcD(immSrc), .resultSrcD(resultSrc), .ALUsrcAD(ALUsrcA), 
                  .instrF(instr), .readDataM(readData), .dataAdrM(dataAdr), .writeDataM(writeData), .PCF(PC), .regs(regs),
                  .memWriteM(memWriteM), .memWriteD(memWriteD), .stallF(stallF), .stallD(stallD), .flushD(flushD), .flushE(flushE),
                  .rs1E(rs1E), .rs2E(rs2E), .rdM(rdM), .rdW(rdW), .regWriteM(regWriteM), .regWriteW(regWriteW),
                  .forwardAE(forwardAE), .forwardBE(forwardBE), .rs1D(rs1D), .rs2D(rs2D), .rdE(rdE),
                  .resultSrcE0(resultSrcE0), .PCsrcE(PCsrcE), .instrD(instrD), .PCE(PCE), .PCtargetE(PCtargetE),
                  .corr_pred(corr_pred), .bpPred(bpPred), .bpValid(bpValid), .bpUpdate(bpUpdate), .bpDest(bpDest));

  controller  c(.op(instrD[6:0]), .funct3(instrD[14:12]), .funct7(instrD[30]), .jump(jumpD), .memWrite(memWriteD), 
                .ALUsrcB(ALUsrcB), .regWrite(regWrite), .Jsrc(Jsrc), .resultSrc(resultSrc), .ALUsrcA(ALUsrcA), 
                .immSrc(immSrc), .ALUcontrol(ALUcontrol), .branch(branch));


  logic[4 :0] rs1E, rs2E, rdM, rdW;
  logic       regWriteM, regWriteW;
  logic[1 :0] forwardAE, forwardBE;
  logic[4 :0] rs1D, rs2D, rdE;
  logic       resultSrcE0, jumpD;
  logic       stallF, stallD;
  logic       PCsrcE;
  logic       flushD, flushE;

  hazard      h(.rs1E(rs1E), .rs2E(rs2E), .rdM(rdM), .rdW(rdW), .regWriteM(regWriteM), .regWriteW(regWriteW),
                .forwardAE(forwardAE), .forwardBE(forwardBE), .rs1D(rs1D), .rs2D(rs2D), .rdE(rdE),
                .resultSrcE0(resultSrcE0), .jumpD(jumpD), .stallF(stallF), .stallD(stallD), 
                .PCsrcE(PCsrcE), .flushD(flushD), .flushE(flushE));

  logic       corr_pred, bpPred, bpValid, bpUpdate;
  logic[31:0] bpDest, 

  branch_prediction bp( .addr(PC), .adrw(PCE), .wd(PCtargetE), .we(bpUpdate), .clk(clk), .rst(rst), 
                        .corr_pred(corr_pred), .dest(bpDest), .pred(bpPred), .valid(bpValid));

endmodule