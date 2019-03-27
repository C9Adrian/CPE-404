module testbench3();
  reg         clk, reset;
  reg[4:0]    RsE, RtE, RsD, RtD, WriteRegM, WriteRegW, WriteRegE;
  reg 		  RegWriteE, RegWriteM, RegWriteW, MemtoRegE, MemtoRegM, BranchD;
  reg[1:0]	  ForwardAE_Expected, ForwardBE_Expected;
  reg		  StallF_Expected, StallD_Expected, FlushE_Expected, ForwardAD_Expected, 
			  ForwardBD_Expected;
  wire[1:0]   ForwardAE, ForwardBE;
  wire		  StallF, StallD, FlushE, ForwardAD, ForwardBD;
  
  reg  [31:0] vectornum, errors;
  reg  [49:0]  testvectors[10000:0];

  // instantiate device under test
  hazunit dut(RsE, RtE, RsD, RtD, WriteRegM, WriteRegW, WriteRegE,
				  RegWriteE, RegWriteM, RegWriteW, MemtoRegE, MemtoRegM, BranchD,
				  ForwardAE, ForwardBE,
				  StallF, StallD, FlushE, ForwardAD, ForwardBD);

  // generate clock
  always 
    begin
      clk = 1; #5; clk = 0; #5;
    end

  // at start of test, load vectors
  // and pulse reset
  initial
    begin
      $readmemb("hazunit_vectors.txt", testvectors);
      vectornum = 0; errors = 0;
      reset = 1; #27; reset = 0;
    end

  // apply test vectors on rising edge of clk
  always @(posedge clk)
    begin
      #1; {RsE, RtE, RsD, RtD, WriteRegM, WriteRegW, WriteRegE,
		   RegWriteE,RegWriteM, RegWriteW, MemtoRegE, MemtoRegM, BranchD,
		   ForwardAE_Expected, ForwardBE_Expected,
		   StallF_Expected, StallD_Expected, FlushE_Expected, ForwardAD_Expected, ForwardBD_Expected} = testvectors[vectornum];
    end

  // check results on falling edge of clk
  always @(negedge clk)
    if (~reset) begin // skip cycles during reset
      if (ForwardAE !== ForwardAE_Expected) begin  // check result
	$display("Error: %d ForwardAE outputs = %b (%b expected)",
	         vectornum, ForwardAE, ForwardAE_Expected);
	errors = errors + 1;
      end
	  
	  if (ForwardBE !== ForwardBE_Expected) begin  // check result
	$display("Error: %d ForwardBE outputs = %b (%b expected)",
	         vectornum, ForwardBE, ForwardBE_Expected);
	errors = errors + 1;
      end
		
		if (StallF !== StallF_Expected) begin  // check result
	$display("Error: %d StallF outputs = %b (%b expected)",
	         vectornum, StallF, StallF_Expected);
	errors = errors + 1;
      end	
	  
		if (StallD !== StallD_Expected) begin  // check result
	$display("Error: %d StallD outputs = %b (%b expected)",
	         vectornum, StallD, StallD_Expected);
	errors = errors + 1;
      end  
	  
	  if (FlushE !== FlushE_Expected) begin  // check result
	$display("Error: %d FlushE outputs = %b (%b expected)",
	         vectornum, FlushE, FlushE_Expected);
	errors = errors + 1;
      end
	  
	  if (ForwardAD !== ForwardAD_Expected) begin  // check result
	$display("Error: %d ForwardAD outputs = %b (%b expected)",
	         vectornum, ForwardAD, ForwardAD_Expected);
	errors = errors + 1;
      end
	  
	 if (ForwardBD !== ForwardBD_Expected) begin  // check result
	$display("Error: %d ForwardBD outputs = %b (%b expected)",
	         vectornum, ForwardBD, ForwardBD_Expected);
	errors = errors + 1;
      end 
	  
      vectornum = vectornum + 1;
      if (testvectors[vectornum] === 50'bx) begin 
        $display("%d tests completed with %d errors", 
	         vectornum, errors);
        $finish;
      end
    end
endmodule