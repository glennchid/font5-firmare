`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:29:17 11/24/2014 
// Design Name: 
// Module Name:    reset_detector 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module overflow_detector(
    input clk,
    input oflow_Clr,
	 input oflow_in,
    output reg oflow_state = 1'b0
    );

//initial rst_state = 1'b1;
always @(posedge clk) oflow_state <= (oflow_Clr) ? 1'b0 : oflow_in;


endmodule
