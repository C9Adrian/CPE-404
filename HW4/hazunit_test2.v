module testbenchhaz();
  reg         clk, reset;
  reg[4:0]    RsE, RtE, RsD, RtD, WriteRegM, WriteRegW, WriteRegE;
  reg 		  RegWriteE, RegWriteM, RegWriteW, MemtoRegE, MemtoRegM, BranchD;
  wire[1:0]   ForwardAE, ForwardBE;
  wire		  StallF, StallD, FlushE, ForwardAD, ForwardBD;
  
  // instantiate device under test
  hazunit dut(RsE, RtE, RsD, RtD, WriteRegM, WriteRegW, WriteRegE,
				  RegWriteE, RegWriteM, RegWriteW, MemtoRegE, MemtoRegM, BranchD,
				  ForwardAE, ForwardBE,
				  StallF, StallD, FlushE, ForwardAD, ForwardBD);

  initial begin
	$display("Test all zeros"); #10;
	RsE = 0; RtE = 0; RsD = 0; RtD = 0; WriteRegM = 0; WriteRegW = 0;
	WriteRegE = 0; RegWriteE = 0; MemtoRegE = 0; MemtoRegM = 0; RegWriteM = 0; RegWriteW = 0; BranchD = 0; #10
	$display("ForwardAD = %b, ForwardBD = %b, StallD = %b, StallF = %b, FlushE = %b, ForwardAE = %b, ForwardBE = %b", 
	ForwardAD, ForwardBD, StallD, StallF, FlushE, ForwardAE, ForwardBE); #10;
	
	$display("Testing RsE Mem Data"); #10;
	RsE = 1; RtE = 2; RsD = 3; RtD = 4; WriteRegM = 1; WriteRegW = 5;
	WriteRegE = 6; RegWriteE = 0; RegWriteM = 1; RegWriteW = 0; BranchD = 0; #10
	$display("ForwardAD = %b, ForwardBD = %b, StallD = %b, StallF = %b, FlushE = %b, ForwardAE = %b, ForwardBE = %b Expected ForwardAE = 10",
	ForwardAD, ForwardBD, StallD, StallF, FlushE, ForwardAE, ForwardBE); #10;
	
	$display("Testing RsE Write Back Data "); #10;
	RsE = 1; RtE = 2; RsD = 3; RtD = 4; WriteRegM = 8; WriteRegW = 1;
	WriteRegE = 6; RegWriteE = 0; RegWriteM = 1; RegWriteW = 1; BranchD = 0; #10
	$display("ForwardAD = %b, ForwardBD = %b, StallD = %b, StallF = %b, FlushE = %b, ForwardAE = %b, ForwardBE = %b Expected ForwardAE = 01", 
	ForwardAD, ForwardBD, StallD, StallF, FlushE, ForwardAE, ForwardBE); #10;
	
	$display("Testing RsE with no Data Hazards "); #10;
	RsE = 1; RtE = 2; RsD = 3; RtD = 4; WriteRegM = 8; WriteRegW = 5;
	WriteRegE = 6; RegWriteE = 0; RegWriteM = 1; RegWriteW = 1; BranchD = 0; #10
	$display("ForwardAD = %b, ForwardBD = %b, StallD = %b, StallF = %b, FlushE = %b, ForwardAE = %b, ForwardBE = %b Expected ForwardAE = 00", 
	ForwardAD, ForwardBD, StallD, StallF, FlushE, ForwardAE, ForwardBE); #10;	
	
	$display("Testing RtE Mem Back Data Hazard"); #10;
	RsE = 1; RtE = 2; RsD = 3; RtD = 4; WriteRegM = 2; WriteRegW = 5;
	WriteRegE = 6; RegWriteE = 0; RegWriteM = 1; RegWriteW = 1; BranchD = 0; #10
	$display("ForwardAD = %b, ForwardBD = %b, StallD = %b, StallF = %b, FlushE = %b, ForwardAE = %b, ForwardBE = %b Expected ForwardBE = 10", 
	ForwardAD, ForwardBD, StallD, StallF, FlushE, ForwardAE, ForwardBE); #10;
	
	$display("Testing RtE Write Back Data Hazard"); #10;
	RsE = 1; RtE = 2; RsD = 3; RtD = 4; WriteRegM = 8; WriteRegW = 2;
	WriteRegE = 6; RegWriteE = 0; RegWriteM = 1; RegWriteW = 1; BranchD = 0; #10
	$display("ForwardAD = %b, ForwardBD = %b, StallD = %b, StallF = %b, FlushE = %b, ForwardAE = %b, ForwardBE = %b Expected ForwardBE = 01", 
	ForwardAD, ForwardBD, StallD, StallF, FlushE, ForwardAE, ForwardBE); #10;
		
	$display("Testing RsE No Data Hazard "); #10;
	RsE = 1; RtE = 2; RsD = 3; RtD = 4; WriteRegM = 8; WriteRegW = 5;
	WriteRegE = 6; RegWriteE = 0; RegWriteM = 1; RegWriteW = 1; BranchD = 0; #10
	$display("ForwardAD = %b, ForwardBD = %b, StallD = %b, StallF = %b, FlushE = %b, ForwardAE = %b, ForwardBE = %b Expected ForwardBE = 00", 
	ForwardAD, ForwardBD, StallD, StallF, FlushE, ForwardAE, ForwardBE); #10;
	
	$display("Testing LW Stall/ RsD == RtE"); #10;
	RsE = 1; RtE = 2; RsD = 2; RtD = 4; WriteRegM = 8; WriteRegW = 5;
	WriteRegE = 6; RegWriteE = 0; RegWriteM = 1; RegWriteW = 1; MemtoRegE = 1; MemtoRegM = 0; BranchD = 0; #10
	$display("ForwardAD = %b, ForwardBD = %b, StallD = %b, StallF = %b, FlushE = %b, ForwardAE = %b, ForwardBE = %b Expected Flush  = 1", 
	ForwardAD, ForwardBD, StallD, StallF, FlushE, ForwardAE, ForwardBE); #10;
	
	$display("Testing LW Stall/ RtD == RtE"); #10;
	RsE = 1; RtE = 2; RsD = 3; RtD = 2; WriteRegM = 8; WriteRegW = 5;
	WriteRegE = 6; RegWriteE = 0; RegWriteM = 1; RegWriteW = 1; MemtoRegE = 1; MemtoRegM = 0; BranchD = 0; #10
	$display("ForwardAD = %b, ForwardBD = %b, StallD = %b, StallF = %b, FlushE = %b, ForwardAE = %b, ForwardBE = %b Expected Flush  = 1", 
	ForwardAD, ForwardBD, StallD, StallF, FlushE, ForwardAE, ForwardBE); #10;
		
	$display("Testing ForwardAD"); #10;
	RsE = 1; RtE = 2; RsD = 2; RtD = 4; WriteRegM = 2; WriteRegW = 5;
	WriteRegE = 6; RegWriteE = 0; RegWriteM = 1; RegWriteW = 1; MemtoRegE = 1; MemtoRegM = 0; BranchD = 0; #10
	$display("ForwardAD = %b, ForwardBD = %b, StallD = %b, StallF = %b, FlushE = %b, ForwardAE = %b, ForwardBE = %b Expected ForwardAD  = 1", 
	ForwardAD, ForwardBD, StallD, StallF, FlushE, ForwardAE, ForwardBE); #10;
		
	$display("Testing ForwardBD"); #10;
	RsE = 1; RtE = 2; RsD = 2; RtD = 4; WriteRegM = 4; WriteRegW = 5;
	WriteRegE = 6; RegWriteE = 0; RegWriteM = 1; RegWriteW = 1; MemtoRegE = 1; MemtoRegM = 0; BranchD = 0; #10
	$display("ForwardAD = %b, ForwardBD = %b, StallD = %b, StallF = %b, FlushE = %b, ForwardAE = %b, ForwardBE = %b Expected ForwardBD  = 1", 
	ForwardAD, ForwardBD, StallD, StallF, FlushE, ForwardAE, ForwardBE); #10;
	
	$display("Testing Branch Stall Execute Stage"); #10;
	RsE = 1; RtE = 2; RsD = 3; RtD = 4; WriteRegM = 8; WriteRegW = 5;
	WriteRegE = 3; RegWriteE = 1; RegWriteM = 1; RegWriteW = 1; MemtoRegE = 1; MemtoRegM = 0; BranchD = 1; #10
	$display("ForwardAD = %b, ForwardBD = %b, StallD = %b, StallF = %b, FlushE = %b, ForwardAE = %b, ForwardBE = %b Expected Flush  = 1", 
	ForwardAD, ForwardBD, StallD, StallF, FlushE, ForwardAE, ForwardBE); #10;
	
	
	$display("Testing Branch Memory Stage"); #10;
	RsE = 1; RtE = 2; RsD = 6; RtD = 4; WriteRegM = 6; WriteRegW = 5;
	WriteRegE = 10; RegWriteE = 0; RegWriteM = 1; RegWriteW = 1; MemtoRegE = 1; MemtoRegM = 1; BranchD = 1; #10
	$display("ForwardAD = %b, ForwardBD = %b, StallD = %b, StallF = %b, FlushE = %b, ForwardAE = %b, ForwardBE = %b Expected Flush  = 1", 
	ForwardAD, ForwardBD, StallD, StallF, FlushE, ForwardAE, ForwardBE); #10;
			
 end
endmodule