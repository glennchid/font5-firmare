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
module reset_detector(
    input clk,
    input rst,
    output reg rst_state = 1'b1
    );

//initial rst_state = 1'b1;
always @(posedge clk) rst_state <= (rst) ? 1'b0 : rst_state;


endmodule
