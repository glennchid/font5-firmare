`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:31:46 04/05/2017 
// Design Name: 
// Module Name:    DSP48E_1 
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
module DSPCalcModule(
			input signed [20:0] charge_in,
			input signed [16:0] signal_in,
			input delay_en,
			input clk,
			input store_strb,
			output reg signed [14:0] pout,
			input bunch_strb,
			output reg DSPoflow,
//			input signed [12:0] banana_corr,
			output reg fb_cond,
			output reg dac_clk
			
//			input fb_en
		
    );

(* equivalent_register_removal = "no"*) reg [7:0] j;

reg signed [37:0]  DSPtemp;
//reg signed [14:0] DSPtemp2;
reg signed [14:0] delayed; 
//initial DSPout=0;
reg signed [37:0] DSPout;
//reg DSPoflow=1'b0;


always @ (posedge clk) begin
DSPtemp <= charge_in*signal_in;
//DSPtemp2=DSPtemp[24:12];   // Doesnt help timing!!!
DSPout <= DSPtemp+{delayed, 12'b0}; // Remove 4096 factor added for LUT // delayed 25 bits, 
pout<=DSPout[26:12];
DSPoflow<=(~&DSPout[37:26] && ~&(~DSPout[37:26]));
end

//reg signed [10:0] banana_fract;
// ***** Clk Counter after strobe *****
// No. of samples after bunch strb
always @ (posedge clk) begin
if (~store_strb) begin
j<=10;       
 end
else if (bunch_strb) begin j<=0;
//banana_fract<=banana_corr[12:2];    /// Bring in as 13 bit and pad with zeros to 25 bits
end
else if (~bunch_strb) begin
j<=j+1;
end
//else j<=10;
end

//reg [47:0] banana_corr_48=0;


// If more than two bunches multiplex to add banana correction
//k1_b2_offset

reg [14:0] delayed_a;
always @ (posedge clk) begin
delayed<=delayed_a; // add banana here
if (~store_strb) begin
delayed_a<=0;
end
else if (delay_en==1) begin
if (j==4) delayed_a<=pout;
end
end

//reg fb_cond2;

always @ (posedge clk) begin
if (j==2||j==3) fb_cond<=1;
else fb_cond<=0;
end

always @ (posedge clk) begin
if (j==6||j==7) dac_clk<=1;
else dac_clk<=0;
end

endmodule


