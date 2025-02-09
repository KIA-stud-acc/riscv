module immExt(input  logic [2:0] immSrc,
              input  logic [31:7] imm,
              output logic [31:0] immExt
              );

  always_comb begin
    case (immSrc) 
      3'b000:  immExt = {20{imm[31]}, imm[31:20]};                                     //I
      3'b001:  immExt = {20{imm[31]}, imm[31:25], imm[11:7]};                          //S
      3'b010:  immExt = {19{imm[31]}, imm[31], imm[7], imm[30:25], imm[11:8], 1'b0};   //B
      3'b011:  immExt = {imm[31:12], 12'b0};                                           //U
      3'b100:  immExt = {12{imm[31]}, imm[31], imm[19:12], imm[20], imm[30:21], 1'b0}; //J
      default: immExt = 'x;
    endcase
  end

endmodule