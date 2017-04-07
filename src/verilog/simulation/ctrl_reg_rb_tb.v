`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:04:52 01/04/2013
// Design Name:   ctrl_reg_readback
// Module Name:   H:/Firmware/FONT5_base/ISE13/FONT5_base/ctrl_reg_rb_tb.v
// Project Name:  FONT5_base
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: ctrl_reg_readback
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module ctrl_reg_rb_tb;

	// Inputs
	reg clk;
	reg rst;
	//reg [6:0] data;
	reg tx_en;
	reg tx_data_loaded;

	// Outputs
	wire tx_data_ready;
	//wire [7:0] tx_data;
	wire tx_complete;
	wire [5:0] tx_cnt;

	// Instantiate the Unit Under Test (UUT)
	ctrl_reg_readback uut (
		.clk(clk), 
		.rst(rst), 
		//.data(data), 
		.tx_en(tx_en), 
		.tx_data_loaded(tx_data_loaded), 
		.tx_data_ready(tx_data_ready), 
		//.tx_data(tx_data), 
		.tx_complete(tx_complete), 
		.tx_cnt(tx_cnt)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;
		//data = 0;
		tx_en = 0;
		tx_data_loaded = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		rst = 1;
		tx_en = 0;
		
		#100;
		rst=0;
		tx_en = 1;
	end
      
	always #12.5 clk = !clk;
		
	always @(*) begin
		if (tx_data_ready) tx_data_loaded = 1;
		else if (tx_data_loaded) #0 tx_data_loaded = 0;
		else tx_data_loaded = tx_data_loaded;
		if (tx_complete) tx_en=0;
		else tx_en = tx_en;
		end
		
		
endmodule

