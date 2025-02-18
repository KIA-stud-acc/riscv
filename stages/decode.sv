`include "./stages/decode/immExt.sv"
`include "./stages/decode/regFile.sv"

module decode(input  logic[31 : 0]     instrD,
              input  logic[31 : 0]     resultW,
              input  logic[4  : 0]     rdW,
              input  logic[2  : 0]     immSrcD,
              input  logic             regWriteW, clk,
              output logic[4  : 0]     rs1D, rs2D, rdD,
              output logic[31 : 0]     rd1D, rd2D, immExtD,
              output logic[31:0][31:0] regs
              );

  immExt  ie(.immSrc(immSrcD), .imm(instrD[31:7]), .immExt(immExtD));

  assign  rs1D = instrD[19:15];
  assign  rs2D = instrD[24:20];
  assign  rdD  = instrD[11: 7];

  regFile rf(.adrr1(rs1D), .adrr2(rs2D), .adrw(rdW), .wd(resultW), .we(regWriteW), .clk(clk), .rd1(rd1D), .rd2(rd2D), .regs(regs));

endmodule