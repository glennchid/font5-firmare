              module FBModule(
                             input clk,
                             input store_strb,
                             input [1:0] sel,
                             input signed [12:0] ai_in,
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
									  input signed [12:0] banana_corr_temp_b,
									  input const_dac_en_b,
									  input signed [12:0] const_dac_b,
									  input [1:0] no_bunches_b,
									  input [3:0] no_samples_b,
									  input [7:0] sample_spacing_b,
									  input fb_en_b,
		(* IOB = "true" *) 	  output reg [12:0] fb_sgnl,
									  output [6:0] bpm2_i_lut_doutb,
						    		  output [6:0] bpm2_q_lut_doutb,
									  output [6:0] bpm1_i_lut_doutb,
									  output [6:0] bpm1_q_lut_doutb,
	  (* IOB = "true" *) 	  output dac_clk,
									  output reg oflow
                             );
									 
wire signed [16:0] bpm1_i_reg_int;
wire signed [16:0] bpm1_q_reg_int;
wire signed [16:0] bpm2_i_reg_int;
wire signed [16:0] bpm2_q_reg_int;
//wire dac_clk;
reg dac_cond;
//reg signed [12:0] charge;

(* shreg_extract = "no" ,ASYNC_REG = "TRUE" *) reg [1:0] no_bunches_a,no_bunches;
(* shreg_extract = "no" ,ASYNC_REG = "TRUE" *) reg [3:0] no_samples_a, no_samples;
(* shreg_extract = "no" ,ASYNC_REG = "TRUE" *) reg [7:0] sample_spacing_a, sample_spacing;
(* shreg_extract = "no" ,ASYNC_REG = "TRUE" *) reg [7:0] b1_strobe_a, b1_strobe;
(* shreg_extract = "no" ,ASYNC_REG = "TRUE" *) reg [7:0] b2_strobe_a, b2_strobe;
(* shreg_extract = "no" ,ASYNC_REG = "TRUE" *) reg fb_en_a, fb_en;
(* shreg_extract = "no" ,ASYNC_REG = "TRUE" *) reg [12:0] banana_corr_temp_a, banana_corr_temp;
(* shreg_extract = "no" ,ASYNC_REG = "TRUE" *) reg [12:0] const_dac_a, const_dac;
(* shreg_extract = "no" ,ASYNC_REG = "TRUE" *) reg const_dac_en_a, const_dac_en;


// Banana correction and const dac
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
//charge<=q_signal;
fb_en_a<=fb_en_b;
fb_en<=fb_en_a;
banana_corr_temp_a<=banana_corr_temp_b;
banana_corr_temp<=banana_corr_temp_a;
const_dac_a<=const_dac_b;
const_dac<=const_dac_a;
const_dac_en_a<=const_dac_en_b;
const_dac_en<=const_dac_en_a;
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
   .ai_in(ai_in),
   .aq_in(aq_in),
   .bi_in(bi_in),
   .bq_in(bq_in),
   .ci_in(ci_in),
   .cq_in(cq_in),
	.bpm1_q_reg_int_a(bpm1_q_reg_int), 
	.bpm1_i_reg_int_a(bpm1_i_reg_int), 
	.bpm2_q_reg_int_a(bpm2_q_reg_int), 
	.bpm2_i_reg_int_a(bpm2_i_reg_int),
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
									  //.q_signal(charge),
									  .q_signal(q_signal),
									  .bpm1_i_lut_out(g1_inv_q),
									  .bpm1_q_lut_out(g2_inv_q),
									  .bpm2_i_lut_out(g3_inv_q),
									  .bpm2_q_lut_out(g4_inv_q),
									  .LUTcond(LUTcond)
									
    );


// ***** DSP48E modules  *****
// Charge and dipole signals in
// I/q + Q/q + I/q + Q/q out
//wire signed [12:0] DSPout, DSPout2, DSPout3, DSPout4;
wire signed [14:0] pout, pout2, pout3, pout4;
reg signed [12:0] banana_corr;
wire DSPoflow1, DSPoflow2, DSPoflow3, DSPoflow4;

