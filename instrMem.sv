module instrMem(input  logic[31:0] adr,
                output logic[31:0] instr);

initial begin
  $readmemh("testProg.txt", mem);
end

logic[31:0] mem [64];

assign instr = mem[adr[31:2]];


endmodule