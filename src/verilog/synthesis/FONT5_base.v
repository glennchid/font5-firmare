`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 	   John Adams Institute at the University of Oxford
// Engineer: 	   Glenn Christian
// 
// Create Date:    09:24:59 10/24/2009 
// Design Name:	   font5-firmware
// Module Name:    FONT5_base 
// Project Name:   font5_base
// Target Devices: xc5vlx50t-3ff1136
// Tool versions:  Xilinx ISE14.7
// Description:    Pseudo top-level for the FONT5 digital signal processing gateware
//
// Dependencies: 
//

//
//////////////////////////////////////////////////////////////////////////////////
module FONT5_base(
`ifdef	XILINX_ISIM	
		output store_strb,
`endif
		//Inputs from top level wrapper
		input clk357, 
		input clk40,
		input clk40_ibufg, 
		input signed [12:0] ch1_data_in_del, 
		input signed [12:0] ch2_data_in_del, 
		input signed [12:0] ch3_data_in_del, 
		input signed [12:0] ch4_data_in_del, 
		input signed [12:0] ch5_data_in_del, 
		input signed [12:0] ch6_data_in_del, 
		input signed [12:0] ch7_data_in_del, 
		input signed [12:0] ch8_data_in_del, 
		input signed [12:0] ch9_data_in_del, 
		input rs232_in, 
		//Inputs/Outputs to top level pins
		//output amp_trig,
		//output amp_trig2,
		(* IOB = "TRUE" *) output reg adc_powerdown = 1'b1, 
		(* shreg_extract = "no" *) output reg iddr_ce = 1'b0,
		//output dcm200_rst, //output to xlnx
		output signed [12:0] dac1_out,
		output dac1_clk,	
		output signed [12:0] dac2_out,
		output dac2_clk,
//		output signed [12:0] dac3_out,
//		output dac3_clk,	
//		output signed [12:0] dac4_out,
//		output dac4_clk,
		//(* IOB = "TRUE" *) output reg [12:0] dac1_out,
		//(* IOB = "TRUE" *) output reg dac1_clk,	
		//(* IOB = "TRUE" *) output reg [12:0] dac2_out,
		//(* IOB = "TRUE" *) output reg dac2_clk,
		//(* IOB = "TRUE" *) output reg [12:0] dac3_out,
		//(* IOB = "TRUE" *) output reg dac3_clk,
		//(* IOB = "TRUE" *) output reg [12:0] dac4_out,
		//(* IOB = "TRUE" *) output reg dac4_clk,
		output rs232_out, 
		(* IOB = "TRUE" *) output reg led0_out, 
		(* IOB = "TRUE" *) output reg led1_out, 
		(* IOB = "TRUE" *) output reg led2_out, 
		output trim_cs_ld, 
		output trim_sck, 
		output trim_sdi, 
		(* IOB = "TRUE" *) output reg diginput1A, 
		(* IOB = "TRUE" *) output reg diginput1B, 
		input diginput1, 
		(* IOB = "TRUE" *) output reg diginput2A, 
		(* IOB = "TRUE" *) output reg diginput2B,
		input diginput2, 
		//(* IOB = "TRUE" *) output reg auxOutA,
		output reg auxOutA,
		//output auxOutA,
		//(* IOB = "TRUE" *) output reg auxOutB,
		output reg auxOutB,
		//output diginput2_loopback, //For monitoring digital input
		//Internal control I/Os to top level
		input dcm200_locked, //input to top
		output reg clk_blk = 1'b0, //output to xlnx
		input idelayctrl_rdy, //input to top
		output clk357_idelay_ce, //output to xlnx
		output clk357_idelay_rst, //output to xlnx
		output idelay_rst, //output to xlnx
		`ifdef FASTCLK_INT
			input dcm360_locked, //input to top
			output fastClk_sel, //output to xlnx
		`endif
		`ifdef CLK357_PLL
			output dcm200_rst, //output to xlnx
			input pll_clk357_locked, //input to top
			output reg clkPLL_sel_a, //output to xlnx
		`endif
		output run, //output to xlnx
		output delay_calc_strb1, //output to xlnx from ADC_block
		output delay_calc_strb2, //output to xlnx from ADC_block
		output delay_calc_strb3, //output to xlnx from ADC_block
		output delay_trig1, //output to xlnx from top (UART decoder)
		output delay_trig2, //output to xlnx from top (UART decoder)
		output delay_trig3, //output to xlnx from top (UART decoder)
		output adc1_drdy_delay_ce, //output to xlnx from ADC_block
		output adc2_drdy_delay_ce, //output to xlnx from ADC_block
		output adc3_drdy_delay_ce, //output to xlnx from ADC_block
		output adc1_clk_delay_ce, //output to xlnx from ADC_block
		output adc2_clk_delay_ce, //output to xlnx from ADC_block
		output adc3_clk_delay_ce, //output to xlnx from ADC_block
		output adc1_data_delay_ce, //output to xlnx from ADC_block
		output adc2_data_delay_ce, //output to xlnx from ADC_block
		output adc3_data_delay_ce, //output to xlnx from ADC_block
		input IDDR1_Q1, //input to top (to Alignment monitors via ADC block)
		input IDDR1_Q2, //input to top (to Alignment monitors via ADC block)
		input IDDR2_Q1, //input to top (to Alignment monitors via ADC block)
		input IDDR2_Q2, //input to top (to Alignment monitors via ADC block)
		input IDDR3_Q1, //input to top (to Alignment monitors via ADC block)
		input IDDR3_Q2, //input to top (to Alignment monitors via ADC block)
		//inout DirectIO1 //Bi-directional I/O port for synchronisation
		output DirIOB,
		input auxInA,
		output auxOutC
    );

//parameters and defintions
parameter DSP_WIDTH = 16;
//`include "font5_base_top.vh"
`include "definitions.vh"
//`define INCLUDE_TESTBENCH

//`define DOUBLE_CONTROL_REGS

//`define ADDPIPEREGS

//`define DISABLE_AUXOUTS;

//`define LOAD_ATF_DEFAULTS
`define LOAD_ATF_DEFAULTS


`ifdef DOUBLE_CONTROL_REGS
	parameter N_CTRL_REGS = 128;
	parameter CR_WIDTH = 7;
	parameter ADDROFF = 64;
`else
	parameter N_CTRL_REGS = 64;
	parameter CR_WIDTH = 6;
	parameter ADDROFF = 0;
`endif
reg [CR_WIDTH-1:0] ctrl_regs [0:N_CTRL_REGS-1];
reg [CR_WIDTH-1:0] ctrl_regs_mem [0:N_CTRL_REGS-1];

//`include "H:\Firmware\FONT5_base\sources\verilog\ctrl_regs.v"
`include "ctrl_regs.v"
//`ifdef XILINX_ISIM 
//	`include "H:\Firmware\FONT5_base\sources\verilog\ctrl_regs_init_sim.v"
//`else 
//	`include "H:\Firmware\FONT5_base\sources\verilog\ctrl_regs_init.v"
//`endif

/*`ifdef LOAD_ATF_DEFAULTS
	`include "H:\Firmware\FONT5_base\sources\verilog\ctrl_regs_init_ATF.v"	
`else
	`ifdef LOAD_CTF_DEFAULTS
		`include "H:\Firmware\FONT5_base\sources\verilog\ctrl_regs_init_CTF.v"
	`else
		`include "H:\Firmware\FONT5_base\sources\verilog\ctrl_regs_init.v"
	`endif
`endif*/
`ifdef LOAD_ATF_DEFAULTS
	`include "ctrl_regs_init_ATF.v"	
`else
	`ifdef LOAD_CTF_DEFAULTS
		`include "ctrl_regs_init_CTF.v"
	`else
		`include "ctrl_regs_init.v"
	`endif
`endif

//Instantiate USR_ACCESS register

//wire [31:0] usr_access;

   // USR_ACCESS_VIRTEX5: Configuration Data Memory Access Port
   //                     Virtex-5
   // Xilinx HDL Language Template, version 13.2

/*   USR_ACCESS_VIRTEX5 USR_ACCESS_VIRTEX5_inst (
      .CFGCLK(),      // 1-bit configuration clock output
      .DATA(usr_access),          // 32-bit config data output
      .DATAVALID() // 1-bit data valid output
   );*/

   // End of USR_ACCESS_VIRTEX5_inst instantiation


// %%%%%%%%%%%   WIRE DIGITAL INPUT TO TRIGGER LOOPBACK   %%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

wire clk2_16_ext = (use_trigSyncExt) ? diginput1 : 1'b0;
wire trig = diginput2;
//assign diginput2_loopback = diginput2;
//wire diginput2_loopback = diginput2;
//assign auxOutA = diginput2;



// **** Reset controller ****
// Deals with resetting DCM, idelayctrl and iodelay elements
wire full_rst_trig;
reset_ctrl reset_ctrl1(
	.clk40(clk40_ibufg),
	.idelay_rst_trig(1'b0),				//Always perform a full DCM reset
	.full_rst_trig(full_rst_trig),
	.dcm_rst(dcm200_rst),
	.idelay_rst(idelay_rst)
);

wire rst_state;
reset_detector reset_detector1(clk40, dcm200_rst, rst_state);

//always @(posedge clk2_16_tmp) clk_align <= (clk357_delayed) ? 1 : 0;


// **** incrementor for 357MHz IODELAY ****
wire [5:0] clk357_idelay_value;
wire [5:0] clk357_idelay_mon;
wire		  clk357_idelay_trig;
iodelay_incrementor clk357_idelay_inc(
	.clk40(clk40),
	.rst(clk357_idelay_rst | idelay_rst),
	.count_trig(clk357_idelay_trig),
	.spec_delay(clk357_idelay_value),
	.inc_en(clk357_idelay_ce),
	.actual_delay(clk357_idelay_mon)
);

// *** Instantiate Internal Testbench ***//

/*wire auxOut_en;
`ifdef DISABLE_AUXOUTS assign auxOut_en = 1'b0;
`else assign auxOut_en = 1'b1;
`endif*/


/*reg auxOutA_a, auxOutB_a;
always @(posedge clk357) begin
	auxOutA <= auxOutA_a;
	auxOutB <= auxOutB_a;
	end*/
	
`ifdef INCLUDE_TESTBENCH
	wire tb_trigOut, tb_dataOut;
	supply0 gnd;
	always @(posedge clk357) begin
		//auxOutA <= tb_trigOut;
		//auxOutA <= diginput2_loopback;
		//auxOutA <= (auxOut_en) ? gnd : 1'bz;
		//auxOutB <= (auxOut_en) ? tb_dataOut : 1'bz;
		auxOutA <=  gnd;
		auxOutB <= tb_dataOut;
		//auxOutB <= gnd;
		end
	bench #(
		.MAX_CNT(21'd1402596),
		.RING_CLK_HOLDOFF(8'd82),
		.DOUT_OFFSET(8'd27),
		.OPWIDTH(10'd1000)) bench(clk357, tb_trigOut, tb_dataOut);
`else
	//supply0 gnd;
	wire tb_trigOut, amp1_trig, amp2_trig;
	assign tb_trigOut = 1'b0;
	always @ (posedge clk357) begin
		//auxOutA <= (auxOut_en) ? amp1_trig : 1'bz;
		//auxOutB <= (auxOut_en) ? amp2_trig : 1'bz;
		auxOutA <= amp1_trig;
		auxOutB <= amp2_trig;
		end
