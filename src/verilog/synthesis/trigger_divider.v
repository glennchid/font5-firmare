`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    02:39:57 10/12/2010 
// Design Name: 
// Module Name:    trigger_divider 
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
module trigger_divider(
    input clk,
    input trig_ext,
	 input trig_int,
	 input trig_int_en,
	 input empty_trig_blk,
	 input trig_blk,
    input [1:0] trig_max_cnt,
    input [1:0] trig_seq_sel,
	 input pulse_ctr_rst_b,
	 input run,
	 input trig_rdy,
    output reg trig_out = 1'b0,
	//output reg trig_strb
	 output reg trig_strb = 1'b0,
	 output reg [5:0] pulse_ctr = 6'd0,
	 output reg pile_up
    );

// Input trigger and signals from UART are all async 
(* ASYNC_REG = "TRUE" *) reg trig_blk_a = 1'b0, trig_blk_b = 1'b0;
(* ASYNC_REG = "TRUE" *) reg empty_trig_blk_a = 1'b0, empty_trig_blk_b = 1'b0;
(* IOB = "TRUE" *) reg trig_a = 1'b0;
(* ASYNC_REG = "TRUE" *) reg trig_b = 1'b0, trig_c = 1'b0;
reg trig_d = 1'b0;
(* ASYNC_REG = "TRUE" *) reg [1:0] trig_max_cnt_a = 2'd0, trig_max_cnt_b = 2'd0;
(* ASYNC_REG = "TRUE" *) reg [1:0] trig_seq_sel_a= 2'd0, trig_seq_sel_b = 2'd0;
(* ASYNC_REG = "TRUE" *) reg trig_int_en_a = 1'b0, trig_int_en_b = 1'b0;
(* ASYNC_REG = "TRUE" *) reg pulse_ctr_rst= 1'b0, pulse_ctr_rst_a = 1'b0;
wire trig_mux = (trig_int_en_b) ? trig_int : trig_b;
(* ASYNC_REG = "TRUE" *) reg trig_rdy_a= 1'b0, trig_rdy_b = 1'b0;
reg trig_rdy_c= 1'b0;
(* ASYNC_REG = "TRUE" *) reg run_a = 1'b0, run_b  = 1'b0;
reg blocked = 1'b0;
//wire unblock;
//wire trig_edge;
reg trig_edge = 1'b0;

`define TRIG_DISARM

reg disarm = 1'b0;
`ifdef TRIG_DISARM // dis-arm trigger for ~700 ns following trigger edge
	localparam DISARM_TC = 9'd511;
	reg [7:0] trig_arm_ctr = 8'd0;
	
	
	always @(posedge clk) begin
		if (disarm) begin
			trig_arm_ctr <= trig_arm_ctr + 1'b1;
			disarm <= (DISARM_TC == trig_arm_ctr) ? 1'b0 : disarm;
		end else begin
			trig_arm_ctr <= trig_arm_ctr;
			disarm <= trig_edge;
		end
	end
`endif
			
always @(posedge clk) begin
	run_a <= run;
	run_b <= run_a; //OK for logic
	trig_rdy_a <= trig_rdy;
	trig_rdy_b <= trig_rdy_a; // OK for logic
	trig_rdy_c <= trig_rdy_b; //back end
	//trig_rdy_d <= trig_rdy_c;
	trig_int_en_a <= trig_int_en;
	trig_int_en_b <= trig_int_en_a;
	trig_blk_a <= trig_blk;
	trig_blk_b <= trig_blk_a;
	empty_trig_blk_a <= empty_trig_blk;
	empty_trig_blk_b <= empty_trig_blk_a;
	trig_a <= trig_ext;
	trig_b <= trig_a;
	trig_c <= trig_mux; //can be used in logical expressions
	trig_d <= trig_c; //back end
	trig_max_cnt_a <= trig_max_cnt;
	trig_max_cnt_b <= trig_max_cnt_a;
	trig_seq_sel_a <= trig_seq_sel;
	trig_seq_sel_b <= trig_seq_sel_a;
end

//trigger counter
reg [1:0] trig_ctr = 2'd0;

always @(posedge clk) begin
	if (trig_edge && (trig_ctr==trig_max_cnt_b)) trig_ctr <= 0;
	else if (trig_edge) trig_ctr <= trig_ctr + 1'b1;
	else trig_ctr <= trig_ctr;
	
	//if ((trig_blk_b) begin
	if (blocked || ~run_b) begin
		trig_strb <= 1'b0;
		trig_out <= 1'b0;
		end
	else begin
		//trig_strb <= (trig_ctr==trig_seq_sel_b) ? 1'b1 : 1'b0; //signal to send to FB/FF loops - always just the real data
		trig_strb <= (trig_ctr==trig_seq_sel_b) ? trig_edge : 1'b0; //signal to send to FB/FF loops - always just the real data
		//if (~empty_trig_blk_b || trig_ctr==trig_seq_sel_b) trig_out <= trig_edge; // send trig on to DAQ
		//else trig_out <= 1'b0;
		trig_out <= (~empty_trig_blk_b || trig_ctr==trig_seq_sel_b) ? trig_edge : 1'b0; // send trig on to DAQ
		end
		
//	if (trig_out) blocked <= 1'b1;
//	else if (trig_rdy_b && ~trig_rdy_c) blocked <= 1'b0;
//	else blocked <= blocked;

	
	if (trig_rdy_b & ~trig_rdy_c) blocked <= 1'b0;
	//if (unblock) blocked <= 1'b0;
	else if (trig_out && trig_blk_b) blocked <= 1'b1;
	else blocked <= blocked;

end

//wire trig_rdy_
	
//assign trig_edge = (disarm) ? 1'b0: trig_c & ~trig_d;
//assign unblock = trig_rdy_c & ~ trig_rdy_d;

//pulse counter
always @(posedge clk) begin
	trig_edge <= (disarm) ? 1'b0 : trig_c & ~trig_d;
	// NB pile_up needs re-writing - logic for blocked and pile_up should be the same
	if (trig_edge) pile_up <= (trig_rdy_c) ? 1'b0 : 1'b1;
	else pile_up <= pile_up;
	
	pulse_ctr_rst <= pulse_ctr_rst_a;
	pulse_ctr_rst_a <= pulse_ctr_rst_b;
	if (pulse_ctr_rst) pulse_ctr <= 6'd0;
	else if (trig_edge) pulse_ctr <= pulse_ctr + 1'b1;
	else pulse_ctr <= pulse_ctr;
	end

endmodule
