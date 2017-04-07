`timescale 1ns / 1ps

///////////////// ** uart_decoder ** //////////////////////////////////////////
//
// This module listens to the UART RX data and interprets bytes as commands/data
// Clocked at the UART RX clock period of 40MHz
// Bytes are unloaded from UART manually
//
// MSB set implies data
// MSB unset implies command
//
// A command with bit 6 set specifies the address of a 7-bit control register, which becomes 
// current.  The less significant 6 bits hold the address (0-63)
// Of the control register addresses, 0-31 are dedicated to the 357 MHz domain registers
// and 32-63 indicate a 40 MHz register address with the LS 5 bits (i.e 0-31 again)
//
// Given an address 0-31
// The state reverts to the default STATE_CTRL_REGS_357
// Any subsequent data received are to be written to the current 357 control register
//
// Given an address 32-63 the state becomes STATE_CTRL_REGS_40
// Any subsequent data are written to the current 40 control register
//
// This module exposes the control reg data along with a single cycle strobe
// The current address is exposed continuously
//
// A command with bit 6 unset and bit 5 set specifies a RAM, which becomes current
// The less significant 5 bits are the RAM select (0-31, used in demultiplexing)
// The state changes to STATE_FILL_RAM
// An internal RAM address counter is set to zero
// Any subsequent data are output with single cycle strobe, incrementing the RAM addr count
// The RAM addr count is continuously exposed
//
// Note when using larger LUT, need to write addr 0-2, skip 3, 4-6, skip 7 etc.  This
// corresponds to not using the LUT's uppermost 7 bits.  The gain LUTs (select 0,1) require
// this.  Other LUTs do not
//
// A command with both bit 5 and 6 unset is a reserved command
// Includes XON/XOFF characters (0x11 / 0x13)
// Commands:
// 7'd0 == Full reset (sets full_reset output high for one cycle)
// 7'd1 == p1_delay_trig (sets delay_trig high for once cycle)
// 7'd2 == p2_delay_trig (sets delay_trig high for once cycle)
// 7'd3 == p3_delay_trig (sets delay_trig high for once cycle)
//
// For master 357Mhz delay.  First write new delay value to the ctrl_reg
// Then must send reset, followed by trigger.  Delay will then increment to new value
// 7'd4 == clk357_idelay_rst	
// 7'd5 == clk357_idelay_trig
//
// For trim DACS.  First load the trim dac LUT then send the trigger to update them
// 7'd6 == trim_dac_trig
//
// Reserved for framing bytes in the data stream
// 7'd15 == Monitor readback
// 7'd16 == P1 ch1		(0x10)
// 7'd18 == P1 ch2		(0x12)
// 7'd20 == P1 ch3		(0x14)
// 7'd21 == P2 ch1		(0x15)
// 7'd22 == P2 ch2		(0x16)
// 7'd23 == P2 ch3		(0x17)
// 7'd24 == P3 ch1		(0x18)
// 7'd25 == P3 ch2		(0x19)
// 7'd26 == P3 ch3		(0x1A)
// 7'd27 == 357MHz ctrl reg readback	(0x1B)
// 7'd28 == 40MHz  ctrl reg readback	(0x1C)
// 7'd29 == K1 DAC readback (0x1D)
// 7'd30 == K2 DAC readback (0x1E)
// 7'd31 == Timestamp readback (0x1F)


module uart_decoder3(	
	input				 clk,
	input 			 rst,
	input		[7:0]	 data_in,
	input				 byte_rdy,
	output reg			 byte_uld = 1'b0,
	output reg	[6:0]	 current_addr = 7'd0,
	output reg			 data_strobe = 1'b0,
	output reg	[6:0]	 data_out = 7'd0,
	output reg	[14:0] ram_addr = 15'd0,
	output reg	[6:0]	 ram_data = 7'd0,
	output reg			 ram_data_strobe = 1'b0,
	output reg	[4:0]	 ram_select = 5'd0,
	output reg		 	 full_reset = 1'b0,
	output reg         p1_delay_trig = 1'b0,
	output reg 			 p2_delay_trig = 1'b0,
	output reg 			 p3_delay_trig = 1'b0,
	output reg 			 clk357_idelay_rst = 1'b0,
	output reg 			 clk357_idelay_trig = 1'b0,
	output reg			 trim_dac_trig = 1'b0,
	//output reg			 poll_uart
	output reg			 poll_uart = 1'b0, 	
	output reg 			 pulse_ctr_rst = 1'b0
);

// State register values
parameter STATE_CTRL_REGS	= 1'b0;
parameter STATE_FILL_RAM		= 1'b1;


// Internal registers
reg		[1:0]	 ram_addr_skip = 2'b0;
reg				 state_register = 1'b0;

reg byte_rdy_b = 1'b0;
//wire byte_rdy_le = byte_rdy && ~byte_uld; // detect the rising edge of byte rdy
wire byte_rdy_fe = byte_rdy_b && ~byte_rdy; // detect the falling edge of byte rdy

always @(posedge clk) begin
	if (rst) begin
		// Enter default state (loading 357MHz domain control registers)
		state_register <= STATE_CTRL_REGS;
		byte_rdy_b <= 1'b0;
		byte_uld <= 1'b0;
		current_addr <= 7'd0;
		data_out <= 7'd0;
		data_strobe <= 1'b0;
		ram_data <= 7'd0;
		ram_addr <= 15'd0;
		ram_data_strobe <= 1'b0;
		ram_select <= 5'd0;
		full_reset <= 1'b0;
		p1_delay_trig <= 1'b0;
		p2_delay_trig <= 1'b0;
		p3_delay_trig <= 1'b0;
		clk357_idelay_rst <= 1'b0;
		clk357_idelay_trig <= 1'b0;
		ram_addr_skip <= 2'd0;
		trim_dac_trig <= 1'b0;
		poll_uart <= 1'b0;
		pulse_ctr_rst <= 1'b0;
	end else begin //Waiting for byte_rdy (synchronous to clk)
		byte_rdy_b <= byte_rdy;
		byte_uld <= (byte_rdy & ~byte_rdy_b) ? 1'b1 : 1'b0;
		/*if (byte_rdy) begin //Byte ready, unload it
			byte_uld <= (byte_uld) ? byte_uld : 1'b1; 
			state_register <= state_register;
			current_addr <= current_addr;
			data_out <= data_out;
			data_strobe <= data_strobe;
			ram_data <= ram_data;
			ram_addr <= ram_addr;
			ram_data_strobe <= ram_data_strobe;
			ram_select <= ram_select;
			full_reset <= full_reset;
			p1_delay_trig <= p1_delay_trig;
			p2_delay_trig <= p2_delay_trig;
			p3_delay_trig <= p3_delay_trig;
			clk357_idelay_rst <= clk357_idelay_rst;
			clk357_idelay_trig <= clk357_idelay_trig;
			ram_addr_skip <= ram_addr_skip;
			trim_dac_trig <= trim_dac_trig;
			poll_uart <= poll_uart;
			pulse_ctr_rst <= pulse_ctr_rst;
		end else begin //Byte has been unloaded*/
			//byte_uld <=  (byte_uld) ? 1'b0 : byte_uld;
			//DECODE BYTE HERE
			if (byte_rdy_fe && data_in[7]) begin //Byte contains data.  Redirect according to state
				state_register <= state_register;
				current_addr <= current_addr;
				ram_addr <= ram_addr;
				ram_select <= ram_select;
				full_reset <= full_reset;
				p1_delay_trig <= p1_delay_trig;
				p2_delay_trig <= p2_delay_trig;
				p3_delay_trig <= p3_delay_trig;
				clk357_idelay_rst <= clk357_idelay_rst;
				clk357_idelay_trig <= clk357_idelay_trig;
				ram_addr_skip <= ram_addr_skip;
				trim_dac_trig <= trim_dac_trig;
				poll_uart <= poll_uart;
				pulse_ctr_rst <= pulse_ctr_rst;
				case (state_register)
					STATE_CTRL_REGS: begin
						data_out <= data_in[6:0]; //Put 7-bit word on the data_out port
						data_strobe <= 1; // Set the data_strobe
						ram_data <= ram_data;
						ram_data_strobe <= ram_data_strobe;
					end
					STATE_FILL_RAM: begin
						ram_data <= data_in[6:0]; //Put 7-bit word on the ram_data port
						ram_data_strobe <= 1;	// Set the ram_data_strobe
						data_out <= data_out;
						data_strobe <= data_strobe;
					end
					default: begin //if state_register not 1 or 0 do nothing (this is not possible!)
						data_out <= data_out;
						data_strobe <= data_strobe;
						ram_data <= ram_data;
						ram_data_strobe <= ram_data_strobe;
					end
				endcase
			end else if (byte_rdy_fe && data_in<=8'd8) begin //This is a reserved command
				state_register <= state_register;
				current_addr <= current_addr;
				ram_addr <= ram_addr;
				ram_select <= ram_select;
				data_out <= data_out;
				data_strobe <= data_strobe;
				ram_data <= ram_data;
				ram_data_strobe <= ram_data_strobe;
				ram_addr_skip <= ram_addr_skip;
				case(data_in[3:0])
					4'd0: begin
						full_reset   		 <= 1'b1;
						p1_delay_trig <= p1_delay_trig;
						p2_delay_trig <= p2_delay_trig;
						p3_delay_trig <= p3_delay_trig;
						clk357_idelay_rst <= clk357_idelay_rst;
						clk357_idelay_trig <= clk357_idelay_trig;
						trim_dac_trig <= trim_dac_trig;
						poll_uart <= poll_uart;
						pulse_ctr_rst <= pulse_ctr_rst;
					end
					4'd1: begin
						p1_delay_trig 		 <= 1'b1;
						full_reset <= full_reset;
						p2_delay_trig <= p2_delay_trig;
						p3_delay_trig <= p3_delay_trig;
						clk357_idelay_rst <= clk357_idelay_rst;
						clk357_idelay_trig <= clk357_idelay_trig;
						trim_dac_trig <= trim_dac_trig;
						poll_uart <= poll_uart;
						pulse_ctr_rst <= pulse_ctr_rst;
					end
					4'd2: begin
						p2_delay_trig 		 <= 1'b1;
						full_reset <= full_reset;
						p1_delay_trig <= p1_delay_trig;
						p3_delay_trig <= p3_delay_trig;
						clk357_idelay_rst <= clk357_idelay_rst;
						clk357_idelay_trig <= clk357_idelay_trig;
						trim_dac_trig <= trim_dac_trig;
						poll_uart <= poll_uart;
						pulse_ctr_rst <= pulse_ctr_rst;
					end
					4'd3: begin
						p3_delay_trig 		 <= 1'b1;
						full_reset <= full_reset;
						p1_delay_trig <= p1_delay_trig;
						p2_delay_trig <= p2_delay_trig;
						clk357_idelay_rst <= clk357_idelay_rst;
						clk357_idelay_trig <= clk357_idelay_trig;
						trim_dac_trig <= trim_dac_trig;
						poll_uart <= poll_uart;
						pulse_ctr_rst <= pulse_ctr_rst;
					end
					4'd4: begin
						clk357_idelay_rst  <= 1'b1;
						full_reset <= full_reset;
						p1_delay_trig <= p1_delay_trig;
						p2_delay_trig <= p2_delay_trig;
						p3_delay_trig <= p3_delay_trig;
						clk357_idelay_trig <= clk357_idelay_trig;
						trim_dac_trig <= trim_dac_trig;
						poll_uart <= poll_uart;
						pulse_ctr_rst <= pulse_ctr_rst;
					end
					4'd5: begin
						clk357_idelay_trig <= 1'b1;
						full_reset <= full_reset;
						p1_delay_trig <= p1_delay_trig;
						p2_delay_trig <= p2_delay_trig;
						p3_delay_trig <= p3_delay_trig;
						clk357_idelay_rst <= clk357_idelay_rst;
						trim_dac_trig <= trim_dac_trig;
						poll_uart <= poll_uart;
						pulse_ctr_rst <= pulse_ctr_rst;
					end
					4'd6: begin
						trim_dac_trig		 <= 1'b1;
						full_reset <= full_reset;
						p1_delay_trig <= p1_delay_trig;
						p2_delay_trig <= p2_delay_trig;
						p3_delay_trig <= p3_delay_trig;
						clk357_idelay_rst <= clk357_idelay_rst;
						clk357_idelay_trig <= clk357_idelay_trig;
						poll_uart <= poll_uart;
						pulse_ctr_rst <= pulse_ctr_rst;
					end
					4'd7: begin 
						poll_uart <= 1'b1;
						full_reset <= full_reset;
						p1_delay_trig <= p1_delay_trig;
						p2_delay_trig <= p2_delay_trig;
						p3_delay_trig <= p3_delay_trig;
						clk357_idelay_rst <= clk357_idelay_rst;
						clk357_idelay_trig <= clk357_idelay_trig;
						trim_dac_trig <= trim_dac_trig;
						pulse_ctr_rst <= pulse_ctr_rst;
					end
					4'd8: begin
						pulse_ctr_rst <= 1'b1;
						full_reset <= full_reset;
						p1_delay_trig <= p1_delay_trig;
						p2_delay_trig <= p2_delay_trig;
						p3_delay_trig <= p3_delay_trig;
						clk357_idelay_rst <= clk357_idelay_rst;
						clk357_idelay_trig <= clk357_idelay_trig;
						trim_dac_trig <= trim_dac_trig;
						poll_uart <= poll_uart;
						end
					default: begin
						full_reset <= full_reset;
						p1_delay_trig <= p1_delay_trig;
						p2_delay_trig <= p2_delay_trig;
						p3_delay_trig <= p3_delay_trig;
						clk357_idelay_rst <= clk357_idelay_rst;
						clk357_idelay_trig <= clk357_idelay_trig;
						trim_dac_trig <= trim_dac_trig;
						poll_uart <= poll_uart;
						pulse_ctr_rst <= pulse_ctr_rst;
					end
				endcase
			end else if (byte_rdy_fe && data_in<=8'd36 && data_in>=8'd32) begin //This command specifies a RAM select
				state_register <= STATE_FILL_RAM; // Change State
				ram_select <= data_in[4:0]; // set ram_select to bottom 5 bits of data_in
				ram_addr <= 15'd0; //Reset ram address counter
				ram_addr_skip <= 2'd0; //Reset ram_addr_skip
				current_addr <= current_addr;
				data_out <= data_out;
				data_strobe <= data_strobe;
				ram_data <= ram_data;
				ram_data_strobe <= ram_data_strobe;
				full_reset <= full_reset;
				p1_delay_trig <= p1_delay_trig;
				p2_delay_trig <= p2_delay_trig;
				p3_delay_trig <= p3_delay_trig;
				clk357_idelay_rst <= clk357_idelay_rst;
				clk357_idelay_trig <= clk357_idelay_trig;
				trim_dac_trig <= trim_dac_trig;
				poll_uart <= poll_uart;
				pulse_ctr_rst <= pulse_ctr_rst;
			end else if (byte_rdy_fe) begin //This command specifies a control register
				state_register <= STATE_CTRL_REGS; // Change State
				current_addr <= data_in[6:0]; // set current_addr to bottom 6 bits of data_in
				data_out <= data_out;
				data_strobe <= data_strobe;
				ram_data <= ram_data;
				ram_data_strobe <= ram_data_strobe;
				ram_addr <= ram_addr;
				ram_select <= ram_select;
				full_reset <= full_reset;
				p1_delay_trig <= p1_delay_trig;
				p2_delay_trig <= p2_delay_trig;
				p3_delay_trig <= p3_delay_trig;
				clk357_idelay_rst <= clk357_idelay_rst;
				clk357_idelay_trig <= clk357_idelay_trig;
				ram_addr_skip <= ram_addr_skip;
				trim_dac_trig <= trim_dac_trig;
				poll_uart <= poll_uart;
				pulse_ctr_rst <= pulse_ctr_rst;
			end else begin //Reset the strobes after one cycle.   
				data_strobe    <= 1'b0;
				ram_data_strobe    <= 1'b0;
				full_reset		    <= 1'b0;				
				p1_delay_trig 	    <= 1'b0;
				p2_delay_trig 	    <= 1'b0;
				p3_delay_trig 	    <= 1'b0;
				clk357_idelay_rst  <= 1'b0;
				clk357_idelay_trig <= 1'b0; 
				trim_dac_trig		 <= 1'b0;
				poll_uart <= 1'b0;
				pulse_ctr_rst <= 1'b0;
				//Count RAM strobes to increment address
				//Skip the empty entries for FB LUTs, but not for the trim dac lut
				if (ram_data_strobe) begin
					if ((ram_select != 5'd2) && (ram_addr_skip == 2'd2)) begin
						ram_addr <= ram_addr + 2;
						ram_addr_skip <= 0;
					end else begin
						ram_addr_skip <= ram_addr_skip + 1;
						ram_addr <= ram_addr + 1;
					end //if(~ram_select !=5'd2)
				end else begin
					ram_addr <= ram_addr;
					ram_addr_skip <= ram_addr_skip;
				end //if (ram_addr_strobe)
				state_register <= state_register;
				current_addr <= current_addr;
				ram_select <= ram_select;
				data_out <= data_out;
				ram_data <= ram_data;
			end //if (~byte_uld etc)
		//end //if (~byte_rdy)
	end //if (~rst)
end //always

endmodule