`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:02:08 04/05/2017 
// Design Name: 
// Module Name:    MuxModule 
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
module MuxModule(
	input bunch_strb,
	input [1:0] sel,
   input signed [12:0] ai_in,
   input signed [12:0] aq_in,
   input signed [12:0] bi_in,
   input signed [12:0] bq_in,
   input signed [12:0] ci_in,
   input signed [12:0] cq_in,
	output reg signed [16:0] bpm1_q_reg_int_a, 
	output reg signed [16:0] bpm1_i_reg_int_a, 
	output reg signed [16:0] bpm2_q_reg_int_a, 
	output reg signed [16:0] bpm2_i_reg_int_a,
	input clk,
	input dac_cond,
	input store_strb
  
    );

//(* equivalent_register_removal = "no"*) reg [6:0] j;
wire signed [12:0] bpm1_i, bpm1_q, bpm2_i, bpm2_q; 
(* equivalent_register_removal = "no"*)reg signed [16:0] bpm1_i_reg_int,bpm1_q_reg_int,bpm2_i_reg_int,bpm2_q_reg_int;
initial begin 
bpm1_i_reg_int=0;
bpm1_q_reg_int=0;
bpm2_i_reg_int=0;
bpm2_q_reg_int=0;
end

// ***** Multiplexer unit *****               
assign bpm2_i = (sel[1])? ci_in: bi_in;
assign bpm2_q = (sel[1])? cq_in: bq_in;
assign bpm1_q = (sel[0])? bq_in: aq_in;
assign bpm1_i = (sel[0])? bi_in: ai_in;

// ***** Integrate over samples ***** 



always@(posedge clk) begin
bpm1_i_reg_int_a<=bpm1_i_reg_int;
bpm1_q_reg_int_a<=bpm1_q_reg_int;
bpm2_i_reg_int_a<=bpm2_i_reg_int;
bpm2_q_reg_int_a<=bpm2_q_reg_int;
if (bunch_strb) begin
bpm1_i_reg_int<=bpm1_i+bpm1_i_reg_int;
bpm1_q_reg_int<=bpm1_q+bpm1_q_reg_int;
bpm2_i_reg_int<=bpm2_i+bpm2_i_reg_int;
bpm2_q_reg_int<=bpm2_q+bpm2_q_reg_int;
//q_signal_int<=q_signal+q_signal_int;
end
else if (dac_cond|~store_strb) begin
bpm1_i_reg_int<=0;
bpm1_q_reg_int<=0;
bpm2_i_reg_int<=0;
bpm2_q_reg_int<=0;
//q_signal_int<=0;
end
end




endmodule
