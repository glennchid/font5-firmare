///////////////// ** reset_ctrl ** //////////////////////////////////////////
//
// This module is clocked at 40MHz.  It waits for a trigger pulse synchronous to
// 40MHz before initiating one of two reset routines
//
// idelay_rst_trig causes a reset of the idelayctrl and idelay instances.  The idelayctrl
// is has its asynch reset held high for 3 cycles of 40MHz (75ns - the minimum reset time is 50ns)
// Both idelay resets are then asserted (synchronous to 40MHz as req'd) for a cycle
//
// The 200MHz clock used by idelayctrl is produced with a DCM and must be stable prior
// to reset.  full_rst_trig causes the DCM to be reset first using its asynch reset line
// The DCM nominally takes 10ms to lock, after which the reset must be held for a further
// 200ms to ensure stability.  The idelayctrl reset must be tied to the the DCMs locked signal
//
// 210ms = 8,400,000 cycles of 40MHz (24-bit counter)

module reset_ctrl(
	input clk40,
	input idelay_rst_trig,
	input full_rst_trig,
	output reg dcm_rst = 1'b0,
	output reg idelay_rst = 1'b0
);

// Ports
/*input 	clk40;
input 	idelay_rst_trig;
input		full_rst_trig;
output 	dcm_rst;
output 	idelay_rst;*/

// Internal registers
//reg 			dcm_rst;
//reg 			idelay_rst;
reg 			rst_flag = 1'b0;
reg [23:0]	rst_count = 24'd0;

always @(posedge clk40) begin
	if (rst_flag) begin
		//Triggered
		rst_count <= rst_count + 1'd1;
		case (rst_count)
			24'd0: begin
				//Begin resetting DCM
				dcm_rst <= 1'b1;
				idelay_rst <= idelay_rst;
				rst_flag <= rst_flag;
			end
			24'd8500000: begin
				//212.5ms have passed.  Stop reset then reset idelayctrl
				dcm_rst <= 1'b0;
				idelay_rst <= idelay_rst;
				rst_flag <= rst_flag;
			end
			24'd8500010: begin
				//idelayctrl is reset.  Now do idelays
				idelay_rst <= 1'b1;
				dcm_rst <= dcm_rst;
				rst_flag <= rst_flag;
			end
			24'd8500020: begin
				//Finished
				idelay_rst <= 1'b0;
				dcm_rst <= dcm_rst;
				rst_flag <= 1'b0;
			end
		endcase
	end else begin
		//Not triggered yet
		if (idelay_rst_trig) begin
			//Trigger partial reset
			rst_flag <= 1'b1;
			rst_count <= 24'd8500010;
			idelay_rst <= idelay_rst;
			dcm_rst <= dcm_rst;
		end else begin
			//Trigger full reset
			if (full_rst_trig) begin
				rst_flag <= 1'b1;
				rst_count <= 24'd0;
				idelay_rst <= idelay_rst;
				dcm_rst <= dcm_rst;
			end
		end
	end
end

endmodule