//wire signed [47:0] pout_a, pout2_a, pout3_a, pout4_a;
DSPCalcModule DSPModule1(
			.charge_in(g1_inv_q),
			.signal_in(bpm1_i_reg_int),
			.delay_en(delay_en),
			.clk(clk),
			.store_strb(store_strb),
			.pout(pout),
			.bunch_strb(bunch_strb),
			.DSPoflow(DSPoflow1),
			.fb_en(fb_en)
//			.banana_corr(banana_corr),
//			.fb_cond(fb_cond),
//			.dac_clk(dac_clk)
					);
			
DSPCalcModule DSPModule2(
			.charge_in(g2_inv_q),
			.signal_in(bpm1_q_reg_int),
			.delay_en(delay_en),
			.clk(clk),
			.store_strb(store_strb),
			.pout(pout2),
			.bunch_strb(bunch_strb),
			.fb_cond(fb_cond),
			.dac_clk(dac_clk),
			.DSPoflow(DSPoflow2),
			.fb_en(fb_en)
//			.banana_corr(banana_corr)
			);
			
DSPCalcModule DSPModule3(
			.charge_in(g3_inv_q),
			.signal_in(bpm2_i_reg_int),
			.delay_en(delay_en),
			.clk(clk),
			.store_strb(store_strb),
			.pout(pout3),
			.bunch_strb(bunch_strb),
			.DSPoflow(DSPoflow3),
			.fb_en(fb_en)
//			.fb_cond(fb_cond),
//			.dac_clk(dac_clk)
//			.banana_corr(banana_corr)
			);
			
DSPCalcModule DSPModule4(
			.charge_in(g4_inv_q),
			.signal_in(bpm2_q_reg_int),
			.delay_en(delay_en),
			.clk(clk),
			.store_strb(store_strb),
			.pout(pout4),
			.bunch_strb(bunch_strb),
			.DSPoflow(DSPoflow4),
			.fb_en(fb_en)
//			.fb_cond(fb_cond),
//			.dac_clk(dac_clk)
//			.banana_corr(banana_corr)
			);

// ***** Clock DAC/Assign fb_sgnl *****

reg signed [14:0] sum1, sum2;
reg output_cond1, output_cond2;
//reg oflowsum1,oflowsum2;
//reg oflowadd=0;

wire signed [15:0] fb_sgnl_16bit = sum1 + sum2;

//reg dac_clk;
reg oflow_temp;

always @ (posedge clk)begin
banana_corr<=banana_corr_temp;
dac_cond<=fb_cond; 
//dac_clk<=dac_cond; 
sum1<=pout+pout2;
sum2<=pout3+pout4+banana_corr;
output_cond1<=dac_cond & !const_dac_en;
output_cond2<=dac_cond & const_dac_en;
////oflow2<=((&sum1[15:12]==0)&(&!sum1[15:12]==0))|((&sum2[15:12]==0)&(&!sum2[15:12]==0));
//oflowsum1<=(~&sum1[14:12] && ~&(~sum1[14:12]));
//oflowsum2<=(~&sum2[14:12] && ~&(~sum2[14:12]));

oflow_temp<=(~&fb_sgnl_16bit[15:12] && ~&(~fb_sgnl_16bit[15:12]));

oflow<=oflow_temp|DSPoflow1|DSPoflow2|DSPoflow3|DSPoflow4;
if (~store_strb) fb_sgnl<=0;
else begin
if (output_cond1) begin
	
fb_sgnl <= fb_sgnl_16bit[12:0];

//oflowadd<=((sum1[12]&sum2[12]) & ~fb_sgnl[12])|((~sum1[12]&~sum2[12]) & fb_sgnl[12]);
end
else if (output_cond2) fb_sgnl<=const_dac;
//else fb_sgnl<=0;
end
end


endmodule

