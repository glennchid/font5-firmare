`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:05:35 06/18/2015 
// Design Name: 
// Module Name:    gainMult 
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
module gainMult(
    input clk,
	 input [1:0] oflowMode,
    input signed [15:0] mixerIn,
    input signed [6:0] gain,
    output reg signed [15:0] dout = 16'sd0,
    output reg overflow = 1'b0
    );

parameter GAIN_SCALE = 1; //sets the scale factor for the gain; e.g. 128 ADC cnts maps to 2048 at DAC for GAIN_SCALE = -4 //
parameter GAIN_OFFSET = 5; // maps ADC counts to DAC counts for the mid-range of the gain (i.e. 2^5 for 7-bit gain) // 7-bit gain //
parameter GAIN_MSB = 23;

(* shreg_extract = "no" *) reg signed [15:0] mixerIn_reg = 16'sd0; // gainMult input register //
(* shreg_extract = "no" *) reg signed [6:0] gain_reg = 7'sd0, gain_reg_b = 7'sd0; // 7-bit gain // gainMult input register //
//(* shreg_extract = "no" *) reg signed [13:0] gain_reg = 14'sd0; // 14-bit gain // gainMult input register //

reg signed [GAIN_MSB:0] gainMult = 24'sd0;// = GAIN_MSB+1'sd0; // 7-bit gain //
//reg signed [GAIN_MSB:0] gainMult = 31'sd0; // 14-bit gain //

wire oflowDet = (~&gainMult[GAIN_MSB:GAIN_OFFSET+GAIN_SCALE+15] && ~&(~gainMult[GAIN_MSB:GAIN_OFFSET+GAIN_SCALE+15]));

always @(posedge clk) begin
	mixerIn_reg <= mixerIn;
	gain_reg <= gain;
	gain_reg_b <= gain_reg;
	gainMult <= (mixerIn_reg * gain_reg_b);
	overflow <= oflowDet;
	if (oflowDet) begin
		case (oflowMode)
		2'b00: dout <= gainMult[GAIN_OFFSET+GAIN_SCALE+15:GAIN_OFFSET+GAIN_SCALE]; // do nothing - ignore overflow //
		2'b01: dout <= 16'sd0; // kill output //
		2'b10: dout <= (gainMult[GAIN_MSB]) ? -16'sd32768 : 16'sd32767; // saturate output //
		default: dout <= 16'sd0;
		endcase 
	end else dout <= gainMult[GAIN_OFFSET+GAIN_SCALE+15:GAIN_OFFSET+GAIN_SCALE];
end

endmodule
