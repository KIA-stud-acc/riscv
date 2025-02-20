module fetch( input   logic         clk, rst, PCsrcE, stallF, bpPred,
              input   logic[31 : 0] PCtargetE, bpDest,
              output  logic[31 : 0] PCF, PCplus4F
            );

  assign PCplus4F = PCF + 32'd4;

  //PC
  always_ff @(posedge clk) begin
    if (rst) begin
      PCF <= '0;
    end
    else if (~stallF) begin
      PCF <= PCsrcE ? PCtargetE : (bpPred ? bpDest : PCplus4F);
    end
  end

endmodule