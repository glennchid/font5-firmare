`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:13:38 12/14/2015
// Design Name:   uart_rx
// Module Name:   H:/Firmware/font5_base_new/font5_base/font5-firmware/UART_RX_TB.v
// Project Name:  font5_base
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: uart_rx
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module UART_RX_TB;

	// Inputs
	reg reset;
	reg clk = 0;
	reg [1:0] baud_rate = 2 ;
	//reg uld_rx_data;
	reg rx_enable = 1;
	reg rx_in;

	// Outputs
	wire [7:0] rx_data;
	//wire rx_empty;
	wire byte_rdy;
	wire uart_rx_unload;
	
	//localparam real BAUD_PERIOD = 2170.139; // 460.8 kBaud
	localparam real BAUD_PERIOD = 104166.667; // 9600 Baud

	//localparam real BAUD_PERIOD = 8680.556; // 115.2 kBaud
	

	// Instantiate the Unit Under Test (UUT)
	/*uart uut ( 					// Original version of the UART from FBFW (Ben)
					.reset(reset),
					.txclk(),
					.ld_tx_data(),
					.tx_data(),
					.tx_enable(),
					.tx_out(),
					.tx_empty(),
					.rxclk(clk),
					.uld_rx_data(uart_rx_unload),
					.rx_data(rx_data),
					.rx_enable(rx_enable),
					.rx_in(rx_in),
					.rx_empty(rx_empty)
	);*/
	
	uart2_rx #(8, 9600) uut1 ( // new variable Baud UART_RX
		.reset(reset),
		.clk(clk),
		.uld_rx_data(uart_rx_unload),
		.rx_data(rx_data),
		.rx_enable(rx_enable),
		.rx_in(rx_in),
		.byte_rdy(byte_rdy)
		);
	
	/*uart_rx uut1(	// original UART_RX from FONT5_base
		.reset(reset),
		.clk(clk),
		.baud_rate(baud_rate),
		.uld_rx_data(uart_rx_unload),
		.rx_data(rx_data),
		.rx_enable(rx_enable),
		.rx_in(rx_in),
		.rx_empty(byte_rdy)
);*/
	
	wire [6:0] ctrl_reg_addr;
	wire ctrl_reg_strb;
	wire [6:0] ctrl_reg_data;
	wire [14:0] gainlut_ld_addr;
	wire [4:0] gainlut_ld_select;	
	wire [6:0] gainlut_ld_data;
	wire gainlut_ld_en;
	wire full_rst_trig;
	wire delay_trig1;
	wire delay_trig2;
	wire delay_trig3;
	wire clk357_idelay_rst;
	wire clk357_idelay_trig;
	wire trim_dac_trig;
	wire poll_uart;
	wire pulse_ctr_rst;

	uart_decoder3 uut2 (	
		.clk(clk),
		.rst(reset),
		.data_in(rx_data),
		.byte_rdy(byte_rdy),
		.byte_uld(uart_rx_unload),
		.current_addr(ctrl_reg_addr),
		.data_strobe(ctrl_reg_strb),
		.data_out(ctrl_reg_data),
		.ram_addr(gainlut_ld_addr),
		.ram_select(gainlut_ld_select),	
		.ram_data(gainlut_ld_data),
		.ram_data_strobe(gainlut_ld_en),
		.full_reset(full_rst_trig),
		.p1_delay_trig(delay_trig1),
		.p2_delay_trig(delay_trig2),
		.p3_delay_trig(delay_trig3),
		.clk357_idelay_rst(clk357_idelay_rst),
		.clk357_idelay_trig(clk357_idelay_trig),
		.trim_dac_trig(trim_dac_trig),
		.poll_uart(poll_uart),
		.pulse_ctr_rst(pulse_ctr_rst)
);	 
	initial begin
		// Initialize Inputs
		reset = 0;
		//clk = 0;
		//baud_rate = 0;
		//uld_rx_data = 0;
		//rx_enable = 0;
		rx_in = 1;

		// Wait 100 ns for global reset to finish
		#100 reset = 1;
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

		
		
		// Add stimulus here

	end
	
	initial forever #12.5 clk = ~clk;
      
endmodule