`endif
			
// %%%%%%%% TRIGGER DIVIDER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%			
	
wire trigger, trig_strb;
//wire trig_mux;		
wire trig_rdy;
/*reg trig_rdy_a, trig_rdy_b, blocked;
			
reg run_a, run_b;
always @(posedge clk357) begin
run_a <= run;
run_b <= run_a;
trig_rdy_a <= trig_rdy;
trig_rdy_b <= trig_rdy_a;
if (trigger) blocked <= 1'b1;
else if (trig_rdy_a && ~trig_rdy_b) blocked <= 1'b0;
else blocked <= blocked;

end
*/
wire [5:0] pulse_ctr;
wire pulse_ctr_rst;		
wire pile_up;	
			
trigger_divider trig_div (
    .clk(clk357), 
    .trig_ext(trig), 
	 .trig_int(tb_trigOut),
	 .trig_int_en(trig_int_en),
	 .empty_trig_blk(empty_trig_blk),
	 //.trig_blk((trig_blk && blocked) || ~run_b),
	 .trig_blk(trig_blk),
    .trig_max_cnt(cr_trig_max_cnt), 
    .trig_seq_sel(cr_trig_seq_sel), 
	 .pulse_ctr_rst_b(pulse_ctr_rst),
	 .run(run),
	 .trig_rdy(trig_rdy),
    .trig_out(trigger),
	 //.trig_strb(trig_strb)
	 .trig_strb(trig_strb),
	 .pulse_ctr(pulse_ctr),
	 .pile_up(pile_up)
    );





// %%%%%%%%%%%%%%%%%   TIMING & SYNCHRONISATION MODULE   %%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

// Brings trigger and ring clock onto 357 domain.  Uses them to produce the
// strobes and triggers for ADCs, DAQ and amplifier.
// All control signals from 357MHz control registers

wire store_strb;
wire adc_align_en;
// Control register wires
//wire 			cr_clk2_16_edge_sel;
//wire [11:0] 	cr_trig_delay;
//wire [6:0] 	cr_trig_out_delay;
//wire [6:0] 	cr_trig_out_delay2;
//wire 			cr_trig_out_en;
//wire 			trig_out_temp;
//wire 			trig_out_temp2;
//wire [7:0]	cr_p1_b1_pos;
//wire [7:0]	cr_p1_b2_pos;
//wire [7:0]	cr_p1_b3_pos;
//wire [7:0]	cr_p2_b1_pos;
//wire [7:0]	cr_p2_b2_pos;
//wire [7:0]	cr_p2_b3_pos;
//wire [7:0]	cr_p3_b1_pos;
//wire [7:0]	cr_p3_b2_pos;
//wire [7:0]	cr_p3_b3_pos;
//wire [6:0]  cr_sample_hold_off;
wire			led1_strb;
//wire			p1_bunch_strb;
//wire			p2_bunch_strb;
//wire			p3_bunch_strb;
wire 			adc_powerup;
wire [3:0] TFSMstate;

timing_synch_fsm #(.FASTCLK_PERIOD(FASTCLK_PERIOD)) timing_synch1 (
	.fastClk(clk357),
	.slowClk(clk40),
	//.rst(dcm200_rst),
	.trigSyncExt(clk2_16_ext),
	.trigSyncExt_edge_sel(cr_clk2_16_edge_sel),
	.trig(trigger),
	//.trig(trigger && run),
	.trig_delay(cr_trig_delay),
	.sample_hold_off(cr_sample_hold_off),
	.num_smpls(num_smpls),
	.trigSync_size_b(trigSync_size),
	.use_trigSyncExt_b(use_trigSyncExt),
	/*.p1_b1_pos(),
	.p1_b2_pos(),
	.p1_b3_pos(),
	.p2_b1_pos(),
	.p2_b2_pos(),
	.p2_b3_pos(),
	.p3_b1_pos(),
	.p3_b2_pos(),
	.p3_b3_pos(),
	.trig_out_delay(),
	.trig_out_delay2(),
	.amp_trig(),
	.amp_trig2(),*/
//	.p1_b1_pos(cr_p1_b1_pos),
//	.p1_b2_pos(cr_p1_b2_pos),
//	.p1_b3_pos(cr_p1_b3_pos),
//	.p2_b1_pos(cr_p2_b1_pos),
//	.p2_b2_pos(cr_p2_b2_pos),
//	.p2_b3_pos(cr_p2_b3_pos),
//	.p3_b1_pos(cr_p3_b1_pos),
//	.p3_b2_pos(cr_p3_b2_pos),
//	.p3_b3_pos(cr_p3_b3_pos),
//	.trig_out_delay(cr_trig_out_delay),
//	.trig_out_delay2(cr_trig_out_delay2),
//	.amp_trig(trig_out_temp),
//	.amp_trig2(trig_out_temp2),
	.store_strb_b(store_strb),
	.adc_powerup(adc_powerup),
	.adc_align_en(adc_align_en),
	//.p1_bunch_strb(),
	//.p2_bunch_strb(),
	//.p3_bunch_strb(),
	//.p2_bunch_strb(p2_bunch_strb),
	//.p3_bunch_strb(p3_bunch_strb),
	.trig_led_strb(led2_strb),
	.clk2_16_led_strb(led1_strb),
	.state(TFSMstate)
);

// Register amp trig, powerdown and align_en for timing
//reg trig_out_temp_a, trig_out_temp_b, trig_out_temp_c, trig_out_temp_d;
//reg trig_out_temp2_a, trig_out_temp2_b, trig_out_temp2_c, trig_out_temp2_d;
reg adc_align_en_a = 1'b0, adc_align_en_b = 1'b0;//adc_align_en_c, adc_align_en_d;
//(* shreg_extract = "no" *) reg adc_powerup_c = 1'b0, adc_powerup_b = 1'b0, adc_powerup_a = 1'b0;
//(* shreg_extract = "no" *) reg adc_powerup_a = 1'b1, adc_powerup_b = 1'b1, adc_powerup_c = 1'b1;
always @(posedge clk357) begin
/*
	trig_out_temp_a <= trig_out_temp;
	// synthesis attribute shreg_extract of trig_out_temp_a is "no";
	trig_out_temp_b <= trig_out_temp_a;
	// synthesis attribute shreg_extract of trig_out_temp_b is "no";
	trig_out_temp_c <= trig_out_temp_b;
	// synthesis attribute shreg_extract of trig_out_temp_c is "no";
	trig_out_temp_d <= trig_out_temp_c;
	// synthesis attribute shreg_extract of trig_out_temp_d is "no";
	
	trig_out_temp2_a <= trig_out_temp2;
	// synthesis attribute shreg_extract of trig_out_temp2_a is "no";
	trig_out_temp2_b <= trig_out_temp2_a;
	// synthesis attribute shreg_extract of trig_out_temp2_b is "no";
	trig_out_temp2_c <= trig_out_temp2_b;
	// synthesis attribute shreg_extract of trig_out_temp2_c is "no";
	trig_out_temp2_d <= trig_out_temp2_c;
	// synthesis attribute shreg_extract of trig_out_temp2_d is "no";
*/	
	adc_align_en_a <= adc_align_en;
	// synthesis attribute shreg_extract of align_en_a is "no";
	adc_align_en_b <= adc_align_en_a;
	// synthesis attribute shreg_extract of align_en_b is "no";
	//adc_align_en_c <= adc_align_en_b;
	// synthesis attribute shreg_extract of align_en_b is "no";
	//adc_align_en_d <= adc_align_en_c;
	// synthesis attribute shreg_extract of align_en_d is "no";
	
	//adc_powerup_a <= adc_powerup;
//	adc_powerup_a <= ~adc_powerup;
//	adc_powerup_b <= adc_powerup_a;
//	adc_powerup_c <= adc_powerup_b;
//	adc_powerdown <= adc_powerup_c;
	//adc_powerdown <= ~adc_powerup_a;

end

// Synchronise the ADC_powerdown and ADC_powerup on the 40 MHz domain
(* ASYNC_REG = "true" *) reg adc_powerup_slow_a = 1'b0, adc_powerup_slow_b = 1'b0;
always @(posedge clk40) begin
	adc_powerup_slow_a <= adc_powerup; //Sync first stage
	adc_powerup_slow_b <= adc_powerup_slow_a; // Sync second stage
	adc_powerdown <= ~adc_powerup_slow_b; //Extra stage needed as this REG in IOB, can't be used in synchroniser + inverter (logic) usage
	iddr_ce <= adc_powerup_slow_b; // Output register for CE of IDDR, *_slow_b used in logic!
	end

//assign amp_trig = trig_out_temp_d & cr_trig_out_en;
//assign amp_trig2 = trig_out_temp2_d & cr_trig_out_en;
//assign adc_powerdown = ~adc_powerup_d;

// %%%%%%%%%%%%%%%%%%%%%%%   STORE STROBE FAN OUT   %%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

// Relax timing by duplicating sotre strobe register for each ADC group
reg p1_store_strb = 1'b0, p2_store_strb = 1'b0, p3_store_strb = 1'b0;
always @(posedge clk357) begin
	p1_store_strb <= store_strb;
	// synthesis attribute shreg_extract of p1_store_strb is "no";
	p2_store_strb <= store_strb;
	// synthesis attribute shreg_extract of p2_store_strb is "no";
	p3_store_strb <= store_strb;
	// synthesis attribute shreg_extract of p3_store_strb is "no";
	clk_blk <= store_strb;
	// synthesis attribute shreg_extract of clk_blk is "no";

end

//Match bunch strobes to store_strb
/*
reg p3_bunch_strb_a, p2_bunch_strb_a, p1_bunch_strb_a;
always @(posedge clk357) begin
	p3_bunch_strb_a <= p3_bunch_strb;
	p2_bunch_strb_a <= p2_bunch_strb;
	p1_bunch_strb_a <= p1_bunch_strb;
end
*/
// %%%%%%%%%%%%%%%%%%%%%%%%%%   LIGHT LEDS   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

// Light when 357MHz is present

// Flash ~200ms on trigger
//reg led2_out;
reg [22:0] led2_count = 23'd0;
always @(posedge clk40) begin
	`ifdef CLK357_PLL
		led0_out <= pll_clk357_locked;
	`else
		led0_out <= 1'b1;
	`endif
	if (dcm200_rst) begin
		led2_out <= 0;
		led2_count <= 0;
	end else begin
		case (led2_count)
			23'd0: if (led2_strb) led2_count <= 23'd1;
			23'd1: begin
				led2_out <= 1;
				led2_count <= led2_count + 1;
			end
			23'd8388607: begin
				led2_out <= 0;
				led2_count <= 0;
			end
			default: led2_count <= led2_count + 1;
		endcase
	end
end

// Flash just over a ring clock cycle on ring clock edge.  Will be lit
// all the time the clock is present
//reg led1_out;
reg [4:0] led1_count = 5'd0;
always @(posedge clk40) begin
	if (dcm200_rst) begin
		led1_out <= 0;
		led1_count <= 0;
	end else begin
		if (led1_strb) begin 
			led1_count <= 5'd1;
			led1_out <= led1_out;
		end else begin
			case (led1_count)
				5'd0: begin
					led1_count <= 0;
					led1_out <= led1_out;
				end
				5'd1: begin
					led1_out <= 1;
					led1_count <= led1_count + 1;
				end
				5'd31: begin
					led1_out <= 0;
					led1_count <= 0;
				end
				default: begin
					led1_count <= led1_count + 1;
					led1_out <= led1_out;
				end
			endcase
		end
	end
end

/////////////////////////////////////////////////////////////////////////////
///// Channel Offset De-multiplexer /////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

wire signed [12:0] chan1_offset, chan2_offset, chan3_offset;
wire signed [12:0] chan4_offset, chan5_offset, chan6_offset;
wire signed [12:0] chan7_offset, chan8_offset, chan9_offset;


chanOffsetMUX chanOffsetDeMUX ( 
	.clk(clk357),
	.chanOffset(chanOffset),
	.chanOffsetSel(chanOffsetSel),
	.chan1_offset(chan1_offset),
	.chan2_offset(chan2_offset),
	.chan3_offset(chan3_offset),
	.chan4_offset(chan4_offset),
	.chan5_offset(chan5_offset),
	.chan6_offset(chan6_offset),
	.chan7_offset(chan7_offset),
	.chan8_offset(chan8_offset),
	.chan9_offset(chan9_offset)
	);


// %%%%%%%%%%%%%%%%%%   P1 ADC GROUP ADC_BLOCK MODULE   %%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

// Bring the data from the 3 ADCs for P1 into the module via an adc_clock
// The adc block ensures the adc data is aligned with the 357MHz clock
// All control signals from 40MHz control registers

reg  [6:0]  cr_p1_offset_delay  = 7'd0;
wire [5:0] 	cr_p1_scan_delay;
wire [1:0] 	cr_p1_align_ch_sel;
wire signed [13:0] chan1_data;
wire signed [13:0] chan2_data;
wire signed [13:0] chan3_data;
wire 			p1_mon_strb;
wire 			p1_mon_saturated;
wire [5:0]  p1_mon_total_data_del;
wire [5:0]  p1_mon_total_drdy_del;
wire [6:0]  p1_mon_delay_mod;
wire [6:0]  p1_mon_count1;
wire [6:0]  p1_mon_count2;
wire [6:0]  p1_mon_count3;
wire [5:0]  p1_mon_adc_clk_del;
adc_block p1_adc_block(
	.clk357(clk357),
	.clk40(clk40),
	.rst(dcm200_rst),
	.align_en(adc_align_en_b),	// From time/synch mod.
	.align_ch_sel(cr_p1_align_ch_sel),
	//.ch1_data_in_del(ch1_data_in_del),
	//.ch2_data_in_del(ch2_data_in_del),
	//.ch3_data_in_del(ch3_data_in_del),	
	.data_offset_delay(cr_p1_offset_delay),
	.scan_delay(cr_p1_scan_delay),
	.delay_trig(delay_trig1),
	.IDDR_Q1(IDDR1_Q1),
	.IDDR_Q2(IDDR1_Q2),
	//.ch1_data_out(p1_xdif_data),
	//.ch2_data_out(p1_ydif_data),
	//.ch3_data_out(p1_sum_data),
	.saturated(p1_mon_saturated),
	.adc_data_delay(p1_mon_total_data_del),	//Monitoring
	.adc_drdy_delay(p1_mon_total_drdy_del), //Monitoring
	.delay_modifier(p1_mon_delay_mod),					//Monitoring
	.monitor_strb(p1_mon_strb),					//Monitoring
	.count1(p1_mon_count1),							//Monitoring
	.count2(p1_mon_count2),							//Monitoring
	.count3(p1_mon_count3),							//Monitoring
	.adc_clk_delay_mon(p1_mon_adc_clk_del),		//Monitoring
	.delay_calc_strb(delay_calc_strb1),
	.adc_drdy_delay_ce(adc1_drdy_delay_ce),
	.adc_clk_delay_ce(adc1_clk_delay_ce),
	.adc_data_delay_ce(adc1_data_delay_ce)
);

parameter ch1_bitflip = ~13'b1011010000101;
parameter ch2_bitflip = ~13'b0101110001000;
parameter ch3_bitflip = ~13'b0001011110100;
(* shreg_extract = "no" *) reg [4:0] bank1_sr_tap_a = 5'd2, bank1_sr_tap_b = 5'd2, bank1_sr_tap_c = 5'd2;
reg [1:0] bank1_sr_bypass = 2'b11;

dataRegConvert #(13, ch1_bitflip ^ -13'sd4096) ch1_dataRegConvert(clk357, bank1_sr_bypass, ch1_data_in_del, chan1_offset, bank1_sr_tap_c, chan1_data);
dataRegConvert #(13, ch2_bitflip ^ -13'sd4096) ch2_dataRegConvert(clk357, bank1_sr_bypass, ch2_data_in_del, chan2_offset, bank1_sr_tap_c, chan2_data);
dataRegConvert #(13, ch3_bitflip ^ -13'sd4096) ch3_dataRegConvert(clk357, bank1_sr_bypass, ch3_data_in_del, chan3_offset, bank1_sr_tap_c, chan3_data);
//dataRegConvert #(13) ch1_dataRegConvert(clk357, ch1_data_in_del, p1_xdif_data);
//dataRegConvert #(13) ch2_dataRegConvert(clk357, ch2_data_in_del, p1_ydif_data);
//dataRegConvert #(13) ch3_dataRegConvert(clk357, ch3_data_in_del, p1_sum_data);


// Flip the signals which were incorrect polarity at LVDS inputs
//`include "p1_adcblock_flip_signals.v"


//Insert Droop Correction Filter 

//wire signed [DSP_WIDTH-1:0] chan1_IIR_out, chan1_RAM_data;
//wire signed [DSP_WIDTH-1:0] p1_ydif_IIR_out, p1_ydif_RAM_data;
wire signed [DSP_WIDTH-1:0] chan1_IIR_out, chan2_IIR_out, chan3_IIR_out;
wire signed [DSP_WIDTH-1:0] chan1_RAM_data, chan2_RAM_data, chan3_RAM_data;
//reg signed [DSP_WIDTH:0] chan1_RAM_data = 17'd0, chan2_RAM_data = 17'd0, chan3_RAM_data = 17'd0;
//wire signed [DSP_WIDTH-1:0] chan1_RAM_data, chan3_RAM_data;
//wire signed [DSP_WIDTH:0] chan2_RAM_data;
//reg signed [DSP_WIDTH-1:0] chan1_RAM_data = 14'd0, chan2_RAM_data = 14'd0, chan3_RAM_data = 14'd0;
//wire signed [DSP_WIDTH-1:0] chan3_IIR_out, chan3_RAM_data;
wire ch1_oflowDet, ch2_oflowDet, ch3_oflowDet;


//synchronise signals coming in from uart
//(* shreg_extract = "no" *) reg [10:0] IIRbypass_a = 11'd0, IIRbypass_b = 11'd0;
reg [10:0] IIRbypass_a = 11'd0, IIRbypass_b = 11'd0;
//reg [12:0] p1_xdif_data_reg, p1_ydif_data_reg, p1_sum_data_reg;
//reg [12:0] p1_xdif_corr, p1_ydif_corr, p1_sum_corr;

always @(posedge clk357) begin
	bank1_sr_tap_a <= bank1_sr_tap;
	bank1_sr_tap_b <= bank1_sr_tap_a;
	bank1_sr_tap_c <= bank1_sr_tap_b;
	case (bank1_sr_tap_b)
	5'd0: bank1_sr_bypass <= 2'b01;
	5'd1: bank1_sr_bypass <= 2'b10;
	default: bank1_sr_bypass <= 2'b00;
	endcase
	IIRbypass_a <= IIRbypass;
	IIRbypass_b <= IIRbypass_a;
//	p1_xdif_data_reg <= p1_xdif_data;
//	p1_ydif_data_reg <= p1_ydif_data;
//	p1_sum_data_reg <= p1_sum_data;
//	p1_xdif_corr <= p1_xdif_IIR_out + p1_xdif_data_reg;
//	p1_ydif_corr <= p1_ydif_IIR_out + p1_ydif_data_reg;
//	p1_sum_corr <= p1_sum_IIR_out + p1_sum_data_reg;
	end

