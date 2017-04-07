`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:05:35 06/18/2015 
// Design Name: 
// Module Name:    gainMult 
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
module normMult(
    input clk,
	 input useDiode,
	 input [1:0] oflowMode,
	 input signed [17:0] lutReg,
    input signed [15:0] mixerIn,
    //input signed [6:0] gain,
    input signed [13:0] gain,
    output reg signed [15:0] dout = 16'sd0,
    output reg overflow = 1'b0
    );

parameter GAIN_SCALE = 1; //sets the scale factor for the gain; e.g. 128 ADC cnts maps to 2048 at DAC for GAIN_SCALE = -4 //
parameter GAIN_OFFSET = 5; // maps ADC counts to DAC counts for the mid-range of the gain (i.e. 2^5 for 7-bit gain) // 7-bit gain //
parameter GAIN_MSB = 23;
parameter DIODE_SCALE = 4; // set to compensate the scale factor when using diode normalisation (eg. if diode =1000, sqrt(diode)~32, factor = 5 - 2 bits already included in LUT, -1 bit MSB)//


(* shreg_extract = "no" *) reg signed [15:0] mixerIn_reg = 16'sd0; // gainMult input register //
//(* shreg_extract = "no" *) reg signed [6:0] gain_reg = 7'sd0, gain_reg_b = 7'sd0; // 7-bit gain // gainMult input register //
(* shreg_extract = "no" *) reg signed [13:0] gain_reg = 14'sd0, gain_reg_b = 14'sd0; // 14-bit gain // gainMult input register //

//(* shreg_extract = "no" *) reg signed [13:0] gain_reg = 14'sd0; // 14-bit gain // gainMult input register //

//reg signed [GAIN_MSB:0] gainMult = 24'sd0; // GAIN_MSB+1'sd0, gainMult_a = GAIN_MSB+1'sd0, gainMult_b = GAIN_MSB+1'sd0, gainMult_c = GAIN_MSB+1'sd0; // 7-bit gain //
//reg signed [GAIN_MSB:0] gainMult = GAIN_MSB+1'sd0, gainMult_a = GAIN_MSB+1'sd0, gainMult_b = GAIN_MSB+1'sd0, gainMult_c = GAIN_MSB+1'sd0; // 7-bit gain //
reg signed [GAIN_MSB:0] gainMult = 31'sd0; // 14-bit gain //

wire gain_oflowDet = (~&gainMult[GAIN_MSB:GAIN_OFFSET+GAIN_SCALE+15] && ~&(~gainMult[GAIN_MSB:GAIN_OFFSET+GAIN_SCALE+15]));

(* equivalent_register_removal = "no", shreg_extract = "no" *) reg signed [17:0] lutReg_b = 18'sd0;
//(* shreg_extract = "no" *) reg signed [17:0] lutReg_c = 18'sd0; // normMult input register
(* shreg_extract = "no" *) reg signed [34:0] normMult = 35'sd0;//, normMult_reg = 35'sd0;
(* keep = "yes", shreg_extract = "no" *) reg signed [15:0] multReg = 16'sd0;//, multReg_b = 16'sd0;//, multReg_c = 16'sd0;
//(* shreg_extract = "no" *) reg signed [15:0] multReg = 16'sd0;//, multReg_b = 16'sd0;//, multReg_c = 16'sd0;

(* shreg_extract = "no" *) reg signed [15:0] multReg_b = 16'sd0;
(* shreg_extract = "no" *) reg signed [15:0] multReg_c = 16'sd0;


wire norm_oflowDet = (~&normMult[34:34-DIODE_SCALE] && ~&(~normMult[34:34-DIODE_SCALE]));
//wire [15:0] multReg;

always @(posedge clk) begin
	mixerIn_reg <= mixerIn; //mult input reg
	gain_reg <= gain; //mult input reg
	gain_reg_b <= gain_reg; // to stop tools packing synchroniser into DSP48 (NB "keep" atribute should also do the trick ...)
	//overflow <= gain_oflowDet || norm_oflowDet;
	gainMult <= (mixerIn_reg * gain_reg_b);
	//gainMult_a <= gainMult;
	//gainMult_b <= gainMult_a;
	//gainMult_c <= gainMult_b;
	if (gain_oflowDet) begin
		case (oflowMode)
		2'b00: multReg <= gainMult[GAIN_OFFSET+GAIN_SCALE+15:GAIN_OFFSET+GAIN_SCALE]; // do nothing - ignore overflow //
		2'b01: multReg <= 16'sd0; // kill output //
		2'b10: multReg <= (gainMult[GAIN_MSB]) ? -16'sd32768 : 16'sd32767; // saturate output //
		default: multReg <= 16'sd0;
		endcase 
	end else multReg <= gainMult[GAIN_OFFSET+GAIN_SCALE+15:GAIN_OFFSET+GAIN_SCALE];
end


//wire oflowDet;
//gainMult #(GAIN_SCALE, GAIN_OFFSET, GAIN_MSB) gainMult(clk, oflowMode, mixerIn, gain, multReg, oflowDet);

	
always @(posedge clk) begin	
	overflow <= gain_oflowDet || norm_oflowDet;
	//lutReg_b <= (useDiode) ? lutReg : {17'sd0, |lutReg}; //mult input reg
	//lutReg_c <= lutReg_b;
	multReg_b <= multReg;
	multReg_c <= multReg_b;
	lutReg_b <= lutReg;
	//if (useDiode) normMult <= (multReg_b * lutReg_b);
	//else normMult <= (multReg_b * |lutReg_b);
	normMult <= (multReg_c * lutReg_b);
	//if (useDiode) normMult <= (multReg * lutReg);
	//else normMult <= (multReg * |lutReg);
	//normMult_reg <= normMult;
	if (norm_oflowDet) begin
		case (oflowMode)
		2'b00: dout <= (useDiode) ? normMult[34-DIODE_SCALE:34-DIODE_SCALE-15] : normMult[15:0]; // do nothing - ignore overflow //
		2'b01: dout <= 16'sd0; // kill output //
		2'b10: dout <= (normMult[34]) ? -16'sd32768 : 16'sd32767; // saturate output //
		default: dout <= 16'sd0;
		endcase 
	end else dout <= (useDiode) ? normMult[34-DIODE_SCALE:34-DIODE_SCALE-15] : normMult[15:0];
	//dout <= (useDiode) ? normMult[34-DIODE_SCALE:34-DIODE_SCALE-15] : normMult[15:0];
end

endmodule
