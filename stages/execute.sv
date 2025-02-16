module execute( output logic [31:0]  PCtarget,);

  assign        PCtargetE = (Jsrc ? rd : PCF) + immExt;

endmodule