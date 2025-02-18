`include "ALU.sv"

module execute( input  logic[31 : 0]  immExtE, rd1E, rd2E, PCE, ALUresultM, resultW,
                input  logic[3  : 0]  ALUcontrolE,
                input  logic[2  : 0]  funct3,
                input  logic[1  : 0]  ALUsrcAE, forwardAE, forwardBE,
                input  logic          jumpE, branchE, JsrcE,
                input  logic          ALUsrcBE, 
                output logic          PCsrcE,       
                output logic[31 : 0]  PCtargetE, ALUresultE, writeDataE
              );

  assign        PCtargetE = (JsrcE ? rd1E : PCE) + immExtE;

  logic [31:0]  srcA, srcB;

  always_comb begin
    case(ALUsrcAE)
      2'b00:   case(forwardAE)
                  2'b00: srcA = rd1E;
                  2'b01: srcA = resultW;
                  2'b10: srcA = ALUresultM;
               endcase
      2'b01:   srcA = PCE;
      2'b10:   srcA = '0;
      default: srcA = 'x;
    endcase
  end

  always_comb begin
    if (ALUsrcBE) begin
      srcB          = immExtE;
    end
    else begin
      case(forwardBE)
        2'b00: srcB = rd2E;
        2'b01: srcB = resultW;
        2'b10: srcB = ALUresultM;
      endcase
    end
  end

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