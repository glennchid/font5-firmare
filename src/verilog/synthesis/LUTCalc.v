`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:16:56 04/05/2017 
// Design Name: 
// Module Name:    LUTCalc 
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
module LUTCalc(
									  input clk,
									  input slow_clk,
									  input [6:0] bpm1_i_lut_dinb,
									  input [14:0] bpm1_i_lut_addrb,
									  input bpm1_i_lut_web,
									  output [6:0] bpm1_i_lut_doutb,
									  input [6:0] bpm1_q_lut_dinb,
									  input [14:0] bpm1_q_lut_addrb,
									  input bpm1_q_lut_web,
									  output [6:0] bpm1_q_lut_doutb,
									  input [6:0] bpm2_i_lut_dinb,
									  input [14:0] bpm2_i_lut_addrb,
									  input bpm2_i_lut_web,
									  output [6:0] bpm2_i_lut_doutb,
									  input [6:0] bpm2_q_lut_dinb,
									  input [14:0] bpm2_q_lut_addrb,
									  input bpm2_q_lut_web,
									  output [6:0] bpm2_q_lut_doutb,
									  input [12:0] q_signal,
									  output reg signed[20:0] bpm1_i_lut_out,
									  output reg signed [20:0] bpm1_q_lut_out,
									  output reg signed [20:0] bpm2_i_lut_out,
									  output reg signed [20:0] bpm2_q_lut_out								  
									  
    );


wire signed [27:0] bpm1_i_lut_out_a, bpm1_q_lut_out_a, bpm2_i_lut_out_a,bpm2_q_lut_out_a;

//lookuptable1 bpm1_i_lut_inst (
LUTRAM200317 bpm1_i_lut_inst (

	.clka(clk),
	.dina(), // Bus [27 : 0] 
	.addra(q_signal), // Bus [12 : 0] 
	.wea(1'b0), // Bus [0 : 0] 
	.douta(bpm1_i_lut_out_a), // Bus [27 : 0] 
	.clkb(slow_clk),
	.dinb(bpm1_i_lut_dinb), // Bus [6 : 0] 
	.addrb(bpm1_i_lut_addrb), // Bus [14 : 0] 
	.web(bpm1_i_lut_web), // Bus [0 : 0] 
	.doutb(bpm1_i_lut_doutb)); // Bus [6 : 0] 
	
/*	LUTRAM200317 your_instance_name (
  .clka(clka), // input clka
  .wea(wea), // input [0 : 0] wea
  .addra(addra), // input [12 : 0] addra
  .dina(dina), // input [27 : 0] dina
  .douta(douta), // output [27 : 0] douta
  .clkb(clkb), // input clkb
  .web(web), // input [0 : 0] web
  .addrb(addrb), // input [14 : 0] addrb
  .dinb(dinb), // input [6 : 0] dinb
  .doutb(doutb) // output [6 : 0] doutb
);*/
	
//lookuptable2 bpm1_q_lut_inst (
LUTRAM200317 bpm1_q_lut_inst (
	.clka(clk),
	.dina(), // Bus [27 : 0] 
	.addra(q_signal), // Bus [12 : 0] 
	.wea(1'b0), // Bus [0 : 0] 
	.douta(bpm1_q_lut_out_a), // Bus [27 : 0] 
	.clkb(slow_clk),
	.dinb(bpm1_q_lut_dinb), // Bus [6 : 0] 
	.addrb(bpm1_q_lut_addrb), // Bus [14 : 0] 
	.web(bpm1_q_lut_web), // Bus [0 : 0] 
	.doutb(bpm1_q_lut_doutb)); // Bus [6 : 0]
	
//lookuptable3 bpm2_i_lut_inst (
LUTRAM200317 bpm2_i_lut_inst (
	.clka(clk),
	.dina(), // Bus [27 : 0] 
	.addra(q_signal), // Bus [12 : 0] 
	.wea(1'b0), // Bus [0 : 0] 
	.douta(bpm2_i_lut_out_a), // Bus [27 : 0] 
	.clkb(slow_clk),
	.dinb(bpm2_i_lut_dinb), // Bus [6 : 0] 
	.addrb(bpm2_i_lut_addrb), // Bus [14 : 0] 
	.web(bpm2_i_lut_web), // Bus [0 : 0] 
	.doutb(bpm2_i_lut_doutb)); // Bus [6 : 0] 
	
//lookuptable4 bpm2_q_lut_inst (
LUTRAM200317 bpm2_q_lut_inst (
	.clka(clk),
	.dina(), // Bus [27 : 0] 
	.addra(q_signal), // Bus [12 : 0] 
	.wea(1'b0), // Bus [0 : 0] 
	.douta(bpm2_q_lut_out_a), // Bus [27 : 0] 
	.clkb(slow_clk),
	.dinb(bpm2_q_lut_dinb), // Bus [6 : 0] 
	.addrb(bpm2_q_lut_addrb), // Bus [14 : 0] 
	.web(bpm2_q_lut_web), // Bus [0 : 0] 
	.doutb(bpm2_q_lut_doutb)); // Bus [6 : 0] 	
	
always @ (posedge clk) begin
bpm1_i_lut_out<=bpm1_i_lut_out_a[20:0];
bpm1_q_lut_out<=bpm1_q_lut_out_a[20:0];
bpm2_i_lut_out<=bpm2_i_lut_out_a[20:0];
bpm2_q_lut_out<=bpm2_q_lut_out_a[20:0];
end	

endmodule
