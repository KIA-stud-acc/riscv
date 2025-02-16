module datapath ( input   logic clk, rst,
                                Jsrc,
                  input   logic[1  : 0] resultSrc,
                  input   logic[31 : 0] readData,
                  output  logic[31 : 0] dataAdr, writeData, PC, 
                  );

  
  
  

  

  

  assign writeData = srcB0;
  assign dataAdr   = ALUresult;
  

endmodule