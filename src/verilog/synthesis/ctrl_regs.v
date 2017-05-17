//****************** Control Register Assignments *************************

// Declare controls as named wires

//old 40 MHz
wire [1:0] bpm_sel;
wire [1:0] no_bunches;
wire [3:0] no_samples;
wire [7:0] sample_spacing;
wire [7:0] b1_strobe;
wire [7:0] b2_strobe;
wire 	[1:0]		p1_align_ch_sel;	
wire 	[1:0]		p2_align_ch_sel;
wire 	[1:0]		p3_align_ch_sel;
wire 	[6:0]		p1_offset_delay;
wire 	[6:0]		p2_offset_delay;
wire 	[6:0]		p3_offset_delay;
wire 	[5:0]		p1_scan_delay;
wire 	[5:0]		p2_scan_delay;
wire 	[5:0]		p3_scan_delay;
wire 	[5:0]		master357_delay;
wire 	[12:0]	k1_b2_offset;
//wire 	[12:0]	k1_b3_offset;
wire	[2:0]		diginput1_code;
wire	[2:0] 	diginput2_code;
/*wire  [6:0]    k1_fir_k1;
wire  [12:0]  	k2_b2_offset;
wire  [12:0]  	k2_b3_offset;
wire  [6:0]   	k2_fir_k1;
wire				k1_bunch_strb_sel;*/
wire [9:0] num_smpls;
wire [8:0] num_chans;
wire [7:0] trigSync_size;
wire use_trigSyncExt;
wire [1:0] cr_trig_max_cnt, cr_trig_seq_sel;
wire empty_trig_blk, trig_blk;
//wire run;
wire signed [6:0] ch1_IIRtapWeight;
wire signed [6:0] ch2_IIRtapWeight;
wire signed [6:0] ch3_IIRtapWeight;
wire signed [6:0] ch4_IIRtapWeight;
wire signed [6:0] ch5_IIRtapWeight;
wire signed [6:0] ch6_IIRtapWeight;
wire signed [6:0] ch7_IIRtapWeight;
wire signed [6:0] ch8_IIRtapWeight;
wire signed [6:0] ch9_IIRtapWeight;
wire signed [6:0] DAC1_IIRtapWeight;
wire signed [6:0] DAC2_IIRtapWeight;

wire [1:0] baud_rate;
//wire clkPLL_sel;


//wire IIRclr_en, IIRbypass;
wire [10:0] IIRbypass;
wire trig_int_en;
//wire fastClk_sel;
//wire				slow_clk_gate_en;
//wire	[5:0]		k1_bunch_strb_sel;
//wire	[5:0]		k2_bunch_strb_sel;

//old 357 MHz
//wire 	[6:0]		trig_delay;					
wire 	[6:0]		trig_out1_delay;		
wire 				trig_out_en;				
/*wire 	[7:0]		p1_bunch1pos;			
wire 	[7:0]		p1_bunch2pos;			
wire 	[7:0]		p1_bunch3pos;			
wire  [7:0]		p2_bunch1pos;			
wire 	[7:0]		p2_bunch2pos;			
wire 	[7:0]		p2_bunch3pos;		
wire 	[7:0]		p3_bunch1pos;		
wire 	[7:0]		p3_bunch2pos;			
wire 	[7:0]		p3_bunch3pos;*/			
wire 				k1_fb_on;				
//wire 				k2_fb_on;			
wire			 	k1_delayloop_on;			
//wire 				k2_delayloop_on; 		
wire 				k1_const_dac_en;			
/*wire 				k2_const_dac_en;			
wire 	[12:0]	k1_const_dac_out;		
wire  [12:0]	k2_const_dac_out;	*/	
wire 				cr_clk2_16_edge_sel;		
wire 	[6:0]		cr_sample_hold_off;
wire 	[11:0] 	cr_trig_delay;
wire 	[6:0]		trig_out2_delay;
//wire				sync_en;

wire FF_en, use_strbs, DAC1phase, DAC2phase, Interleave; 
//wire FF_en, use_strbs, DAC1phase, DAC2phase; 
wire [9:0] start_addr, end_addr;
wire [4:0] k1_del, k2_del;
wire [1:0] FFOpMode;
wire signed [12:0] k1_const, k2_const;
//wire signed [6:0] k1_gain, k2_gain;


assign bpm_sel=ctrl_regs[70][1:0];
assign no_bunches=ctrl_regs[70][3:2];
assign no_samples=ctrl_regs[71][3:0];
assign sample_spacing=ctrl_regs[67];
assign b1_strobe=ctrl_regs[68];
assign b2_strobe=ctrl_regs[69];

