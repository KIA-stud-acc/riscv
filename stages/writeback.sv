module writeback( input  logic[31 : 0] ALUresultW, readDataW, PCplus4W,
                  input  logic[1  : 0] resultSrcW,
                  output logic[31 : 0] resultW
                );

  always_comb begin
    case(resultSrcW)
      2'b00:   resultW = ALUresultW;
      2'b01:   resultW = PCplus4W;
      2'b10:   resultW = readDataW;
      default: resultW = 'x;
    endcase
  end

endmodule