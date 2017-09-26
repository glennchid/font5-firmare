//****************** Control Register Assignments *************************

//********* FONT5_base common CRs *****************************//

wire Interleave = ctrl_regs[43][1];
`ifdef FASTCLK_INT
	wire fastClk_sel = ctrl_regs[51][0];
`endif
wire trig_int_en = ctrl_regs[51][1];
wire [10:0] IIRbypass = {ctrl_regs[52][5:0], ctrl_regs[51][6:2]};
`ifdef LUTRAMreadout
	wire LUTRAMreadout = ctrl_regs[52][6];
`endif
wire signed [6:0] ch1_IIRtapWeight = ctrl_regs[53];
wire signed [6:0] ch2_IIRtapWeight = ctrl_regs[54];
wire signed [6:0] ch3_IIRtapWeight = ctrl_regs[55];
wire signed [6:0] ch4_IIRtapWeight = ctrl_regs[56];
wire signed [6:0] ch5_IIRtapWeight = ctrl_regs[57];
wire signed [6:0] ch6_IIRtapWeight = ctrl_regs[58];
wire signed [6:0] ch7_IIRtapWeight = ctrl_regs[59];
wire signed [6:0] ch8_IIRtapWeight = ctrl_regs[60];
wire signed [6:0] ch9_IIRtapWeight = ctrl_regs[61];
wire signed [12:0] chanOffset = {ctrl_regs[ADDROFF+2][6:1], ctrl_regs[ADDROFF+0]};
wire 	[6:0] trig_out1_delay = ctrl_regs[ADDROFF+1];
wire trig_out_en = ctrl_regs[ADDROFF+2][0];
wire signed [12:0] k1_const = {ctrl_regs[86][5:0], ctrl_regs[87]};
wire signed [12:0] k2_const = {ctrl_regs[88][5:0], ctrl_regs[89]};
wire cr_clk2_16_edge_sel	= ctrl_regs[ADDROFF+26][0];
wire [3:0] chanOffsetSel = ctrl_regs[ADDROFF+26][6:3];
wire [6:0] cr_sample_hold_off = ctrl_regs[ADDROFF+27];
wire [11:0] cr_trig_delay = {ctrl_regs[ADDROFF+29][4:0], ctrl_regs[ADDROFF+28]};
wire [6:0] trig_out2_delay = ctrl_regs[ADDROFF+30];
wire [1:0] p1_align_ch_sel = ctrl_regs[ADDROFF+32][1:0];
wire [1:0] baud_rate = ctrl_regs[ADDROFF+32][3:2];
`ifdef CLK357_PLL
	wire clkPLL_sel = ctrl_regs[ADDROFF+32][4];
`endif
wire synch_en = ctrl_regs[ADDROFF+32][5];
wire sync_opMode = ctrl_regs[ADDROFF+32][6];
wire [1:0] p2_align_ch_sel = ctrl_regs[ADDROFF+33][1:0];
wire [1:0] sync_cnt_n = ctrl_regs[ADDROFF+33][3:2];
wire [1:0] sync_cnt_m = ctrl_regs[ADDROFF+33][5:4];
wire [1:0] p3_align_ch_sel = ctrl_regs[ADDROFF+34][1:0];
wire constDAC1UARTor = ctrl_regs[ADDROFF+34][2];
wire constDAC2UARTor = ctrl_regs[ADDROFF+34][3];
wire 	[6:0] p1_offset_delay = ctrl_regs[ADDROFF+35][6:0];
wire 	[6:0] p2_offset_delay = ctrl_regs[ADDROFF+36][6:0];
wire 	[6:0] p3_offset_delay = ctrl_regs[ADDROFF+37][6:0];
wire 	[5:0] p1_scan_delay = ctrl_regs[ADDROFF+38][5:0];
wire 	[5:0] p2_scan_delay = ctrl_regs[ADDROFF+39][5:0];
wire 	[5:0] p3_scan_delay = ctrl_regs[ADDROFF+40][5:0];
wire 	[5:0] master357_delay	= ctrl_regs[ADDROFF+41][5:0];
wire	[2:0] diginput1_code = ctrl_regs[ADDROFF+46][2:0];
wire	[2:0] diginput2_code = ctrl_regs[ADDROFF+47][2:0];
wire [9:0] num_smpls = {ctrl_regs[ADDROFF+55], ctrl_regs[ADDROFF+56][6:4]};
wire [8:0] num_chans = {ctrl_regs[ADDROFF+56][3:0], ctrl_regs[ADDROFF+57][6:2]};
wire [7:0] trigSync_size = {ctrl_regs[ADDROFF+57][1:0], ctrl_regs[ADDROFF+58][6:1]};
wire use_trigSyncExt = ctrl_regs[ADDROFF+58][0];
wire [1:0] cr_trig_seq_sel = ctrl_regs[ADDROFF+59][6:5];
wire [1:0] cr_trig_max_cnt = ctrl_regs[ADDROFF+59][4:3];
wire trig_blk = ctrl_regs[ADDROFF+59][2];
wire empty_trig_blk = ctrl_regs[ADDROFF+59][1];
assign run = ctrl_regs[ADDROFF+59][0]; // declared as top-level output
wire [4:0] bank1_sr_tap = ctrl_regs[ADDROFF+61][4:0];
wire [4:0] bank2_sr_tap = ctrl_regs[ADDROFF+62][4:0];
wire [4:0] bank3_sr_tap = ctrl_regs[ADDROFF+63][4:0];

