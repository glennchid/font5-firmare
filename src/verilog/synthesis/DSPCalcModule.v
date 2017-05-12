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
			input signed [14:0] signal_in,
			input delay_en,
			input clk,
			input store_strb,
			output reg signed [12:0] pout,
			input bunch_strb,
			input signed [12:0] banana_corr,
			output reg fb_cond
//			input fb_en
		
    );

(* equivalent_register_removal = "no"*) reg [7:0] j;

reg signed [36:0]  DSPtemp;
reg signed [12:0] DSPtemp2;
reg signed [12:0] delayed =0; 
//initial DSPout=0;
reg signed [36:0] DSPout;



always @ (posedge clk) begin
DSPtemp <= charge_in*signal_in;
//DSPtemp2=DSPtemp[24:12];   // Doesnt help timing!!!
DSPout <= DSPtemp+{delayed, 12'b0}; // Remove 4096 factor added for LUT // delayed 25 bits, 
pout<=DSPout[24:12];
end

//reg signed [10:0] banana_fract;
// ***** Clk Counter after strobe *****
// No. of samples after bunch strb
always @ (posedge clk) begin
if (~store_strb) begin
j<=7;       
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

reg [12:0] delayed_a;
always @ (posedge clk) begin
delayed<=delayed_a;
if (~store_strb) begin
delayed_a<=0;
end
else if (delay_en==1) begin
if (j==5) delayed_a<=pout+banana_corr[12:2];
end
end

//reg fb_cond2;

always @ (posedge clk) begin
if (j==3||j==4) fb_cond<=1;
else fb_cond<=0;
end

endmodule


