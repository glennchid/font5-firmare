              module FBModule(
                             input clk,
                             input store_strb,
                             input [1:0] sel,
                             input signed[12:0] ai_in,
                             input signed [12:0] aq_in,
                             input signed [12:0] bi_in,
                             input signed [12:0] bq_in,
                             input signed [12:0] ci_in,
                             input signed [12:0] cq_in,
                             input [7:0] b1_strobe_b,
									  input [7:0] b2_strobe_b,
									  input signed [12:0] q_signal,
                             input delay_en,
									  input slow_clk,
									  input [6:0] bpm_lut_dinb,
									  input [14:0] bpm_lut_addrb,
									  input bpm1_i_lut_web,
									  input bpm1_q_lut_web,
									  input bpm2_i_lut_web,
									  input bpm2_q_lut_web,
									  input signed [12:0] banana_corr,
									  input const_dac_en,
									  input signed [12:0] const_dac,
									  input [1:0] no_bunches_b,
									  input [3:0] no_samples_b,
									  input [7:0] sample_spacing_b,
									  output reg [12:0] fb_sgnl,
									  output [6:0] bpm2_i_lut_doutb,
						    		  output [6:0] bpm2_q_lut_doutb,
									  output [6:0] bpm1_i_lut_doutb,
									  output [6:0] bpm1_q_lut_doutb,
									  output reg dac_cond
                             );
                            
wire signed [14:0] bpm1_i_reg_int, bpm1_q_reg_int,bpm2_i_reg_int,bpm2_q_reg_int;
//reg dac_cond;
(* async_reg = "TRUE" *) reg [1:0] no_bunches_a,no_bunches;
(* async_reg = "TRUE" *) reg [3:0] no_samples_a, no_samples;
(* async_reg = "TRUE" *) reg [7:0] sample_spacing_a, sample_spacing;
(* async_reg = "TRUE" *) reg [7:0] b1_strobe_a, b1_strobe;
(* async_reg = "TRUE" *) reg [7:0] b2_strobe_a, b2_strobe;

(* keep = "yes" *) reg signed [12:0] ai, aq, bi, bq, ci, cq, chrg;

always @ (posedge clk) begin
no_bunches_a<=no_bunches_b;
no_bunches<=no_bunches_a;
no_samples_a<=no_samples_b;
no_samples<=no_samples_a;
sample_spacing_a<=sample_spacing_b;
sample_spacing<=sample_spacing_a;
b1_strobe_a<=b1_strobe_b;
b1_strobe<=b1_strobe_a;
b2_strobe_a<=b2_strobe_b;
b2_strobe<=b2_strobe_a;
ai <= ai_in;
aq <= aq_in;
bi <= bi_in;
bq <= bq_in;
ci <= ci_in;
cq <= cq_in;
chrg <= q_signal;
end 



//parameter NO_BUNCHES=2;      // Number of bunches 
//parameter NO_SAMPLES=1;      // Number of samples
//parameter SAMPLE_SPACING=100; // Number of samples between consecutive bunches

Timing  TimingStrobes(
		.no_bunches(no_bunches),
		.no_samples(no_samples),
		.sample_spacing(sample_spacing),
		.bunch_strb(bunch_strb),
		.store_strb(store_strb),
		.clk(clk),
		.b1_strobe(b1_strobe),   // For dipole signal
		.b2_strobe(b2_strobe),
		.LUTcond(LUTcond)
    );
                     
             
MuxModule Multiplexers(
	.bunch_strb(bunch_strb),
	.sel(sel),
   .ai_in(ai),
   .aq_in(aq),
   .bi_in(bi),
   .bq_in(bq),
   .ci_in(ci),
   .cq_in(cq),
	.bpm1_q_reg_int(bpm1_q_reg_int), 
	.bpm1_i_reg_int(bpm1_i_reg_int), 
	.bpm2_q_reg_int(bpm2_q_reg_int), 
	.bpm2_i_reg_int(bpm2_i_reg_int),
	.clk(clk),  // static offset to be applied to I or Q
	.dac_cond(dac_cond)
);


// ***** LUT to gain scale *****
// Read out LUT when store strobe goes low
wire signed [20:0] g1_inv_q,g2_inv_q,g3_inv_q,g4_inv_q;
////reg fb_cond;
//reg [6:0] bpm1_i_lut_dinb1, bpm1_i_lut_dinb2;
//always @ (posedge clk) begin
//bpm1_i_lut_dinb2<=bpm1_i_lut_dinb;
//bpm1_i_lut_dinb1<=bpm1_i_lut_dinb2;
//end
	
