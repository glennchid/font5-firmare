module PFF_DSP_16 (
	input clk,
	input store_strb,
	input feedfwd_en_b,
	input useDiode_b, loop2_useDiode_b,
	input diodeGating_b, loop2_diodeGating_b,
	input use_strobes_b,
	input [9:0] start_proc_b,
	input [9:0] end_proc_b,
	input [4:0] kick1_delay_b,
	input [4:0] kick2_delay_b,
	input [1:0] opMode_b, //0 = sample-by-sample, 1 = constant DAC, 2 = Pulse mean removal //
	input [1:0] oflowMode_b, // 0 = ignore, 1 = kill output, 2 = saturate output, 3 = undefined (default to 2) //
	input signed [12:0] diodeIn, loop2_diodeIn,
	input signed [15:0] mixerIn, loop2_mixerIn,
	input signed [12:0] kick1_constDac_val_b,
	input signed [12:0] kick2_constDac_val_b,
	//input signed [6:0] kick1_gain_b, loop2_kick1_gain_b,
	//input signed [6:0] kick2_gain_b, loop2_kick2_gain_b,
	input signed [13:0] kick1_gain_b, loop2_kick1_gain_b,
	input signed [13:0] kick2_gain_b, loop2_kick2_gain_b,
	input DAC1clkPhase_b,
	input DAC2clkPhase_b,
	input oflowClr,
	input signed [6:0] DAC1_IIRtapWeight, DAC2_IIRtapWeight,
	//input [1:0] IIRbypass,
	output reg oflowDetect = 1'b0,
	output signed [12:0] kick1_dout,
	output signed [12:0] kick2_dout,
	//output signed [12:0] kick3_dout,
	//output signed [12:0] kick4_dout,
	output DAC1_en,
	output DAC2_en
	//output DAC3_en,
	//output DAC4_en
);

parameter GAIN_SCALE = -4; //sets the scale factor for the gain; e.g. 128 ADC cnts maps to 2048 at DAC for GAIN_SCALE = -4 //
//parameter GAIN_OFFSET = 5; // maps ADC counts to DAC counts for the mid-range of the gain (i.e. 2^5 for 7-bit gain) // 7-bit gain //
parameter GAIN_OFFSET = 12; // maps ADC counts to DAC counts for the mid-range of the gain (i.e. 2^5 for 7-bit gain) // 14-bit gain //
//parameter GAIN_MSB = 23; // 7-bit gain // sets the MSB of the gain multipication (i.e. 16-bit x 7-bit = 23-bit + 1 bit for overflow detection = 24-bit) //
parameter GAIN_MSB = 30; // 14-bit gain // sets the MSB of the gain multipication (i.e. 16-bit x 14-bit = 30-bit + 1 bit for overflow detection = 31-bit) //

parameter DIODE_SCALE = 4; // set to compensate the scale factor when using diode normalisation (eg. if diode =1000, sqrt(diode)~32, factor = 5 - 2 bits already included in LUT, -1 bit MSB)//

// This module is the main module for forming the phase signal to drive the amplifier.  Any operation on the data common to both amplifier paths should be included here, for example, it will also contain additional features such as a combiner module for use with combined beam and (rolling) averaging. It instances two DriveOuput modules, one for each amplifier, which control the amplifiers with independant timing, gain, and droop characteristics. //

//Instance LUTROM BRAM core
wire signed [17:0] lutReg;
LUTROM LUT1(
	.clka(clk),
	.addra(diodeIn),
	.douta(lutReg)
	);
	

//Note re RAM sizes - needs to be optimised. Why was 18bit chosesn (native BRAM size?), and cut at 100? Also, check size in FBFW - 28 apparently!
	
//Dual-FF synchronisers for asynchronous UART inputs
(* shreg_extract = "no" *) reg useDiode = 1'b0, useDiode_a = 1'b0;
(* shreg_extract = "no" *) reg diodeGating = 1'b0, diodeGating_a = 1'b0;
(* shreg_extract = "no" *) reg loop2_useDiode = 1'b0, loop2_useDiode_a = 1'b0;
(* shreg_extract = "no" *) reg loop2_diodeGating = 1'b0, loop2_diodeGating_a = 1'b0;
(* shreg_extract = "no" *) reg [1:0] oflowMode = 2'd0, oflowMode_a = 2'd0;
(* keep = "yes", shreg_extract = "no" *) reg signed [17:0] lutReg_b = 18'sd0, loop2_lutReg_b = 18'sd0;
(* shreg_extract = "no" *) reg signed [17:0] lutReg_c = 18'sd0, loop2_lutReg_c = 18'sd0;

