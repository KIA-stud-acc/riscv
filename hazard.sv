module hazard(input  logic[4 :0] rs1E, rs2E, rdM, rdW,
              input  logic       regWriteM, regWriteW,
              output logic[1 :0] forwardAE, forwardBE,

              input  logic[4 :0] rs1D, rs2D, rdE,
              input  logic       resultSrcE0, jumpD, 
              output logic       stallF, stallD, 

              input  logic       PCsrcE,
              output logic       flushD, flushE
             );

  always_comb begin
    if ((rs1E == rdM) & regWriteM) & (rs1E != '0) begin
      forwardAE = 2'b10;
    end
    else if ((rs1E == rdW) & regWriteW) & (rs1E != '0) begin
      forwardAE = 2'b01;
    end
    else begin
      forwardAE = 2'b00;
    end
  end

  always_comb begin
    if ((rs2E == rdM) & regWriteM) & (rs2E != '0) begin
      forwardAE = 2'b10;
    end
    else if ((rs2E == rdW) & regWriteW) & (rs2E != '0) begin
      forwardAE = 2'b01;
    end
    else begin
      forwardAE = 2'b00;
    end
  end

  logic  lwStall;
  assign lwStall = ~jumpD & resultSrcE0 & (((rs1D == rdE) & (rs1D != '0)) | ((rs2D == rdE) & (rs2D != '0))); //можно ещё провести сюда ALUop0, чтобы предотвратить возможное ложное срабатываение от команд типа I
  assign stallD  = lwStall;
  assign stallF  = lwStall;

  //логика очистки, если произошло ветвление (под изменение после добавления предсказания переходов)
  assign flushD = PCsrcE;
  assign dlushE = PCsrcE | lwStall;

endmodule