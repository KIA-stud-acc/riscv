`include "./stages/fetch.sv"
`include "./stages/decode.sv"
`include "./stages/execute.sv"
`include "./stages/writeback.sv"

module datapath ( input   logic         clk, rst,
                  input   logic         jumpD, branchD, regWriteD, JsrcD, ALUsrcBD, memWriteD, regWriteD,
                  input   logic[1  : 0] resultSrcD, ALUsrcAD, 
                  input   logic[2  : 0] immSrcD,
                  input   logic[3  : 0] ALUcontrolD,
                  input   logic[31 : 0] instrF, readDataM,
                  output  logic         memWriteM,
                  output  logic[31 : 0] dataAdrM, writeDataM, PCF,
                  output  logic[31 : 0][31:0] regs
                );

  
  fetch  f(.clk(clk), .rst(rst), .PCsrcE(PCsrcE), .PCtargetE(PCtargetE), .PCF(PCF), .PCplus4F(PCplus4F));

/////////////////////////////////////////////////////////

  logic[31 : 0] instrD, PCD, PCplus4D;
  always_ff @(posedge clk) begin
    instrD   <= instrF;
    PCD      <= PCF;
    PCplus4D <= PCplus4F;
  end

  logic[4 : 0] rs1D, rs2D, rdD;
  logic[31: 0] rd1D, rd2D, immExtD;
  decode d( .clk(clk), .instrD(instrD), .resultW(resultW), .immSrcD(immSrcD), .regWriteW(regWriteW), 
            .rs1D(rs1D), .rs2D(rs2D), .rdD(rdD), .rd1D(rd1D), .rd2D(rd2D), .immExtD(immExtD), .regs(regs));

/////////////////////////////////////////////////////////

  logic[4 : 0] rs1E, rs2E, rdE;
  logic[31: 0] rd1E, rd2E, immExtE;
  logic[31: 0] PCE, PCplus4E;
  always_ff @(posedge clk) begin //data
    PCE      <= PCD;
    PCplus4E <= PCplus4D;
    rs1E     <= rs1D;
    rs2E     <= rs2D;
    rdE      <= rdD;
    rd1E     <= rd1D;
    rd2E     <= rd2D;
    immExtE  <= immExtD;
  end

  logic        jumpE, branchE JsrcE, ALUsrcBE, memWriteE, regWriteE;
  logic[1 : 0] resultSrcE, ALUsrcAE;
  logic[3 : 0] ALUcontrolE;
  always_ff @(posedge clk) begin //control signals
    {jumpE, branchE, JsrcE, ALUsrcBE, memWriteE, regWriteE, resultSrcE, ALUsrcAE, ALUcontrolE} <= {jumpD, branchD, JsrcD, ALUsrcBD, memWriteD, regWriteD, resultSrcD, ALUsrcAD, ALUcontrolD};
  end

  logic         PCsrcE;
  logic[31: 0]  PCtargetE, ALUresultE;
  execute e(.immExtE(immExtE), .rd1E(rd1E), .rd2E(rd2E), .PCE(PCE), .ALUcontrolE(ALUcontrolE), .ALUsrcAE(ALUsrcAE), 
            .jumpE(jumpE), .branchE(branchE), .JsrcE(JsrcE), .ALUsrcBE(ALUsrcBE), .PCsrcE(PCsrcE), .PCtargetE(PCtargetE), .ALUresultE(ALUresultE));

/////////////////////////////////////////////////////////

  logic[4 : 0] rdM;
  logic[31: 0] ALUresultM, rd2M; //rd2M поменяется на writeDataM
  logic[31: 0] PCplus4M;
  always_ff @(posedge clk) begin //data
    PCplus4M    <= PCplus4E;
    rdM         <= rdE;
    rd2M        <= rd2E;
    ALUresultM  <= ALUresultE;
  end

  logic        memWriteM, regWriteM;
  logic[1 : 0] resultSrcM;
  always_ff @(posedge clk) begin //control signals
    {memWriteM, regWriteM, resultSrcM} <= {memWriteE, regWriteE, resultSrcE};
  end

  assign dataAdrM   = ALUresultM;
  assign writeDataM = rd2M;

/////////////////////////////////////////////////////////

  logic[4 : 0] rdW;
  logic[31: 0] ALUresultW, readDataW; //rd2M поменяется на writeDataM
  logic[31: 0] PCplus4W;
  always_ff @(posedge clk) begin //data
    PCplus4W    <= PCplus4M;
    rdW         <= rdM;
    readDataW   <= readDataM;
    ALUresultW  <= ALUresultM;
  end

  logic        regWriteW;
  logic[1 : 0] resultSrcW;
  always_ff @(posedge clk) begin //control signals
    {regWriteW, resultSrcW} <= {regWriteM, resultSrcM};
  end

  logic [31: 0] resultW;
  writeback w(.ALUresultW(ALUresultW), .readDataW(readDataW), .PCplus4W(PCplus4W), .resultSrcW(resultSrcW), .resultW(resultW));

 
  


  assign writeData = srcB0;
  assign dataAdr   = ALUresult;
  

endmodule