wire signed [17:0] loop2_lutReg;

`ifdef XILINX_ISIM
	(* shreg_extract = "no" *) reg feedfwd_en = 1'b1, feedfwd_en_a = 1'b1;
	(* shreg_extract = "no" *) reg use_strobes = 1'b1, use_strobes_a = 1'b1;
	(* shreg_extract = "no" *) reg [9:0] start_proc = 10'd0, start_proc_a = 10'd0;
	(* shreg_extract = "no" *) reg [9:0] end_proc = 10'd164, end_proc_a = 10'd164;
	(* shreg_extract = "no" *) reg [4:0] kick1_delay = 5'd0, kick1_delay_a = 5'd0;
	(* shreg_extract = "no" *) reg [4:0] kick2_delay = 5'd0, kick2_delay_a= 5'd0;
	(* shreg_extract = "no" *) reg [1:0] opMode = 2'd0, opMode_a = 2'd0;
	(* shreg_extract = "no" *) reg signed [12:0] kick1_constDac_val = 13'd0, kick1_constDac_val_a = 13'd0;
	(* shreg_extract = "no" *) reg signed [12:0] kick2_constDac_val = 13'd0, kick2_constDac_val_a = 13'd0;
//	(* shreg_extract = "no" *) reg signed [6:0] kick1_gain = 7'd63, kick1_gain_a = 7'd63;
//	(* shreg_extract = "no" *) reg signed [6:0] kick2_gain = 7'd32, kick2_gain_a = 7'd32;
//	(* shreg_extract = "no" *) reg signed [6:0] loop2_kick1_gain = 7'd63, loop2_kick1_gain_a = 7'd63;
//	(* shreg_extract = "no" *) reg signed [6:0] loop2_kick2_gain = 7'd32, loop2_kick2_gain_a = 7'd32;
	(* shreg_extract = "no" *) reg signed [13:0] kick1_gain = 14'd0, kick1_gain_a = 14'd0;
	(* shreg_extract = "no" *) reg signed [13:0] kick2_gain = 14'd0, kick2_gain_a = 14'd0;
	(* shreg_extract = "no" *) reg signed [13:0] loop2_kick1_gain = 14'd0, loop2_kick1_gain_a = 14'd0;
	(* shreg_extract = "no" *) reg signed [13:0] loop2_kick2_gain = 14'd0, loop2_kick2_gain_a = 14'd0;
	(* shreg_extract = "no" *) reg DAC1clkPhase = 1'b0, DAC1clkPhase_a = 1'b0;
	(* shreg_extract = "no" *) reg DAC2clkPhase = 1'b0, DAC2clkPhase_a = 1'b0;
`else
	(* shreg_extract = "no" *) reg feedfwd_en = 1'b0, feedfwd_en_a = 1'b0;
	(* shreg_extract = "no" *) reg use_strobes = 1'b0, use_strobes_a = 1'b0;
	(* shreg_extract = "no" *) reg [9:0] start_proc = 10'd0, start_proc_a = 10'd0;
	(* shreg_extract = "no" *) reg [9:0] end_proc = 10'd0, end_proc_a = 10'd0;
	(* shreg_extract = "no" *) reg [4:0] kick1_delay = 5'd0, kick1_delay_a = 5'd0;
	(* shreg_extract = "no" *) reg [4:0] kick2_delay = 5'd0, kick2_delay_a= 5'd0;
	(* shreg_extract = "no" *) reg [1:0] opMode = 2'd0, opMode_a = 2'd0;
	(* shreg_extract = "no" *) reg signed [12:0] kick1_constDac_val = 13'd0, kick1_constDac_val_a = 13'd0;
	(* shreg_extract = "no" *) reg signed [12:0] kick2_constDac_val = 13'd0, kick2_constDac_val_a = 13'd0;