//****************** CTF3-PFF CRs ***********************//
`ifdef BUILD_CTF
	wire use_strbs = ctrl_regs[39][0]; 
	wire [9:0] start_addr = {ctrl_regs[40][3:0], ctrl_regs[39][6:1]};
	wire [9:0] end_addr = {ctrl_regs[41], ctrl_regs[40][6:4]};
	wire FF_en = ctrl_regs[43][0]; 
	wire [4:0] k1_del = ctrl_regs[43][6:2];
	wire [1:0] FFOpMode = ctrl_regs[44][1:0];
	wire [4:0] k2_del = ctrl_regs[44][6:2];
	///// GAIN STAGES ////// - macro may now be redundant!!!
	`ifdef GAINRES_14 // 14-bit gain
		wire signed [13:0] k1_gain = {ctrl_regs[37], ctrl_regs[38]};
		wire signed [13:0] k2_gain = {ctrl_regs[45], ctrl_regs[46]};
		wire signed [13:0] loop2_k1_gain = {ctrl_regs[47], ctrl_regs[48]};
		wire signed [13:0] loop2_k2_gain = {ctrl_regs[49], ctrl_regs[50]};
	`else // 7-bit gain
		wire signed [6:0] k1_gain = ctrl_regs[37];
		wire signed [6:0] k2_gain = ctrl_regs[45];
		wire signed [6:0] loop2_k1_gain = ctrl_regs[47];
		wire signed [6:0] loop2_k2_gain = ctrl_regs[49];
`endif
wire signed [6:0] DAC1_IIRtapWeight = ctrl_regs[62];
wire signed [6:0] DAC2_IIRtapWeight = ctrl_regs[63];
wire DAC1phase = ctrl_regs[86][6];
wire DAC2phase = ctrl_regs[88][6];
wire useDiode = ctrl_regs[ADDROFF+60][0];
wire [1:0] oflowMode = ctrl_regs[ADDROFF+60][2:1];
wire diodeGating = ctrl_regs[ADDROFF+60][3];
wire loop2_useDiode = ctrl_regs[ADDROFF+60][4];
wire loop2_diodeGating = ctrl_regs[ADDROFF+60][5];
`endif
//****************** ATF2-FB CRs ************************//
`ifdef BUILD_ATF
	/*
	wire [1:0] bpm_sel=ctrl_regs[70][1:0]; // move to CR90 [2:1]
	wire [1:0] no_bunches=ctrl_regs[70][3:2]; // suggest constant =1
	wire [3:0] no_samples=ctrl_regs[71][3:0]; // suggest use CR124 [3:0]
	wire [7:0] sample_spacing=ctrl_regs[67]; // suggest constant - not needed for 2 bunch!
	wire [7:0] b1_strobe=ctrl_regs[68]; //use p1b1
	wire [7:0] b2_strobe=ctrl_regs[69]; //use p3sum(ch9)b1
	*/
	wire [1:0] bpm_sel=ctrl_regs[90][2:1];
	wire [1:0] no_bunches=ctrl_regs[124][5:4];
	wire [7:0] sample_spacing={ctrl_regs[124][6], ctrl_regs[118]};
	//localparam [1:0] no_bunches = 2'd1; //124
	//localparam [7:0] sample_spacing = 8'd100; //124 + 118
	wire [3:0] no_samples = ctrl_regs[124][3:0]; //124
	wire 	[7:0] b1_strobe = {ctrl_regs[ADDROFF+4][0], ctrl_regs[ADDROFF+3]};
	wire 	[7:0] b2_strobe = {ctrl_regs[ADDROFF+20][0], ctrl_regs[ADDROFF+19]};

	wire FF_en = ctrl_regs[ADDROFF+21][0];				
	//wire k2_fb_on = ctrl_regs[ADDROFF+21][1];	
	wire k1_delayloop_on = ctrl_regs[ADDROFF+21][2];			
	//wire k2_delayloop_on = ctrl_regs[ADDROFF+21][3];	
	wire k1_const_dac_en = ctrl_regs[ADDROFF+21][4];			
	//wire k2_const_dac_en = ctrl_regs[ADDROFF+21][5];
	wire 	[12:0] k1_b2_offset = {ctrl_regs[ADDROFF+43][5:0], ctrl_regs[ADDROFF+42]};
`endif

//*************** Legacy ATF CRs (Reserved) *************//

/*
wire 	[7:0] p1_bunch1pos  = {ctrl_regs[4][0], ctrl_regs[3]};
wire 	[7:0] p1_bunch2pos  = {ctrl_regs[6][0], ctrl_regs[5]};
wire 	[7:0] p1_bunch3pos  = {ctrl_regs[8][0], ctrl_regs[7]};
wire 	[7:0] p2_bunch1pos  = {ctrl_regs[10][0], ctrl_regs[9]};
wire 	[7:0] p2_bunch2pos  = {ctrl_regs[12][0], ctrl_regs[11]};
wire 	[7:0] p2_bunch3pos  = {ctrl_regs[14][0], ctrl_regs[13]};
wire 	[7:0] p3_bunch1pos  = {ctrl_regs[16][0], ctrl_regs[15]};
wire 	[7:0] p3_bunch2pos  = {ctrl_regs[18][0], ctrl_regs[17]};
wire 	[7:0] p3_bunch3pos  = {ctrl_regs[20][0], ctrl_regs[19]};
wire 	[12:0] k1_b3_offset = {ctrl_regs[45][5:0], ctrl_regs[44]};
wire  [6:0] k1_fir_k1 = ctrl_regs[48];
wire  [12:0] k2_b2_offset = {ctrl_regs[50][5:0], ctrl_regs[49]};
wire  [12:0] k2_b3_offset = {ctrl_regs[52][5:0], ctrl_regs[51]};
wire  [6:0] k2_fir_k1 = ctrl_regs[53];
wire k1_bunch_strb_sel = ctrl_regs[54][0];
*/
//wire signed [12:0] amp1lim = {ctrl_regs[ADDROFF+44][5:0], ctrl_regs[ADDROFF+45]};