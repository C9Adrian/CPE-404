//------------------------------------------------
// mipssingle.v
// Sarah_Harris@hmc.edu 22 June 2007
// Single-cycle MIPS processor
//------------------------------------------------

// multi-cycle MIPS processor

module controller(input  [5:0] op, funct,
                  input        zero,
                  output       memtoreg, memwrite, 
				  output 	   alusrc,      // LUI
                  output	   regdst,      // JAL 
				  output       regwrite,
                  output       Jump,
                  output [3:0] alucontrol,  // 4 bits for SLL
						input        ltez,        // BLEZ
						output       jal,         // JAL
						output       BranchD);         // BranchD
						
  wire [1:0] aluop;
  wire       branch;
  wire       blez;  // BLEZ and JAL not Used, they wires do connect
					//any where in the datapath. 

  maindec md(op, memtoreg, memwrite, branch,
             alusrc, regdst, regwrite, Jump,
             aluop, blez, jal, BranchD);  // BLEZ, JAL, BranchD
  aludec  ad(funct, aluop, alucontrol);

endmodule

//Maindecoder
//Alu src and regdst have been reduced to one bit
//since JAL and LUI are not used
module maindec(input  [5:0] op,
               output       memtoreg, memwrite,
               output       branch, 
			   output  		alusrc, // 
               output  		regdst, // JAL 
			   output       regwrite,
               output       Jump,
               output [1:0] aluop,
					output       blez,   // BLEZ
					output       jal,    // JAL
					output       BranchD);    // BranchD

  reg [11:0] controls;  
  assign {regwrite, regdst, alusrc,
          branch, memwrite,
          memtoreg, Jump, aluop, 
			 blez,   // BLEZ
			 jal,    // JAL
			 BranchD}     // BranchD
			 = controls;

  always @(*)
    case(op)
      6'b000000: controls <= 12'b1_1_0_0_0_0_0_10_0_0_0_; //Rtype
      6'b100011: controls <= 12'b1_0_1_0_0_1_0_00_0_0_0_; //LW
      6'b101011: controls <= 12'b0_0_1_0_1_1_0_00_0_0_0_; //SW
      6'b000100: controls <= 12'b0_0_0_1_0_0_0_00_0_0_1_; //BEQ
      6'b001000: controls <= 12'b1_0_1_0_0_0_0_00_0_0_0_; //ADDI
      6'b000010: controls <= 12'b0_0_0_0_0_0_1_00_0_0_0; //J
      //6'b001010: controls <= 12'b1_0_001000011000; //SLTI
	  //6'b001111: controls <= 14'b10010000000000; //LUI
      //6'b000110: controls <= 14'b00000000001100; //BLEZ
      //6'b000011: controls <= 14'b11000000100010; //JAL
      //6'b100001: controls <= 14'b10001001000001; // LH 
      default:   controls <= 12'bxxxxxxxxxxxx; //???
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
          //6'b000000: alucontrol <= 4'b0100; // SLL
          default:   alucontrol <= 4'bxxxx; // ???
        endcase
    endcase
endmodule

