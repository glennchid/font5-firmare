`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:22:01 02/13/2014 
// Design Name: 
// Module Name:    Interleaver 
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
module Interleaver(
    input clk,
    input trigger,
    input Interleave_b,
	 input FF_en,
	 `ifdef XILINX_ISIM
		output reg output_en = 1'b1
	 `else
		output reg output_en = 1'b0
	 `endif
    );

(* shreg_extract = "no" *) reg Interleave = 1'b0, Interleave_a = 1'b0;
(* shreg_extract = "no" *) reg FF_en_a = 1'b0, FF_en_b = 1'b0;

always @(posedge clk) begin
	Interleave <= Interleave_a;
	Interleave_a <= Interleave_b;
	FF_en_a <= FF_en;
	FF_en_b <= FF_en_a;
	
	//output_en <= (trigger && Interleave) ? ~output_en : 1'b0;
	
	//if (trigger && Interleave) output_en <= ~output_en;
	if (trigger && FF_en_b) output_en <= (Interleave) ? ~output_en : 1'b1;
	else if (trigger) output_en <= 1'b0;
	else output_en <= output_en;
	//else if (trigger) output_en <= 1'b1;
	//else output_en <= output_en;
end
	
endmodule
