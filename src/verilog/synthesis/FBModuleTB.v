`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:24:27 01/31/2017 
// Design Name: 
// Module Name:    FBModuleTB 
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
module FBModuleTB;

reg signed [12:0] ai_in, aq_in,bi_in,bq_in,ci_in,cq_in;
reg signed [12:0] ai_in1 [0:8199];
reg signed [12:0] aq_in1 [0:8199];
reg signed [12:0] bi_in1 [0:8199];
reg signed [12:0] bq_in1 [0:8199];
reg signed [12:0] ci_in1 [0:8199];
reg signed [12:0] cq_in1 [0:8199];
reg signed [12:0] q_signal1 [0:8199];
reg [1:0] sel;
reg clk = 0;
reg store_strb = 0;
wire signed [12:0] fb_sgnal;
reg  signed [9:0] b1_strobe;
wire signed[47:0] const_kick;
reg signed[12:0] q_signal;
wire [6:0] bpm1_i_lut_dinb;
wire [14:0] bpm1_i_lut_addrb;
wire bpm1_i_lut_web;
wire [6:0] bpm1_i_lut_doutb;
wire [6:0] bpm1_q_lut_dinb;
wire [14:0] bpm1_q_lut_addrb;
wire bpm1_q_lut_web;
wire [6:0] bpm1_q_lut_doutb;
wire [6:0] bpm2_i_lut_dinb;
wire [14:0] bpm2_i_lut_addrb;
wire bpm2_i_lut_web;
wire [6:0] bpm2_i_lut_doutb;
wire [6:0] bpm2_q_lut_dinb;
wire [14:0] bpm2_q_lut_addrb;
wire bpm2_q_lut_web;
wire [6:0] bpm2_q_lut_doutb;
reg slow_clk=0;
//wire [31:0] no_bunches, no_samples,sample_spacing;


initial begin
$readmemb("tempai.txt",ai_in1);
$readmemb("tempaq.txt",aq_in1);
$readmemb("tempbi.txt",bi_in1);
$readmemb("tempbq.txt",bq_in1);
$readmemb("tempci.txt",ci_in1);
$readmemb("tempcq.txt",cq_in1);
$readmemb("tempq.txt",q_signal1);
end

//always @ (posedge trigger_counter) begin
//$readmemb("tempai.txt",ai_in1);
//$readmemb("tempaq.txt",aq_in1);
//$readmemb("tempbi.txt",bi_in1);
//$readmemb("tempbq.txt",bq_in1);
//$readmemb("tempci.txt",ci_in1);
//$readmemb("tempcq.txt",cq_in1);
//$readmemb("tempq.txt",q_signal1);
//end
//end

FBModule my_FBmod(
		.clk(clk),
		.sel(sel),
		.ai_in(ai_in),
		.aq_in(aq_in),
		.bi_in(bi_in),
	   .bq_in(bq_in),
		.ci_in(ci_in),
		.cq_in(cq_in),
		.q_signal(q_signal),
		.bpm1_i_lut_dinb(bpm1_i_lut_dinb),
		.bpm1_i_lut_addrb(bpm1_i_lut_addrb),
		.bpm1_i_lut_web(bpm1_i_lut_web),
		.bpm1_i_lut_doutb(bpm1_i_lut_doutb),
		.bpm1_q_lut_dinb(bpm1_q_lut_dinb),
		.bpm1_q_lut_addrb(bpm1_q_lut_addrb),
		.bpm1_q_lut_web(bpm1_q_lut_web),
		.bpm1_q_lut_doutb(bpm1_q_lut_doutb),
		.bpm2_i_lut_dinb(bpm2_i_lut_dinb),
		.bpm2_i_lut_addrb(bpm2_i_lut_addrb),
		.bpm2_i_lut_web(bpm2_i_lut_web),
		.bpm2_i_lut_doutb(bpm2_i_lut_doutb),
	   .bpm2_q_lut_dinb(bpm2_q_lut_dinb),
		.bpm2_q_lut_addrb(bpm2_q_lut_addrb),
		.bpm2_q_lut_web(bpm2_q_lut_web),
		.bpm2_q_lut_doutb(bpm2_q_lut_doutb),
		.fb_sgnl(fb_sgnal),
		.b1_strobe(b1_strobe),
		.delay_en(delay_en),
//		.const_kick(const_kick),
		.store_strb(store_strb),
	   .slow_clk(slow_clk)
//		.no_bunches(no_bunches),
//		.no_samples(no_samples),
//		.sample_spacing(sample_spacing)
//	
		);

always  #1.4 clk=!clk;
always  #12.5 slow_clk=!slow_clk;

assign delay_en=0;
//assign no_bunches=2;
//assign no_samples=1;
//assign sample_spacing=100;
integer i;
integer trigger_counter;

always begin 
#918.4 store_strb=1;	
#459.2 store_strb=0;

end

initial begin
	 b1_strobe=0;
    ai_in <= 0;
    bi_in<=0;
	 ci_in<=0;
	 aq_in <=0;
	 bq_in<=0;
	 cq_in<=0;
	 sel[1] <=1;
	 sel[0] <=0;
	 q_signal<=0;
	 i=0;
	 trigger_counter=0;
	 b1_strobe=25;
end


always @ (negedge clk) 
begin
if (store_strb==0) begin
    ai_in <= 0;
    bi_in<=0;
	 ci_in<=0;
	 aq_in <=0;
	 bq_in<=0;
	 cq_in<=0;
	 sel[1] <=1;
	 sel[0] <=0;
    i<=(4*trigger_counter+2)*164;
end else begin 
ai_in<=ai_in1[i];
aq_in<=aq_in1[i];
bi_in<=bi_in1[i];
bq_in<=bq_in1[i];
ci_in<=ci_in1[i+5];
cq_in<=cq_in1[i+5];
q_signal<=q_signal1[i+5]; 
i<=i+1;

end
end


always @ (posedge store_strb) begin
#1 trigger_counter=trigger_counter+1;
end



endmodule