module datapath(input         clk, reset,
                output [31:0] pcF,
                output [31:0] ReadDataW, WriteDataM, ResultsW,
				output MemWriteM
                );   

	

	//Wires Next PC Logic				 
	wire [31:0] pcnext, pcnextbr, pcplus4, pcbranch;
	wire [31:0] InstrF;
	
	//Not inputted Anywhere Only used for as Place Keeper in ALU
	wire zero;
  
  //Wire Fetch Register
	wire [31:0] pcplus4F;
  
  //Wires for Decode Register
	wire [31:0] InstrD, pcplus4D, pcBranchD, signImmD, RD1BMuxD, RD2BMuxD, RD1AMuxD, RD2AMuxD;
	wire [31:0] signImmshD;
	wire [3:0] AluControlD;
	wire equalD, PCSrcD, RegWriteD, MemtoRegD, MemWriteD, AluSrcD, RegDstD, BranchD;
	
	//Wires for Execute
	wire[31:0] RD1AMuxE, RD2AMuxE, AluOutE, SrcAE, SrcBE, WriteDataE, signImmE;
	wire[4:0]  RsE, RtE, RdE, WriteRegE, ShamtE;
	wire[3:0]  AluControlE;
	wire RegWriteE, MemtoRegE, MemWriteE, AluSrcE, RegDstE;
	
	//Wire for Memory
	wire[31:0] AluOutM, ReadDataM;
	wire[4:0]  WriteRegM;
	wire RegWriteM, MemtoRegM;

	//Wire For Write Back
	wire[31:0] AluOutW;
	wire[4:0] WriteRegW;
	wire RegWriteW, MemtoRegW;
	
	//Haz unit wires
	wire[1:0] ForwardAE, ForwardBE;
	wire StallD, StallF, FlushE, ForwardAD, ForwardBD;
	
	
	//Hazard Unit
	hazunit hazunit(RsE, RtE, InstrD[25:21],InstrD[20:16], WriteRegM, WriteRegW, WriteRegE,
					RegWriteE, RegWriteM, RegWriteW, MemtoRegE, MemtoRegM, BranchD, Jump,
					ForwardAE, ForwardBE,
					StallF, StallD, FlushE, ForwardAD, ForwardBD);	

	
	//Controller 
	controller c(InstrD[31:26], InstrD[5:0], zero,
               MemtoRegD, MemWriteD, 
               AluSrcD, RegDstD, RegWriteD, Jump,
               AluControlD, 
					ltez,  // BLEZ
					jal,   // JAL
					BranchD);   // BranchD
	
	
	//Instruction and Data Memory
	imem imem(pcF[7:2], InstrF);
	dmem dmem(clk, MemWriteM, AluOutM, WriteDataM, 
            ReadDataM);
	
	//next PC Logic
	flopenr #(32)	pcreg(clk, reset, StallF, pcnext, pcF);
	adder			pcadd1(pcF, 32'b100, pcplus4F);
	
	
	
	//Branch 
	sl2				immsh(signImmD, signImmshD);
	adder			pcadd2(pcplus4D, signImmshD, pcBranchD);
	mux2 #(32)		pcbrmux(pcplus4F, pcBranchD, PCSrcD, pcnextbr); 
	//Jump
	mux2 #(32)		pcmux(pcnextbr, {pcplus4D[31:28], InstrD[25:0], 2'b00}, Jump, pcnext);		
	
	
	//RegisterFile
	regfile			rf(clk, RegWriteW, InstrD[25:21], InstrD[20:16], WriteRegW, ResultsW,
					   RD1BMuxD, RD2BMuxD);
					   
	//Branch and Jump Data Hazard Mux
	mux2 #(32)		br1mux(RD1BMuxD, AluOutM, ForwardAD, RD1AMuxD);
	mux2 #(32)		br2mux(RD2BMuxD, AluOutM, ForwardBD, RD2AMuxD);
	equalReg		eq(RD1AMuxD, RD2AMuxD, equalD);
	and2			BAnd(BranchD, equalD, PCSrcD);
	
	//WriteRegE Mux 
	mux2 #(5)		wrmux(RtE, RdE, RegDstE, WriteRegE);
	
	//ForwardAE Mux 
	mux3 #(32)		faemux(RD1AMuxE, ResultsW, AluOutM, ForwardAE, SrcAE);
	
	//ForwardBE Mux
	mux3 #(32)		fbemux(RD2AMuxE, ResultsW, AluOutM, ForwardBE, WriteDataE);
	
	//Immediate or Register Mux
	mux2 #(32)		immux(WriteDataE, signImmE, AluSrcE, SrcBE);
	
	//ALU 
	alu 			alu(SrcAE, SrcBE, AluControlE, ShamtE, 
						AluOutE, zero, ltez); //last two bits not used
						
	//Data Memory output Mux
	mux2 #(32)		memmux(AluOutW, ReadDataW, MemtoRegW, ResultsW);
	
	//signExt
	signext			se(InstrD[15:0], signImmD);
	
	//Fetch Register
	floprFet		floprFet(clk, reset | PCSrcD | Jump, StallD, PCSrcD, pcplus4F, InstrF,
							 pcplus4D, InstrD);
							 
	//Decode Register
	floprDec		floprDec(clk, reset | FlushE, FlushE, RD1AMuxD, RD2AMuxD, signImmD,
							 InstrD[25:21], InstrD[20:16], InstrD[15:11], InstrD[10:6],
							 RegWriteD, MemtoRegD, MemWriteD, AluSrcD, RegDstD,
							 BranchD, AluControlD, RD1AMuxE, RD2AMuxE, signImmE,
							 RsE, RtE, RdE, ShamtE, RegWriteE, MemtoRegE, MemWriteE,
							 AluSrcE, RegDstE, AluControlE);
	//Execute Register
	floprExe		floprExe(clk, reset, AluOutE, WriteDataE, WriteRegE, RegWriteE,
							 MemtoRegE, MemWriteE, AluOutM, WriteDataM, WriteRegM, 
							 RegWriteM, MemtoRegM, MemWriteM);
	
	//Memory Register
	floprMem		floprMem(clk, reset, AluOutM, ReadDataM, WriteRegM, RegWriteM,
							 MemtoRegM, AluOutW, ReadDataW, WriteRegW, RegWriteW,
							 MemtoRegW);
	
endmodule

