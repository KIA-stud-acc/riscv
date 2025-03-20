`include "ALU.sv"

module execute( input  logic[31 : 0]  immExtE, rd1E, rd2E, PCE, PCplus4E, ALUresultM, resultW, bpDestE,
                input  logic[3  : 0]  ALUcontrolE,
                input  logic[2  : 0]  funct3,
                input  logic[1  : 0]  ALUsrcAE, forwardAE, forwardBE,
                input  logic          jumpE, branchE, JsrcE,
                input  logic          bpPredE, bpValidE,
                input  logic          ALUsrcBE, 
                output logic          PCsrcE, corr_pred, bpUpdate,      
                output logic[31 : 0]  PCtargetE, ALUresultE, writeDataE, targetImmExt
              );

  assign      targetImmExt = (JsrcE ? rd1E : PCE) + immExtE;
  always_comb begin
    PCtargetE = 'x;
    if (corr_pred) begin
      if (bpPredE) begin
        PCtargetE = PCplus4E;
      end
      else begin
        PCtargetE = targetImmExt;
      end
    end
  end

  assign bpUpdate = ~bpValidE&(jumpE|branchE);

  logic [31:0]  srcA, srcB;

  always_comb begin
    case(ALUsrcAE)
      2'b00:   case(forwardAE)
                  2'b00:   srcA = rd1E;
                  2'b01:   srcA = resultW;
                  2'b10:   srcA = ALUresultM;
                  default: srcA = 'x;
               endcase
      2'b01:   srcA = PCE;
      2'b10:   srcA = '0;
      default: srcA = 'x;
    endcase
  end

  always_comb begin
    case(forwardBE)
      2'b00:   writeDataE = rd2E;
      2'b01:   writeDataE = resultW;
      2'b10:   writeDataE = ALUresultM;
      default: writeDataE = 'x;
    endcase
  end

  always_comb begin
    if (ALUsrcBE) begin
      srcB = immExtE;
    end
    else begin
      srcB = writeDataE;
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
  
  assign corr_pred = ((bpDestE != targetImmExt) && bpPredE) || ((jumpE | (branchE & condIsTrue)) ^ bpPredE);
/*
  initial begin
    forever begin
      #4;
      $display("AAAAAAAAAAAAA %h %h %h %h %h %h %h %h %h", corr_pred, condIsTrue, funct3, zero, bpDestE, targetImmExt, bpPredE, jumpE, branchE);
      $display("BBBBBBBBBBBBB %h %h %h %h", ALUcontrolE, srcA, srcB, ALUresultE);
    end
  end
*/
  assign PCsrcE = corr_pred;

endmodule