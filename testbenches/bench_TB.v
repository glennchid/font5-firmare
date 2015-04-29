`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   18:22:44 07/28/2013
// Design Name:   bench
// Module Name:   H:/Firmware/FONT5_base/ISE13/FONT5_base/bench_TB.v
// Project Name:  FONT5_base
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: bench
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module bench_TB;

	// Inputs
	reg clk;

	// Outputs
	wire trig;
	wire data_out;

	// Instantiate the Unit Under Test (UUT)
	bench uut (
		.clk(clk), 
		.trig(trig), 
		.data_out(data_out)
	);

	initial begin
		// Initialize Inputs
		clk = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
	
	always # 1.4 clk = ~clk; //357 MHz clock

      
endmodule