antiDroopIIR #(17) antiDroopIIR_ch1(
	.clk(clk357),
	.trig(TFSMstate[2]),
	//.din(p1_xdif_data_fix),
	.din(chan1_data[12:0]),
	.tapWeight(ch1_IIRtapWeight),
	.accClr_en(1'b1),
	//.oflowClr(),
	.oflowDetect(ch1_oflowDet),
	.dout(chan1_IIR_out)
);
antiDroopIIR #(17) antiDroopIIR_ch2(
	.clk(clk357),
	.trig(TFSMstate[2]),
	//.din(p1_ydif_data_fix),
	.din(chan2_data[12:0]),
	.tapWeight(ch2_IIRtapWeight),
	.accClr_en(1'b1),
	//.oflowClr(),
	.oflowDetect(ch2_oflowDet),
	.dout(chan2_IIR_out)
);
antiDroopIIR #(17) antiDroopIIR_ch3(
	.clk(clk357),
	.trig(TFSMstate[2]),
	//.din(p1_sum_data_fix),
	.din(chan3_data[12:0]),
	.tapWeight(ch3_IIRtapWeight),
	.accClr_en(1'b1),
	//.oflowClr(),
	.oflowDetect(ch3_oflowDet),
	.dout(chan3_IIR_out)
);
reg bank1_oflowDet = 1'b0;
wire chan1_offset_oflow, chan2_offset_oflow, chan3_offset_oflow;
//wire chan2_offset_oflow;
//reg signed [12:0] chan2_offset_a = 13'd0, chan2_offset_b = 13'd0;
//reg signed [12:0] chan5_offset_a = 13'd0, chan5_offset_b = 13'd0;

always @(posedge clk357) begin
//chan2_offset_a <= chan2_offset;
//chan2_offset_b <= chan2_offset_a;
//chan5_offset_a <= chan5_offset;
//chan5_offset_b <= chan5_offset_a;
//chan1_RAM_data <= ((~IIRbypass_b[0]) ? {chan1_data[12:0], 3'b000} : chan1_IIR_out);// + {chan1_offset, 3'b000};
//chan2_RAM_data <= ((~IIRbypass_b[1]) ? {chan2_data[12:0], 3'b000} : chan2_IIR_out);// + {chan2_offset, 3'b000};
//chan3_RAM_data <= ((~IIRbypass_b[2]) ? {chan3_data[12:0], 3'b000} : chan3_IIR_out);// + {chan3_offset, 3'b000};
//chan1_RAM_data <= chan1_RAM_data_b + {chan1_offset, 3'b000};
//chan2_RAM_data <= chan2_RAM_data_b + {chan2_offset, 3'b000};
//chan3_RAM_data <= chan3_RAM_data_b + {chan3_offset, 3'b000};
bank1_oflowDet <= (ch1_oflowDet | ch2_oflowDet | ch3_oflowDet | chan1_offset_oflow | chan2_offset_oflow | chan3_offset_oflow);
//bank1_oflowDet <= (ch1_oflowDet | ch2_oflowDet | ch3_oflowDet);
end