assign FF_en = ctrl_regs[43][0]; 
assign Interleave = ctrl_regs[43][1];
assign use_strbs = ctrl_regs[39][0]; 
assign start_addr = {ctrl_regs[40][3:0], ctrl_regs[39][6:1]};
assign end_addr = {ctrl_regs[41], ctrl_regs[40][6:4]};
assign k1_del = ctrl_regs[43][6:2];
assign k2_del = ctrl_regs[44][6:2];
//assign k1_del = ctrl_regs[43][6:1];
//assign k2_del = ctrl_regs[44][6:1];
//assign FFOpMode = ctrl_regs[44][0];
assign FFOpMode = ctrl_regs[44][1:0];
//sign k1_const = {ctrl_regs[46][5:0], ctrl_regs[45]};
//assign k2_const = {ctrl_regs[48][5:0], ctrl_regs[47]};
//assign k1_const = {ctrl_regs[86][5:0], ctrl_regs[87]};
//assign k2_const = {ctrl_regs[88][5:0], ctrl_regs[89]};

//assign k1_gain = ctrl_regs[49];
//assign k2_gain = ctrl_regs[50];
//assign DAC1phase = ctrl_regs[46][6];
//assign DAC2phase = ctrl_regs[48][6];
assign DAC1phase = ctrl_regs[86][6];
assign DAC2phase = ctrl_regs[88][6];


//Declare temporary wires for memory bit-selects
//wire [6:0] temp1, temp2, temp3, temp5, temp6, temp7, temp8, temp9, temp10;
//wire [6:0] temp11, temp12, temp14, temp15, temp16, temp17;
//wire [6:0] temp18, temp19, temp20, temp21, temp22, temp23, temp24, temp25, temp26, temp27, temp28, temp29, temp30; //, temp14;
//wire [6:0] temp30;
wire [6:0] temp27,temp28,temp11;
//assign temp1 = ctrl_regs[32];
assign p1_align_ch_sel = ctrl_regs[ADDROFF+32][1:0];
assign baud_rate = ctrl_regs[ADDROFF+32][3:2];
`ifdef CLK357_PLL
	wire clkPLL_sel = ctrl_regs[ADDROFF+32][4];
`endif
wire synch_en = ctrl_regs[ADDROFF+32][5];
wire sync_opMode = ctrl_regs[ADDROFF+32][6];
//assign temp2 = ctrl_regs[33];
assign p2_align_ch_sel = ctrl_regs[ADDROFF+33][1:0];
wire [1:0] sync_cnt_n = ctrl_regs[ADDROFF+33][3:2];
wire [1:0] sync_cnt_m = ctrl_regs[ADDROFF+33][5:4];
//assign temp3 = ctrl_regs[34];
assign p3_align_ch_sel = ctrl_regs[ADDROFF+34][1:0];
wire constDAC1UARTor = ctrl_regs[ADDROFF+34][2];
wire constDAC2UARTor = ctrl_regs[ADDROFF+34][3];


//assign temp5 = ctrl_regs[35];
assign p1_offset_delay = ctrl_regs[ADDROFF+35][6:0];
//assign temp6 = ctrl_regs[36];
assign p2_offset_delay = ctrl_regs[ADDROFF+36][6:0];
//assign temp7 = ctrl_regs[37];
assign p3_offset_delay = ctrl_regs[ADDROFF+37][6:0];

//assign temp8 = ctrl_regs[38];
assign p1_scan_delay = ctrl_regs[ADDROFF+38][5:0];
//assign temp9 = ctrl_regs[39];
assign p2_scan_delay = ctrl_regs[ADDROFF+39][5:0];
//assign temp10 = ctrl_regs[40];
assign p3_scan_delay = ctrl_regs[ADDROFF+40][5:0];

//assign temp17 = ctrl_regs[41];
assign master357_delay	= ctrl_regs[ADDROFF+41][5:0];
//
assign temp11 = ctrl_regs[ADDROFF+43];
assign k1_b2_offset = {temp11[5:0], ctrl_regs[ADDROFF+42]};

/*assign temp12 = ctrl_regs[45];
assign k1_b3_offset = {temp12[5:0], ctrl_regs[44]};*/

assign diginput1_code = ctrl_regs[ADDROFF+46][2:0];
assign diginput2_code = ctrl_regs[ADDROFF+47][2:0];

