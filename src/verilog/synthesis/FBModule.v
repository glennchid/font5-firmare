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
                             input signed [9:0] b1_strobe,
									  input [12:0] q_signal,
                             output reg [12:0] fb_sgnl,
                             input delay_en,
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
									  output [6:0] bpm2_q_lut_doutb
//									  input [10:0] NO_BUNCHES,
//									  input [10:0] NO_SAMPLES,
//									  input [10:0] SAMPLE_SPACING
//									 
                             );
                            
//wire [20:0] signal_in;
//wire [14:0] bpm1_i_reg_int_a, bpm1_q_reg_int_a,bpm2_i_reg_int_a,bpm2_q_reg_int_a;
wire [14:0] bpm1_i_reg_int, bpm1_q_reg_int,bpm2_i_reg_int,bpm2_q_reg_int;

parameter NO_BUNCHES=2;
parameter NO_SAMPLES=1;
parameter SAMPLE_SPACING=100;

Timing #(.NO_BUNCHES(NO_BUNCHES),
			.NO_SAMPLES(NO_SAMPLES),
			.SAMPLE_SPACING(SAMPLE_SPACING)
	) TimingStrobes(
		.bunch_strb(bunch_strb),
		.store_strb(store_strb),
		.clk(clk),
		.b1_strobe(b1_strobe)
//		.NO_BUNCHES(NO_BUNCHES),
//		.NO_SAMPLES(NO_SAMPLES),
//		.SAMPLE_SPACING(SAMPLE_SPACING)
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
	.clk(clk)
);

//// ***** Register 21 bits of LUT output *****
wire signed [20:0] g1_inv_q,g2_inv_q,g3_inv_q,g4_inv_q;
//reg signed [20:0] g1_inv_q_a,g2_inv_q_a,g3_inv_q_a,g4_inv_q_a;


//// ***** LUT to add gain *****
//
//wire [6:0] bpm1_i_lut_dinb,bpm2_i_lut_dinb,bpm1_q_lut_dinb,bpm2_q_lut_dinb;
//wire [14:0] bpm1_i_lut_addrb,bpm2_i_lut_addrb,bpm1_q_lut_addrb,bpm2_q_lut_addrb;
//wire [6:0] bpm1_i_lut_doutb,bpm2_i_lut_doutb,bpm1_q_lut_doutb,bpm2_q_lut_doutb;
//wire signed [20:0] bpm1_i_lut_out, bpm1_q_lut_out, bpm2_i_lut_out, bpm2_q_lut_out;
	
LUTCalc LookUpTableModule(
									  .clk(clk),
									  .slow_clk(slow_clk),
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
									  .q_signal(q_signal),
									  .bpm1_i_lut_out(g1_inv_q),
									  .bpm1_q_lut_out(g2_inv_q),
									  .bpm2_i_lut_out(g3_inv_q),
									  .bpm2_q_lut_out(g4_inv_q)				  
    );




// ***** Infer DSP48E *****
// In implementation will require pipelining to meet timing constraints

reg signed [12:0] sum_all1=0;
reg signed [12:0]  sum_all2=0;
//reg signed [12:0] sum_all3;
wire signed [12:0] pout, pout2, pout3, pout4;
//wire signed [47:0] pout_a, pout2_a, pout3_a, pout4_a;
DSP48E_1 DSPModule1(
			.charge_in(g1_inv_q),
			.signal_in(bpm1_i_reg_int),
			.delay_en(delay_en),
			.clk(clk),
			.store_strb(store_strb),
			.DSPout(pout),
			.bunch_strb(bunch_strb)
			);
			
DSP48E_1 DSPModule2(
			.charge_in(g2_inv_q),
			.signal_in(bpm1_q_reg_int),
			.delay_en(delay_en),
			.clk(clk),
			.store_strb(store_strb),
			.DSPout(pout2),
			.bunch_strb(bunch_strb)
			);
			
DSP48E_1 DSPModule3(
			.charge_in(g3_inv_q),
			.signal_in(bpm2_i_reg_int),
			.delay_en(delay_en),
			.clk(clk),
			.store_strb(store_strb),
			.DSPout(pout3),
			.bunch_strb(bunch_strb)
			);
			
DSP48E_1 DSPModule4(
			.charge_in(g4_inv_q),
			.signal_in(bpm2_q_reg_int),
			.delay_en(delay_en),
			.clk(clk),
			.store_strb(store_strb),
			.DSPout(pout4),
			.bunch_strb(bunch_strb)
			);


always @(posedge clk) begin
sum_all1<=pout+pout2;
sum_all2<=pout3+pout4;
//sum_all3<=sum_all1+sum_all2;		
end		

// ***** Clock DAC/Assign fb_sgnl *****

// Restricted by time taken for LUT
// Integrating more samples allows 2 cycles for LUT

// ***** Clk Counter after strobe *****
(* equivalent_register_removal = "no"*) reg [7:0] j;   // leave at 10
always @ (posedge clk) begin
if (~store_strb) j<=14;
else if (bunch_strb) j<=0;
else if (~bunch_strb) j<=j+1;
else j<=14;
end

always @ (posedge clk) begin
case (NO_SAMPLES)
	1: if (j==9) fb_sgnl <= sum_all1+sum_all2  ;
	2: if (j==8) fb_sgnl <= sum_all1+sum_all2 ;
	3: if (j==7) fb_sgnl <= sum_all1+sum_all2  ;
	default: if (j==6) fb_sgnl <= sum_all1+sum_all2  ;
endcase
end


endmodule

