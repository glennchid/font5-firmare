// *****************  DELAY_CALC  *********************************************
// v1.0 testbenched
//
// This module simply takes in three delay values and a synchronous strobe.
// When the strobe arrives, the 3 values are combined to calculate the tap setting
// of two IODELAY elements, with the two results being registered and stored
//
// data_offset_delay is used to vary the phase of the the data delays versus drdy
// In this way, constant offsets can be removed or sampling window measured
//
// For the ADC data IDELAYS, the formula is:
// data_offset_delay + delay_modifier - scan_delay
//
// For the ADC data and data ready IDELAYS, the formula is:
// delay_modifier - scan_delay
//
// Added a 32 count constant offset to data and drdy delays to allow -ve 
// delay modifier 
//
// For the ADC clock output ODELAY, the value is just scan_delay
//
// As scan_delay is increased, the phase between the logic 357 and the adc data
// is therefore preserved.  If the phase drifts (temperature etc), then this is 
// detected by the alignment monitor module which updates delay_modifier
//
// First, the register adc_data_delay_2s is written to.  This contains the 2's comp
// result of the the arithmetic (9-bit).  The output is based on this register,
// and saturates at 0 - 63.

module delay_calc (
	clk40,
	rst,
	data_offset_delay,
	delay_modifier,
	scan_delay,
	strb,
	adc_clock_delay,
	adc_data_delay,
	adc_drdy_delay,
	saturated
);

input clk40;
input rst;
input [6:0] data_offset_delay;
input [6:0] delay_modifier;
input [5:0] scan_delay;
input strb;

output [5:0] adc_clock_delay;
output [5:0] adc_data_delay;
output [5:0] adc_drdy_delay;
output saturated;

//Internal registers
reg [5:0] adc_clock_delay;
reg [7:0] adc_data_delay_2s;
reg [7:0] adc_drdy_delay_2s;

always @(posedge clk40) begin
	if (rst) begin
		adc_clock_delay <= 0;
		adc_data_delay_2s <= 0;
		adc_drdy_delay_2s <= 0;
	end else begin
		if (strb) begin
			//Calculate the output delay values
			//Note that data_offset_delay is signed and scan is unsigned, delay_modifier is twos complement
			//The scan_delay is flipped to be negative here
			//Adding together gives twos complement number from -127 to 126 (8 bit)
			//therefore must pad the other numbers to 8-bit for the maths to work
			//The 32 sets a middlepoint of the idelay as default
			adc_data_delay_2s <= 8'd32 + {data_offset_delay[6],data_offset_delay} + {delay_modifier[6],delay_modifier} + (8'b1 + ~scan_delay);
			adc_drdy_delay_2s <= 8'd32 + {delay_modifier[6],delay_modifier} + (8'b1 + ~scan_delay);
			adc_clock_delay <= scan_delay;
		end
	end
end

//Check for saturation
assign adc_data_delay = (adc_data_delay_2s[7] ? 6'b0 : ( (adc_data_delay_2s[6:0] > 6'd63) ? 6'd63 : adc_data_delay_2s[5:0]));
assign adc_drdy_delay = (adc_drdy_delay_2s[7] ? 6'b0 : ( (adc_drdy_delay_2s[6:0] > 6'd63) ? 6'd63 : adc_drdy_delay_2s[5:0]));
assign saturated = ( (adc_data_delay_2s[7] ? 1 : ( (adc_data_delay_2s[6:0] > 6'd63) ? 1 : 0)) ||
							(adc_drdy_delay_2s[7] ? 1 : ( (adc_drdy_delay_2s[6:0] > 6'd63) ? 1 : 0)) );

endmodule