module FFControl (
	input clk,
	input store_strb,
	input feedfwd_en_b,
	//input Interleave_b,
	input use_strobes_b,
	input [9:0] start_proc_b,
	input [9:0] end_proc_b,
	input [4:0] kick1_delay_b,
	input [4:0] kick2_delay_b,
	//input [3:0] offset_delay, //what is this? and why 4 bit (16)? // This is possibly to account for differences in timing of the DAQ RAMs relative to the data - better implemented with a fixed parametrer?
	//input constDac_en,
	input [1:0] opMode_b, //0 = sample-by-sample, 1 = constant DAC, 2 = Pulse mean removal //
	input signed [12:0] kick1_constDac_val_b,
	input signed [12:0] kick2_constDac_val_b,
	input signed [12:0] diodeIn,
	input signed [12:0] mixerIn,
	input signed [6:0] kick1_gain_b,
	input signed [6:0] kick2_gain_b,
	input DAC1clkPhase_b,
	input DAC2clkPhase_b,
	input oflowClr,
	input signed [6:0] DAC1_IIRtapWeight, DAC2_IIRtapWeight,
	//input [1:0] IIRbypass,
	//input [3:0] leftShift,
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

// This module is the main module for forming the phase signal to drive the amplifier.  Any operation on the data common to both amplifier paths should be included here, for example, it will also contain additional features such as a combiner module for use with combined beam and (rolling) averaging. It instances two DriveOuput modules, one for each amplifier, which control the amplifiers with independant timing, gain, and droop characteristics. //

//reg signed [17:0] mem [-4096:4095]; //signed
wire signed [17:0] lutReg;
//(* shreg_extract = "no" *) reg signed [17:0] lutReg_a = 18'sd0, lutReg_b = 18'sd0, lutReg_c = 18'sd0;
(* shreg_extract = "no" *) reg signed [17:0] lutReg_b = 18'sd0;
//(* shreg_extract = "no" *) reg signed [12:0] mixerInReg_a = 13'sd0, mixerInReg_b = 13'sd0, mixerInReg_c = 13'sd0, mixerInReg_d = 13'sd0, diodeInReg = 13'sd0; 
//(* shreg_extract = "no" *) reg signed [12:0] mixerInReg_a = 13'sd0, mixerInReg_b = 13'sd0, mixerInReg_c = 13'sd0; 
(* shreg_extract = "no" *) reg signed [24:0] mixerInReg_a = 25'sd0, mixerInReg_b = 25'sd0, mixerInReg_c = 25'sd0; 
//Note re RAM sizes - needs to be optimised. Why was 18bit chosesn (native BRAM size?), and cut at 100? Also, check size in FBFW - 28 apparently!
(* shreg_extract = "no" *) reg signed [43:0] mult = 44'sd0, multReg = 44'sd0; // NB: The multiplier output only needs to be 30 bits (+ 1 for overflow detection) as the Diode signal is capped at 100 cnts.
//reg signed [47:0] mult = 48'sd0; // NB: The multiplier output only needs to be 30 bits (+ 1 for overflow detection) as the Diode signal is capped at 100 cnts.
//reg signed [19:0] mixerIn_LS = 20'sd0;
//parameter leftShift = 2'd3; //Need to determine max LS size - need overflow protection up to this size! Now max is 11, and all bits checked for oflow?! um! check this! 2 x 2 2's'comp
//parameter leftShift = 2'd0; //Need to determine max LS size - need overflow protection up to this size! Now max is 11, and all bits checked for oflow?! um! check this! 2 x 2 2's'comp
parameter leftShift = 3'd6; //Need to determine max LS size - need overflow protection up to this size! Now max is 11, and all bits checked for oflow?! um! check this! 2 x 2 2's'comp

//initial 
//begin
//	$readmemb("data.dat", mem, -4096, 4095); //signed
//end

//Instance LUTROM BRAM core
LUTROM LUT1(
	.clka(clk),
	.addra(diodeIn),
	.douta(lutReg)
	);

//Double synchronisers for async UART inputs
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
	(* shreg_extract = "no" *) reg signed [6:0] kick1_gain = 7'd32, kick1_gain_a = 7'd32;
	(* shreg_extract = "no" *) reg signed [6:0] kick2_gain = 7'd32, kick2_gain_a = 7'd32;
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
	(* shreg_extract = "no" *) reg signed [6:0] kick1_gain = 7'd0, kick1_gain_a = 7'd0;
	(* shreg_extract = "no" *) reg signed [6:0] kick2_gain = 7'd0, kick2_gain_a = 7'd0;
	(* shreg_extract = "no" *) reg DAC1clkPhase = 1'b0, DAC1clkPhase_a = 1'b0;
	(* shreg_extract = "no" *) reg DAC2clkPhase = 1'b0, DAC2clkPhase_a = 1'b0;
`endif
//(* shreg_extract = "no" *) reg Interleave, Interleave_a;
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
	DAC1clkPhase <= DAC1clkPhase_a;
	DAC1clkPhase_a <= DAC1clkPhase_b;
	DAC2clkPhase <= DAC2clkPhase_a;
	DAC2clkPhase_a <= DAC2clkPhase_b;
	//Interleave <= Interleave_a;
	//Interleave_a <= Interleave_b;	
end
	
//multiply mixer signal by Inverse
always @(posedge clk) begin
	//mixerIn_LS <= (mixerIn <<< leftShift);
	//mixerInReg_d <= mixerInReg_c;
	mixerInReg_c <= mixerInReg_b; // PIPELINE ? no mult input reg
	mixerInReg_b <= mixerInReg_a;
	mixerInReg_a <= (mixerIn <<< leftShift); //matching delay for LUT
	//diodeInReg <= diodeIn;
	//lutReg_c <= lutReg_b;
	lutReg_b <= lutReg; //PIPELINE? no mult input reg
	//lutReg_a <= mem[diodeInReg]; //for sim? to match delays?
	//mult <= (mixerIn * mem[diodeIn]);
	mult <= (mixerInReg_c * lutReg_b);
	//multReg <= (mult <<< leftShift);
	multReg <= mult;
	//mult <= (mixerIn * lutReg) <<< leftShift;
	if (oflowDetect && oflowClr) oflowDetect <= 1'b0;
	else if (!(&multReg[43:29] || &(~multReg[43:29]))) oflowDetect <= 1'b1; //check for all ones or all zeros in overflow bits
	//else if (!(&mult[47:29] || &(~mult[47:29]))) oflowDetect <= 1'b1; //check for all ones or all zeros in overflow bits
	else oflowDetect <= oflowDetect;
	//dout <= mult >> 20;
end

// Instance the DriveOutput modules //
//DriveOutput kick1Drive(clk, store_strb, feedfwd_en, use_strobes, start_proc, end_proc, kick1_delay, opMode, kick1_constDac_val, multReg[29:0], kick1_gain, DAC1clkPhase, kick1_dout, DAC1_en);
//DriveOutput kick2Drive(clk, store_strb, feedfwd_en, use_strobes, start_proc, end_proc, kick2_delay, opMode, kick2_constDac_val, multReg[29:0], kick2_gain, DAC2clkPhase, kick2_dout, DAC2_en);
//DriveOutput kick1Drive(clk, store_strb, feedfwd_en, use_strobes, start_proc, end_proc, kick1_delay, opMode, kick1_constDac_val, multReg[29:5], kick1_gain, DAC1clkPhase, DAC1_IIRtapWeight, IIRbypass[0], kick1_dout, DAC1_en);
//DriveOutput kick2Drive(clk, store_strb, feedfwd_en, use_strobes, start_proc, end_proc, kick2_delay, opMode, kick2_constDac_val, multReg[29:5], kick2_gain, DAC2clkPhase, DAC2_IIRtapWeight, IIRbypass[1], kick2_dout, DAC2_en);
DriveOutput kick1Drive(clk, store_strb, feedfwd_en, use_strobes, start_proc, end_proc, kick1_delay, opMode, kick1_constDac_val, multReg[29:5], kick1_gain, DAC1clkPhase, DAC1_IIRtapWeight, kick1_dout, DAC1_en);//, kick3_dout, DAC3_en);
DriveOutput kick2Drive(clk, store_strb, feedfwd_en, use_strobes, start_proc, end_proc, kick2_delay, opMode, kick2_constDac_val, multReg[29:5], kick2_gain, DAC2clkPhase, DAC2_IIRtapWeight, kick2_dout, DAC2_en);//, kick4_dout, DAC4_en);
//DriveOutput kick1Drive(clk, store_strb, feedfwd_en, use_strobes, start_proc, end_proc, kick1_delay, opMode, kick1_constDac_val, multReg[27:3], kick1_gain, DAC1clkPhase, DAC1_IIRtapWeight, kick1_dout, DAC1_en);
//DriveOutput kick2Drive(clk, store_strb, feedfwd_en, use_strobes, start_proc, end_proc, kick2_delay, opMode, kick2_constDac_val, multReg[27:3], kick2_gain, DAC2clkPhase, DAC2_IIRtapWeight, kick2_dout, DAC2_en);
//DriveOutput kick1Drive(clk, store_strb, feedfwd_en, use_strobes, start_proc, end_proc, kick1_delay, opMode, kick1_constDac_val, mult[29:5], kick1_gain, DAC1clkPhase, kick1_dout, DAC1_en);
//DriveOutput kick2Drive(clk, store_strb, feedfwd_en, use_strobes, start_proc, end_proc, kick2_delay, opMode, kick2_constDac_val, mult[29:5], kick2_gain, DAC2clkPhase, kick2_dout, DAC2_en);

endmodule

