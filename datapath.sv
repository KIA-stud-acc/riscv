module datapath ( input   logic clk, rst,
                                Jsrc,
                  input   logic[1  : 0] resultSrc,
                  input   logic[31 : 0] readData,
                  output  logic[31 : 0] dataAdr, writeData, PC, 
                  );

  
  
  

  

  

  assign writeData = srcB0;
  assign dataAdr   = ALUresult;

  

  

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