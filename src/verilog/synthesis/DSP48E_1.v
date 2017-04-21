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
module DSP48E_1(
			input signed [20:0] charge_in,
			input signed [14:0] signal_in,
			input delay_en,
			input clk,
			input store_strb,
			output reg [12:0] DSPout,
			input bunch_strb
    );


(* equivalent_register_removal = "no"*) reg [7:0] j;

reg signed [47:0]  DSPout_temp, DSPout_temp2,DSPout_temp4,DSPout_temp5;
reg signed [47:0] delayed =48'b0; 
reg signed [47:0] delayed_a =48'b0; 
reg signed [47:0] delayed_b =48'b0; 
reg signed [12:0] DSPout_temp6;
//reg signed [47:0] delayed_c =48'b0; 
initial DSPout=0;
//reg signed [20:0] charge_in_a;
//reg signed [14:0] signal_in_a;

always @ (posedge clk) begin
if (delay_en==1 & j<14) begin
//charge_in_a<=charge_in;
//signal_in_a<=signal_in;
DSPout_temp <= (charge_in*signal_in);
DSPout_temp2<=DSPout_temp;
DSPout_temp4<=DSPout_temp2;
DSPout_temp5<=DSPout_temp4+delayed;
DSPout_temp6 <= DSPout_temp5[24:12];
DSPout<=DSPout_temp6;

end
else begin
//charge_in_a<=charge_in;
//signal_in_a<=signal_in;
DSPout_temp <= (charge_in*signal_in);
DSPout_temp2<=DSPout_temp;
DSPout_temp4<=DSPout_temp2;
DSPout_temp5<=DSPout_temp4;
DSPout_temp6 <= DSPout_temp5[24:12];
DSPout<=DSPout_temp6;
end
end


// ***** Clk Counter after strobe *****
always @ (posedge clk) begin
//j<=j_a;
if (~bunch_strb) j<=j+1;
else j<=0;
end

always @ (posedge clk) begin
delayed<=delayed_a;
delayed_a<=delayed_b;
if (~store_strb) begin
delayed_b<=0;
end
else if (j==1) delayed_b<=DSPout_temp5;
else delayed_b<=delayed_b;
end

endmodule
