module ALU #(parameter ALUcontrolWidth = 4)
            (input  logic [ALUcontrolWidth-1:0] ALUcontrol, 
             input  logic [31:0] srcA, srcB,
             output logic zero, negative, overflow, carry,
             output logic [31:0] ALUresult
             );

  logic[32:0] sum;
  assign      sum = srcA + (ALUcontrol[0] ? ~srcB : srcB) + ALUcontrol[0];

  assign negative = ALUresult[31];
  assign zero     = ~|ALUresult;
  assign overflow = (srcA[31] ^ sum[31]) & ~(srcA[31] ^ srcB[31] ^ ALUcontrol[0]);
  assign carry    = sum[32];

  always_comb begin
    case(ALUcontrol)
      ALUcontrolWidth'(0): begin //add
        ALUresult = sum;
      end
      ALUcontrolWidth'(1): begin //sub
        ALUresult = sum;
      end
      ALUcontrolWidth'(2): begin //and
        ALUresult = srcA & srcB;
      end
      ALUcontrolWidth'(3): begin //or
        ALUresult = srcA | srcB;
      end
      ALUcontrolWidth'(4): begin //xor
        ALUresult = srcA ^ srcB;
      end
      ALUcontrolWidth'(5): begin //sll
        ALUresult = srcA << srcB[4:0];
      end
      ALUcontrolWidth'(6): begin //srl
        ALUresult = srcA >> srcB[4:0];
      end
      ALUcontrolWidth'(7): begin //sltu
        ALUresult = {31'b0, ~carry};
      end
      ALUcontrolWidth'(8): begin //sra
        ALUresult = srcA >>> srcB[4:0];
      end
      ALUcontrolWidth'(9): begin //slt
        ALUresult = {31'b0, sum[31]^overflow};
      end
    endcase
  end

endmodule