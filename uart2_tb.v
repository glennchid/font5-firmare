`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:10:35 12/16/2015
// Design Name:   uart2_tx
// Module Name:   H:/Firmware/font5_base_new/font5_base/font5-firmware/uart2_tb.v
// Project Name:  font5_base
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: uart2_tx
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module uart2_tb;

	// Inputs
	reg reset;
	reg clk;
	reg ld_tx_data;
	reg [7:0] tx_data;
	reg tx_enable;

	// Outputs
	wire tx_out;
	wire tx_empty;

	// Instantiate the Unit Under Test (UUT)
	uart2_tx uut (
		.reset(reset), 
		.clk(clk), 
		.ld_tx_data(ld_tx_data), 
		.tx_data(tx_data), 
		.tx_enable(tx_enable), 
		.tx_out(tx_out), 
		.tx_empty(tx_empty)
	);

	initial begin
		// Initialize Inputs
		reset = 0;
		clk = 0;
		ld_tx_data = 0;
		tx_data = 0;
		tx_enable = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
      
endmodule

