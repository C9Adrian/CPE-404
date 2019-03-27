//------------------------------------------------
// alu32.v
// Sarah_Harris@hmc.edu 23 October 2005
// 32-bit ALU used by MIPS single-cycle processor
//------------------------------------------------

`timescale 1ns / 1ps

module alu(	input [31:0] A, B, 
            input [3:0] F, input [4:0] shamt, // SLL 
				output reg [31:0] Y, output Zero, 
				output ltez);  // BLEZ
	
	wire [31:0] S, Bout;
	
	assign Bout = F[3] ? ~B : B;
	assign S = A + Bout + F[3];  // SLL

	always @ ( * )
		case (F[2:0])
			3'b000: Y <= A & Bout;
			3'b001: Y <= A | Bout;
			3'b010: Y <= S;
			3'b011: Y <= S[31];
			3'b100: Y <= (Bout << shamt);  // SLL
		endcase
	
	assign Zero = (Y == 32'b0);
	assign ltez = Zero | S[31];  // BLEZ
	
//	assign Overflow =  A[31]& Bout[31] & ~Y[31] |
//							~A[31] & ~Bout[31] & Y[31];

endmodule
