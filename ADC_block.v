`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:41:25 07/13/2009 
// Design Name: 
// Module Name:    slign_mon
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
//
// Finalised 20/08/09.  The same as testVA version with added data paths



// ****************  ADC_BLOCK   **********************************************
//
// This module deals with the io delays on the adc clock and the adc data+drdy
// The data and data ready come from the adc directly and are fed through idelay
// The data idelay has a nominal value set by calibration and passed to this module
//
// This module takes the input (logic) 357 clock and puts it through an odelay
// to clock the adc
//
// The phase of the ADC clock is changed by varying scan_delay.  This is added to the adc
// clock delay and subtracted from the data delays to maintain the data phase wrt
// logic 357 clock
//
// Sending delay_trig high synchronous to 40MHz causes a change in data_offset_delay or
// scan_delay to be registered
//
// This module also implements the align_monitor module
// Works only when align_en is taken high
// This monitors the phase of the first drdy signal wrt logic 357, and if it drifts
// a correction is applied to the data idelays
//
// Saturated goes high if one of the delays tries to move beyond its limit
//
// Monitoring signals are exposed, along with a strobe delay_mod_changed
//
// Three ADCs are clocked by a single adc clock, so there are 3 data I/Os and
// 3 drdy inputs.  align_ch_sel can be used to select which drdy to pass to the
// alignment monitor, but all data paths are given the same delay

module adc_block(
		input clk357,
		input clk40,
		input rst,
		input align_en,
		input [1:0] align_ch_sel,
		//input [12:0] ch1_data_in_del,
		//input [12:0] ch2_data_in_del,
		//input [12:0] ch3_data_in_del,
		input [6:0] data_offset_delay,
		input [5:0] scan_delay,
		input delay_trig,
		input IDDR_Q1,
		input IDDR_Q2,
		//output [12:0] ch1_data_out,
		//output [12:0] ch2_data_out,
		//output [12:0] ch3_data_out,
		output saturated,
		output [5:0] total_drdy_delay,		//Monitoring
		output [5:0] total_data_delay,		//Monitoring
		output [6:0] delay_mod,				//Monitoring
		output reg monitor_strb,			//Monitoring
		output [6:0] count1,					//Monitoring
		output [6:0] count2,					//Monitoring
		output [6:0] count3,					//Monitoring
		output [5:0] adc_clk_delay_mon,		//Monitoring
		output delay_calc_strb,
		output adc_drdy_delay_ce,
		output adc_clk_delay_ce,
		output adc_data_delay_ce
);

//(* IOB = "TRUE" *) reg [12:0] ch1_data_in_reg, ch2_data_in_reg, ch3_data_in_reg;

//Pipeline stage
//reg [12:0] ch1_data_in_a, ch2_data_in_a, ch3_data_in_a;
reg align_en_a;

// ***** Register the delayed signals in the IOB registers and pipeline *****
always @(posedge clk357) begin
	/*ch1_data_in_reg <= ch1_data_in_del;
	ch2_data_in_reg <= ch2_data_in_del;
	ch3_data_in_reg <= ch3_data_in_del;
	ch1_data_in_a <= ch1_data_in_reg;
	ch2_data_in_a <= ch2_data_in_reg;
	ch3_data_in_a <= ch3_data_in_reg;*/
	align_en_a <= align_en;
end

// ***** Assign the delayed, registered and pipelined signals to outputs *****
// Invert data MSB to convert from offset binary to 2's complement
/*assign ch1_data_out = {~ch1_data_in_a[12], ch1_data_in_a[11:0]};
assign ch2_data_out = {~ch2_data_in_a[12], ch2_data_in_a[11:0]};
assign ch3_data_out = {~ch3_data_in_a[12], ch3_data_in_a[11:0]};*/

//DON'T FOR NOW
// *****  Multiplex the DRDY signals  *****
// sel = 0,1,2  =>  ch1,ch2,ch3
//wire drdy;
//assign drdy = (align_ch_sel == 0) ? ch1_drdy_out : ( (align_ch_sel == 1) ? ch2_drdy_out : ch3_drdy_out);
//assign drdy = ch1_drdy_out;
	
//The delay calculator takes one 40MHz cycle to register the result
//of its calculation.  Register its strobe, and use it to trigger the
//delay incrementors after a cycle.  Also accept the delay_trig
reg iodelay_cnt_trig;
always @(posedge clk40) iodelay_cnt_trig <= (delay_calc_strb | delay_trig);
//Do the same for the monitor strobe
wire monitor_strb_in;
always @(posedge clk40) monitor_strb <= monitor_strb_in;

// *****  Instantiate the drdy delay incrementor  *****
wire [5:0] adc_drdy_delay;
iodelay_incrementor drdy_idelay_inc(
	.clk40(clk40),
	.rst(delay_calc_strb | delay_trig),			//This reset line goes high one cycle before the strb
	.count_trig(iodelay_cnt_trig),
	.spec_delay(adc_drdy_delay),
	.inc_en(adc_drdy_delay_ce),
	.actual_delay()
);




// *****  Instantiate the adc_clk odelay incrementor  *****
wire [5:0] adc_clk_delay;
iodelay_incrementor adc_clk_delay_inc(
	.clk40(clk40),
	.rst(delay_calc_strb | delay_trig),	//This reset line goes high one cycle before the strb
	.count_trig(iodelay_cnt_trig),
	.spec_delay(adc_clk_delay),
	.inc_en(adc_clk_delay_ce),
	.actual_delay(adc_clk_delay_mon)
);

//Instantiate the delay calculator
wire [5:0] adc_data_delay;
wire [6:0] delay_modifier;	
delay_calc delay_calc1(
	.clk40(clk40),
	.rst(rst),
	.data_offset_delay(data_offset_delay),
	.delay_modifier(delay_modifier),
	.scan_delay(scan_delay),
	.strb(delay_calc_strb | delay_trig),
	.adc_clock_delay(adc_clk_delay),
	.adc_data_delay(adc_data_delay),
	.adc_drdy_delay(adc_drdy_delay),
	.saturated(saturated)
);

//Instantiate the alignment monitor
align_monitor align_mon1( 
	.clk357(clk357),
	.clk40(clk40),
	.rst(rst),
	.align_en(align_en_a),
	.Q1(IDDR_Q1),
	.Q2(IDDR_Q2),
	.delay_modifier(delay_modifier),
	.delay_mod_strb(delay_calc_strb),
	.count1(count1),
	.count2(count2),
	.count3(count3),
	.monitor_strb(monitor_strb_in) 
);

// Output the delay modifier for monitoring
assign delay_mod = delay_modifier;
// Output actual data delay for monitoring
assign total_data_delay = adc_data_delay;
// Output drdy delay for monitoring
assign total_drdy_delay = adc_drdy_delay;

// *****  Instantiate the data delay incrementor  *****
iodelay_incrementor data_idelay_inc(
	.clk40(clk40),
	.rst(delay_calc_strb | delay_trig),			//This reset line goes high one cycle before the strb
	.count_trig(iodelay_cnt_trig),
	.spec_delay(adc_data_delay),
	.inc_en(adc_data_delay_ce),
	.actual_delay()
);
	
endmodule