LUTCalc	LookUpTableModule(
									  .clk(clk),
									  .slow_clk(slow_clk),
									  .bpm1_i_lut_dinb(bpm_lut_dinb),
									  .bpm1_i_lut_addrb(bpm_lut_addrb),
									  .bpm1_i_lut_web(bpm1_i_lut_web),
									  .bpm1_i_lut_doutb(bpm1_i_lut_doutb),
									  .bpm1_q_lut_dinb(bpm_lut_dinb),
									  .bpm1_q_lut_addrb(bpm_lut_addrb),
									  .bpm1_q_lut_web(bpm1_q_lut_web),
									  .bpm1_q_lut_doutb(bpm1_q_lut_doutb),
									  .bpm2_i_lut_dinb(bpm_lut_dinb),
									  .bpm2_i_lut_addrb(bpm_lut_addrb),
									  .bpm2_i_lut_web(bpm2_i_lut_web),
									  .bpm2_i_lut_doutb(bpm2_i_lut_doutb),
									  .bpm2_q_lut_dinb(bpm_lut_dinb),
									  .bpm2_q_lut_addrb(bpm_lut_addrb),
									  .bpm2_q_lut_web(bpm2_q_lut_web),
									  .bpm2_q_lut_doutb(bpm2_q_lut_doutb),
									  .q_signal(chrg),
									  .bpm1_i_lut_out(g1_inv_q),
									  .bpm1_q_lut_out(g2_inv_q),
									  .bpm2_i_lut_out(g3_inv_q),
									  .bpm2_q_lut_out(g4_inv_q),
									  .store_strb(store_strb),
									  .b2_strobe(b2_strobe), // for reference signal
									  .LUTcond(LUTcond)
									
    );


// ***** DSP48E modules  *****
// Charge and dipole signals in
// I/q + Q/q + I/q + Q/q out
//wire signed [12:0] DSPout, DSPout2, DSPout3, DSPout4;
wire signed [12:0] pout, pout2, pout3, pout4;

//wire signed [47:0] pout_a, pout2_a, pout3_a, pout4_a;
DSPCalcModule DSPModule1(
			.charge_in(g1_inv_q),
			.signal_in(bpm1_i_reg_int),
			.delay_en(delay_en),
			.clk(clk),
			.store_strb(store_strb),
			.pout(pout),
			.bunch_strb(bunch_strb),
			.banana_corr(banana_corr),
			.fb_cond(fb_cond)
					);
			
DSPCalcModule DSPModule2(
			.charge_in(g2_inv_q),
			.signal_in(bpm1_q_reg_int),
			.delay_en(delay_en),
			.clk(clk),
			.store_strb(store_strb),
			.pout(pout2),
			.bunch_strb(bunch_strb),
			.banana_corr(banana_corr)
			);
			
DSPCalcModule DSPModule3(
			.charge_in(g3_inv_q),
			.signal_in(bpm2_i_reg_int),
			.delay_en(delay_en),
			.clk(clk),
			.store_strb(store_strb),
			.pout(pout3),
			.bunch_strb(bunch_strb),
			.banana_corr(banana_corr)
			);
			
DSPCalcModule DSPModule4(
			.charge_in(g4_inv_q),
			.signal_in(bpm2_q_reg_int),
			.delay_en(delay_en),
			.clk(clk),
			.store_strb(store_strb),
			.pout(pout4),
			.bunch_strb(bunch_strb),
			.banana_corr(banana_corr)
			);

// ***** Clock DAC/Assign fb_sgnl *****

reg signed [12:0] sum1, sum2;
reg output_cond1, output_cond2;


always @ (posedge clk)begin
dac_cond<=fb_cond; 
sum1<=pout+pout2;
sum2<=pout3+pout4;
output_cond1<=dac_cond & !const_dac_en;
output_cond2<=dac_cond & const_dac_en;
if (output_cond1) fb_sgnl<=sum1+sum2; // If reference not delayed by two samples then increase j accordingly
else if (output_cond2) fb_sgnl<=const_dac;
//else if (output_cond2) fb_sgnl<=const_dac;
else fb_sgnl<=0;
end


endmodule