//assign temp13 = ctrl_regs[16];
/*assign k1_fir_k1 = ctrl_regs[48];

assign temp14 = ctrl_regs[50];
assign k2_b2_offset = {temp14[5:0], ctrl_regs[49]};
assign temp15 = ctrl_regs[52];
assign k2_b3_offset = {temp15[5:0], ctrl_regs[51]};
assign k2_fir_k1 = ctrl_regs[53];

assign temp16 = ctrl_regs[54];
assign k1_bunch_strb_sel = temp16[0];

*/

assign num_smpls = {ctrl_regs[ADDROFF+55], ctrl_regs[ADDROFF+56][6:4]};
assign num_chans = {ctrl_regs[ADDROFF+56][3:0], ctrl_regs[ADDROFF+57][6:2]};
assign trigSync_size = {ctrl_regs[ADDROFF+57][1:0], ctrl_regs[ADDROFF+58][6:1]};
assign use_trigSyncExt = ctrl_regs[ADDROFF+58][0];

assign cr_trig_seq_sel = ctrl_regs[ADDROFF+59][6:5];
assign cr_trig_max_cnt = ctrl_regs[ADDROFF+59][4:3];
assign trig_blk = ctrl_regs[ADDROFF+59][2];
assign empty_trig_blk = ctrl_regs[ADDROFF+59][1];
assign run = ctrl_regs[ADDROFF+59][0];

//assign IIRtapWeight = ctrl_regs[ADDROFF+60];
//assign trig_int_en = ctrl_regs[ADDROFF+61][0];
//assign IIRclr_en = ctrl_regs[61][0];
//assign IIRbypass = ctrl_regs[ADDROFF+61][1];
//assign fastClk_sel = ctrl_regs[ADDROFF+61][2];

`ifdef FASTCLK_INT
	assign fastClk_sel = ctrl_regs[51][0];
`endif
assign trig_int_en = ctrl_regs[51][1];
assign IIRbypass = {ctrl_regs[52][5:0], ctrl_regs[51][6:2]};


assign ch1_IIRtapWeight = ctrl_regs[53];
assign ch2_IIRtapWeight = ctrl_regs[54];
assign ch3_IIRtapWeight = ctrl_regs[55];
assign ch4_IIRtapWeight = ctrl_regs[56];
assign ch5_IIRtapWeight = ctrl_regs[57];
assign ch6_IIRtapWeight = ctrl_regs[58];
assign ch7_IIRtapWeight = ctrl_regs[59];
assign ch8_IIRtapWeight = ctrl_regs[60];
assign ch9_IIRtapWeight = ctrl_regs[61];
assign DAC1_IIRtapWeight = ctrl_regs[62];
assign DAC2_IIRtapWeight = ctrl_regs[63];


//assign temp17 = ctrl_regs[23];
//assign k2_bunch_strb_sel = temp17[5:0];

//assign temp17 = ctrl_regs[31];
//assign slow_clk_gate_en = temp17[0];

//wire [6:0] temp1, temp2, temp3, temp4, temp5, temp6, temp7, temp8, temp9, temp10, temp11, temp12, temp13;//, temp14;

//assign trig_delay = ctrl_regs[0];			
assign trig_out1_delay = ctrl_regs[ADDROFF+1];
//assign trig_out_en = (ctrl_regs[ADDROFF+2]==0) ? 0 : 1;
assign trig_out_en = ctrl_regs[ADDROFF+2][0];

/*assign temp18 = ctrl_regs[4];
assign p1_bunch1pos  = {temp18[0], ctrl_regs[3]};
assign temp19 = ctrl_regs[6];
assign p1_bunch2pos  = {temp19[0], ctrl_regs[5]};
assign temp20 = ctrl_regs[8];
assign p1_bunch3pos  = {temp20[0], ctrl_regs[7]};

assign temp21 = ctrl_regs[10];
assign p2_bunch1pos  = {temp21[0], ctrl_regs[9]};
assign temp22 = ctrl_regs[12];
assign p2_bunch2pos  = {temp22[0], ctrl_regs[11]};
assign temp23 = ctrl_regs[14];
assign p2_bunch3pos  = {temp23[0], ctrl_regs[13]};

assign temp24 = ctrl_regs[16];
assign p3_bunch1pos  = {temp24[0], ctrl_regs[15]};
assign temp25 = ctrl_regs[18];
assign p3_bunch2pos  = {temp25[0], ctrl_regs[17]};
assign temp26 = ctrl_regs[20];
assign p3_bunch3pos  = {temp26[0], ctrl_regs[19]};*/
		
