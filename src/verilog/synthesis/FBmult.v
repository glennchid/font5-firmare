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
module FBmult #(parameter NUM_SMPLS_INTEG = 4) (
			input clk,
			input signed [20:0] charge_in,
			input signed [14:0] signal_in,
			input delay_en,
			input store_strb,
			input bunch_strb,
			output reg signed [12:0] DSPout = 13'sd0
    );


(* equivalent_register_removal = "no"*) reg [7:0] sample_ctr; //j

reg signed [47:0] FBmult_m = 48'sd0, FBmult_p =48'sd0;
reg signed [15:0] delayed = 16'sd0;//, delayed_reg = 16'sd0;

reg updateDelay = 1'b0;


always @ (posedge clk) begin

	updateDelay <= (delay_en && sample_ctr == bunch_strb + NUM_SMPLS_INTEG - 1'b1);

	if (store_strb) begin

		sample_ctr <= (bunch_strb) ? 8'd0 : sample_ctr + 1'b1;
		
		FBmult_m <= charge_in*signal_in;
		//FBmult_p <= FBmult_m + delayed_reg;
		FBmult_p <= FBmult_m + {delayed, 9'd0};
		DSPout <= FBmult_p[24:12];

		delayed <= (updateDelay) ? FBmult_p[24:9] : delayed;
		//delayed_reg <= delayed;
		
			
	end else begin
		sample_ctr <= 8'd0;
		FBmult_m <= 48'd0;
		FBmult_p <= 48'd0;
		DSPout <= 48'd0;
		delayed <= 16'd0;
	end

end

endmodule
