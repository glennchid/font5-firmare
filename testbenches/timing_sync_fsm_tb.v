`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   22:26:40 08/18/2012
// Design Name:   timing_synch_fsm
// Module Name:   /home/glenn/Documents/Firmware/FONT5_base/ISE10/FONT5_base/timing_sync_fsm_tb.v
// Project Name:  FONT5_base
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: timing_synch_fsm
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module timing_sync_fsm_tb;

	// Inputs
	reg fastClk;
	reg slowClk;
	reg rst;
	reg trigSyncExt;
	reg trigSyncExt_edge_sel;
	reg trig;
	reg [11:0] trig_delay;
	reg [6:0] sample_hold_off;
	reg [9:0] num_smpls;
	reg [7:0] trigSync_size_b;
	reg 		use_trigSyncExt_b;

	// Outputs
	wire store_strb;
	wire adc_powerup;
	wire adc_align_en;
	wire trig_led_strb;
	wire clk2_16_led_strb;
	wire [3:0] state;

	// Instantiate the Unit Under Test (UUT)
	timing_synch_fsm uut (
		.fastClk(fastClk), 
		.slowClk(slowClk), 
		.rst(rst), 
		.trigSyncExt(trigSyncExt), 
		.trigSyncExt_edge_sel(trigSyncExt_edge_sel), 
		.trig(trig), 
		.trig_delay(trig_delay), 
		.sample_hold_off(sample_hold_off), 
		.num_smpls(num_smpls),
		.trigSync_size_b(trigSync_size_b),
		.use_trigSyncExt_b(use_trigSyncExt_b),
		.store_strb(store_strb), 
		.adc_powerup(adc_powerup), 
		.adc_align_en(adc_align_en), 
		.trig_led_strb(trig_led_strb), 
		.clk2_16_led_strb(clk2_16_led_strb), 
		.state(state)
	);

	initial begin
		// Initialize Inputs
		fastClk = 0;
		slowClk = 0;
		rst = 0;
		trigSyncExt = 0;
		trigSyncExt_edge_sel = 0;
		trig = 0;
		trig_delay = 0;
		sample_hold_off = 0;
		num_smpls = 165;
		trigSync_size_b = 0;
		use_trigSyncExt_b = 0;

		// Wait 100 ns for global reset to finish
		#100;
		
        
		// Add stimulus here
		trig_delay = 10;
		sample_hold_off = 50;
		#150 trig =1;
		#200 trig =0;
		

	end
      
always # 1.4 fastClk = ~fastClk; //357 MHz clock
//always # 2.5 fastClk = ~fastClk; //200 MHz clock
always # 12.5 slowClk = ~slowClk;
	
	
		
endmodule