assign temp27 = ctrl_regs[ADDROFF+21];
assign k1_fb_on = temp27[0];				
//assign k2_fb_on = temp27[1];	*/			
assign k1_delayloop_on = temp27[2];			
/*assign k2_delayloop_on = temp27[3]; */			
assign k1_const_dac_en = temp27[4];			
assign k2_const_dac_en = temp27[5];
			
assign temp28 = ctrl_regs[23];
//assign k1_const_dac_out	= {temp28[5:0], ctrl_regs[22]};
assign k1_const	= {temp28[5:0], ctrl_regs[22]};

/*assign temp29 = ctrl_regs[25];
assign k2_const_dac_out	= {temp29[5:0], ctrl_regs[24]};*/

//assign cr_clk2_16_edge_sel	= (ctrl_regs[ADDROFF+26]==0) ? 0 : 1;	
assign cr_clk2_16_edge_sel	= ctrl_regs[ADDROFF+26][0];	

assign cr_sample_hold_off = ctrl_regs[ADDROFF+27];

//assign temp30 = ctrl_regs[29];
assign cr_trig_delay = {ctrl_regs[ADDROFF+29][4:0], ctrl_regs[ADDROFF+28]};

assign trig_out2_delay = ctrl_regs[ADDROFF+30];

//assign temp14 = ctrl_regs[31];
//assign sync_en = temp14[0];

wire useDiode = ctrl_regs[ADDROFF+60][0];
wire [1:0] oflowMode = ctrl_regs[ADDROFF+60][2:1];
wire diodeGating = ctrl_regs[ADDROFF+60][3];
wire loop2_useDiode = ctrl_regs[ADDROFF+60][4];
wire loop2_diodeGating = ctrl_regs[ADDROFF+60][5];


wire [4:0] bank1_sr_tap = ctrl_regs[ADDROFF+61][4:0];
wire [4:0] bank2_sr_tap = ctrl_regs[ADDROFF+62][4:0];
wire [4:0] bank3_sr_tap = ctrl_regs[ADDROFF+63][4:0];

//wire [5:0] bank1_sr_tap = ctrl_regs[ADDROFF+61][5:0];
//wire [5:0] bank2_sr_tap = ctrl_regs[ADDROFF+62][5:0];
//wire [5:0] bank3_sr_tap = ctrl_regs[ADDROFF+63][5:0];

//wire signed [12:0] chan2_offset = {ctrl_regs[ADDROFF+43][5:0], ctrl_regs[ADDROFF+42]};
//wire signed [12:0] chan5_offset = {ctrl_regs[ADDROFF+50][5:0], ctrl_regs[ADDROFF+49]};

wire signed [12:0] chanOffset = {ctrl_regs[ADDROFF+2][6:1], ctrl_regs[ADDROFF+0]};
wire [3:0] chanOffsetSel = ctrl_regs[ADDROFF+26][6:3];

//wire signed [12:0] amp1lim = {ctrl_regs[ADDROFF+44][5:0], ctrl_regs[ADDROFF+45]};

///// GAIN STAGES //////

//   7-bit //

/*wire [6:0] k1_gain = ctrl_regs[49];
wire [6:0] k2_gain = ctrl_regs[50];
wire [6:0] loop2_k1_gain = ctrl_regs[37];
wire [6:0] loop2_k2_gain = ctrl_regs[38];*/

// 14-bit ////
`ifdef GAINRES_14
//wire [13:0] k1_gain = {ctrl_regs[49], ctrl_regs[86]};
//wire [13:0] k2_gain = {ctrl_regs[50], ctrl_regs[87]};
//wire [13:0] loop2_k1_gain = {ctrl_regs[37], ctrl_regs[88]};
//wire [13:0] loop2_k2_gain = {ctrl_regs[38], ctrl_regs[89]};
wire [13:0] k1_gain = {ctrl_regs[37], ctrl_regs[38]};
wire [13:0] k2_gain = {ctrl_regs[45], ctrl_regs[46]};
wire [13:0] loop2_k1_gain = {ctrl_regs[47], ctrl_regs[48]};
wire [13:0] loop2_k2_gain = {ctrl_regs[49], ctrl_regs[50]};
`else // 7-bit gain
//wire [6:0] k1_gain = ctrl_regs[49];
//wire [6:0] k2_gain = ctrl_regs[50];
//wire [6:0] loop2_k1_gain = ctrl_regs[37];
//wire [6:0] loop2_k2_gain = ctrl_regs[38];
wire [6:0] k1_gain = ctrl_regs[37];
wire [6:0] k2_gain = ctrl_regs[45];
wire [6:0] loop2_k1_gain = ctrl_regs[47];
wire [6:0] loop2_k2_gain = ctrl_regs[49];
`endif