//	(* shreg_extract = "no" *) reg signed [6:0] kick1_gain = 7'd0, kick1_gain_a = 7'd0;
//	(* shreg_extract = "no" *) reg signed [6:0] kick2_gain = 7'd0, kick2_gain_a = 7'd0;
//	(* shreg_extract = "no" *) reg signed [6:0] loop2_kick1_gain = 7'd0, loop2_kick1_gain_a = 7'd0;
//	(* shreg_extract = "no" *) reg signed [6:0] loop2_kick2_gain = 7'd0, loop2_kick2_gain_a = 7'd0;
	(* shreg_extract = "no" *) reg signed [13:0] kick1_gain = 14'd0, kick1_gain_a = 14'd0;
	(* shreg_extract = "no" *) reg signed [13:0] kick2_gain = 14'd0, kick2_gain_a = 14'd0;
	(* shreg_extract = "no" *) reg signed [13:0] loop2_kick1_gain = 14'd0, loop2_kick1_gain_a = 14'd0;
	(* shreg_extract = "no" *) reg signed [13:0] loop2_kick2_gain = 14'd0, loop2_kick2_gain_a = 14'd0;
	(* shreg_extract = "no" *) reg DAC1clkPhase = 1'b0, DAC1clkPhase_a = 1'b0;
	(* shreg_extract = "no" *) reg DAC2clkPhase = 1'b0, DAC2clkPhase_a = 1'b0;
