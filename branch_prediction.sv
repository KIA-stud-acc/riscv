module branch_prediction #(parameter clog2depth = 5)
                         (input  logic[31:0] adrr, adrw, wd,
                          input  logic       we, clk, rst, corr_pred,
                          output logic[31:0] dest,
                          output logic       pred, valid
                         );

  typedef struct packed {
    logic                      valid;
    logic[30-clog2depth-1 : 0] tag;
    logic[              1 : 0] predBits;
    logic[             31 : 0] destAdr;
  } cacheLine;

  typedef struct packed {
    logic          lruBit;
    cacheLine[1:0] line;
  } cacheSet;

  cacheSet[clog2depth-1 : 0] btb; //branch table buffer 

  `define way btb[adrw[clog2depth+1:2]].lruBit

  always_ff @( posedge clk ) begin
    if (rst) begin
      for (int i = 0; i < pow(2, clog2depth); i++) begin
        btb[i].lruBit        <= 1'b0;
        btb[i].line[0].valid <= 1'b0;
        btb[i].line[1].valid <= 1'b0;
      end
    end
    else if (we) begin
      btb[adrw[clog2depth+1:2]].lruBit             <= 1'b0;
      btb[adrw[clog2depth+1:2]].line[way].valid    <= 1'b1;
      btb[adrw[clog2depth+1:2]].line[way].tag      <= adrw[$left(adrw) : clog2depth+2];
      btb[adrw[clog2depth+1:2]].line[way].destAdr  <= wd;

      if (btb[adrw[clog2depth+1:2]].line[way].valid == 1'b0) begin
        btb[adrw[clog2depth+1:2]].line[way].predBits <= {2{corr_pred}};
      end
      else begin
        case(btb[adrw[clog2depth+1:2]].line[way].predBits)
          2'b00: begin
            if (corr_pred) begin
              btb[adrw[clog2depth+1:2]].line[way].predBits <= 2'b01;
            end
            else begin
              btb[adrw[clog2depth+1:2]].line[way].predBits <= 2'b00;
            end
          end
          2'b01: begin
            if (corr_pred) begin
              btb[adrw[clog2depth+1:2]].line[way].predBits <= 2'b11;
            end
            else begin
              btb[adrw[clog2depth+1:2]].line[way].predBits <= 2'b00;
            end
          end
          2'b10: begin
            if (corr_pred) begin
              btb[adrw[clog2depth+1:2]].line[way].predBits <= 2'b00;
            end
            else begin
              btb[adrw[clog2depth+1:2]].line[way].predBits <= 2'b11;
            end
          end
          2'b11: begin
            if (corr_pred) begin
              btb[adrw[clog2depth+1:2]].line[way].predBits <= 2'b10;
            end
            else begin
              btb[adrw[clog2depth+1:2]].line[way].predBits <= 2'b11;
            end
          end
        endcase
      end
    end
  end

  logic  cacheHit1 , cacheHit0;
  assign cacheHit1 = btb[adrw[clog2depth+1:2]].line[1].valid & (btb[adrw[clog2depth+1:2]].line[1].tag == adrw[$left(adrw) : clog2depth+2]);
  assign cacheHit0 = btb[adrw[clog2depth+1:2]].line[0].valid & (btb[adrw[clog2depth+1:2]].line[0].tag == adrw[$left(adrw) : clog2depth+2]);
  always_comb begin
    if (cacheHit0 || cacheHit1) begin
      dest  = btb[adrw[clog2depth+1:2]].line[cacheHit1].destAdr;
      valid = 1'b1;
      case(btb[adrw[clog2depth+1:2]].line[cacheHit1].predBits)
        2'b00: begin
          pred = 1'b0;
        end
        2'b01: begin
          pred = 1'b0;
        end
        2'b10: begin
          pred = 1'b1;
        end
        2'b11: begin
          pred = 1'b1;
        end
      endcase
    end
    else begin
      valid = 1'b0;
      pred  = 1'b0;
      dest  = 32'bx;
    end
  end
  
endmodule