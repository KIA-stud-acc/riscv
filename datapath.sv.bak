`include "./stages/fetch.sv"
`include "./stages/decode.sv"
`include "./stages/execute.sv"
`include "./stages/writeback.sv"

module datapath ( input   logic         clk, rst,
                  input   logic         jumpD, branchD, JsrcD, ALUsrcBD, memWriteD, regWriteD,
                  input   logic         bpPred, bpValid, 
                  output  logic         corr_pred, bpUpdate,
                  input   logic[1  : 0] resultSrcD, ALUsrcAD, 
                  input   logic[2  : 0] immSrcD,
                  input   logic[3  : 0] ALUcontrolD,
                  input   logic[31 : 0] instrF, readDataM, bpDest,
                  output  logic         memWriteM,
                  output  logic[31 : 0] dataAdrM, writeDataM, PCF, PCE, instrD, PCtargetE, targetImmExt,
                  output  logic[31 : 0][31:0] regs,


                  output  logic[4 :0] rs1E, rs2E, rdM, rdW,
                  output  logic       regWriteM, regWriteW,
                  input   logic[1 :0] forwardAE, forwardBE,

                  output  logic[4 :0] rs1D, rs2D, rdE,
                  output  logic       resultSrcE0, 
                  input   logic       stallF, stallD, 

                  output  logic       PCsrcE,
                  input   logic       flushD, flushE,

                  input   logic       uo,
                  output  logic       ui
                );

  logic[31:0] PCplus4F;
  fetch  f(.clk(clk), .rst(rst), .PCsrcE(PCsrcE), .PCtargetE(PCtargetE), .PCF(PCF), .PCplus4F(PCplus4F), .stallF(stallF), .bpPred(bpPred), .bpDest(bpDest));

/////////////////////////////////////////////////////////
  logic         bpPredD, bpValidD, uoD;
  logic[31 : 0] PCD, PCplus4D, bpDestD;
  always_ff @(posedge clk) begin
    if (flushD || rst) begin
      instrD   <= '0;
      PCD      <= 'x;
      PCplus4D <= 'x;

      bpPredD  <= '0;
      bpValidD <= 'x;
      bpDestD  <= 'x;
      uoD      <= 'x;
    end
    else if (~stallD) begin
      instrD   <= instrF;
      PCD      <= PCF;
      PCplus4D <= PCplus4F;
      
      bpPredD  <= bpPred;
      bpValidD <= bpValid;
      bpDestD  <= bpDest;
      uoD      <= uo;
    end
  end

  logic[4 : 0] rdD;
  logic[31: 0] rd1D, rd2D, immExtD;
  decode d( .clk(clk), .instrD(instrD), .resultW(resultW), .immSrcD(immSrcD), .regWriteW(regWriteW), .rdW(rdW),
            .rs1D(rs1D), .rs2D(rs2D), .rdD(rdD), .rd1D(rd1D), .rd2D(rd2D), .immExtD(immExtD), .regs(regs));

