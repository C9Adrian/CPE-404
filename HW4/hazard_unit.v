module hazunit(input[4:0] RsE, RtE, RsD,RtD, WriteRegM, WriteRegW, WriteRegE, 
			   input RegWriteE, RegWriteM, RegWriteW, MemtoRegE,MemtoRegM, BranchD, Jump,
			   output [1:0] ForwardAE, ForwardBE,
			   output StallF, StallD, FlushE, ForwardAD, ForwardBD);
	
	reg lwstall, branchstall, superstall, jumpstall; 
	reg [1:0] ForwardAEReg, ForwardBEReg;
	reg ForwardADReg, ForwardBDReg;
	
	always @(*) begin  //Forward AE and ForwardBE
		if ((RsE !=0) & (RsE == WriteRegM) & (RegWriteM)) 
			ForwardAEReg <= 10;
		else if ((RsE !=0) & (RsE == WriteRegW) & (RegWriteW))
			ForwardAEReg <= 01;
		else 
			ForwardAEReg <= 00;
			
		if ((RtE !=0) & (RtE == WriteRegM) & (RegWriteM)) 
			ForwardBEReg <= 10;
		else if ((RtE !=0) & (RtE == WriteRegW) && (RegWriteW))
			ForwardBEReg <= 01;
		else 
			ForwardBEReg <= 00;
		
		//Forward AD and Forward BD
		ForwardADReg <= (RsD !=0) & (RsD == WriteRegM) & RegWriteM;
		ForwardBDReg <= (RtD !=0) & (RtD == WriteRegM) & RegWriteM;
			
		//LWstall	
		lwstall <= ((RsD == RtE) | (RtD == RtE)) & MemtoRegE;
		
		//Branch Stall
		branchstall <= (BranchD & RegWriteE & (WriteRegE == RsD | WriteRegE == RtD)) |
					   (BranchD & MemtoRegM & (WriteRegM == RsD | WriteRegM == RtD));
		//Jump Stall
		jumpstall <= (Jump & RegWriteE & (WriteRegE == RsD | WriteRegE == RtD)) |
					 (Jump & MemtoRegM & (WriteRegM == RsD | WriteRegM == RtD));
					   
		superstall <= lwstall | branchstall | jumpstall;
		
	end 
	//Assigning Outputs
	assign ForwardAE = ForwardAEReg;
	assign ForwardBE = ForwardBEReg;
	
	assign ForwardAD = ForwardADReg;
	assign ForwardBD = ForwardBDReg;
	
	assign StallF = superstall;
	assign StallD = superstall;
	assign FlushE = superstall;
	
endmodule 