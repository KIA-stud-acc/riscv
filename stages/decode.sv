module decode(input  logic[31 : 0]     PCF, PCplus4F, instrF,
              output logic[31 : 0]     PCD, PCplus4D,
              input  logic[31 : 0]     resultW,
              input  logic[2  : 0]     immSrcD,
              input  logic             regWriteW,
              output logic[4  : 0]     rs1D, rs2D, rdD,
              output logic[31 : 0]     rd1D, rd2D, immExtD,
              output logic[31:0][31:0] regs
              );

  immExt  ie(.immSrc(immSrcD), .imm(instrF[31:7]), .immExt(immExtD));

  assign  rs1D = instrF[19:15];
  assign  rs2D = instrF[24:20];
  assign  rdD  = instrF[11: 7];

  regFile rf(.adrr1(rs1D), .adrr2(rs2D), .adrw(rdD), .wd(resultW), .we(regWriteW), .clk(clk), .rd1(rd1D), .rd2(rd2D), .regs(regs));

endmodule