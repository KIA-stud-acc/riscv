module branch_prediction #(parameter clog2depth = 5)
                         (input  logic[31:0] adrr, adrw, wd,
                          input  logic       we, clk, rst, corr_pred,
                          output logic[31:0] dest,
                          output logic       pred, valid
                         );
  /*
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
*/
  initial begin
    forever begin
      @(posedge clk);
      #1;
      for (int i = 0; i<32; i++) begin
        $display("CACHE %h %h %h %h %h %h %h %h", lruBit[i], valids[0][i], tag[0][i],valids[1][i], tag[1][i], adrw[$left(adrw) : clog2depth+2], predBits[0][i], destAdr[0][i]);
      end
      $display("CACHE! %h %h %h",valids[0][adrr[clog2depth+1:2]], tag[0][adrr[clog2depth+1:2]], adrr[$left(adrr) : clog2depth+2]);
    end
  end

  logic[$pow(2, clog2depth)-1 : 0]                            lruBit;
  logic[1:0][$pow(2, clog2depth)-1 : 0]                       valids;
  logic[1:0][$pow(2, clog2depth)-1 : 0][30-clog2depth-1 : 0]  tag;
  logic[1:0][$pow(2, clog2depth)-1 : 0][1:0]                  predBits;
  logic[1:0][$pow(2, clog2depth)-1 : 0][31:0]                 destAdr;

  //logic[$pow(2, clog2depth)-1 : 0][1+(1+30-clog2depth+2+32)*2-1 : 0] btb; //branch table buffer 
  
  genvar i;
  generate
    for (i = 0; i < $pow(2, clog2depth); i++) begin
      always_ff @(posedge clk) begin
        if (rst) begin
          lruBit[i]   <= 1'b0;
          valids[0][i] <= 1'b0;
          valids[1][i] <= 1'b0;
        end
      end
    end
  endgenerate

  `define way lruBit[adrw[clog2depth+1:2]]

  always_ff @( posedge clk ) begin
    if (we) begin
      if (lruBit[adrw[clog2depth+1:2]]) begin
        lruBit[adrw[clog2depth+1:2]]      <= ~lruBit[adrw[clog2depth+1:2]];
        valids[1][adrw[clog2depth+1:2]]   <= 1'b1;
        tag[1][adrw[clog2depth+1:2]]      <= adrw[$left(adrw) : clog2depth+2];
        destAdr[1][adrw[clog2depth+1:2]]  <= wd;
        if (valids[1][adrw[clog2depth+1:2]] == 1'b0) begin
          predBits[1][adrw[clog2depth+1:2]] <= {2{corr_pred}};
        end
        else begin
          case(predBits[1][adrw[clog2depth+1:2]])
            2'b00: begin
              if (corr_pred) begin
                predBits[1][adrw[clog2depth+1:2]] <= 2'b01;
              end
              else begin
                predBits[1][adrw[clog2depth+1:2]] <= 2'b00;
              end
            end
            2'b01: begin
              if (corr_pred) begin
                predBits[1][adrw[clog2depth+1:2]] <= 2'b11;
              end
              else begin
                predBits[1][adrw[clog2depth+1:2]] <= 2'b00;
              end
            end
            2'b10: begin
              if (corr_pred) begin
                predBits[1][adrw[clog2depth+1:2]] <= 2'b00;
              end
              else begin
                predBits[1][adrw[clog2depth+1:2]] <= 2'b11;
              end
            end
            2'b11: begin
              if (corr_pred) begin
                predBits[1][adrw[clog2depth+1:2]] <= 2'b10;
              end
              else begin
                predBits[1][adrw[clog2depth+1:2]] <= 2'b11;
              end
            end
          endcase
        end
      end
      else begin
        lruBit[adrw[clog2depth+1:2]]      <= ~lruBit[adrw[clog2depth+1:2]];
        valids[0][adrw[clog2depth+1:2]]   <= 1'b1;
        tag[0][adrw[clog2depth+1:2]]      <= adrw[$left(adrw) : clog2depth+2];
        destAdr[0][adrw[clog2depth+1:2]]  <= wd;
        
        predBits[0][adrw[clog2depth+1:2]] <=2'b00;
        if (valids[0][adrw[clog2depth+1:2]] == 1'b0) begin
          predBits[0][adrw[clog2depth+1:2]] <= {2{corr_pred}};
        end
        else begin
          case(predBits[0][adrw[clog2depth+1:2]])
            2'b00: begin
              if (corr_pred) begin
                predBits[0][adrw[clog2depth+1:2]] <= 2'b01;
              end
              else begin
                predBits[0][adrw[clog2depth+1:2]] <= 2'b00;
              end
            end
            2'b01: begin
              if (corr_pred) begin
                predBits[0][adrw[clog2depth+1:2]] <= 2'b11;
              end
              else begin
                predBits[0][adrw[clog2depth+1:2]] <= 2'b00;
              end
            end
            2'b10: begin
              if (corr_pred) begin
                predBits[0][adrw[clog2depth+1:2]] <= 2'b00;
              end
              else begin
                predBits[0][adrw[clog2depth+1:2]] <= 2'b11;
              end
            end
            2'b11: begin
              if (corr_pred) begin
                predBits[0][adrw[clog2depth+1:2]] <= 2'b10;
              end
              else begin
                predBits[0][adrw[clog2depth+1:2]] <= 2'b11;
              end
            end
          endcase
        end
      end
    end
  end

  logic  cacheHit1, cacheHit0;
  assign cacheHit1 = valids[1][adrr[clog2depth+1:2]] & (tag[1][adrr[clog2depth+1:2]] == adrr[$left(adrr) : clog2depth+2]);
  assign cacheHit0 = valids[0][adrr[clog2depth+1:2]] & (tag[0][adrr[clog2depth+1:2]] == adrr[$left(adrr) : clog2depth+2]);
  always_comb begin
    if (cacheHit0 || cacheHit1) begin
      if (cacheHit1) begin
        dest  = destAdr[1][adrr[clog2depth+1:2]];
        valid = 1'b1;
        case(predBits[1][adrr[clog2depth+1:2]])
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
        dest  = destAdr[0][adrr[clog2depth+1:2]];
        valid = 1'b1;
        case(predBits[0][adrr[clog2depth+1:2]])
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
      
    end
    else begin
      valid = 1'b0;
      pred  = 1'b0;
      dest  = 32'bx;
    end
  end
  
endmodule