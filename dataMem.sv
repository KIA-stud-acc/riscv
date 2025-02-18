module dataMem( input  logic       clk, we,
                input  logic[31:0] adr, writeData,
                output logic[31:0] readData);

logic[31:0] mem [64];

assign readData = mem[adr[31:2]];

always_ff @(posedge clk) begin
  if (we) begin
    mem[adr[31:2]] <= writeData;
  end
end

endmodule