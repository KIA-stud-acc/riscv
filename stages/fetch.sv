module fetch( input   logic         clk, rst, PCsrcE, stallF,
              input   logic[31 : 0] PCtargetE,
              output  logic[31 : 0] PCF, PCplus4F
            );

  assign PCplus4F = PCF + 32'd4;

  //PC
  always_ff @(posedge clk) begin
    if (rst) begin
      PCF <= '0;
    end
    else if (~stallF) begin
      PCF <= PCsrcE ? PCtargetE : PCplus4F;
    end
  end

endmodule