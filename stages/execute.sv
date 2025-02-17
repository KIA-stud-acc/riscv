`include "ALU.sv"

module execute( input  logic[31 : 0]  immExtE, rd1E, rd2E, PCE, 
                input  logic[3  : 0]  ALUcontrolE,
                input  logic[1  : 0]  ALUsrcAE,
                input  logic          jumpE, branchE, JsrcE,
                input  logic          ALUsrcBE, 
                output logic          PCsrcE,       
                output logic[31 : 0]  PCtargetE, ALUresultE
              );

  assign        PCtargetE = (JsrcE ? rd1E : PCE) + immExtE;

  logic [31:0]  srcA, srcB,  ALUresultE;

  always_comb begin
    case(ALUsrcAE)
      2'b00:   srcA = rd1E;
      2'b01:   srcA = PCE;
      2'b10:   srcA = '0;
      default: srcA = 'x;
    endcase
  end

  assign srcB = ALUsrcBE ? immExtE : rd2E;

  ALU   alu(.ALUcontrol(ALUcontrolE), .srcA(srcA), .srcB(srcB), .zero(zero), .negative(negative), .overflow(overflow), .carry(carry), .ALUresult(ALUresultE));

  logic zero, negative, overflow, carry;

  logic condIsTrue;
  always_comb begin //PCsrcE / branch module
    case (funct3)
      3'b000:  condIsTrue = zero;
      3'b001:  condIsTrue = ~zero;
      3'b100:  condIsTrue = negative^overflow;
      3'b101:  condIsTrue = ~(negative^overflow);
      3'b110:  condIsTrue = carry;
      3'b111:  condIsTrue = ~carry;
      default: condIsTrue = 'x;
    endcase
  end
  
  assign PCsrcE = jumpE | (branchE & condIsTrue);

endmodule