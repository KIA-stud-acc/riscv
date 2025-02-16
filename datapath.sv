module datapath ( input   logic clk, rst,
                                ALUsrcB, Jsrc,
                  input   logic[3  : 0] ALUcontrol,
                  input   logic[1  : 0] resultSrc, ALUsrcA,
                  input   logic[31 : 0] instr, readData,
                  output  logic zero, negative, overflow, carry,
                  output  logic[31 : 0] dataAdr, writeData, PC,
                  output  logic[31:0][31:0] regs 
                  );

  logic [31:0] srcA, srcB,  ALUresult;
  
  

  

  

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