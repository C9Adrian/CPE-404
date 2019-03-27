//------------------------------------------------
// mipsparts.v
// David_Harris@hmc.edu 23 October 2005
// Components used in MIPS processor
//------------------------------------------------


module regfile(input         clk, 
               input         we3, 
               input  [4:0]  ra1, ra2, wa3, 
               input  [31:0] wd3, 
               output [31:0] rd1, rd2);

  reg [31:0] rf[31:0];

  // three ported register file
  // read two ports combinationally
  // write third port on rising edge of clock
  // register 0 hardwired to 0

  always @(negedge clk) begin
    if (we3) rf[wa3] <= wd3;	
	end
	
  assign rd1 = (ra1 != 0) ? rf[ra1] : 0;
  assign rd2 = (ra2 != 0) ? rf[ra2] : 0;
endmodule

module adder(input [31:0] a, b,
             output [31:0] y);

  assign y = a + b;
endmodule

module sl2(input  [31:0] a,
           output [31:0] y);

  // shift left by 2
  assign y = {a[29:0], 2'b00};
endmodule

module signext(input  [15:0] a,
               output [31:0] y);
              
  assign y = {{16{a[15]}}, a};
endmodule

module flopr #(parameter WIDTH = 8)
              (input                  clk, reset,
               input      [WIDTH-1:0] d, 
               output reg [WIDTH-1:0] q);

  always @(posedge clk)
    if (reset) q <= 0;
    else       q <= d;
endmodule

module flopenr #(parameter WIDTH = 8)
                (input                  clk, reset,
                 input                  en,
                 input      [WIDTH-1:0] d, 
                 output reg [WIDTH-1:0] q);
 
  always @(posedge clk)
    if      (reset) q <= 0;
    else if (~en)    q <= d;
endmodule


//Registers for the mulitcycle processor

//Fetch Register
module floprFet(input clk, reset,
				input en, clr, 
				input [31:0] pcPlus4F, InstrF,
				output reg [31:0] pcPlus4D, InstrD);
	always@ (posedge clk)
	/*
		if (reset) begin
			pcPlus4D <= 0;
			InstrD <= 0;
		end
		//else if(clr) begin
			//pcPlus4D <= 0;
			//InstrD <=0;
		//end
		else if(~en) begin
			pcPlus4D <= pcPlus4F;
			InstrD <= InstrF;
		end 
	*/

		if(~en) begin
			if (reset) begin
				pcPlus4D <= 0;
				InstrD <= 0;
			end
			else begin
				pcPlus4D <= pcPlus4F;
				InstrD <= InstrF;
			end
		end
endmodule

//Decode Register
module floprDec(input clk, reset, 
				input clr,
				input [31:0] Reg1D, Reg2D, signextD,
				input [4:0] RsD, RtD, RdD, ShamtD, 
				input RegWriteD, MemtoRegD, MemwriteD, AluSrcD, RegDstD, BranchD,
				input [3:0] AluControlD,
				output reg [31:0] Reg1E, Reg2E, signextE,
				output reg [4:0] RsE, RtE, RdE, ShamtE,
				output reg RegWriteE, MemtoRegE, MemwriteE, AluSrcE, RegDstE, 
				output reg [3:0] AluControlE);
	always@(posedge clk)
		if(reset) begin
			Reg1E <= 0;
			Reg2E <= 0;
			signextE <= 0;
			RsE <= 0;
			RtE <= 0;
			RdE <= 0;
			ShamtE <= 0;
			RegWriteE <= 0;
			MemtoRegE <= 0;
			MemwriteE <= 0;
			AluSrcE <= 0;
			RegDstE <= 0;
			AluControlE <= 0;
			end
			/*
		else if(clr)  begin 
			Reg1E <= 0;
			Reg2E <= 0;
			signextE <= 0;
			RsE <= 0;
			RtE <= 0;
			RdE <= 0;
			ShamtE <= 0;
			RegWriteE <= 0;
			MemtoRegE <= 0;
			MemwriteE <= 0;
			AluSrcE <= 0;
			RegDstE <= 0;
			AluControlE <= 0;
			end
			*/
		else begin
			Reg1E <= Reg1D;
			Reg2E <= Reg2D;
			signextE <= signextD;
			RsE <= RsD;
			RtE <= RtD;
			RdE <= RdD;
			ShamtE <= ShamtD;
			RegWriteE <= RegWriteD;
			MemtoRegE <= MemtoRegD;
			MemwriteE <= MemwriteD;
			AluSrcE <= AluSrcD;
			RegDstE <= RegDstD;
			AluControlE <= AluControlD;			
			end
	endmodule
	
//Execute Register
module floprExe(input clk, reset,
				input[31:0] AluOutE, WriteDataE,
				input[4:0] WriteRegE,
				input RegWriteE, MemtoRegE, MemwriteE,
				output reg [31:0] AluOutM, WriteDataM,
				output reg [4:0] WriteRegM,
				output reg RegWriteM, MemtoRegM, MemWriteM);
				
	always@(posedge clk, posedge reset)
		if(reset) begin
			AluOutM <= 0;
			WriteDataM <= 0;
			WriteRegM <= 0;
			RegWriteM <= 0;
			MemtoRegM <= 0;
			MemWriteM <= 0;
			end
		else begin
			AluOutM <= AluOutE;
			WriteDataM <= WriteDataE;
			WriteRegM <= WriteRegE; 
			RegWriteM <= RegWriteE;
			MemtoRegM <= MemtoRegE;
			MemWriteM <= MemwriteE;
			end
	endmodule

//Memory Register
module floprMem(input clk, reset,
				input [31:0] AluOutM, ReadDataM,
				input [4:0] WriteRegM,
				input RegWriteM, MemtoRegM,
				output reg[31:0] AluOutW, ReadDataW,
				output reg[4:0] WriteRegW, 
				output reg RegWriteW, MemtoRegW);
				
	always@(posedge clk)
		if(reset) begin
			AluOutW <= 0;
			ReadDataW <= 0;
			WriteRegW <= 0;
			RegWriteW <= 0;
			MemtoRegW <= 0;
			end
		else begin
			AluOutW <= AluOutM;
			ReadDataW <= ReadDataM;
			WriteRegW <= WriteRegM;
			RegWriteW <= RegWriteM;
			MemtoRegW <= MemtoRegM;
			end
	endmodule

module mux2 #(parameter WIDTH = 8)
             (input  [WIDTH-1:0] d0, d1, 
              input              s, 
              output [WIDTH-1:0] y);

  assign y = s ? d1 : d0; 
endmodule

// upimm module needed for LUI
module upimm(input  [15:0] a,
             output [31:0] y);
              
  assign y = {a, 16'b0};
endmodule

// mux3 needed for LUI
module mux3 #(parameter WIDTH = 8)
             (input  [WIDTH-1:0] d0, d1, d2,
              input  [1:0]       s, 
              output [WIDTH-1:0] y);

  assign #1 y = s[1] ? d2 : (s[0] ? d1 : d0); 
endmodule

//4 to 1 Mux
module mux4 #(parameter WIDTH = 8)
             (input  [WIDTH-1:0] d0, d1, d2, d3,
              input  [1:0]       s, 
              output [WIDTH-1:0] y);

  assign #1 y = s[1] ? (s[0] ? d3 : d2) : (s[0] ? d1: d0) ; 
endmodule

//Equal Module
module equalReg(input [31:0] r0, r1,
				output y);
	wire[31:0] z;
	assign z =  r0 ~^ r1; 
	assign y = &z;
endmodule
	
module and2(input  a, b,
			 output y);
	assign y = a & b;
endmodule
