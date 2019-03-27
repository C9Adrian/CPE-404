//------------------------------------------------
// mipssingle.v
// Sarah_Harris@hmc.edu 22 June 2007
// Single-cycle MIPS processor
//------------------------------------------------

// single-cycle MIPS processor

module mipssingle(input         clk, reset,
                  output [31:0] pc,
                  input  [31:0] instr,
                  output        memwrite,
                  output [31:0] aluresult, writedata,
                  input  [31:0] readdata);

  wire        memtoreg;
  wire [1:0]  alusrc;  // LUI
  wire [1:0]  regdst;  // JAL 
  wire        regwrite, jump, pcsrc, zero;
  wire [3:0]  alucontrol;  // SLL
  wire        ltez;  // BLEZ
  wire        jal;   // JAL
  wire        lh;    // LH

  controller c(instr[31:26], instr[5:0], zero,
               memtoreg, memwrite, pcsrc,
               alusrc, regdst, regwrite, jump,
               alucontrol, 
					ltez,  // BLEZ
					jal,   // JAL
					lh);   // LH
  datapath dp(clk, reset, memtoreg, pcsrc,
              alusrc, regdst, regwrite, jump,
              alucontrol,
              zero, pc, instr,
              aluresult, writedata, readdata, 
				  ltez,  // BLEZ
				  jal,   // JAL
				  lh);   // LH
endmodule

module controller(input  [5:0] op, funct,
                  input        zero,
                  output       memtoreg, memwrite,
                  output       pcsrc, 
						output [1:0] alusrc,      // LUI
                  output [1:0] regdst,      // JAL 
						output       regwrite,
                  output       jump,
                  output [3:0] alucontrol,  // 4 bits for SLL
						input        ltez,        // BLEZ
						output       jal,         // JAL
						output       lh);         // LH
						
  wire [1:0] aluop;
  wire       branch;
  wire       blez;  // BLEZ

  maindec md(op, memtoreg, memwrite, branch,
             alusrc, regdst, regwrite, jump,
             aluop, blez, jal, lh);  // BLEZ, JAL, LH
  aludec  ad(funct, aluop, alucontrol);

  assign pcsrc = (branch & zero) | (blez & ltez);  // BLEZ
endmodule

module maindec(input  [5:0] op,
               output       memtoreg, memwrite,
               output       branch, 
					output [1:0] alusrc, // LUI
               output [1:0] regdst, // JAL 
					output       regwrite,
               output       jump,
               output [1:0] aluop,
					output       blez,   // BLEZ
					output       jal,    // JAL
					output       lh);    // LH

  reg [13:0] controls;  // increase controls for LUI, BLEZ, JAL, LH

  assign {regwrite, regdst, alusrc,
          branch, memwrite,
          memtoreg, jump, aluop, 
			 blez,   // BLEZ
			 jal,    // JAL
			 lh}     // LH
			 = controls;

  always @(*)
    case(op)
      6'b000000: controls <= 14'b10100000010000; //Rtype
      6'b100011: controls <= 14'b10001001000000; //LW
      6'b101011: controls <= 14'b00001010000000; //SW
      6'b000100: controls <= 14'b00000100001000; //BEQ
      6'b001000: controls <= 14'b10001000000000; //ADDI
      6'b000010: controls <= 14'b00000000100000; //J
      6'b001010: controls <= 14'b10001000011000; //SLTI
		6'b001111: controls <= 14'b10010000000000; //LUI
      6'b000110: controls <= 14'b00000000001100; //BLEZ
      6'b000011: controls <= 14'b11000000100010; //JAL
      6'b100001: controls <= 14'b10001001000001; //LH
      default:   controls <= 14'bxxxxxxxxxxxxxx; //???
    endcase
endmodule

module aludec(input      [5:0] funct,
              input      [1:0] aluop,
              output reg [3:0] alucontrol); // 4-bits for SLL

  always @(*)
    case(aluop)
      2'b00: alucontrol <= 4'b0010;  // add
      2'b01: alucontrol <= 4'b1010;  // sub
		2'b11: alucontrol <= 4'b1011;  // slt
      default: case(funct)          // RTYPE
          6'b100000: alucontrol <= 4'b0010; // ADD
          6'b100010: alucontrol <= 4'b1010; // SUB
          6'b100100: alucontrol <= 4'b0000; // AND
          6'b100101: alucontrol <= 4'b0001; // OR
          6'b101010: alucontrol <= 4'b1011; // SLT
          6'b000000: alucontrol <= 4'b0100; // SLL
          default:   alucontrol <= 4'bxxxx; // ???
        endcase
    endcase
endmodule

module datapath(input         clk, reset,
                input         memtoreg, pcsrc,
                input [1:0]   alusrc,    // LUI 
					 input [1:0]   regdst,    // JAL
                input         regwrite, jump,
                input  [3:0]  alucontrol, // SLL
                output        zero,
                output [31:0] pc,
                input  [31:0] instr,
                output [31:0] aluresult, writedata,
                input  [31:0] readdata,
					 output        ltez,  // BLEZ
					 input         jal,   // JAL
					 input         lh);   // LH

  wire [4:0]  writereg;
  wire [31:0] pcnext, pcnextbr, pcplus4, pcbranch;
  wire [31:0] signimm, signimmsh;
  wire [31:0] upperimm;  // LUI
  wire [31:0] srca, srcb;
  wire [31:0] result;
  wire [31:0] writeresult;  // JAL
  wire [15:0] half;         // LH
  wire [31:0] signhalf, memdata;     // LH

  // next PC logic
  flopr #(32) pcreg(clk, reset, pcnext, pc);
  adder       pcadd1(pc, 32'b100, pcplus4);
  sl2         immsh(signimm, signimmsh);
  adder       pcadd2(pcplus4, signimmsh, pcbranch);
  mux2 #(32)  pcbrmux(pcplus4, pcbranch, pcsrc,
                      pcnextbr);
  mux2 #(32)  pcmux(pcnextbr, {pcplus4[31:28], 
                    instr[25:0], 2'b00}, 
                    jump, pcnext);

  // register file logic
  regfile     rf(clk, regwrite, instr[25:21],
                 instr[20:16], writereg,
					  writeresult,  // JAL 
					  srca, writedata);

  mux2 #(32)  wamux(result, pcplus4, jal, writeresult);  // JAL
  mux3 #(5)   wrmux(instr[20:16], instr[15:11], 5'd31,
                    regdst, writereg);  // JAL
  
  // hardware to support LH
  mux2 #(16)  lhmux1(readdata[15:0], readdata[31:16], 
                     aluresult[1], half);  // LH
  signext     lhse(half, signhalf);        // LH
  mux2 #(32)  lhmux2(readdata, signhalf, lh, memdata); // LH
  
  mux2 #(32)  resmux(aluresult, memdata, memtoreg, result); // LH
  signext     se(instr[15:0], signimm);
  upimm       ui(instr[15:0], upperimm);  // LUI

  // ALU logic
  mux3 #(32)  srcbmux(writedata, signimm, upperimm, alusrc,
                      srcb);                            // LUI
  alu         alu(srca, srcb, alucontrol, instr[10:6],  // SLL
                  aluresult, zero, ltez); // BLEZ
endmodule

