module decode(input  logic[31 : 0] PCF, PCplus4F, instrF,
              input  logic[4  : 0] resultW,
              input  logic[2  : 0] immSrcD,
              input  logic         regWrite,
              output logic         eggs,
              output logic[31 : 0] rd1D, rd2D, immExtD,
              );

  immExt  ie(.immSrc(immSrcD), .imm(instrF[31:7]), .immExt(immExtD));

  regFile rf(.adrr1(instrF[19:15]), .adrr2(instrF[24:20]), .adrw(instrF[11:7]), .wd(ALUresult), .we(regWrite), .clk(clk), .rd1(rd), .rd2(srcB0), .regs(regs));

endmodule