//------------------------------------------------
// mipstest.v
// Sarah_Harris@hmc.edu 23 October 2005
// Testbench for single-cycle MIPS processor
//------------------------------------------------

module testbench();

  reg         clk;
  reg         reset;

  wire [31:0] aluout, writedata, readdata;
  wire memwrite;
						
  // instantiate device to be tested
  topsingle dut(clk, reset, readdata, writedata, 
                aluout, memwrite);
  
  // initialize test
  initial
    begin
      reset <= 1; # 22; reset <= 0;
    end

  // generate clock to sequence tests
  always
    begin
      clk <= 1; # 5; clk <= 0; # 5;
    end

  // check results
  always@(negedge clk)
    begin
      if(memwrite & aluout == 84) begin
        if(writedata == 7)
          $display("Simulation succeeded");
        else begin
          $display("Simulation failed");
        end
        $stop;
      end
    end
endmodule