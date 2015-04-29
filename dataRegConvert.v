`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:47:11 07/31/2013 
// Design Name: 
// Module Name:    dataRegConvert 
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
module dataRegConvert(
    input clk,
    input signed [12:0] din,
    output reg signed [12:0] dout = 13'sd0
    );
	 
	 //parameter ADDPIPEREG = 1;
	 parameter width = 13;
	 parameter BITFLIP = (13'd0 ^ -13'sd4096);

//`define ADDPIPEREGS
//supply0 gnd;
(* IOB = "true" *) reg signed [width-1:0] data_reg = 13'sd0;
`ifdef ADDPIPEREGS reg signed [width-1:0] pipereg = 13'sd0;
`endif
//reg signed [width-1:0] dreg_b;
//reg signed [width-1:0] dout;

always @(posedge clk) begin
	data_reg <= din;
	`ifdef ADDPIPEREGS begin
		pipereg <= data_reg;
		//dout <= {~pipereg[width-1], pipereg[width-2:0]};
		dout <= pipereg ^ BITFLIP;
	end 
	`else
		//dout <= {~data_reg[width-1], data_reg[width-2:0]};
		dout <= data_reg ^ BITFLIP;
	`endif
	//dout <= dreg_b;
end


endmodule
