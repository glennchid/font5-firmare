`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:12:26 12/16/2015
// Design Name:   uart2_rx
// Module Name:   H:/Firmware/font5_base_new/font5_base/font5-firmware/uart2_rx_tb.v
// Project Name:  font5_base
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: uart2_rx
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module uart2_rx_tb;

	//localparam real BAUD_PERIOD = 104166.667; // 9600 Baud
	localparam real BAUD_PERIOD = 2170.139; // 460.8 kBaud

	// Inputs
	reg reset = 1'b0;
	reg clk = 1'b0;
	wire uld_rx_data;
	reg rx_enable = 1'b1;
	reg rx_in = 1'b1;

	// Outputs
	wire [7:0] rx_data;
	wire byte_rdy;

	// Instantiate the Unit Under Test (UUT)
	uart2_rx #(8, 460800) uut (
		.reset(reset), 
		.clk(clk), 
		.uld_rx_data(uld_rx_data), 
		.rx_data(rx_data), 
		.rx_enable(rx_enable), 
		.rx_in(rx_in), 
		.byte_rdy(byte_rdy)
	);

	uart_unload #(.BYTE_WIDTH(8),.WORD_WIDTH(13)) uart2_uld (.rst(reset), .clk(clk), .byte_rdy(byte_rdy), .unload_uart(uld_rx_data));


	initial begin
		// Initialize Inputs
		reset = 1'b0;
		//clk = 1'b0;
		//uld_rx_data = 0;
		//rx_enable = 0;
		rx_in = 1'b1;

		// Wait 100 ns for global reset to finish
		#100 reset = 1;
        
		// Add stimulus here
		#100 reset = 0;
		
		#50 rx_in = 0;  //start bit
		#BAUD_PERIOD rx_in = 0;
		#BAUD_PERIOD rx_in = 1;
		#BAUD_PERIOD rx_in = 0;
		#BAUD_PERIOD rx_in = 1;
		#BAUD_PERIOD rx_in = 0;
		#BAUD_PERIOD rx_in = 1;
		#BAUD_PERIOD rx_in = 0;
		#BAUD_PERIOD rx_in = 0; 
		#BAUD_PERIOD rx_in = 1; //stop bit

	end
	initial forever #12.5 clk = ~clk;
      
endmodule