//assign p1_xdif_RAM_data = (~IIRbypass_b[0]) ? p1_xdif_data_fix : p1_xdif_IIR_out;
//assign p1_ydif_RAM_data = (~IIRbypass_b[1]) ? p1_ydif_data_fix : p1_ydif_IIR_out;
//assign p1_sum_RAM_data = (~IIRbypass_b[2]) ? p1_sum_data_fix : p1_sum_IIR_out;
assign chan1_RAM_data = ((~IIRbypass_b[0]) ? {chan1_data, 3'b000} : chan1_IIR_out);// + {chan1_offset, 3'b000};
assign chan2_RAM_data = ((~IIRbypass_b[1]) ? {chan2_data, 3'b000} : chan2_IIR_out);// + {chan2_offset, 3'b000};
assign chan3_RAM_data = ((~IIRbypass_b[2]) ? {chan3_data, 3'b000} : chan3_IIR_out);// + {chan3_offset, 3'b000};
//assign p1_xdif_RAM_data = (~IIRbypass_b[0]) ? p1_xdif_data : p1_xdif_IIR_out;
//assign p1_ydif_RAM_data = (~IIRbypass_b[1]) ? p1_ydif_data : p1_ydif_IIR_out;
//assign p1_sum_RAM_data = (~IIRbypass_b[2]) ? p1_sum_data : p1_sum_IIR_out;
//assign p1_xdif_RAM_data = (~IIRbypass_b[0]) ? p1_xdif_data : p1_xdif_IIR_out + p1_xdif_data_reg;
//assign p1_ydif_RAM_data = (~IIRbypass_b[1]) ? p1_ydif_data : p1_ydif_IIR_out + p1_ydif_data_reg;
//assign p1_sum_RAM_data = (~IIRbypass_b[2]) ? p1_sum_data : p1_sum_IIR_out + p1_sum_data_reg;
//assign p1_xdif_RAM_data = (~IIRbypass_b[0]) ? p1_xdif_data : p1_xdif_corr;
//assign p1_ydif_RAM_data = (~IIRbypass_b[1]) ? p1_ydif_data : p1_ydif_corr;
//assign p1_sum_RAM_data = (~IIRbypass_b[2]) ? p1_sum_data : p1_sum_corr;

//assign chan1_offset_oflow = (^chan1_RAM_data[DSP_WIDTH:DSP_WIDTH-1]) ? 1'b1 : 1'b0;
assign chan1_offset_oflow = (^chan1_data[13:12]) ? 1'b1 : 1'b0;
assign chan2_offset_oflow = (^chan2_data[13:12]) ? 1'b1 : 1'b0;
assign chan3_offset_oflow = (^chan3_data[13:12]) ? 1'b1 : 1'b0;

//assign chan2_offset_oflow = (^chan2_RAM_data[DSP_WIDTH:DSP_WIDTH-1]) ? 1'b1 : 1'b0;
//assign chan3_offset_oflow = (^chan3_RAM_data[DSP_WIDTH:DSP_WIDTH-1]) ? 1'b1 : 1'b0;

// %%%%%%%%%%%%%%%%%%   P1 ADC GROUP DAQ_RAM MODULES   %%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

// Three RAM modules with self contained transmission logic.  Data are written 
// at 357MHz and number of samples tracked.  When tx_en goes high, data are sent
// to the UART

wire 			daq_ram_rst;
wire			uart_tx_empty;

reg 			daq_chan1_tx_en = 1'b0;
wire 			daq_chan1_tx_done;
//wire [7:0] 	daq_p1_xdif_tx_data;
wire [6:0] 	daq_chan1_tx_data;
wire 			daq_chan1_tx_load;
DAQ_RAM daq_ram_chan1(
	.reset(daq_ram_rst),
	.tx_en(daq_chan1_tx_en),
	.tx_clk(clk40),
	.tx_data_ready(daq_chan1_tx_load),
	.tx_data(daq_chan1_tx_data),
	.tx_data_loaded(~uart_tx_empty),
	.tx_complete(daq_chan1_tx_done),
	.wr_clk(clk357),
	.wr_en(p1_store_strb),
	.wr_data({chan1_RAM_data[DSP_WIDTH-1], chan1_RAM_data[DSP_WIDTH-1:DSP_WIDTH-13]})
);

reg 			daq_chan2_tx_en = 1'b0;
wire 			daq_chan2_tx_done;
//wire [7:0] 	daq_p1_ydif_tx_data;
wire [6:0] 	daq_chan2_tx_data;
wire 			daq_chan2_tx_load;
DAQ_RAM daq_ram_chan2(
	.reset(daq_ram_rst),
	.tx_en(daq_chan2_tx_en),
	.tx_clk(clk40),
	.tx_data_ready(daq_chan2_tx_load),
	.tx_data(daq_chan2_tx_data),
	.tx_data_loaded(~uart_tx_empty),
	.tx_complete(daq_chan2_tx_done),
	.wr_clk(clk357),
	.wr_en(p1_store_strb),
	.wr_data({chan2_RAM_data[DSP_WIDTH-1], chan2_RAM_data[DSP_WIDTH-1:DSP_WIDTH-13]})
);

reg 			daq_chan3_tx_en = 1'b0;
wire 			daq_chan3_tx_done;
//wire [7:0] 	daq_p1_sum_tx_data;
wire [6:0] 	daq_chan3_tx_data;
wire 			daq_chan3_tx_load;
DAQ_RAM daq_ram_chan3(
	.reset(daq_ram_rst),
	.tx_en(daq_chan3_tx_en),
	.tx_clk(clk40),
	.tx_data_ready(daq_chan3_tx_load),
	.tx_data(daq_chan3_tx_data),
	.tx_data_loaded(~uart_tx_empty),
	.tx_complete(daq_chan3_tx_done),
	.wr_clk(clk357),
	.wr_en(p1_store_strb),
	.wr_data({chan3_RAM_data[DSP_WIDTH-1], chan3_RAM_data[DSP_WIDTH-1:DSP_WIDTH-13]})
);


// %%%%%%%%%%%%%%%%%%   P2 ADC GROUP ADC_BLOCK MODULE   %%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

// Bring the data from the 3 ADCs for P2 into the module via an adc_clock
// The adc block ensures the adc data is aligned with the 357MHz clock
// All control signals from 40MHz control registers

reg  [6:0]  cr_p2_offset_delay = 7'd0;
wire [5:0] 	cr_p2_scan_delay;
wire [1:0] 	cr_p2_align_ch_sel;
wire signed [13:0] chan4_data;
wire signed [13:0] chan5_data;
wire signed [13:0] chan6_data;
wire 			p2_mon_strb;
wire 			p2_mon_saturated;
wire [5:0]  p2_mon_total_data_del;
wire [5:0]  p2_mon_total_drdy_del;
wire [6:0]  p2_mon_delay_mod;
wire [6:0]  p2_mon_count1;
wire [6:0]  p2_mon_count2;
wire [6:0]  p2_mon_count3;
wire [5:0]  p2_mon_adc_clk_del;
adc_block p2_adc_block(
	.clk357(clk357),
	.clk40(clk40),
	.rst(dcm200_rst),
	.align_en(adc_align_en_b),	// From time/synch mod.
	.align_ch_sel(cr_p2_align_ch_sel),
	//.ch1_data_in_del(ch4_data_in_del),
	//.ch2_data_in_del(ch5_data_in_del),
	//.ch3_data_in_del(ch6_data_in_del),	
	.data_offset_delay(cr_p2_offset_delay),
	.scan_delay(cr_p2_scan_delay),
	.delay_trig(delay_trig2),
	.IDDR_Q1(IDDR2_Q1),
	.IDDR_Q2(IDDR2_Q2),
	//.ch1_data_out(p2_xdif_data),
	//.ch2_data_out(p2_ydif_data),
	//.ch3_data_out(p2_sum_data),
	.saturated(p2_mon_saturated),
	.adc_data_delay(p2_mon_total_data_del),	//Monitoring
	.adc_drdy_delay(p2_mon_total_drdy_del), //Monitoring
	.delay_modifier(p2_mon_delay_mod),					//Monitoring
	.monitor_strb(p2_mon_strb),					//Monitoring
	.count1(p2_mon_count1),							//Monitoring
	.count2(p2_mon_count2),							//Monitoring
	.count3(p2_mon_count3),							//Monitoring
	.adc_clk_delay_mon(p2_mon_adc_clk_del),		//Monitoring
	.delay_calc_strb(delay_calc_strb2),
	.adc_drdy_delay_ce(adc2_drdy_delay_ce),
	.adc_clk_delay_ce(adc2_clk_delay_ce),
	.adc_data_delay_ce(adc2_data_delay_ce)
);

parameter ch4_bitflip = ~13'b0111100000000;
parameter ch5_bitflip = ~13'b0100110011010;
parameter ch6_bitflip = ~13'b1111111010110;
(* shreg_extract = "no" *) reg [4:0] bank2_sr_tap_a = 5'd2, bank2_sr_tap_b = 5'd2, bank2_sr_tap_c = 5'd2;
reg [1:0] bank2_sr_bypass = 2'b11;

dataRegConvert #(13, ch4_bitflip ^ -13'sd4096) ch4_dataRegConvert(clk357, bank2_sr_bypass, ch4_data_in_del, chan4_offset, bank2_sr_tap_c, chan4_data);
dataRegConvert #(13, ch5_bitflip ^ -13'sd4096) ch5_dataRegConvert(clk357, bank2_sr_bypass, ch5_data_in_del, chan5_offset, bank2_sr_tap_c, chan5_data);
dataRegConvert #(13, ch6_bitflip ^ -13'sd4096) ch6_dataRegConvert(clk357, bank2_sr_bypass, ch6_data_in_del, chan6_offset, bank2_sr_tap_c, chan6_data);

// Flip the signals which were incorrect polarity at LVDS inputs
//`include "p2_adcblock_flip_signals.v"

//Insert P2 Droop Correction Filters 

//wire signed [DSP_WIDTH-1:0] chan4_IIR_out, chan4_RAM_data;
//wire signed [DSP_WIDTH-1:0] p2_ydif_IIR_out, p2_ydif_RAM_data;
//wire signed [DSP_WIDTH-1:0] chan5_IIR_out;
//wire signed [DSP_WIDTH:0] chan5_RAM_data;

wire signed [DSP_WIDTH-1:0] chan4_IIR_out, chan5_IIR_out, chan6_IIR_out;
//reg signed [DSP_WIDTH:0] chan4_RAM_data = 17'd0, chan5_RAM_data = 17'd0, chan6_RAM_data = 17'd0;
wire signed [DSP_WIDTH-1:0] chan4_RAM_data, chan5_RAM_data, chan6_RAM_data;
//wire signed [DSP_WIDTH-1:0] chan4_RAM_data, chan6_RAM_data;
//wire signed [DSP_WIDTH:0] chan5_RAM_data;

//wire signed [DSP_WIDTH-1:0] chan6_IIR_out, chan6_RAM_data;
wire ch4_oflowDet, ch5_oflowDet, ch6_oflowDet;


antiDroopIIR #(17) antiDroopIIR_ch4(
	.clk(clk357),
	.trig(TFSMstate[2]),
//	.din(p2_xdif_data_fix),
	.din(chan4_data[12:0]),
	.tapWeight(ch4_IIRtapWeight),
	.accClr_en(1'b1),
	//.oflowClr(),
	.oflowDetect(ch4_oflowDet),
	.dout(chan4_IIR_out)
);
antiDroopIIR #(17) antiDroopIIR_ch5(
	.clk(clk357),
	.trig(TFSMstate[2]),
	//.din(p2_ydif_data_fix),
	.din(chan5_data[12:0]),
	.tapWeight(ch5_IIRtapWeight),
	.accClr_en(1'b1),
	//.oflowClr(),
	.oflowDetect(ch5_oflowDet),
	.dout(chan5_IIR_out)
);
antiDroopIIR #(17) antiDroopIIR_ch6(
	.clk(clk357),
	.trig(TFSMstate[2]),
	//.din(p2_sum_data_fix),
	.din(chan6_data[12:0]),
	.tapWeight(ch6_IIRtapWeight),
	.accClr_en(1'b1),
	//.oflowClr(),
	.oflowDetect(ch6_oflowDet),
	.dout(chan6_IIR_out)
);

reg bank2_oflowDet = 1'b0;
wire chan4_offset_oflow, chan5_offset_oflow, chan6_offset_oflow;
//wire chan5_offset_oflow;
always @(posedge clk357) begin
bank2_sr_tap_a <= bank2_sr_tap;
bank2_sr_tap_b <= bank2_sr_tap_a;
bank2_sr_tap_c <= bank2_sr_tap_b;
case (bank2_sr_tap_b)
	5'd0: bank2_sr_bypass <= 2'b01;
	5'd1: bank2_sr_bypass <= 2'b10;
	default: bank2_sr_bypass <= 2'b00;
	endcase
bank2_oflowDet <= (ch4_oflowDet | ch5_oflowDet | ch6_oflowDet | chan4_offset_oflow | chan5_offset_oflow | chan6_offset_oflow);
//bank2_oflowDet <= (ch4_oflowDet | ch5_oflowDet | ch6_oflowDet);
//chan4_RAM_data <= ((~IIRbypass_b[3]) ? {chan4_data, 3'b000} : chan4_IIR_out);// + {chan4_offset, 3'b000};
//chan5_RAM_data <= ((~IIRbypass_b[4]) ? {chan5_data, 3'b000} : chan5_IIR_out);// + {chan5_offset, 3'b000};
//chan6_RAM_data <= ((~IIRbypass_b[5]) ? {chan6_data, 3'b000} : chan6_IIR_out);// + {chan6_offset, 3'b000};
//chan4_RAM_data <= chan4_RAM_data_b + {chan4_offset, 3'b000};
//chan5_RAM_data <= chan5_RAM_data_b + {chan5_offset, 3'b000};
//chan6_RAM_data <= chan6_RAM_data_b + {chan6_offset, 3'b000};
end

//assign p2_xdif_RAM_data = (~IIRbypass_b[3]) ? p2_xdif_data_fix : p2_xdif_IIR_out;
//assign p2_ydif_RAM_data = (~IIRbypass_b[4]) ? p2_ydif_data_fix : p2_ydif_IIR_out;
//assign p2_sum_RAM_data = (~IIRbypass_b[5]) ? p2_sum_data_fix : p2_sum_IIR_out;
assign chan4_RAM_data = ((~IIRbypass_b[3]) ? {chan4_data, 3'b000} : chan4_IIR_out);// + {chan4_offset, 3'b000};
assign chan5_RAM_data = ((~IIRbypass_b[4]) ? {chan5_data, 3'b000} : chan5_IIR_out);// + {chan5_offset, 3'b000};
//assign p2_ydif_RAM_data = (~IIRbypass_b[4]) ? {p2_ydif_data, 3'b000} : p2_ydif_IIR_out;
assign chan6_RAM_data = ((~IIRbypass_b[5]) ? {chan6_data, 3'b000} : chan6_IIR_out);// + {chan6_offset, 3'b000};
//assign p2_xdif_RAM_data = (~IIRbypass_b[3]) ? p2_xdif_data : p2_xdif_IIR_out;
//assign p2_ydif_RAM_data = (~IIRbypass_b[4]) ? p2_ydif_data : p2_ydif_IIR_out;
//assign p2_sum_RAM_data = (~IIRbypass_b[5]) ? p2_sum_data : p2_sum_IIR_out;

//assign chan4_offset_oflow = (^chan4_RAM_data[DSP_WIDTH:DSP_WIDTH-1]) ? 1'b1 : 1'b0;
//assign chan5_offset_oflow = (^chan5_RAM_data[DSP_WIDTH:DSP_WIDTH-1]) ? 1'b1 : 1'b0;
//assign chan6_offset_oflow = (^chan6_RAM_data[DSP_WIDTH:DSP_WIDTH-1]) ? 1'b1 : 1'b0;
assign chan4_offset_oflow = (^chan4_data[13:12]) ? 1'b1 : 1'b0;
assign chan5_offset_oflow = (^chan5_data[13:12]) ? 1'b1 : 1'b0;
assign chan6_offset_oflow = (^chan6_data[13:12]) ? 1'b1 : 1'b0;

// %%%%%%%%%%%%%%%%%%   P2 ADC GROUP DAQ_RAM MODULES   %%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

// Three RAM modules with self contained transmission logic.  Data are written 
// at 357MHz and number of samples tracked.  When tx_en goes high, data are sent
// to the UART

reg 			daq_chan4_tx_en = 1'b0;
wire 			daq_chan4_tx_done;
//wire [7:0] 	daq_p2_xdif_tx_data;
wire [6:0] 	daq_chan4_tx_data;
wire 			daq_chan4_tx_load;
DAQ_RAM daq_ram_chan4(
	.reset(daq_ram_rst),
	.tx_en(daq_chan4_tx_en),
	.tx_clk(clk40),
	.tx_data_ready(daq_chan4_tx_load),
	.tx_data(daq_chan4_tx_data),
	.tx_data_loaded(~uart_tx_empty),
	.tx_complete(daq_chan4_tx_done),
	.wr_clk(clk357),
	.wr_en(p2_store_strb),
	.wr_data({chan4_RAM_data[DSP_WIDTH-1], chan4_RAM_data[DSP_WIDTH-1:DSP_WIDTH-13]})
);

reg 			daq_chan5_tx_en = 1'b0;
wire 			daq_chan5_tx_done;
//wire [7:0] 	daq_p2_ydif_tx_data;
wire [6:0] 	daq_chan5_tx_data;
wire 			daq_chan5_tx_load;
DAQ_RAM daq_ram_chan5(
	.reset(daq_ram_rst),
	.tx_en(daq_chan5_tx_en),
	.tx_clk(clk40),
	.tx_data_ready(daq_chan5_tx_load),
	.tx_data(daq_chan5_tx_data),
	.tx_data_loaded(~uart_tx_empty),
	.tx_complete(daq_chan5_tx_done),
	.wr_clk(clk357),
	.wr_en(p2_store_strb),
	.wr_data({chan5_RAM_data[DSP_WIDTH-1], chan5_RAM_data[DSP_WIDTH-1:DSP_WIDTH-13]})
);

reg 			daq_chan6_tx_en = 1'b0;
wire 			daq_chan6_tx_done;
//wire [7:0] 	daq_p2_sum_tx_data;
wire [6:0] 	daq_chan6_tx_data;
wire 			daq_chan6_tx_load;
DAQ_RAM daq_ram_chan6(
	.reset(daq_ram_rst),
	.tx_en(daq_chan6_tx_en),
	.tx_clk(clk40),
	.tx_data_ready(daq_chan6_tx_load),
	.tx_data(daq_chan6_tx_data),
	.tx_data_loaded(~uart_tx_empty),
	.tx_complete(daq_chan6_tx_done),
	.wr_clk(clk357),
	.wr_en(p2_store_strb),
	.wr_data({chan6_RAM_data[DSP_WIDTH-1], chan6_RAM_data[DSP_WIDTH-1:DSP_WIDTH-13]})
);


// %%%%%%%%%%%%%%%%%%   P3 ADC GROUP ADC_BLOCK MODULE   %%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

// Bring the data from the 3 ADCs for P3 into the module via an adc_clock
// The adc block ensures the adc data is aligned with the 357MHz clock
// All control signals from 40MHz control registers

reg  [6:0]  cr_p3_offset_delay = 7'd0;
wire [5:0] 	cr_p3_scan_delay;
wire [1:0] 	cr_p3_align_ch_sel;
wire signed [13:0] chan7_data;
wire signed [13:0] chan8_data;
wire signed [13:0] chan9_data;
wire 			p3_mon_strb;
wire 			p3_mon_saturated;
wire [5:0]  p3_mon_total_data_del;
wire [5:0]  p3_mon_total_drdy_del;
wire [6:0]  p3_mon_delay_mod;
wire [6:0]  p3_mon_count1;
wire [6:0]  p3_mon_count2;
wire [6:0]  p3_mon_count3;
wire [5:0]  p3_mon_adc_clk_del;
adc_block p3_adc_block(
	.clk357(clk357),
	.clk40(clk40),
	.rst(dcm200_rst),
	.align_en(adc_align_en_b),	// From time/synch mod.
	.align_ch_sel(cr_p3_align_ch_sel),
	//.ch1_data_in_del(ch7_data_in_del),
	//.ch2_data_in_del(ch8_data_in_del),
	//.ch3_data_in_del(ch9_data_in_del),	
	.data_offset_delay(cr_p3_offset_delay),
	.scan_delay(cr_p3_scan_delay),
	.delay_trig(delay_trig3),
	.IDDR_Q1(IDDR3_Q1),
	.IDDR_Q2(IDDR3_Q2),
	//.ch1_data_out(p3_xdif_data),
	//.ch2_data_out(p3_ydif_data),
	//.ch3_data_out(p3_sum_data),
	.saturated(p3_mon_saturated),
	.adc_data_delay(p3_mon_total_data_del),	//Monitoring
	.adc_drdy_delay(p3_mon_total_drdy_del), //Monitoring
	.delay_modifier(p3_mon_delay_mod),					//Monitoring
	.monitor_strb(p3_mon_strb),					//Monitoring
	.count1(p3_mon_count1),							//Monitoring
	.count2(p3_mon_count2),							//Monitoring
	.count3(p3_mon_count3),							//Monitoring
	.adc_clk_delay_mon(p3_mon_adc_clk_del),		//Monitoring
	.delay_calc_strb(delay_calc_strb3),
	.adc_drdy_delay_ce(adc3_drdy_delay_ce),
	.adc_clk_delay_ce(adc3_clk_delay_ce),
	.adc_data_delay_ce(adc3_data_delay_ce)
);

parameter ch7_bitflip = ~13'b0001101000010;
parameter ch8_bitflip = ~13'b1000011100001;
parameter ch9_bitflip = ~13'b0001001111010;
(* shreg_extract = "no" *) reg [4:0] bank3_sr_tap_a = 5'd2, bank3_sr_tap_b = 5'd2, bank3_sr_tap_c = 5'd2;
reg [1:0] bank3_sr_bypass = 2'b11;

dataRegConvert #(13, ch7_bitflip ^ -13'sd4096) ch7_dataRegConvert(clk357, bank3_sr_bypass, ch7_data_in_del, chan7_offset, bank3_sr_tap_c, chan7_data);
dataRegConvert #(13, ch8_bitflip ^ -13'sd4096) ch8_dataRegConvert(clk357, bank3_sr_bypass, ch8_data_in_del, chan8_offset, bank3_sr_tap_c, chan8_data);
dataRegConvert #(13, ch9_bitflip ^ -13'sd4096) ch9_dataRegConvert(clk357, bank3_sr_bypass, ch9_data_in_del, chan9_offset, bank3_sr_tap_c, chan9_data);

// Flip the signals which were incorrect polarity at LVDS inputs
//`include "p3_adcblock_flip_signals.v"

//Insert P3 Droop Correction Filters 

//wire signed [DSP_WIDTH-1:0] chan7_IIR_out, chan7_RAM_data;
//wire signed [DSP_WIDTH-1:0] chan8_IIR_out, chan8_RAM_data;
//wire signed [DSP_WIDTH-1:0] chan9_IIR_out, chan9_RAM_data;

wire signed [DSP_WIDTH-1:0] chan7_IIR_out, chan8_IIR_out, chan9_IIR_out;
wire signed [DSP_WIDTH-1:0] chan7_RAM_data, chan8_RAM_data, chan9_RAM_data;
//reg signed [DSP_WIDTH:0] chan7_RAM_data = 17'd0, chan8_RAM_data = 17'd0, chan9_RAM_data = 17'd0;
wire ch7_oflowDet, ch8_oflowDet, ch9_oflowDet;


antiDroopIIR #(17) antiDroopIIR_ch7(
	.clk(clk357),
	.trig(TFSMstate[2]),
	//.din(p3_xdif_data_fix),
	.din(chan7_data[12:0]),
	.tapWeight(ch7_IIRtapWeight),
	.accClr_en(1'b1),
	//.oflowClr(),
	.oflowDetect(ch7_oflowDet),
	.dout(chan7_IIR_out)
);
antiDroopIIR #(17) antiDroopIIR_ch8(
	.clk(clk357),
	.trig(TFSMstate[2]),
	//.din(p3_ydif_data_fix),
	.din(chan8_data[12:0]),
	.tapWeight(ch8_IIRtapWeight),
	.accClr_en(1'b1),
	//.oflowClr(),
	.oflowDetect(ch8_oflowDet),
	.dout(chan8_IIR_out)
);
antiDroopIIR #(17) antiDroopIIR_ch9(
	.clk(clk357),
	.trig(TFSMstate[2]),
	//.din(p3_sum_data_fix),
	.din(chan9_data[12:0]),
	.tapWeight(ch9_IIRtapWeight),
	.accClr_en(1'b1),
	//.oflowClr(),
	.oflowDetect(ch9_oflowDet),
	.dout(chan9_IIR_out)
);

reg bank3_oflowDet = 1'b0;
wire chan7_offset_oflow, chan8_offset_oflow, chan9_offset_oflow;
always @(posedge clk357) begin
bank3_sr_tap_a <= bank3_sr_tap;
bank3_sr_tap_b <= bank3_sr_tap_a;
bank3_sr_tap_c <= bank3_sr_tap_b;
case (bank3_sr_tap_b)
	5'd0: bank3_sr_bypass <= 2'b01;
	5'd1: bank3_sr_bypass <= 2'b10;
	default: bank3_sr_bypass <= 2'b00;
	endcase
bank3_oflowDet <= (ch7_oflowDet | ch8_oflowDet | ch9_oflowDet | chan7_offset_oflow | chan8_offset_oflow | chan9_offset_oflow);
//bank3_oflowDet <= (ch7_oflowDet | ch8_oflowDet | ch9_oflowDet);
//chan7_RAM_data <= ((~IIRbypass_b[6]) ? {chan7_data, 3'b000} : chan7_IIR_out);// + {chan7_offset, 3'b000};
//chan8_RAM_data <= ((~IIRbypass_b[7]) ? {chan8_data, 3'b000} : chan8_IIR_out);// + {chan8_offset, 3'b000};
//chan9_RAM_data <= ((~IIRbypass_b[8]) ? {chan9_data, 3'b000} : chan9_IIR_out);// + {chan9_offset, 3'b000};
//chan7_RAM_data <= chan7_RAM_data_b + {chan7_offset, 3'b000};
//chan8_RAM_data <= chan8_RAM_data_b + {chan8_offset, 3'b000};
//chan9_RAM_data <= chan9_RAM_data_b + {chan9_offset, 3'b000};
end

//assign p3_xdif_RAM_data = (~IIRbypass_b[6]) ? p3_xdif_data_fix : p3_xdif_IIR_out;
//assign p3_ydif_RAM_data = (~IIRbypass_b[7]) ? p3_ydif_data_fix : p3_ydif_IIR_out;
//assign p3_sum_RAM_data = (~IIRbypass_b[8]) ? p3_sum_data_fix : p3_sum_IIR_out;
assign chan7_RAM_data = ((~IIRbypass_b[6]) ? {chan7_data, 3'b000} : chan7_IIR_out);// + {chan7_offset, 3'b000};
assign chan8_RAM_data = ((~IIRbypass_b[7]) ? {chan8_data, 3'b000} : chan8_IIR_out);// + {chan8_offset, 3'b000};
assign chan9_RAM_data = ((~IIRbypass_b[8]) ? {chan9_data, 3'b000} : chan9_IIR_out);// + {chan9_offset, 3'b000};
//assign p3_xdif_RAM_data = (~IIRbypass_b[6]) ? p3_xdif_data : p3_xdif_IIR_out;
//assign p3_ydif_RAM_data = (~IIRbypass_b[7]) ? p3_ydif_data : p3_ydif_IIR_out;
//assign p3_sum_RAM_data = (~IIRbypass_b[8]) ? p3_sum_data : p3_sum_IIR_out;

//assign chan7_offset_oflow = (^chan7_RAM_data[DSP_WIDTH:DSP_WIDTH-1]) ? 1'b1 : 1'b0;
//assign chan8_offset_oflow = (^chan8_RAM_data[DSP_WIDTH:DSP_WIDTH-1]) ? 1'b1 : 1'b0;
//assign chan9_offset_oflow = (^chan9_RAM_data[DSP_WIDTH:DSP_WIDTH-1]) ? 1'b1 : 1'b0;
assign chan7_offset_oflow = (^chan7_data[13:12]) ? 1'b1 : 1'b0;
assign chan8_offset_oflow = (^chan8_data[13:12]) ? 1'b1 : 1'b0;
assign chan9_offset_oflow = (^chan9_data[13:12]) ? 1'b1 : 1'b0;


// %%%%%%%%%%%%%%%%%%   P3 ADC GROUP DAQ_RAM MODULES   %%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

// Three RAM modules with self contained transmission logic.  Data are written 
// at 357MHz and number of samples tracked.  When tx_en goes high, data are sent
// to the UART

reg 			daq_chan7_tx_en = 1'b0;
wire 			daq_chan7_tx_done;
//wire [7:0] 	daq_p3_xdif_tx_data;
wire [6:0] 	daq_chan7_tx_data;
wire 			daq_chan7_tx_load;
DAQ_RAM daq_ram_chan7(
	.reset(daq_ram_rst),
	.tx_en(daq_chan7_tx_en),
	.tx_clk(clk40),
	.tx_data_ready(daq_chan7_tx_load),
	.tx_data(daq_chan7_tx_data),
	.tx_data_loaded(~uart_tx_empty),
	.tx_complete(daq_chan7_tx_done),
	.wr_clk(clk357),
	.wr_en(p3_store_strb),
	.wr_data({chan7_RAM_data[DSP_WIDTH-1], chan7_RAM_data[DSP_WIDTH-1:DSP_WIDTH-13]})
);

reg 			daq_chan8_tx_en = 1'b0;
wire 			daq_chan8_tx_done;
//wire [7:0] 	daq_p3_ydif_tx_data;
wire [6:0] 	daq_chan8_tx_data;
wire 			daq_chan8_tx_load;
DAQ_RAM daq_ram_chan8(
	.reset(daq_ram_rst),
	.tx_en(daq_chan8_tx_en),
	.tx_clk(clk40),
	.tx_data_ready(daq_chan8_tx_load),
	.tx_data(daq_chan8_tx_data),
	.tx_data_loaded(~uart_tx_empty),
	.tx_complete(daq_chan8_tx_done),
	.wr_clk(clk357),
	.wr_en(p3_store_strb),
	.wr_data({chan8_RAM_data[DSP_WIDTH-1], chan8_RAM_data[DSP_WIDTH-1:DSP_WIDTH-13]})
);

reg 			daq_chan9_tx_en = 1'b0;
wire 			daq_chan9_tx_done;
//wire [7:0] 	daq_p3_sum_tx_data;
wire [6:0] 	daq_chan9_tx_data;
wire 			daq_chan9_tx_load;
DAQ_RAM daq_ram_chan9(
	.reset(daq_ram_rst),
	.tx_en(daq_chan9_tx_en),
	.tx_clk(clk40),
	.tx_data_ready(daq_chan9_tx_load),
	.tx_data(daq_chan9_tx_data),
	.tx_data_loaded(~uart_tx_empty),
	.tx_complete(daq_chan9_tx_done),
	.wr_clk(clk357),
	.wr_en(p3_store_strb),
	.wr_data({chan9_RAM_data[DSP_WIDTH-1], chan9_RAM_data[DSP_WIDTH-1:DSP_WIDTH-13]})
);


// %%%%%%%%%%%%%%%%%%%%%%%%%%%%   DAC READBACKS  %%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

// Use DAQ RAMS to log and transmit the values put out onto dacs 1 & 3.  Using the
// dac clocks as write strobes means that each dac code will be written twice (clocks
// are 5.6ns pulses) for 6 values per dac per pulse

//Temporarily switched DAC 3 for DAC 2 due to available BNC conections

reg 			daq_dac1_tx_en = 1'b0;
wire 			daq_dac1_tx_done;
//wire [7:0] 	daq_dac1_tx_data;
wire [6:0] 	daq_dac1_tx_data;
wire 			daq_dac1_tx_load;
DAQ_RAM daq_dac1_sum(
	.reset(daq_ram_rst),
	.tx_en(daq_dac1_tx_en),
	.tx_clk(clk40),
	.tx_data_ready(daq_dac1_tx_load),
	.tx_data(daq_dac1_tx_data),
	.tx_data_loaded(~uart_tx_empty),
	.tx_complete(daq_dac1_tx_done),
	.wr_clk(clk357),
	.wr_en(dac1_clk),
	.wr_data({dac1_out[12], dac1_out})
	//.wr_en(1'b0),
	//.wr_data(14'b0)
);

reg 			daq_dac3_tx_en = 1'b0;
wire 			daq_dac3_tx_done;
//wire [7:0] 	daq_dac3_tx_data;
wire [6:0] 	daq_dac3_tx_data;
wire 			daq_dac3_tx_load;
DAQ_RAM daq_dac3_sum(
	.reset(daq_ram_rst),
	.tx_en(daq_dac3_tx_en),
	.tx_clk(clk40),
	.tx_data_ready(daq_dac3_tx_load),
	.tx_data(daq_dac3_tx_data),
	.tx_data_loaded(~uart_tx_empty),
	.tx_complete(daq_dac3_tx_done),
	.wr_clk(clk357),
	.wr_en(dac2_clk),
	.wr_data({dac2_out[12], dac2_out})
	//.wr_en(1'b0),
	//.wr_data(14'b0)
);

wire [14:0] gainlut_ld_addr;
wire [6:0]	gainlut_ld_data;

//Trigger Interleaver
wire output_en;
Interleaver Interleaver1(clk357, trig_strb, Interleave, FF_en, output_en);

//Amplifier trigger control
`ifdef INCLUDE_TESTBENCH
`else  
	AmpTrig2 #(26) AmpTrig1(clk357, TFSMstate[1], trig_out_en, trig_out1_delay, amp1_trig);
	AmpTrig2 #(26) AmpTrig2(clk357, TFSMstate[1], trig_out_en, trig_out2_delay, amp2_trig);
`endif

//Instance FF module
wire loop_oflowDet;

//%%%%%%%%%%%%%%%%%%% INCLUDE UART ON DIGINA %%%%%%%%%%%%%%%%%%////////
wire digIn1_uart = (use_trigSyncExt) ? 1'b0 : diginput1;
wire uart2_byte_rdy, uart2_rx_unload;
wire [7:0] uart2_rx_data;

/*uart2_rx #(8, 9600) uart2_rx (	
	.reset(dcm200_rst),
	.clk(clk40_ibufg),
	.uld_rx_data(uart2_rx_unload),
	.rx_enable(1'b1),
	.rx_data(uart2_rx_data),
	.rx_in(digIn1_uart),
	.byte_rdy(uart2_byte_rdy)
);*/

uart3_rx uart3_rx (	
	//.reset(dcm200_rst),
	.clk(clk357),
	.uld_rx_data(uart2_rx_unload),
	//.rx_enable(1'b1),
	.rx_data(uart2_rx_data),
	.rx_in(digIn1_uart),
	.byte_rdy(uart2_byte_rdy)
);
//uart_unload #(.BYTE_WIDTH(8),.WORD_WIDTH(13)) uart2_uld (.rst(dcm200_rst), .clk(clk40_ibufg), .byte_rdy(uart2_byte_rdy), .unload_uart(uart2_rx_unload));
uart_unload #(.BYTE_WIDTH(8),.WORD_WIDTH(13)) uart2_uld (.rst(dcm200_rst), .clk(clk357), .byte_rdy(uart2_byte_rdy), .unload_uart(uart2_rx_unload));

wire [12:0] k1constDAC = (constDAC1UARTor) ? {uart2_rx_data, 5'd0} : k1_const;
wire [12:0] k2constDAC = (constDAC2UARTor) ? {uart2_rx_data, 5'd0} : k2_const;

`ifdef UART2_SELF_CHECK
	uart2_tx #(8, 9600) uart2_tx (	
	.reset(dcm200_rst),
	.clk(clk40_ibufg),
	//.baud_rate(baud_rate),
	.ld_tx_data(~use_trigSyncExt),
	.tx_data(8'd42),
	.tx_enable(1'b1),
	.tx_out(DirIOB),
	.tx_empty()
);	
`else assign DirIOB = 1'bz;
`endif
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ////

`ifdef BUILD_CTF

PFF_DSP_16 loop (
	.clk(clk357),
	.store_strb(store_strb),
	.feedfwd_en_b(output_en), 
	//.feedfwd_en_b(FF_en && output_en), 
	//.useDiode_b(1'b1),
	.useDiode_b(useDiode),
	.loop2_useDiode_b(loop2_useDiode),
	.diodeGating_b(diodeGating),
	.loop2_diodeGating_b(loop2_diodeGating),
	.use_strobes_b(use_strbs), 
	.start_proc_b(start_addr), 
	.end_proc_b(end_addr), 
	.kick1_delay_b(k1_del), 
	.kick2_delay_b(k2_del), 
	.opMode_b(FFOpMode), 
	//.oflowMode_b(2'd2),
	.oflowMode_b(oflowMode),
	.kick1_constDac_val_b(k1constDAC), 
	.kick2_constDac_val_b(k2constDAC), 
	//.kick1_constDac_val_b(k1_const), 
	//.kick2_constDac_val_b(k2_const), 
	//.diodeIn(p1_xdif_RAM_data[15:3]),
	.diodeIn(chan1_RAM_data[DSP_WIDTH-1:DSP_WIDTH-13]), 
	.loop2_diodeIn(chan4_RAM_data[DSP_WIDTH-1:DSP_WIDTH-13]),
	.MixerIn(chan2_RAM_data[DSP_WIDTH-1:0]), 
	//.loop2_mixerIn(p2_ydif_RAM_data),
	.loop2_MixerIn(chan5_RAM_data[DSP_WIDTH-1:0]),
	//.mixerIn({p1_ydif_RAM_data, 3'b000}), 
	.kick1_gain_b(k1_gain), 
	.kick2_gain_b(k2_gain), 
	.loop2_kick1_gain_b(loop2_k1_gain), 
	.loop2_kick2_gain_b(loop2_k2_gain), 
	.DAC1clkPhase_b(DAC1phase), 
	.DAC2clkPhase_b(DAC2phase), 
	.oflowClr(1'b0), 
	.DAC1_IIRtapWeight(DAC1_IIRtapWeight), 
	.DAC2_IIRtapWeight(DAC2_IIRtapWeight), 
	//.IIRbypass(IIRbypass_b[10:9]),
	//.amp1lim_b(amp1lim),
	.oflowDetect(loop_oflowDet), 
	.kick1_dout(dac1_out), 
	.kick2_dout(dac2_out), 
	//.kick3_dout(dac3_out), 
	//.kick4_dout(dac4_out),
	.DAC1_en(dac1_clk), 
	.DAC2_en(dac2_clk)
	//.DAC3_en(dac3_clk), 
	//.DAC4_en(dac4_clk)
	);

`endif	

`ifdef BUILD_ATF
FBModule my_FBmod(
		.clk(clk357),
		.sel(bpm_sel),
		.ai_in(chan4_RAM_data[15:3]),
		.aq_in(chan5_RAM_data[15:3]),
		.bi_in(chan1_RAM_data[15:3]),
	   .bq_in(chan2_RAM_data[15:3]),
		.ci_in(chan7_RAM_data[15:3]),
		.cq_in(chan8_RAM_data[15:3]),
		.q_signal(chan9_RAM_data[15:3]),
		.bpm_lut_dinb(gainlut_ld_data),
		.bpm_lut_addrb(gainlut_ld_addr),
		.bpm1_i_lut_web(k1_p2_lut_wr_en),
		.bpm1_i_lut_doutb(bpm1_i_lut_doutb),
		.bpm1_q_lut_web(k1_p3_lut_wr_en),
		.bpm1_q_lut_doutb(bpm1_q_lut_doutb),
		.bpm2_i_lut_web(k2_p2_lut_wr_en),
		.bpm2_i_lut_doutb(bpm2_i_lut_doutb),
		.bpm2_q_lut_web(k2_p3_lut_wr_en),
		.bpm2_q_lut_doutb(bpm2_q_lut_doutb),
		.fb_sgnl(dac1_out),
		.b1_strobe_b(b1_strobe),
		.b2_strobe_b(b2_strobe),
		.delay_en(k1_delayloop_on),
		.store_strb(store_strb),
	   .slow_clk(clk40),
		.banana_corr_temp(k1_b2_offset),
		.const_dac(k1constDAC),
		.const_dac_en(k1_const_dac_en),
		.dac_clk(dac1_clk),
		.no_bunches_b(no_bunches),
		.no_samples_b(no_samples),
		.sample_spacing_b(sample_spacing),
		.oflow(oflow)
		);
`endif

//assign dac3_clk = dac1_clk;
//assign dac4_clk = dac2_clk;
//assign dac3_out = dac1_out;
//assign dac4_out = dac2_out;

/*
// %%%%%%%%%%%%%%%%   PROCESS DATA TO PRODUCE FB SIGNAL  %%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

// Modules contain lookup tables with Gain / Sum.  The output is multiplied
// by Y Difference to form FB signal.  This is passed to the DAC, and a DAC enable
// provided.  P2 drives K1, P3 drives K2
//
// REPLACED WITH COUPLED FEEDBACK LOOPS.  K1 AND K2 KICKS ARE LINEAR COMBINATION
// OF P2 AND P3 POSITIONS.  TWO LOOKUP TABLES PER LOOP NOW
//
// Multiplexed ingoing bunch strobes so any can be used in the loops.  The 'p2'
// input in the feedback loop is a high latency path, while 'p3' has minimal
// latency.  The multiplexer should send p2 & p3 bunch strobes respectively in
// normal operation

wire [14:0] gainlut_ld_addr;
wire [6:0]	gainlut_ld_data;

// Multiplex strobes
wire  cr_k1_bunch_strb_sel;
//wire			k1_low_lat_strb;
//wire			k1_high_lat_strb;
//assign k1_high_lat_strb = cr_k1_bunch_strb_sel[0] ? p1_bunch_strb_a :
//								  cr_k1_bunch_strb_sel[1] ? p2_bunch_strb_a :
//								  p3_bunch_strb_a;
//assign k1_low_lat_strb = cr_k1_bunch_strb_sel[3] ? p1_bunch_strb_a :
//								 cr_k1_bunch_strb_sel[4] ? p2_bunch_strb_a :
//								 p3_bunch_strb_a;									 

// **** P2 to K1 feedback ****
reg [12:0]  cr_k1_const_dac_out;
wire			cr_k1_const_dac_en;
wire			cr_k1_fb_en;
wire			cr_k1_delay_loop_en;
wire			k1_p2_lut_wr_en;
wire			k1_p3_lut_wr_en;
wire [12:0] k1_dac_out;
wire 			k1_dac_en;
reg  [12:0] cr_k1_b2_offset;
reg  [12:0] cr_k1_b3_offset;
wire [6:0]  cr_k1_fir_k1;
coupled_data_processing K1_FB ( 
	.clk(clk357),
	.rst(dcm200_rst),	
	.slow_clk(clk40), 
	.p2_sigma_in(p2_sum_data), 
	.p2_delta_in(p2_ydif_data), 
	.p3_sigma_in(cr_k1_bunch_strb_sel ? p3_sum_data : p2_sum_data), 
	.p3_delta_in(cr_k1_bunch_strb_sel ? p3_ydif_data : p2_ydif_data),
	.store_strb(p2_store_strb), 
	.p2_bunch_strb(p2_bunch_strb_a), 
	.p3_bunch_strb(cr_k1_bunch_strb_sel ? p3_bunch_strb_a : p2_bunch_strb_a), 
	.feedbck_en(cr_k1_fb_en), 
	.delay_loop_en(cr_k1_delay_loop_en), 
	.const_dac_en(cr_k1_const_dac_en), 
	.const_dac_out(cr_k1_const_dac_out), 
	.b2_offset(cr_k1_b2_offset),
	.b3_offset(cr_k1_b3_offset),
	.fir_k1(cr_k1_fir_k1),
	.p2_lut_dinb(gainlut_ld_data), 
	.p2_lut_addrb(gainlut_ld_addr),
	.p2_lut_web(k1_p2_lut_wr_en), 
	.p2_lut_doutb(),
	.p3_lut_dinb(gainlut_ld_data), 
	.p3_lut_addrb(gainlut_ld_addr),
	.p3_lut_web(k1_p3_lut_wr_en), 
	.p3_lut_doutb(),
	.amp_drive(k1_dac_out), 
	.dac_en(k1_dac_en)
);
//data_processing P2_to_K1_FB ( 
//	.clk(clk357),
//	.rst(dcm200_rst),	
//	.slow_clk(clk40), 
//	.sigma_in(p2_sum_data), 
//	.delta_in(p2_ydif_data), 
//	.store_strb(p2_store_strb), 
//	.bunch_strb(p2_bunch_strb_a), 
//	.feedbck_en(cr_k1_fb_en), 
//	.delay_loop_en(cr_k1_delay_loop_en), 
//	.const_dac_en(cr_k1_const_dac_en), 
//	.const_dac_out(cr_k1_const_dac_out), 
//	.b2_offset(cr_k1_b2_offset),
//	.b3_offset(cr_k1_b3_offset),
//	.fir_k1(cr_k1_fir_k1),
//	.lut_dinb(gainlut_ld_data), 
//	.lut_addrb(gainlut_ld_addr),
//	.lut_web(p2_lut_wr_en), 
//	.lut_doutb(),
//	.amp_drive(k1_dac_out), 
//	.dac_en(k1_dac_en)
//);

// **** Assign to two DAC outputs ****
assign dac1_out = k1_dac_out;
//assign dac3_out = k1_dac_out;
assign dac1_clk = k1_dac_en;
//assign dac3_clk = k1_dac_en;


// Multiplex strobes
//wire [5:0]  cr_k2_bunch_strb_sel;
//wire			k2_low_lat_strb;
//wire			k2_high_lat_strb;
//assign k2_high_lat_strb = cr_k2_bunch_strb_sel[0] ? p1_bunch_strb_a :
//								  cr_k2_bunch_strb_sel[1] ? p2_bunch_strb_a :
//								  p3_bunch_strb_a;
//assign k2_low_lat_strb = cr_k2_bunch_strb_sel[3] ? p1_bunch_strb_a :
//								 cr_k2_bunch_strb_sel[4] ? p2_bunch_strb_a :
//								 p3_bunch_strb_a;		

// **** P3 to K2 feedback ****
reg [12:0]  cr_k2_const_dac_out;
wire			cr_k2_const_dac_en;
wire			cr_k2_fb_en;
wire			cr_k2_delay_loop_en;
wire			k2_p2_lut_wr_en;
wire			k2_p3_lut_wr_en;
wire [12:0] k2_dac_out;
wire 			k2_dac_en;
reg  [12:0] cr_k2_b2_offset;
reg  [12:0] cr_k2_b3_offset;
wire [6:0]  cr_k2_fir_k1;
coupled_data_processing K2_FB ( 
	.clk(clk357),
	.rst(dcm200_rst),	
	.slow_clk(clk40), 
	.p2_sigma_in(p2_sum_data), 
	.p2_delta_in(p2_ydif_data), 
	.p3_sigma_in(p3_sum_data), 
	.p3_delta_in(p3_ydif_data),
	.store_strb(p3_store_strb), 
	.p2_bunch_strb(p2_bunch_strb_a), 
	.p3_bunch_strb(p3_bunch_strb_a), 
	.feedbck_en(cr_k2_fb_en), 
	.delay_loop_en(cr_k2_delay_loop_en), 
	.const_dac_en(cr_k2_const_dac_en), 
	.const_dac_out(cr_k2_const_dac_out), 
	.b2_offset(cr_k2_b2_offset),
	.b3_offset(cr_k2_b3_offset),
	.fir_k1(cr_k2_fir_k1),
	.p2_lut_dinb(gainlut_ld_data), 
	.p2_lut_addrb(gainlut_ld_addr),
	.p2_lut_web(k2_p2_lut_wr_en), 
	.p2_lut_doutb(),
	.p3_lut_dinb(gainlut_ld_data), 
	.p3_lut_addrb(gainlut_ld_addr),
	.p3_lut_web(k2_p3_lut_wr_en), 
	.p3_lut_doutb(),
	.amp_drive(k2_dac_out), 
	.dac_en(k2_dac_en)
);
//data_processing P3_to_K2_FB ( 
//	.clk(clk357), 
//	.rst(dcm200_rst),
//	.slow_clk(clk40), 
//	.sigma_in(p3_sum_data), 
//	.delta_in(p3_ydif_data), 
//	.store_strb(p3_store_strb), 
//	.bunch_strb(p3_bunch_strb_a), 
//	.feedbck_en(cr_k2_fb_en), 
//	.delay_loop_en(cr_k2_delay_loop_en), 
//	.const_dac_en(cr_k2_const_dac_en), 
//	.const_dac_out(cr_k2_const_dac_out),  
//	.b2_offset(cr_k2_b2_offset),
//	.b3_offset(cr_k2_b3_offset),
//	.fir_k1(cr_k2_fir_k1),
//	.lut_dinb(gainlut_ld_data), 
//	.lut_addrb(gainlut_ld_addr),
//	.lut_web(p3_lut_wr_en), 
//	.lut_doutb(),
//	.amp_drive(k2_dac_out), 
//	.dac_en(k2_dac_en) 
//);

// **** Assign to two DAC outputs ****
assign dac2_out = k2_dac_out;
//assign dac4_out = k2_dac_out;
assign dac2_clk = k2_dac_en;
//assign dac4_clk = k2_dac_en;

*/

// %%%%%%%%%%%%%%%%%%%%%%%%   DAQ SEQUENCER CONTROL    %%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

// State machine keeps track of the current transmission state, transmits
// timestamp and framing bytes, and enables DAQ_RAM transmission as appropriate
// The sequence begins on the falling edge of store strobe

// Sequence state parametrisation
//parameter TRANS_WAIT = 				5'd0;
parameter TRANS_STAMP =				5'd2;
parameter TRANS_CHAN1 = 			5'd4;
parameter TRANS_CHAN2 = 			5'd6;
parameter TRANS_CHAN3 = 			5'd8;
parameter TRANS_CHAN4 = 			5'd10;
parameter TRANS_CHAN5 = 			5'd12;
parameter TRANS_CHAN6 = 			5'd14;
parameter TRANS_CHAN7 = 			5'd16;
parameter TRANS_CHAN8 = 			5'd18;
parameter TRANS_CHAN9 = 			5'd20;
parameter TRANS_DAC_K1 = 			5'd22;
parameter TRANS_DAC_K2 = 			5'd24;
//parameter TRANS_357_RB =			5'd26;
parameter TRANS_40_RB =				5'd28;
parameter TRANS_MON_RB = 			5'd30;

// Control register readback control wires
wire			daq_readback_tx_done;
wire			daq_readback_tx_load;
//wire [7:0]	daq_readback_tx_data;
wire [6:0]	daq_readback_tx_data;
reg			daq_readback_tx_en = 1'b0;
//wire			daq_readback40_tx_done;
//wire			daq_readback40_tx_load;
//wire [7:0]	daq_readback40_tx_data;
//reg			daq_readback40_tx_en;

// Monitor readback control wires
wire			daq_readback_mon_tx_done;
wire			daq_readback_mon_tx_load;
//wire [7:0]	daq_readback_mon_tx_data;
wire [6:0]	daq_readback_mon_tx_data;

reg			daq_readback_mon_tx_en = 1'b0;

wire [4:0]  daq_trans_state;
wire 			daq_ram_tx_en;
reg 			current_daq_ram_tx_done = 1'b0;
//wire [7:0] 	daq_seq_tx_data;
wire [6:0] 	daq_seq_tx_data;
wire 			daq_seq_tx_ld;
wire 			poll_uart;
DAQ_sequencer2 DAQ_sequencer(
	.clk40(clk40_ibufg),
//	.clk40(clk40),
	.rst(dcm200_rst),
	.strobe(p1_store_strb),
	.poll_uart(poll_uart && ~run),
	.trans_done(current_daq_ram_tx_done),
	.num_chans(num_chans),
	.trans_state(daq_trans_state),
	.trans_en(daq_ram_tx_en),
	.rst_out(daq_ram_rst),
	.trig_rdy(trig_rdy),
	.rs232_tx_empty(uart_tx_empty),
	.rs232_tx_buffer(daq_seq_tx_data),
	.rs232_tx_ld(daq_seq_tx_ld)
);

// %%%%%%%%%%%%%   (DE)MULTIPLEX THE DAQ_RAM TX CONTROL SIGNALS   %%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
always @(posedge clk40) begin
	daq_chan1_tx_en <= 0;
	daq_chan2_tx_en <= 0;
	daq_chan3_tx_en  <= 0;
	daq_chan4_tx_en <= 0;
	daq_chan5_tx_en <= 0;
	daq_chan6_tx_en  <= 0;
	daq_chan7_tx_en <= 0;
	daq_chan8_tx_en <= 0;
	daq_chan9_tx_en  <= 0;
	daq_dac1_tx_en		<= 0;
	daq_dac3_tx_en 	<= 0;
	//daq_readback357_tx_en 	<= 0;
	daq_readback_tx_en		<= 0;
	daq_readback_mon_tx_en 	<= 0;
	case(daq_trans_state)
		TRANS_CHAN1 : daq_chan1_tx_en <= daq_ram_tx_en;
		TRANS_CHAN2 : daq_chan2_tx_en <= daq_ram_tx_en;
		TRANS_CHAN3  : daq_chan3_tx_en  <= daq_ram_tx_en;
		TRANS_CHAN4 : daq_chan4_tx_en <= daq_ram_tx_en;
		TRANS_CHAN5 : daq_chan5_tx_en <= daq_ram_tx_en;
		TRANS_CHAN6  : daq_chan6_tx_en  <= daq_ram_tx_en;
		TRANS_CHAN7 : daq_chan7_tx_en <= daq_ram_tx_en;
		TRANS_CHAN8 : daq_chan8_tx_en <= daq_ram_tx_en;
		TRANS_CHAN9  : daq_chan9_tx_en  <= daq_ram_tx_en;
		TRANS_DAC_K1  : daq_dac1_tx_en	 <= daq_ram_tx_en;
		TRANS_DAC_K2  : daq_dac3_tx_en	 <= daq_ram_tx_en;
		//TRANS_357_RB  : daq_readback357_tx_en 		<= daq_ram_tx_en;
		TRANS_40_RB   : daq_readback_tx_en  		<= daq_ram_tx_en;
		TRANS_MON_RB  : daq_readback_mon_tx_en  	<= daq_ram_tx_en;
	endcase
end
	
always @(posedge clk40) begin
	case(daq_trans_state)
		TRANS_CHAN1 : current_daq_ram_tx_done <= daq_chan1_tx_done;
		TRANS_CHAN2 : current_daq_ram_tx_done <= daq_chan2_tx_done;
		TRANS_CHAN3  : current_daq_ram_tx_done <= daq_chan3_tx_done;
		TRANS_CHAN4 : current_daq_ram_tx_done <= daq_chan4_tx_done;
		TRANS_CHAN5 : current_daq_ram_tx_done <= daq_chan5_tx_done;
		TRANS_CHAN6  : current_daq_ram_tx_done <= daq_chan6_tx_done;
		TRANS_CHAN7 : current_daq_ram_tx_done <= daq_chan7_tx_done;
		TRANS_CHAN8 : current_daq_ram_tx_done <= daq_chan8_tx_done;
		TRANS_CHAN9  : current_daq_ram_tx_done <= daq_chan9_tx_done;
		TRANS_DAC_K1  : current_daq_ram_tx_done <= daq_dac1_tx_done;
		TRANS_DAC_K2  : current_daq_ram_tx_done <= daq_dac3_tx_done;
		//TRANS_357_RB  : current_daq_ram_tx_done <= daq_readback357_tx_done;
		TRANS_40_RB   : current_daq_ram_tx_done <= daq_readback_tx_done;
		TRANS_MON_RB  : current_daq_ram_tx_done <= daq_readback_mon_tx_done;
		default		  : current_daq_ram_tx_done <= 0;
	endcase
end

// %%%%%%%%%%%%%%%%%%   MULITPLEX UART TX SIGNALS FOR DAQ   %%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
reg 			uart_tx_load = 1'b0;
reg  [7:0]	uart_tx_data = 8'd0;

always @(posedge clk40) begin
	case(daq_trans_state)
		TRANS_CHAN1 : uart_tx_load <= daq_chan1_tx_load;
		TRANS_CHAN2 : uart_tx_load <= daq_chan2_tx_load;
		TRANS_CHAN3  : uart_tx_load <= daq_chan3_tx_load;
		TRANS_CHAN4 : uart_tx_load <= daq_chan4_tx_load;
		TRANS_CHAN5 : uart_tx_load <= daq_chan5_tx_load;
		TRANS_CHAN6  : uart_tx_load <= daq_chan6_tx_load;
		TRANS_CHAN7 : uart_tx_load <= daq_chan7_tx_load;
		TRANS_CHAN8 : uart_tx_load <= daq_chan8_tx_load;
		TRANS_CHAN9  : uart_tx_load <= daq_chan9_tx_load;
		TRANS_DAC_K1  : uart_tx_load <= daq_dac1_tx_load;
		TRANS_DAC_K2  : uart_tx_load <= daq_dac3_tx_load;
		//TRANS_357_RB  : uart_tx_load <= daq_readback357_tx_load;
		TRANS_40_RB   : uart_tx_load <= daq_readback_tx_load;
		TRANS_MON_RB  : uart_tx_load <= daq_readback_mon_tx_load;
		//By default pass the sequencer's load signal
		default		  : uart_tx_load <= daq_seq_tx_ld;
	endcase
end

always @(posedge clk40) begin
	case(daq_trans_state)
		TRANS_STAMP   : uart_tx_data <= {1'b1, daq_seq_tx_data};
		TRANS_CHAN1 : uart_tx_data <= {1'b1, daq_chan1_tx_data};
		TRANS_CHAN2 : uart_tx_data <= {1'b1, daq_chan2_tx_data};
		TRANS_CHAN3  : uart_tx_data <= {1'b1, daq_chan3_tx_data};
		TRANS_CHAN4 : uart_tx_data <= {1'b1, daq_chan4_tx_data};
		TRANS_CHAN5 : uart_tx_data <= {1'b1, daq_chan5_tx_data};
		TRANS_CHAN6  : uart_tx_data <= {1'b1, daq_chan6_tx_data};
		TRANS_CHAN7 : uart_tx_data <= {1'b1, daq_chan7_tx_data};
		TRANS_CHAN8 : uart_tx_data <= {1'b1, daq_chan8_tx_data};
		TRANS_CHAN9  : uart_tx_data <= {1'b1, daq_chan9_tx_data};
		TRANS_DAC_K1  : uart_tx_data <= {1'b1, daq_dac1_tx_data};
		TRANS_DAC_K2  : uart_tx_data <= {1'b1, daq_dac3_tx_data};
		//TRANS_357_RB  : uart_tx_data <= daq_readback357_tx_data;
		TRANS_40_RB   : uart_tx_data <= {1'b1, daq_readback_tx_data};
		TRANS_MON_RB  : uart_tx_data <= {1'b1, daq_readback_mon_tx_data};
		//By default pass the sequencer's data signal
		default		  : uart_tx_data <= {1'b0, daq_seq_tx_data};
	endcase
end

// %%%%%%%%%%%%%%%%%%%   UART AND CONTROL REGISTERS   %%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

// **** Generate 115200 baud from the 40MHz clock ****
// **** MODIFIED FOR 460800 BAUD ****

/*reg 			baud_115200;
reg [7:0]	baud_cnt;
always @(posedge clk40) begin
	if (dcm200_rst) begin
		baud_115200 <= 0;
		baud_cnt <= 0;
	end else begin 
		//
		//if (baud_cnt == 8'd174) begin
		//if (baud_cnt == 8'd87) begin
		if (baud_cnt == 8'd43) begin
			baud_115200 <= ~baud_115200;
			baud_cnt <= 0;
		end else begin
			baud_cnt <= baud_cnt + 1;
		end
	end
end*/

// **** Instantiate UART ****
wire 			uart_rx_unload;
wire 			uart_rx_empty;
wire [7:0] 	uart_rx_data;
//wire [1:0] baud_rate;

/*uart uart1 (	
	.reset(dcm200_rst),
	.txclk(baud_115200),
	.ld_tx_data(uart_tx_load),
	.tx_data(uart_tx_data),
	.tx_enable(1'b1),
	.tx_out(rs232_out),
	.tx_empty(uart_tx_empty),
	.rxclk(clk40_ibufg),
	.uld_rx_data(uart_rx_unload),
	.rx_data(uart_rx_data),
	.rx_enable(1'b1),
	.rx_in(rs232_in),
	.rx_empty(uart_rx_empty)
);
*/
/*uart2_rx #(8, 9600) uart_rx (	
	.reset(dcm200_rst),
	.clk(clk40_ibufg),
	//.baud_rate(baud_rate),
	.uld_rx_data(uart_rx_unload),
	.rx_enable(1'b1),
	.rx_data(uart_rx_data),
	.rx_in(rs232_in),
	//.rx_empty(uart_rx_empty)
	.byte_rdy(uart_rx_empty)
);*/

uart_rx #(0) uart_rx (	
	.reset(dcm200_rst),
	.clk(clk40_ibufg),
	.baud_rate(baud_rate),
	.uld_rx_data(uart_rx_unload),
	.rx_enable(1'b1),
	.rx_data(uart_rx_data),
	.rx_in(rs232_in),
	.rx_empty(uart_rx_empty)
	//.byte_rdy(uart_rx_empty)
);

// **** Instantiate UART TX ****

/*uart2_tx #(8, 9600) uart_tx (	
	.reset(dcm200_rst),
	.clk(clk40),
	//.baud_rate(baud_rate),
	.ld_tx_data(uart_tx_load),
	.tx_data(uart_tx_data),
	.tx_enable(1'b1),
	.tx_out(rs232_out),
	.tx_empty(uart_tx_empty)
);	
*/
uart_tx #(0) uart_tx (	
	.reset(dcm200_rst),
	.clk(clk40),
	.baud_rate(baud_rate),
	.ld_tx_data(uart_tx_load),
	.tx_data(uart_tx_data),
	.tx_enable(1'b1),
	.tx_out(rs232_out),
	.tx_empty(uart_tx_empty)
);	
	
// **** Instantiate UART decoder ****
//wire [4:0] 	ctrl_reg_addr_357;
//wire [6:0] 	ctrl_reg_data_357;
//wire 			ctrl_reg_strb_357;
wire [6:0] 	ctrl_reg_addr;
wire [6:0] 	ctrl_reg_data;
wire 			ctrl_reg_strb;
wire			gainlut_ld_en;
wire [4:0]	gainlut_ld_select;
wire 			trim_lut_wr_en;
wire			trim_dac_trig;

uart_decoder3 uart_decoder (	
	.clk(clk40_ibufg),
	.rst(dcm200_rst),
	.data_in(uart_rx_data),
	.byte_rdy(~uart_rx_empty),
	.byte_uld(uart_rx_unload),
	//.current_addr_357(ctrl_reg_addr_357),
	//.data_strobe_357(ctrl_reg_strb_357),
	//.data_out_357(ctrl_reg_data_357),
	.current_addr(ctrl_reg_addr),
	.data_strobe(ctrl_reg_strb),
	.data_out(ctrl_reg_data),
	.ram_addr(gainlut_ld_addr),
	.ram_select(gainlut_ld_select),	
	.ram_data(gainlut_ld_data),
	.ram_data_strobe(gainlut_ld_en),
	.full_reset(full_rst_trig),
	.p1_delay_trig(delay_trig1),
	.p2_delay_trig(delay_trig2),
	.p3_delay_trig(delay_trig3),
	.clk357_idelay_rst(clk357_idelay_rst),
	.clk357_idelay_trig(clk357_idelay_trig),
	.trim_dac_trig(trim_dac_trig),
	//.poll_uart(poll_uart)
	.poll_uart(poll_uart),
	.pulse_ctr_rst(pulse_ctr_rst)
);	 

// **** Multiplex the gain lut load strobe ****
assign k1_p2_lut_wr_en = (gainlut_ld_select == 5'd0) ? gainlut_ld_en : 1'b0;
assign k1_p3_lut_wr_en = (gainlut_ld_select == 5'd1) ? gainlut_ld_en : 1'b0;
assign trim_lut_wr_en = (gainlut_ld_select == 5'd2) ? gainlut_ld_en : 1'b0;
assign k2_p2_lut_wr_en = (gainlut_ld_select == 5'd3) ? gainlut_ld_en : 1'b0;
assign k2_p3_lut_wr_en = (gainlut_ld_select == 5'd4) ? gainlut_ld_en : 1'b0;

// ******* Control Registers *******************


//integer i;
wire [CR_WIDTH-1:0] ctrl_reg_addr_cnt;

always @(posedge clk40) begin
	//Port A
	
	//if (dcm200_rst) for (i=0; i < N_CTRL_REGS; i=i+1) ctrl_regs[i] <= 0;
	/*else */ ctrl_regs[ctrl_reg_addr] <= (ctrl_reg_strb) ? ctrl_reg_data : ctrl_regs[ctrl_reg_addr];
	ctrl_regs_mem[ctrl_reg_addr] <= (ctrl_reg_strb) ? ctrl_reg_data : ctrl_regs_mem[ctrl_reg_addr];
	
end

ctrl_reg_readback #(CR_WIDTH, N_CTRL_REGS) ctrl_reg_readback (
	.clk(clk40),
	.rst(dcm200_rst),
	//.data(ctrl_regs[ctrl_reg_addr_cnt]),
	.tx_en(daq_readback_tx_en),
	.tx_data_loaded(~uart_tx_empty),
	.tx_data_ready(daq_readback_tx_load),
	//.tx_data(daq_readback_tx_data),
	.tx_complete(daq_readback_tx_done),
	.tx_cnt(ctrl_reg_addr_cnt)
);

//assign daq_readback_tx_data = {1'b1, ctrl_regs_mem[ctrl_reg_addr_cnt]};
assign daq_readback_tx_data = ctrl_regs_mem[ctrl_reg_addr_cnt];
//assign daq_readback_tx_data = {1'b1, ctrl_regs[ctrl_reg_addr_cnt]};


// **** Instantiate the 40MHz control registers ****
//wire [2:0] diginput1_code,  diginput2_code;
/*
wire [12:0] tmp_a_k1_b2_offset, tmp_a_k1_b3_offset;
reg  [12:0] tmp_b_k1_b2_offset, tmp_b_k1_b3_offset;
reg  [12:0] tmp_c_k1_b2_offset, tmp_c_k1_b3_offset;
wire [12:0] tmp_a_k2_b2_offset, tmp_a_k2_b3_offset;
reg  [12:0] tmp_b_k2_b2_offset, tmp_b_k2_b3_offset;
reg  [12:0] tmp_c_k2_b2_offset, tmp_c_k2_b3_offset;
*/
wire [6:0] 	tmp_a_p1_offset, tmp_a_p2_offset, tmp_a_p3_offset;
reg  [6:0]  tmp_b_p1_offset = 7'd0, tmp_b_p2_offset = 7'd0, tmp_b_p3_offset = 7'd0;
/*font5_ctrl_reg_40 font5_ctrl_reg_40_1 (
	.clk(clk40),
	.rst(dcm200_rst),
	.addr(ctrl_reg_addr_40),
	.data(ctrl_reg_data_40),
	.data_strb(ctrl_reg_strb_40),
	.tx_en(daq_readback40_tx_en),
	.tx_clk(clk40),
	.tx_data_ready(daq_readback40_tx_load),
	.tx_data(daq_readback40_tx_data),
	.tx_data_loaded(~uart_tx_empty),
	.tx_complete(daq_readback40_tx_done),
	.p1_align_ch_sel(cr_p1_align_ch_sel),
	.p2_align_ch_sel(cr_p2_align_ch_sel),
	.p3_align_ch_sel(cr_p3_align_ch_sel),
	.p1_offset_delay(tmp_a_p1_offset),
	.p2_offset_delay(tmp_a_p2_offset),
	.p3_offset_delay(tmp_a_p3_offset),
	.p1_scan_delay(cr_p1_scan_delay),
	.p2_scan_delay(cr_p2_scan_delay),
	.p3_scan_delay(cr_p3_scan_delay),
	.master357_delay(clk357_idelay_value),
	.k1_b2_offset(),
	.k1_b3_offset(),
	//.k1_b2_offset(tmp_a_k1_b2_offset),
	//.k1_b3_offset(tmp_a_k1_b3_offset),
	.ring_clk_thresh_code(diginput1_code),
	.trig_thresh_code(diginput2_code),
	//.k1_fir_k1(cr_k1_fir_k1),
	.k1_fir_k1(),
	.k2_b2_offset(),
	.k2_b3_offset(),
	//.k2_b2_offset(tmp_a_k2_b2_offset),
	//.k2_b3_offset(tmp_a_k2_b3_offset),
	.k2_fir_k1(),
	//.k2_fir_k1(cr_k2_fir_k1),
	//.k1_bunch_strb_sel(cr_k1_bunch_strb_sel)
	.k1_bunch_strb_sel()
	//.slow_clk_gate_en(slow_clk_gate_en)
//	.k2_bunch_strb_sel(cr_k2_bunch_strb_sel)
);*/

//Temporary 40 MHz compatability assigns - MUST BE CHANGED!!
assign cr_p1_align_ch_sel = p1_align_ch_sel;
assign cr_p2_align_ch_sel = p2_align_ch_sel;
assign cr_p3_align_ch_sel = p3_align_ch_sel;
assign tmp_a_p1_offset = p1_offset_delay;
assign tmp_a_p2_offset = p2_offset_delay;
assign tmp_a_p3_offset = p3_offset_delay;
assign cr_p1_scan_delay = p1_scan_delay;
assign cr_p2_scan_delay = p2_scan_delay;
assign cr_p3_scan_delay = p3_scan_delay;
assign clk357_idelay_value = master357_delay;
//assign diginput1_code = ring_clk_thresh_code;
//assign diginput2_code = trig_thresh_code;

// Register for timing
always @(posedge clk357) begin
	tmp_b_p1_offset <= tmp_a_p1_offset;
		// synthesis attribute shreg_extract of tmp_b_p1_offset is "no";
	tmp_b_p2_offset <= tmp_a_p2_offset;
		// synthesis attribute shreg_extract of tmp_b_p2_offset is "no";
	tmp_b_p3_offset <= tmp_a_p3_offset;
		// synthesis attribute shreg_extract of tmp_b_p3_offset is "no";
	cr_p1_offset_delay <= tmp_b_p1_offset;
		// synthesis attribute shreg_extract of cr_p1_offset_delay is "no";
	cr_p2_offset_delay <= tmp_b_p2_offset;
		// synthesis attribute shreg_extract of cr_p2_offset_delay is "no";
	cr_p3_offset_delay <= tmp_b_p3_offset;
		// synthesis attribute shreg_extract of cr_p3_offset_delay is "no";
/*
	cr_k1_b2_offset <= tmp_c_k1_b2_offset;
		// synthesis attribute shreg_extract of cr_k1_b2_offset is "no";
	cr_k1_b3_offset <= tmp_c_k1_b3_offset;
		// synthesis attribute shreg_extract of cr_k1_b3_offset is "no";		
	tmp_c_k1_b2_offset <= tmp_b_k1_b2_offset;
		// synthesis attribute shreg_extract of tmp_c_k1_b2_offset is "no";
	tmp_c_k1_b3_offset <= tmp_b_k1_b3_offset;
		// synthesis attribute shreg_extract of tmp_c_k1_b3_offset is "no";		
	tmp_b_k1_b2_offset <= tmp_a_k1_b2_offset;
		// synthesis attribute shreg_extract of tmp_b_k1_b2_offset is "no";
	tmp_b_k1_b3_offset <= tmp_a_k1_b3_offset;
		// synthesis attribute shreg_extract of tmp_b_k1_b3_offset is "no";


	cr_k2_b2_offset <= tmp_c_k2_b2_offset;
		// synthesis attribute shreg_extract of cr_k2_b2_offset is "no";
	cr_k2_b3_offset <= tmp_c_k2_b3_offset;
		// synthesis attribute shreg_extract of cr_k2_b3_offset is "no";		
	tmp_c_k2_b2_offset <= tmp_b_k2_b2_offset;
		// synthesis attribute shreg_extract of tmp_c_k2_b2_offset is "no";
	tmp_c_k2_b3_offset <= tmp_b_k2_b3_offset;
		// synthesis attribute shreg_extract of tmp_c_k2_b3_offset is "no";		
	tmp_b_k2_b2_offset <= tmp_a_k2_b2_offset;
		// synthesis attribute shreg_extract of tmp_b_k2_b2_offset is "no";
	tmp_b_k2_b3_offset <= tmp_a_k2_b3_offset;
		// synthesis attribute shreg_extract of tmp_b_k2_b3_offset is "no";
		
*/
end

// **** Instantiate the 357MHz control registers ****
//wire [12:0] temp_k1_const_dac_out;
//wire [12:0] temp_k2_const_dac_out;
/*font5_ctrl_reg_357 font4_ctrl_reg_357_1 (
	.clk(clk357),
	.rst(dcm200_rst),
	.addr(ctrl_reg_addr_357),
	.data(ctrl_reg_data_357),
	.data_strb(ctrl_reg_strb_357),
	.tx_en(daq_readback357_tx_en),
	.tx_clk(clk40),
	.tx_data_ready(daq_readback357_tx_load),
	.tx_data(daq_readback357_tx_data),
	.tx_data_loaded(~uart_tx_empty),
	.tx_complete(daq_readback357_tx_done),
	.trig_delay(),					
	.trig_out_delay(),	
	.trig_out_delay2(),	
	.trig_out_en(),	
//	.trig_out_delay(cr_trig_out_delay),	
//	.trig_out_delay2(cr_trig_out_delay2),	
//	.trig_out_en(cr_trig_out_en),			
	.p1_bunch1pos(),			
	.p1_bunch2pos(),			
	.p1_bunch3pos(),			
	.p2_bunch1pos(),			
	.p2_bunch2pos(),			
	.p2_bunch3pos(),
	.p3_bunch1pos(),			
	.p3_bunch2pos(),			
	.p3_bunch3pos(),
//	.p1_bunch1pos(cr_p1_b1_pos),			
//	.p1_bunch2pos(cr_p1_b2_pos),			
//	.p1_bunch3pos(cr_p1_b3_pos),			
//	.p2_bunch1pos(cr_p2_b1_pos),			
//	.p2_bunch2pos(cr_p2_b2_pos),			
//	.p2_bunch3pos(cr_p2_b3_pos),
//	.p3_bunch1pos(cr_p3_b1_pos),			
//	.p3_bunch2pos(cr_p3_b2_pos),			
//	.p3_bunch3pos(cr_p3_b3_pos),	
	.k1_fb_on(),				
	.k2_fb_on(),
	//.k1_fb_on(cr_k1_fb_en),				
	//.k2_fb_on(cr_k2_fb_en),	
	.k1_delayloop_on(),			
	.k2_delayloop_on(),
	//.k1_delayloop_on(cr_k1_delay_loop_en),			
	//.k2_delayloop_on(cr_k2_delay_loop_en),	
	.k1_const_dac_en(),			
	.k2_const_dac_en(),
	//.k1_const_dac_en(cr_k1_const_dac_en),			
	//.k2_const_dac_en(cr_k2_const_dac_en),	
	.k1_const_dac_out(),		
	.k2_const_dac_out(),		
	//.k1_const_dac_out(temp_k1_const_dac_out),		
	//.k2_const_dac_out(temp_k2_const_dac_out),
	.clk2_16_edge_sel(cr_clk2_16_edge_sel),
	.sample_hold_off(cr_sample_hold_off),
	.big_trig_delay(cr_trig_delay)
	//.sync_en(sync_en)
);*/


// **** Register the const_dac outputs for timing and ****
/*
always @(posedge clk357) begin
	cr_k1_const_dac_out <= temp_k1_const_dac_out;
	cr_k2_const_dac_out <= temp_k2_const_dac_out;
end
*/

// %%%%%%%%%%%%%%%%%%%%%%%% BOARD SYNCHRONISER %%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


wire [1:0] syncStatus;
wire syncOut;
boardSynchroniser3 synchro1(clk40, synch_en, trig_rdy, sync_cnt_n, sync_cnt_m, auxInA, syncOut, syncStatus[0], syncStatus[1]);
//boardSynchroniser synchro1(clk40, synch_en, trig_rdy, sync_cnt_n, sync_cnt_m, sync_opMode, syncStatus, syncInOut);
//boardSynchroniser synchro1(clk40, synch_en, trig_rdy, sync_cnt_n, sync_cnt_m, sync_opMode, DirectIO1);
//assign DirectIO1 = syncInOut;
assign auxOutC = syncOut;


// %%%%%%%%%%%%%%%%%%%%%%   READBACK MONITORS FOR DAQ  %%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

// Load important monitor signals into monitor_readback.  They are transmitted
// as part of the DAQ
// 357MHz signals registered to aid timing
wire [6:0] status;
reg dcm200_locked_a = 1'b0, idelayctrl_rdy_a = 1'b0; //clk_align_a, clk_align_b;
`ifdef CLK357_PLL
	reg pll_clk357_locked_a = 1'b0;
`endif
`ifdef FASTCLK_INT
	reg dcm360_locked_a = 1'b0;
`endif
//reg pll_clk357_locked_a, idelayctrl_rdy_a; //clk_align_a, clk_align_b;

reg rst_state_a = 1'b1, oflowDet =  1'b0, loop_oflowDet_b = 1'b0;
wire oflow_state;
(* shreg_extract = "no" *) reg oflow_state_a = 1'b0;

always @(posedge clk357) begin
	loop_oflowDet_b <= loop_oflowDet;
	oflowDet <= (loop_oflowDet_b | bank1_oflowDet | bank2_oflowDet | bank3_oflowDet);
	`ifdef CLK357_PLL
		pll_clk357_locked_a <= pll_clk357_locked;
	`endif
	dcm200_locked_a <= dcm200_locked;
	`ifdef FASTCLK_INT
		dcm360_locked_a <= dcm360_locked;
	`endif
	idelayctrl_rdy_a <= idelayctrl_rdy;
	//clk_align_a <= clk_align;
	//clk_align_b <= clk_align_a;
end
`ifdef CLK357_PLL
	assign status = {pll_clk357_locked_a, dcm200_locked_a, idelayctrl_rdy_a, led1_out, p3_mon_saturated, p2_mon_saturated, p1_mon_saturated};
`else
	assign status = {1'b0, dcm200_locked_a, idelayctrl_rdy_a, led1_out, p3_mon_saturated, p2_mon_saturated, p1_mon_saturated};
`endif
//overflow_detector oflowDet1(clk357, poll_uart || dcm200_rst, oflowDet && TFSMstate[2], oflow_state);
//overflow_detector oflowDet1(clk357, poll_uart || dcm200_rst, oflowDet, TFSMstate[2], oflow_state);
overflow_detector oflowDet1(clk357, poll_uart || dcm200_rst, oflowDet, store_strb, oflow_state);

`ifdef CLK357_PLL
	(* equivalent_register_removal = "no", shreg_extract = "no" *) reg clkPLL_sel_b, clkPLL_sel_c;
`endif
always @(posedge clk40) begin
	oflow_state_a <= oflow_state;
	rst_state_a <= rst_state;
	`ifdef CLK357_PLL
		clkPLL_sel_c <= ~clkPLL_sel;
		clkPLL_sel_b <= clkPLL_sel_c;
		clkPLL_sel_a <= clkPLL_sel_b;
	`endif
	end

monitor_readback monitor_readback1 (
	.clk(clk40),
	.rst(dcm200_rst),
	.tx_en(daq_readback_mon_tx_en),
	//.tx_clk(clk40),
	.tx_data_ready(daq_readback_mon_tx_load),
	.tx_data(daq_readback_mon_tx_data),
	.tx_data_loaded(~uart_tx_empty),
	.tx_complete(daq_readback_mon_tx_done),
	.rb0(status),
	.rb1(p1_mon_count1),
	.rb2(p1_mon_count2),
	.rb3(p1_mon_count3),
	`ifdef FASTCLK_INT
		.rb4({dcm360_locked_a, p1_mon_total_data_del}),
	`else
		.rb4({1'b0, p1_mon_total_data_del}),
	`endif
	//.rb4({clk_align_b, p1_mon_total_data_del}),
	.rb5(p2_mon_count1),
	.rb6(p2_mon_count2),
	.rb7(p2_mon_count3),
	//.rb8({1'b0, p2_mon_total_data_del}),
	.rb8({rst_state_a, p2_mon_total_data_del}),
	.rb9(p3_mon_count1),
	.rb10(p3_mon_count2),
	.rb11(p3_mon_count3),
	.rb12({oflow_state_a, p3_mon_total_data_del}),
	//.rb13({6'b000000,clk_align_b})
	.rb13({pulse_ctr,output_en}),
	.rb14({4'b0000, pile_up, syncStatus})
);


// %%%%%%%%%%%%%%%%%%%%%%%%%   TRIM DAC CONTROLS  %%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

// Instantiate the control logic for the trim dacs
trim_dac_ctrl trims (
	.clk40(clk40),
	.rst(dcm200_rst),
	.lut_in(gainlut_ld_data),
	.lut_addr(gainlut_ld_addr[4:0]),
	.lut_we(trim_lut_wr_en),
	.load_dacs(trim_dac_trig),
	.serial_out(trim_sdi),
	.clk_out(trim_sck),
	.enable_out(trim_cs_ld)
);



// %%%%%%%%%%%%%%%%%%%% DIGITAL INPUT THRESHOLDS  %%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

// The digital inputs have variable thresholds.  Each has two control lines
// diginputnA/B.  The signals are tristate giving 9 values using 0,1,z
//
// The 4 bit code from the control regs specifies which combination
//
//reg diginput1A, diginput1B;
always @(posedge clk40) begin
	case(diginput1_code[2:0])
		3'd0 : begin
			diginput1A <= 0;
			diginput1B <= 0;
		end
		3'd1 : begin
			diginput1A <= 1;
			diginput1B <= 0;
		end
		3'd2 : begin
			diginput1A <= 0;
			diginput1B <= 1;
		end
		3'd3 : begin
			diginput1A <= 1;
			diginput1B <= 1;
		end
		3'd4 : begin
			diginput1A <= 1'bz;
			diginput1B <= 0;
		end
		3'd5 : begin
			diginput1A <= 0;
			diginput1B <= 1'bz;
		end
		3'd6 : begin
			diginput1A <= 1'bz;
			diginput1B <= 1;
		end
		3'd7 : begin
			diginput1A <= 1;
			diginput1B <= 1'bz;
		end
		default : begin
			diginput1A <= 1'bz;
			diginput1B <= 1'bz;
		end
	endcase
end
	
always @(posedge clk40) begin
	case(diginput2_code[2:0])
		3'd0 : begin
			diginput2A <= 0;
			diginput2B <= 0;
		end
		3'd1 : begin
			diginput2A <= 1;
			diginput2B <= 0;
		end
		3'd2 : begin
			diginput2A <= 0;
			diginput2B <= 1;
		end
		3'd3 : begin
			diginput2A <= 1;
			diginput2B <= 1;
		end
		3'd4 : begin
			diginput2A <= 1'bz;
			diginput2B <= 0;
		end
		3'd5 : begin
			diginput2A <= 0;
			diginput2B <= 1'bz;
		end
		3'd6 : begin
			diginput2A <= 1'bz;
			diginput2B <= 1;
		end
		3'd7 : begin
			diginput2A <= 1;
			diginput2B <= 1'bz;
		end
		default : begin
			diginput2A <= 1'bz;
			diginput2B <= 1'bz;
		end
	endcase
end
/*
wire [35:0] control0, control1;
wire [255:0] trig0;

// Instantiate the module
chipscope_icon icon1 (
    .CONTROL0(control0), 
    .CONTROL1(control1)
    );

// Instantiate the module
chipscope_vio vio1 (
    .CONTROL(control0), 
    .CLK(), 
    .ASYNC_IN(), 
    .ASYNC_OUT(), 
    .SYNC_IN(), 
    .SYNC_OUT()
    );

// Instantiate the module
chipscope_ila ila1 (
    .CONTROL(control1), 
    .CLK(clk357), 
    .TRIG0(trig0)
    );

assign trig0={242'd0, p1_xdif_data, store_strb};
*/

// %%%%%%%%%%%%%%%%%%%   CHIPSCOPE CORES FOR DEBUGGING   %%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
/*
// **** ICON controller ****
  wire [35:0] control0;
  wire [35:0] control1;
  wire [35:0] control2;
  font5_icon i_font5_icon
    (
      .control0(control0),
      .control1(control1),
      .control2(control2)
    );

// **** VIO I/O ****
  wire [127:0] async_in;
  wire [127:0] async_out;
  font5_vio i_font5_vio
    (
      .control(control0),
      .async_in(async_in),
      .async_out(async_out)
    );
	 
// **** ILA for P1 data ****
  wire [47:0] ila_p1_data_trig;
  font5_p1_ila i_font5_p1_ila
    (
      .control(control1),
      .clk(clk357),
      .trig0(ila_p1_data_trig)
    );
	assign ila_p1_data_trig = {18'b0, p1_xdif_data, p1_store_strb};
	
// **** ILA for p1 ADC block monitoring ****
  wire [41:0] ila_p1_monitor_trigger;
  font5_p1_mon_ila i_font5_p1_mon_ila
    (
      .control(control2),
      .clk(clk40),
      .trig0(ila_p1_monitor_trigger)
    );
assign ila_p1_monitor_trigger ={p1_mon_total_drdy_del, p1_mon_total_data_del, p1_mon_delay_mod, p1_mon_count1, p1_mon_count2, p1_mon_count3, p1_mon_saturated, p1_mon_strb};
	 
// Assign VIO signals for debugging (128 bits for now)
//assign p1_xdif_polarity = async_out[12:0];
//assign p1_ydif_polarity = async_out[25:13];
//assign p1_sum_polarity  = async_out[38:26];
//assign cr_p1_offset_delay = async_out[5:0];
//assign trim_cnt_stop = async_out[8:0];
//assign trim_dac_addr = async_out[12:9];
//assign trim_dac_cmd = async_out[16:13];
//assign trim_ld_polarity = async_out[17];

// Assign VIO signals to monitor (~128 bits total)
 assign async_in[5:0] = clk357_idelay_mon;
 assign async_in[6] = pll_clk357_locked;
 assign async_in[7] = dcm200_locked;
 assign async_in[8] = idelayctrl_rdy;
 assign async_in[15:9] = cr_trig_delay;					
 assign async_in[22:16] = cr_trig_out_delay;		
 assign async_in[23] = cr_trig_out_en;		
 assign async_in[24] = cr_clk2_16_edge_sel; 
 assign async_in[30:25] = cr_p1_offset_delay;
 assign async_in[36:31] = cr_p1_scan_delay;
 assign async_in[42:37] = p1_mon_adc_clk_del;
//output 	[7:0]		p1_bunch1pos;			
//output 	[7:0]		p1_bunch2pos;			
//output 	[7:0]		p1_bunch3pos;			
//output  	[7:0]		p2_bunch1pos;			
//output 	[7:0]		p2_bunch2pos;			
//output 	[7:0]		p2_bunch3pos;		
//output 	[7:0]		p3_bunch1pos;		
//output 	[7:0]		p3_bunch2pos;			
//output 	[7:0]		p3_bunch3pos;			
//output 				k1_fb_on;				
//output 				k2_fb_on;				
//output			 	k1_delayloop_on;			
//output 				k2_delayloop_on;			
//output 				k1_const_dac_en;			
//output 				k2_const_dac_en;			
//output 	[13:0]	k1_const_dac_out;		
//output  	[13:0]	k2_const_dac_out;		
		
*/


endmodule


/*
module font5_icon 
  (
      control0,
      control1,
      control2
  );
  output [35:0] control0;
  output [35:0] control1;
  output [35:0] control2;
endmodule

module font5_vio
  (
    control,
    async_in,
    async_out
  );
  input  [35:0] control;
  input  [127:0] async_in;
  output [127:0] async_out;
endmodule

module font5_p1_ila
  (
    control,
    clk,
    trig0
  );
  input [35:0] control;
  input clk;
  input [47:0] trig0;
endmodule

module font5_p1_mon_ila
  (
    control,
    clk,
    trig0
  );
  input [35:0] control;
  input clk;
  input [41:0] trig0;
endmodule

*/

