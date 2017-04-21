`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:58:59 04/05/2017 
// Design Name: 
// Module Name:    Timing 
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
module Timing(
		output reg bunch_strb,
		input store_strb,
		input clk,
		input [9:0] b1_strobe
//		input [10:0] NO_BUNCHES,
//		input [10:0] NO_SAMPLES,
//		input [10:0] SAMPLE_SPACING
    );

reg [4:0] bunch_counter=0;
parameter NO_BUNCHES=2;       
parameter NO_SAMPLES=1; 
parameter SAMPLE_SPACING=100;
initial bunch_strb=0;
(* equivalent_register_removal = "no"*) reg [9:0] i;
reg [10:0] start_bunch_strb=0;
reg [10:0] end_bunch_strb=0;
//reg [31:0] NO_BUNCHES, NO_SAMPLES, SAMPLE_SPACING;
//reg bunch_strb_a;
// ***** Generate bunch strobe *****

always @ (posedge clk) begin
if (store_strb) begin
i<=i+1;
end
else i<=0;
end


reg cond1,cond1_a, cond2, cond3;


always @ (posedge clk) begin
cond1_a<=bunch_counter==NO_BUNCHES;
cond1<=cond1_a;
cond2<=i==start_bunch_strb;
cond3<=i==end_bunch_strb;

if (~store_strb) begin
bunch_counter<=0;
start_bunch_strb<=b1_strobe-2;
end_bunch_strb<=b1_strobe+NO_SAMPLES-2;
end
else if (cond1) begin
end
else begin
if (cond2) bunch_strb<=1;
else if (cond3) begin
	bunch_strb<=0;
	bunch_counter<=bunch_counter+1;
	start_bunch_strb<=start_bunch_strb+SAMPLE_SPACING;
	end_bunch_strb<=end_bunch_strb+SAMPLE_SPACING;
end
end
end





endmodule
