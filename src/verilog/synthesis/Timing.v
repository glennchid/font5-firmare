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
		input [7:0] b1_strobe,
		input [7:0] b2_strobe,
		input [1:0] no_bunches,
		input [3:0] no_samples,
		input [7:0] sample_spacing,
		output reg LUTcond
		
    );


//parameter no_bunches=2;       
//parameter no_samples=1; 
//parameter sample_spacing=100;  // Number of samples between consecutive bunches

reg [4:0] bunch_counter=0;
initial bunch_strb=0;
(* equivalent_register_removal = "no"*) reg [7:0] i;
reg [7:0] start_bunch_strb=0;
reg [7:0] end_bunch_strb=0;
//reg LUTcond;


// ***** Generate bunch strobe *****
reg strbA = 1'b0, strbB = 1'b0, strbC = 1'b0;//, strbD =1'b0;

always @ (posedge clk) begin
strbA <= (b2_strobe==i);
strbB <= (b2_strobe+sample_spacing==i);
strbC <= (strbA || strbB);
//strbD <= strbC;
LUTcond <= strbC;
//LUTcond<=i==b2_strobe+3|| i== b2_strobe+sample_spacing+3;
if (store_strb) begin
i<=i+1;
end
else i<=0;
end


reg cond1,cond1_a, cond2, cond3;

always @ (posedge clk) begin
cond1_a<=bunch_counter==no_bunches; // If haven't exceeded number of bunches
cond1<=cond1_a;     
cond2<=i==start_bunch_strb;   // To send bunch strobe high
cond3<=i==end_bunch_strb;     // To send bunch strobe low

if (~store_strb) begin
bunch_counter<=0;
start_bunch_strb<=b1_strobe-1;
end_bunch_strb<=b1_strobe+no_samples-1; // Bunch strobe stays high for no_samples samples
end
else if (cond1) begin
end
else begin
if (cond2) bunch_strb<=1;
else if (cond3) begin
	bunch_strb<=0;
	bunch_counter<=bunch_counter+1;
	start_bunch_strb<=start_bunch_strb+sample_spacing;  // Calculate sample numbers for next bunch
	end_bunch_strb<=end_bunch_strb+sample_spacing;      // Calculate sample numbers for next bunch
end
end
end





endmodule
