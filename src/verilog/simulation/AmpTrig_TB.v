`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:20:31 06/18/2014
// Design Name:   AmpTrig
// Module Name:   H:/Firmware/FONT5_base/ISE13/FONT5_base/AmpTrig_TB.v
// Project Name:  FONT5_base
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: AmpTrig
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module AmpTrig_TB;

	// Inputs
	reg clk;
	reg trigger;
	reg trig_out_en_b;
	reg [6:0] trig_out_delay_b;

	// Outputs
	wire amp_trig;
	reg trigger_a = 1'b0;


	// Instantiate the Unit Under Test (UUT)
	AmpTrig2 uut (
		.clk(clk), 
		.trigger_in(trigger_a), 
		.trig_out_en_b(trig_out_en_b), 
		.trig_out_delay_b(trig_out_delay_b), 
		.amp_trig(amp_trig)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		trigger = 0;
		trigger_a = 0;
		trig_out_en_b = 0;
		trig_out_delay_b = 0;

		// Wait 100 ns for global reset to finish
		#100;
      //trigger_a = 1;
		trig_out_en_b = 1;
		trig_out_delay_b = 1;  
		// Add stimulus here
		#100; trigger = 1;
		#9240; trigger_a = 0;
	end
	
	always #1.4 clk = ~clk;
	always @(posedge clk) trigger_a <= trigger;
      
endmodule