/////////////////////////////////////////////////////////
  logic        bpPredE, bpValidE;
  logic[31: 0] rd1E, rd2E, immExtE, writeDataE;
  logic[31: 0] PCplus4E, bpDestE;
  logic[2 : 0] funct3E;
  always_ff @(posedge clk) begin //data
    PCE      <= PCD;
    PCplus4E <= PCplus4D;
    rs1E     <= rs1D;
    rs2E     <= rs2D;
    rdE      <= rdD;
    rd1E     <= rd1D;
    rd2E     <= rd2D;
    immExtE  <= immExtD;
    funct3E  <= instrD[14:12];
  end

  logic        jumpE, branchE, JsrcE, ALUsrcBE, memWriteE, regWriteE;
  logic[1 : 0] resultSrcE, ALUsrcAE;
  logic[3 : 0] ALUcontrolE;

  assign       resultSrcE0 = resultSrcE[0];

  always_ff @(posedge clk) begin //control signals
    if (flushE || rst) begin
      bpPredE  <= '0;
      bpValidE <= 'x;
      bpDestE  <= 'x;
      ui       <= 'x;
      {jumpE, branchE, JsrcE, ALUsrcBE, memWriteE, regWriteE, resultSrcE, ALUsrcAE, ALUcontrolE} <= 14'b0_0_x_x_0_0_00_xx_xxxx;
    end
    else begin
      bpPredE  <= bpPredD;
      bpValidE <= bpValidD;
      bpDestE  <= bpDestD;
      ui       <= uoD;
      {jumpE, branchE, JsrcE, ALUsrcBE, memWriteE, regWriteE, resultSrcE, ALUsrcAE, ALUcontrolE} <= {jumpD, branchD, JsrcD, ALUsrcBD, memWriteD, regWriteD, resultSrcD, ALUsrcAD, ALUcontrolD};
    end
  end

  logic[31: 0]  ALUresultE;
  execute e(.immExtE(immExtE), .rd1E(rd1E), .rd2E(rd2E), .PCE(PCE), .ALUcontrolE(ALUcontrolE), .ALUsrcAE(ALUsrcAE), .PCplus4E(PCplus4E), 
            .jumpE(jumpE), .branchE(branchE), .JsrcE(JsrcE), .ALUsrcBE(ALUsrcBE), .PCsrcE(PCsrcE), .PCtargetE(PCtargetE), .ALUresultE(ALUresultE),
            .forwardAE(forwardAE), .forwardBE(forwardBE), .ALUresultM(ALUresultM), .resultW(resultW), .funct3(funct3E), .writeDataE(writeDataE),
            .corr_pred(corr_pred), .bpPredE(bpPredE), .bpValidE(bpValidE), .bpUpdate(bpUpdate), .bpDestE(bpDestE), .targetImmExt(targetImmExt));

/////////////////////////////////////////////////////////

  logic[31: 0] ALUresultM;
  logic[31: 0] PCplus4M;
  always_ff @(posedge clk) begin //data
    PCplus4M    <= PCplus4E;
    rdM         <= rdE;
    writeDataM  <= writeDataE;
    ALUresultM  <= ALUresultE;
  end

  logic[1 : 0] resultSrcM;
  always_ff @(posedge clk) begin //control signals
    {memWriteM, regWriteM, resultSrcM} <= {memWriteE, regWriteE, resultSrcE};
  end

  assign dataAdrM   = ALUresultM;

/////////////////////////////////////////////////////////

  logic[31: 0] ALUresultW, readDataW;
  logic[31: 0] PCplus4W;
  always_ff @(posedge clk) begin //data
    PCplus4W    <= PCplus4M;
    rdW         <= rdM;
    readDataW   <= readDataM;
    ALUresultW  <= ALUresultM;
  end

  logic[1 : 0] resultSrcW;
  always_ff @(posedge clk) begin //control signals
    {regWriteW, resultSrcW} <= {regWriteM, resultSrcM};
  end

  logic [31: 0] resultW;
  writeback w(.ALUresultW(ALUresultW), .readDataW(readDataW), .PCplus4W(PCplus4W), .resultSrcW(resultSrcW), .resultW(resultW));

//`define debug_datapath
`ifdef  debug_datapath
 initial begin
    forever begin
      @(posedge clk);
      #4;
      $display("DATAPATH HAZARD %h %h %h %h", stallF, stallD, flushD, flushE);
      $display("PREDICT %h %h %h %h %h %h %h %h %h %h", bpPred, bpValid, corr_pred, bpUpdate, bpDest, bpDestE, PCtargetE, bpPredE, jumpE, branchE);
      $display("DATAPATHF %h %h", PCF, instrF);
      $display("DATAPATHD %h %h %h %h %h %h %h %h %h", instrD, PCD, rdD, rd1D, rd2D, immSrcD, immExtD, regWriteD, jumpD);
      $display("DATAPATHE %h %h %h %h %h %h %h %h %h %h %h %h", forwardAE, forwardBE, rd1E, rd2E, ALUcontrolE,ALUsrcAE,ALUsrcBE, immExtE, ALUresultE,regWriteE, resultSrcE, rdE);
      $display("DATAPATHM %h %h %h %h %h %h", ALUresultM, regWriteM, dataAdrM, writeDataM,readDataM, memWriteM);
      $display("DATAPATHW %h %h %h %h %h", ALUresultW,readDataW, resultSrcW, resultW, regWriteW);
    end
  end
`endif

endmodule