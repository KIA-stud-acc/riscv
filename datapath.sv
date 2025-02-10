module datapath ( input   logic clk, rst,
                                regWrite, PCsrc,
                                ALUsrcB, Jsrc,
                  input   logic[3  : 0] ALUcontrol,
                  input   logic[1  : 0] immSrc, resultSrc, ALUsrcA,
                  input   logic[31 : 0] instr, readData,
                  output  logic zero, negative, overflow, carry,
                  output  logic[31 : 0] dataAdr, writeData, PC,
                  output  logic[31:0][31:0] regs 
                  );

  logic [31:0] srcA, srcB, srcB0, ALUresult, result, rd;
  logic [31:0] PCplus4;
  logic [31:0] immExt;

  assign PCplus4 = PC + 32'd4;

  logic [31:0] PCtarget;
  assign PCtarget = (Jsrc ? rd : PC) + immExt;
  
  //PC
  always_ff @(posedge clk) begin
    if (rst) begin
      PC <= '0;
    end
    else begin
      PC <= PCsrc ? PCtarget : PCplus4;
    end
  end

  immExt  ie(.immSrc(immSrc), .imm(instr[31:7]), .immExt(immExt));

  regFile rf(.adrr1(instr[19:15]), .adrr2(instr[24:20]), .adrw(instr[11:7]), .wd(ALUresult), .we(regWrite), .clk(clk), .rd1(rd), .rd2(srcB0), .regs(regs));

  assign writeData = srcB0;
  assign dataAdr   = ALUresult;

  assign srcB = ALUsrcB ? immExt : srcB0;

  always_comb begin
    case(ALUsrcA)
      2'b00:   srcA = rd;
      2'b01:   srcA = PC;
      2'b10:   srcA = '0;
      default: srcA = 'x;
    endcase
  end

  ALU     alu(.ALUcontrol(ALUcontrol), .srcA(srcA), .srcB(srcB), .zero(zero), .negative(negative), .overflow(overflow), .carry(carry), .ALUresult(ALUresult));

  always_comb begin
    case(resultSrc)
      2'b00:   result = ALUresult;
      2'b01:   result = PCplus4;
      2'b10:   result = readData;
      default: result = 'x;
    endcase
  end

endmodule