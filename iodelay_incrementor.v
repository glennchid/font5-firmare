///////////////// ** iodelay_incrementor ** //////////////////////////////////////////
//
// This module is clocked at 40MHz.  It waits for a trigger pulse synchronous to 40Mhz,
// at which point it counts up to the spec_delay input in units of 40MHz using its
// internal 6 bit counter.  During this time, it outputs an inc_en strobe which is to be
// connected to an idelay element's ce.  In this way, the idelay's tap is set to the value
// of spec_delay.  The module exposes the counter value as actual_delay for debugging/monitoring
//
// Notes:  This element must be reset together with its associated idelay!!!!!
//			  The 6-bit counter will wrap around with the idelay's 6-bit tap count
//
	
module iodelay_incrementor(
	input clk40,
	input rst,
	input count_trig,
	input  [5:0] spec_delay,
	output reg inc_en,
	output reg [5:0] actual_delay
);

always @(posedge clk40) begin
	if (rst) begin
		inc_en <= 0;
		actual_delay <= 0;
	end else begin
		if (inc_en) begin
			//Triggered
			if (actual_delay == spec_delay) begin
				inc_en <= 0;
			end else begin
				actual_delay <= actual_delay + 1;
			end
		end else begin
			if (count_trig) begin
				//Trigger idelay count
				inc_en <= 1;
			end
		end
	end
end

endmodule