`endif

always @(posedge clk) begin
	feedfwd_en <= feedfwd_en_a;
	feedfwd_en_a <= feedfwd_en_b;
	use_strobes <= use_strobes_a;
	use_strobes_a <= use_strobes_b;
	start_proc <= start_proc_a;
	start_proc_a <= start_proc_b;
	end_proc <= end_proc_a;
	end_proc_a <= end_proc_b;
	kick1_delay <= kick1_delay_a;
	kick1_delay_a <= kick1_delay_b;
	kick2_delay <= kick2_delay_a;
	kick2_delay_a <= kick2_delay_b;	
	opMode <= opMode_a;
	opMode_a <= opMode_b;
	kick1_constDac_val <= kick1_constDac_val_a;
	kick1_constDac_val_a <= kick1_constDac_val_b;
	kick2_constDac_val <= kick2_constDac_val_a;
	kick2_constDac_val_a <= kick2_constDac_val_b;
	kick1_gain <= kick1_gain_a;
	kick1_gain_a <= kick1_gain_b;
	kick2_gain <= kick2_gain_a;
	kick2_gain_a <= kick2_gain_b;
	loop2_kick1_gain <= loop2_kick1_gain_a;
	loop2_kick1_gain_a <= loop2_kick1_gain_b;
	loop2_kick2_gain <= loop2_kick2_gain_a;
	loop2_kick2_gain_a <= loop2_kick2_gain_b;
	DAC1clkPhase <= DAC1clkPhase_a;
	DAC1clkPhase_a <= DAC1clkPhase_b;
	DAC2clkPhase <= DAC2clkPhase_a;
	DAC2clkPhase_a <= DAC2clkPhase_b;
	useDiode <= useDiode_a;
	useDiode_a <= useDiode_b;
	diodeGating <= diodeGating_a;
	diodeGating_a <= diodeGating_b;
	loop2_useDiode <= loop2_useDiode_a;
	loop2_useDiode_a <= loop2_useDiode_b;
	loop2_diodeGating <= loop2_diodeGating_a;
	loop2_diodeGating_a <= loop2_diodeGating_b;
	oflowMode <= oflowMode_a;
	oflowMode_a <= oflowMode_b;
	if (diodeGating) lutReg_b <= (useDiode) ? lutReg : {17'sd0, |lutReg};
	else lutReg_b <= (useDiode) ? lutReg : 18'sd1;
	//lutReg_b <= (useDiode) ? lutReg : {17'sd0, (use_strobes) ? 1'b1 : |lutReg};
	if (loop2_diodeGating) loop2_lutReg_b <= (loop2_useDiode) ? loop2_lutReg : {17'sd0, |loop2_lutReg};
	else loop2_lutReg_b <= (loop2_useDiode) ? loop2_lutReg : 18'sd1;
	lutReg_c <= lutReg_b;
	loop2_lutReg_c <= loop2_lutReg_b;
	end
	
// Apply Kicker 1 Gain
wire signed [15:0] kick1_gainMult;
wire kick1_oflowDet;
normMult #(GAIN_SCALE, GAIN_OFFSET, GAIN_MSB, DIODE_SCALE) kick1Mult(clk, useDiode, oflowMode, lutReg_c, mixerIn, kick1_gain, kick1_gainMult, kick1_oflowDet);
	
// Apply Kicker 2 Gain
wire signed [15:0] kick2_gainMult;
wire kick2_oflowDet;
normMult #(GAIN_SCALE, GAIN_OFFSET, GAIN_MSB, DIODE_SCALE) kick2Mult(clk, useDiode, oflowMode, lutReg_c, mixerIn, kick2_gain, kick2_gainMult, kick2_oflowDet);
	

///////// LOOP2 ////////////////////////////////////////// - use a define include statement and compare timings with/without 2nd loop ....

parameter LOOP2_GAIN_SCALE = -4; //sets the scale factor for the gain; e.g. 128 ADC cnts maps to 2048 at DAC for GAIN_SCALE = -4 //
//parameter LOOP2_GAIN_OFFSET = 5; // maps ADC counts to DAC counts for the mid-range of the gain (i.e. 2^5 for 7-bit gain) // 7-bit gain //
parameter LOOP2_GAIN_OFFSET = 12; // maps ADC counts to DAC counts for the mid-range of the gain (i.e. 2^5 for 7-bit gain) // 14-bit gain //
//parameter LOOP2_GAIN_MSB = 23; // 7-bit gain // sets the MSB of the gain multipication (i.e. 16-bit x 7-bit = 23-bit + 1 bit for overflow detection = 24-bit) //
parameter LOOP2_GAIN_MSB = 30; // 14-bit gain // sets the MSB of the gain multipication (i.e. 16-bit x 7-bit = 23-bit + 1 bit for overflow detection = 24-bit) //

parameter LOOP2_DIODE_SCALE = 4; // set to compensate the scale factor when using diode normalisation (eg. if diode =1000, sqrt(diode)~32, factor = 5 - 2 bits already included in LUT, -1 bit MSB)//

//Instance LUTROM BRAM core
LUTROM LUT2(
	.clka(clk),
	.addra(loop2_diodeIn),
	.douta(loop2_lutReg)
	);

// Apply Kicker 1 Gain
wire signed [15:0] loop2_kick1_gainMult;
wire loop2_kick1_oflowDet;
normMult #(LOOP2_GAIN_SCALE, LOOP2_GAIN_OFFSET, LOOP2_GAIN_MSB, LOOP2_DIODE_SCALE) loop2_kick1Mult(clk, loop2_useDiode, oflowMode, loop2_lutReg_c, loop2_mixerIn, loop2_kick1_gain, loop2_kick1_gainMult, loop2_kick1_oflowDet);
	
// Apply Kicker 2 Gain
wire signed [15:0] loop2_kick2_gainMult;
wire loop2_kick2_oflowDet;
normMult #(LOOP2_GAIN_SCALE, LOOP2_GAIN_OFFSET, LOOP2_GAIN_MSB, LOOP2_DIODE_SCALE) loop2_kick2Mult(clk, loop2_useDiode, oflowMode, loop2_lutReg_c, loop2_mixerIn, loop2_kick2_gain, loop2_kick2_gainMult, loop2_kick2_oflowDet);

///////////////// END LOOP2 /////////////////////////////////



/*always @(posedge clk) begin
	multReg <= mult;
	if (oflowDetect && oflowClr) oflowDetect <= 1'b0;
	else if (!(&multReg[43:29] || &(~multReg[43:29]))) oflowDetect <= 1'b1; //check for all ones or all zeros in overflow bits
	else oflowDetect <= oflowDetect;
end*/

//Combinatorial always block for ampDrive input signals
//wire signed [16:0] kick1_drive = kick1_gainMult + loop2_kick1_gainMult;
reg signed [16:0] kick1_drive = 17'sd0;//kick1_gainMult + loop2_kick1_gainMult;

reg signed [15:0] kick1_drive_b = 16'sd0;
//wire signed [16:0] kick2_drive = kick2_gainMult + loop2_kick2_gainMult;
reg signed [16:0] kick2_drive = 17'sd0;//kick2_gainMult + loop2_kick2_gainMult;
reg signed [15:0] kick2_drive_b = 16'sd0;
reg kick1_drive_oflowDet = 1'b0, kick2_drive_oflowDet = 1'b0;

always @(posedge clk) begin
	kick1_drive <= kick1_gainMult + loop2_kick1_gainMult;
	kick2_drive <= kick2_gainMult + loop2_kick2_gainMult;
	end

always @(*) begin
	if (^kick1_drive[16:15]) begin
		kick1_drive_oflowDet = 1'b1;
		(* full_case, parallel_case *) 
		case(oflowMode)
		2'b00: kick1_drive_b = kick1_drive[15:0];
		2'b01: kick1_drive_b = 16'sd0;
		2'b10: kick1_drive_b = (kick1_drive[16]) ? -16'sd32768 : 16'sd32767;
		//default: kick1_drive_b = 16'sd0;
		endcase
	end else begin 
		kick1_drive_b = kick1_drive[15:0];
		kick1_drive_oflowDet = 1'b0;
		end
end

/*always @(posedge clk) begin
	//kick1_drive <= kick1_gainMult + loop2_kick1_gainMult;
	if (^kick1_drive[16:15]) begin
		kick1_drive_oflowDet <= 1'b1;
		(* full_case, parallel_case *)
		case(oflowMode)
		2'b00: kick1_drive_b <= kick1_drive[15:0];
		2'b01: kick1_drive_b <= 16'sd0;
		2'b10: kick1_drive_b <= (kick1_drive[16]) ? -16'sd32768 : 16'sd32767;
		default: kick1_drive_b <= 16'sd0;
		endcase
	end else begin 
		kick1_drive_b <= kick1_drive[15:0];
		kick1_drive_oflowDet <= 1'b0;
		end
end*/

always @(*) begin
	if (^kick2_drive[16:15]) begin
		kick2_drive_oflowDet = 1'b1;
		(* full_case, parallel_case *) 
		case(oflowMode)
		2'b00: kick2_drive_b = kick2_drive[15:0];
		2'b01: kick2_drive_b = 16'sd0;
		2'b10: kick2_drive_b = (kick2_drive[16]) ? -16'sd32768 : 16'sd32767;
		//default: kick2_drive_b = 16'sd0;
		endcase
	end else begin
	kick2_drive_b = kick2_drive[15:0];
	kick2_drive_oflowDet = 1'b0;
	end
end
	
/*always @(posedge clk) begin
	//kick2_drive <= kick2_gainMult + loop2_kick2_gainMult;
	if (^kick2_drive[16:15]) begin
		kick2_drive_oflowDet <= 1'b1;
		(* full_case, parallel_case *)
		case(oflowMode)
		2'b00: kick2_drive_b <= kick2_drive[15:0];
		2'b01: kick2_drive_b <= 16'sd0;
		2'b10: kick2_drive_b <= (kick2_drive[16]) ? -16'sd32768 : 16'sd32767;
		default: kick2_drive_b <= 16'sd0;
		endcase
	end else begin
	kick2_drive_b <= kick2_drive[15:0];
	kick2_drive_oflowDet <= 1'b0;
	end
end*/

// Instance the DriveOutput modules //
ampDrive kick1Drive(clk, store_strb, feedfwd_en, use_strobes, start_proc, end_proc, kick1_delay, opMode, kick1_constDac_val, kick1_drive_b, DAC1clkPhase, DAC1_IIRtapWeight, kick1_dout, DAC1_en);//, kick3_dout, DAC3_en);
ampDrive kick2Drive(clk, store_strb, feedfwd_en, use_strobes, start_proc, end_proc, kick2_delay, opMode, kick2_constDac_val, kick2_drive_b, DAC2clkPhase, DAC2_IIRtapWeight, kick2_dout, DAC2_en);//, kick4_dout, DAC4_en);

reg kick1_oflowDet_a = 1'b0, kick2_oflowDet_a = 1'b0;
always @(posedge clk) begin
	kick1_oflowDet_a <= kick1_oflowDet;
	kick2_oflowDet_a <= kick2_oflowDet;
	oflowDetect <= (kick1_oflowDet_a | kick2_oflowDet_a | loop2_kick1_oflowDet | loop2_kick2_oflowDet | kick1_drive_oflowDet | kick2_drive_oflowDet);
end


endmodule

