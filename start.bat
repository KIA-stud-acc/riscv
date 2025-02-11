iverilog -g2005-sv testbench.sv top.sv riscv_ps.sv regFile.sv instrMem.sv immExt.sv datapath.sv dataMem.sv controller.sv ALU.sv
vvp a.out
del a.out