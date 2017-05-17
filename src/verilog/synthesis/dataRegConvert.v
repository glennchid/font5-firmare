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
	 input [1:0] sr_bypass,
    input signed [12:0] din,
	 input signed [12:0] offset,
	 //input [5:0] sr_tap,
	 input [4:0] sr_tap,
    (* keep = "yes" *) output reg signed [13:0] dout = 14'sd0
		//output signed [12:0] dout
    );
	 
	 //parameter ADDPIPEREG = 1;
	 parameter width = 13;
	 parameter BITFLIP = (13'd0 ^ -13'sd4096); //Generic conversion for correct polarity LVDS signals in offset binary

//`define ADDPIPEREGS
//(* IOB = "true" *) reg signed [width-1:0] data_reg = 13'sd0;
(* IOB = "true" *) reg signed [width-1:0] data_reg = BITFLIP;
//(* shreg_extract = "no" *) reg [5:0] sr_tap_a = 5'd0, sr_tap_b = 5'd0;//, sr_tap_c = 5'd0;
//(* shreg_extract = "no", equivalent_register_removal = "no" *) reg [5:0] sr_tap_b = 6'd0;
//(* shreg_extract = "no" *) reg [5:0] sr_tap_a = 6'd0, sr_tap_b = 6'd0;
//(* shreg_extract = "no" *) reg [4:0] sr_tap_a = 5'd0, sr_tap_b = 5'b0;//, sr_tap_b = 5'd0, sr_tap_c = 5'd0;


`ifdef ADDPIPEREGS reg signed [width-1:0] pipereg = BITFLIP;
`else reg signed [width-1:0] dreg_b = 13'd0;
`endif
//reg signed [width-1:0] dreg_b;
//reg signed [width-1:0] dout;
wire signed [width-1:width-13] data_out;

//(* async_reg = "TRUE" *) reg signed [12:0] offset_a = 13'd0, offset_b = 13'd0;

always @(posedge clk) begin
	//sr_tap_a <= sr_tap;
	//sr_tap_b <= sr_tap_a;
	//sr_tap_c <= sr_tap_b;
	//offset_b <= offset_a;
	//offset_a <= offset;
	data_reg <= din;
	`ifdef ADDPIPEREGS begin
		pipereg <= data_reg;
		//dout <= {~pipereg[width-1], pipereg[width-2:0]};
		//dout <= (sr_tap_b[5]) ? (data_out ^ BITFLIP) : (pipereg ^ BITFLIP);
		dout <= (sr_bypass[0]) ? (pipereg ^ BITFLIP) : (data_out ^ BITFLIP) + offset;
	end 
	`else
		//dout <= {~data_reg[width-1], data_reg[width-2:0]};
		//dout <= data_reg ^ BITFLIP;
		//dout <= (sr_tap_b[5]) ? (data_out ^ BITFLIP) : (data_reg ^ BITFLIP);
		dreg_b <= (sr_bypass[0]) ? (data_reg ^ BITFLIP) : (data_out ^ BITFLIP);// +offset;
		dout <= dreg_b + offset;
	`endif
	//dout <= dreg_b + offset;
end
`ifdef ADDPIPEREGS ShiftReg #(32, BITFLIP) DataInreg(clk, sr_bypass[1], pipereg, sr_tap, data_out);
`else ShiftReg #(32, BITFLIP) DataInreg(clk, sr_bypass[1], data_reg, sr_tap, data_out);
`endif
//assign dout = data_out ^ BITFLIP;

endmodule
