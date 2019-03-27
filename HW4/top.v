//-------------------------------------------------
// top.v
// Sarah_Harris@hmc.edu 23 October 2005
// Top-level module for single-cycle MIPS processor
//-------------------------------------------------

module topsingle(input         clk, reset,
                 input  [31:0] readdata,
                 output [31:0] writedata, dataadr, 
                 output        memwrite);

  wire [31:0] pc, instr;
  
  // instantiate processor and memories
  mipsmulti mipsmulti(clk, reset, pc, instr, memwrite, dataadr, 
                        writedata, readdata);
  imem imem(pc[7:2], instr);
  dmem dmem(clk, memwrite, dataadr, writedata, 
            readdata);
endmodule

