module controller(input  logic[6:0] op,
                  input  logic[2:0] funct3,
                  input  logic      funct7, zero, negative, overflow, carry,
                  output logic  PCsrc, memWrite,
                                ALUsrcB, regWrite,
                                Jsrc,
                  output logic[1:0] resultSrc, ALUsrcA,
                  output logic[2:0] immSrc,
                  output logic[3:0] ALUcontrol 
                  );

  logic[14:0] controls;
  logic[1:0]  ALUop;
  logic       branch, jump;
  assign     {branch, resultSrc, memWrite, ALUsrcA, ALUsrcB, regWrite, immSrc, ALUop, jump, Jsrc} = controls;

  always_comb begin //main decoder
    case(op)
      7'b0000_011: controls = 15'b0_01_0_00_1_1_000_00_0_x;//lw
      7'b0010_011: controls = 15'b0_00_0_00_1_1_000_01_0_x;//I
      7'b0010_111: controls = 15'b0_00_0_01_1_1_011_00_0_x;//auipc
      7'b0100_011: controls = 15'b0_xx_1_00_1_0_001_00_0_x;//sw
      7'b0110_011: controls = 15'b0_00_0_00_0_1_xxx_01_0_x;//R
      7'b0110_111: controls = 15'b0_00_0_10_1_1_011_00_0_x;//lui
      7'b1100_011: controls = 15'b1_xx_0_00_0_0_010_10_0_0;//B
      7'b1100_111: controls = 15'bx_10_0_00_1_1_000_00_1_1;//jalr
      7'b1101_111: controls = 15'bx_10_0_xx_x_1_100_xx_1_0;//jal
    endcase
  end 

  always_comb begin //alu decoder
    case(ALUop)
      2'b00: begin
        ALUcontrol = 4'd0;
      end
      2'b01: begin
        if (~op[5]) begin
          case(funct3)
            3'b000: ALUcontrol = 4'd0;
            3'b001: ALUcontrol = 4'd5;
            3'b010: ALUcontrol = 4'd9;
            3'b011: ALUcontrol = 4'd7;
            3'b100: ALUcontrol = 4'd4;
            3'b101: if (funct7) ALUcontrol = 4'd8;
                    else        ALUcontrol = 4'd6;
            3'b110: ALUcontrol = 4'd3;
            3'b111: ALUcontrol = 4'd2;
          endcase
        end
        else begin
          case(funct3)
            3'b000: if (funct7) ALUcontrol = 4'd1;
                    else        ALUcontrol = 4'd0;
            3'b001: ALUcontrol = 4'd5;
            3'b010: ALUcontrol = 4'd9;
            3'b011: ALUcontrol = 4'd7;
            3'b100: ALUcontrol = 4'd4;
            3'b101: if (funct7) ALUcontrol = 4'd8;
                    else        ALUcontrol = 4'd6;
            3'b110: ALUcontrol = 4'd3;
            3'b111: ALUcontrol = 4'd2;
          endcase
        end
      end
      2'b10: begin
        ALUcontrol = 4'd1;
      end
      default: ALUcontrol = 'x;
    endcase
  end


  logic condIsTrue;
  always_comb begin //PCsrc / branch module
    case (funct3)
      3'b000:  condIsTrue = zero;
      3'b001:  condIsTrue = ~zero;
      3'b100:  condIsTrue = negative^overflow;
      3'b101:  condIsTrue = ~(negative^overflow);
      3'b110:  condIsTrue = ~carry;
      3'b111:  condIsTrue = carry;
      default: condIsTrue = 'x;
    endcase
  end
  
  assign PCsrc = jump | (branch & condIsTrue);
endmodule