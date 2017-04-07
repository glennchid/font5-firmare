`timescale 1ns / 1ps
// *****************  DAQ_sequencer ******************************************
//
// Modified for 9 channel
//
// Clocked at 40MHz
//
// This module is a state machine to control the sequence in which the various
// structures holding data for the DAQ stream are enabled.
//
// It Waits idle until it detects the falling edge of the store_strb.  At this
// point all data for the pulse have been collected and are ready to transmit
// over the UART.  
//
// The module can write values directly to the UART for framing and timestamp purposes,
// monitoring until the values are transmited.
//
// A 7-bit counter is implemented which increments every 40ms.  The value of
// this counter is transmitted at the start of each pulse to provide a timestamp
//
// It can also enable the DAQ_RAMs and monitor until they have exposed all of
// data.  To enable a DAQ_RAM, trans_en is taken high.  The appropriate DAQ_RAM
// output must be connected to the UART externally by multiplexing based on trans_state
// Once that DAQ_RAM has finished, trans_done goes high and the state increments
//
// When all data have finally been transmitted, a reset signal is sent to the DAQ_RAMS
// Reset is also sent when the sequencer module is itself reset


module DAQ_sequencer2(
	clk40,
	rst,
	strobe,
	poll_uart,
	trans_done,
	//num_chans_a,
	num_chans,
	trans_state,
	trans_en,
	rst_out,
	trig_rdy,
	rs232_tx_empty,
	rs232_tx_buffer,
	rs232_tx_ld
);

input 		clk40;
input rst;
input strobe;
input poll_uart;
input trans_done;
input rs232_tx_empty;
//input [8:0] num_chans_a;
input [8:0] num_chans;
output reg [4:0] trans_state = 5'd0;
output reg trans_en = 1'b0;
output reg rst_out = 1'b0;
output reg trig_rdy = 1'b0;
//output [7:0] rs232_tx_buffer;
output reg [6:0] rs232_tx_buffer = 7'd0;
output reg		 rs232_tx_ld = 1'b0;



//reg [8:0] num_chans = 9'b111111111;

// Internal registers
//reg [5:0] trans_state;
//reg trans_en;
//reg rst_out;

//reg  		 rs232_tx_ld = 0;
reg 		 rs232_tx_pending = 1'b0;
//reg [7:0] rs232_tx_buffer;

//reg [6:0] count_40ms;
reg [6:0] count_40ms = 7'd0;

reg strobe_a = 1'b0;
reg strobe_b = 1'b0;
reg rs232_tx_empty_a = 1'b0;
reg rs232_tx_empty_b = 1'b0;


// State parameterisation
parameter TRANS_WAIT = 				5'd0;
parameter TRANS_STAMP_FRAME =		5'd1;
parameter TRANS_STAMP =				5'd2;
parameter TRANS_P1_XDIF_FRAME = 	5'd3;
parameter TRANS_P1_XDIF = 			5'd4;
parameter TRANS_P1_YDIF_FRAME =	5'd5;
parameter TRANS_P1_YDIF = 			5'd6;
parameter TRANS_P1_SUM_FRAME =	5'd7;
parameter TRANS_P1_SUM = 			5'd8;
parameter TRANS_P2_XDIF_FRAME = 	5'd9;
parameter TRANS_P2_XDIF = 			5'd10;
parameter TRANS_P2_YDIF_FRAME =	5'd11;
parameter TRANS_P2_YDIF = 			5'd12;
parameter TRANS_P2_SUM_FRAME =	5'd13;
parameter TRANS_P2_SUM = 			5'd14;
parameter TRANS_P3_XDIF_FRAME = 	5'd15;
parameter TRANS_P3_XDIF = 			5'd16;
parameter TRANS_P3_YDIF_FRAME =	5'd17;
parameter TRANS_P3_YDIF = 			5'd18;
parameter TRANS_P3_SUM_FRAME =	5'd19;
parameter TRANS_P3_SUM = 			5'd20;
parameter TRANS_DAC_K1_FRAME =	5'd21;
parameter TRANS_DAC_K1 = 			5'd22;
parameter TRANS_DAC_K2_FRAME =	5'd23;
parameter TRANS_DAC_K2 = 			5'd24;
parameter TRANS_357_RB_FRAME = 	5'd25;
//parameter TRANS_357_RB =			5'd26;
parameter TRANS_40_RB_FRAME = 	5'd27;
parameter TRANS_40_RB =				5'd28;
parameter TRANS_MON_RB_FRAME = 	5'd29;
parameter TRANS_MON_RB = 			5'd30;
parameter TRANS_TERM_BYTE = 		5'd31;

always @(posedge clk40) begin
	//num_chans <= num_chans_a;
	if (rst) begin
		strobe_a <= 0;
		strobe_b <= 0;
		rs232_tx_empty_a <= 0;
		rs232_tx_empty_b <= 0;
		trans_state <= TRANS_WAIT;
		trans_en <= 0;
		//Propogate reset
		rst_out <= 1;
		trig_rdy <= 1'b1;
	end else begin
		//Synchronise the uart empty signal
		rs232_tx_empty_a <= rs232_tx_empty;
		rs232_tx_empty_b <= rs232_tx_empty_a;
		//Synchronise the strobe
		strobe_a <= strobe;
		strobe_b <= strobe_a;
		//On falling edge of strobe, move to first transmission state
//		if (~strobe_a && strobe_b) begin
//			trans_state <= TRANS_STAMP_FRAME;
//		end else begin
			//STATE MACHINE
			case (trans_state)
				TRANS_WAIT: begin
					//trans_state <= (~strobe_a && strobe_b) ? TRANS_STAMP_FRAME : trans_state;
					if (~strobe_a && strobe_b) trans_state <= TRANS_STAMP_FRAME;
					else if (poll_uart) trans_state <= TRANS_357_RB_FRAME;
					else trans_state <= trans_state;
					//Reset internal registers
					rs232_tx_ld <= 0;
					rs232_tx_pending <= 0;
					//If neither channel is transmitting, ensure the daq_ram reset is low
					rst_out <= 0;
					trig_rdy <= trig_rdy;
				end
				TRANS_STAMP_FRAME: begin
					//Transmit timestamp frame byte
					trig_rdy <= 1'b0;
					if (!rs232_tx_ld && rs232_tx_empty_b) begin
						if (rs232_tx_pending) begin
							//Transmission complete
							rs232_tx_pending <= 0;
							//Move to next state
							trans_state <= TRANS_STAMP;
						end else begin
							//uart is empty.  Load byte to transmit
							rs232_tx_buffer <= 7'd31;
							rs232_tx_ld <= 1;
						end
					end else begin
						if (rs232_tx_ld && !rs232_tx_empty_b) begin
							//byte loaded to uart.  
							//rs232_tx_empty will stay low until transmission complete
							rs232_tx_ld <= 0;
							rs232_tx_pending <= 1;
						end
					end
				end
				TRANS_STAMP: begin
					trig_rdy <= trig_rdy;
					//Transmit current timestamp as data
					if (!rs232_tx_ld && rs232_tx_empty_b) begin
						if (rs232_tx_pending) begin
							//Transmission complete
							rs232_tx_pending <= 0;
							//Move to next state
							trans_state <= TRANS_P1_XDIF_FRAME;
						end else begin
							//uart is empty.  Load timestamp byte to transmit
							//rs232_tx_buffer <= {1'b1, count_40ms};
							rs232_tx_buffer <= count_40ms;
							rs232_tx_ld <= 1;
						end
					end else begin
						if (rs232_tx_ld && !rs232_tx_empty_b) begin
							//byte loaded to uart.  
							//rs232_tx_empty will stay low until transmission complete
							rs232_tx_ld <= 0;
							rs232_tx_pending <= 1;
						end
					end
				end					
				TRANS_P1_XDIF_FRAME: begin
					trig_rdy <= trig_rdy;
					//Send P1 xdif frame byte directly to uart
					if (!rs232_tx_ld && rs232_tx_empty_b) begin
						if (rs232_tx_pending) begin
							//Transmission complete
							rs232_tx_pending <= 0;
							//Move to next state and enable DAQ_RAM transmission
							if (num_chans[0]) begin
								trans_en 	<= 1;
								trans_state <= TRANS_P1_XDIF;
								end else begin
								trans_en 	<= 0;
								trans_state <= TRANS_P1_YDIF_FRAME;
								end
						end else begin
							//uart is empty.  Load byte to transmit
							rs232_tx_buffer <= 7'd16;
							rs232_tx_ld <= 1;
						end
					end else begin
						if (rs232_tx_ld && !rs232_tx_empty_b) begin
							//byte loaded to uart.  
							//uart_tx_empty will stay low until transmission complete
							rs232_tx_ld <= 0;
							rs232_tx_pending <= 1;
						end
					end				
				end
				TRANS_P1_XDIF: begin
					trig_rdy <= trig_rdy;
					//Transmit until done, then start next
					if (trans_en) begin
						if (trans_done) begin
							trans_en 	<= 0;
							trans_state <= TRANS_P1_YDIF_FRAME;
						end
					end 
				end
				TRANS_P1_YDIF_FRAME: begin
					trig_rdy <= trig_rdy;
					//Send P1 ydif frame byte directly to uart
					if (!rs232_tx_ld && rs232_tx_empty_b) begin
						if (rs232_tx_pending) begin
							rs232_tx_pending <= 0;
							if (num_chans[1]) begin
								trans_en 	<= 1;
								trans_state <= TRANS_P1_YDIF;
								end else begin
								trans_en 	<= 0;
								trans_state <= TRANS_P1_SUM_FRAME;
								end
						end else begin
							//uart is empty.  Load byte to transmit
							rs232_tx_buffer <= 7'd18;
							rs232_tx_ld <= 1;
						end
					end else begin
						if (rs232_tx_ld && !rs232_tx_empty_b) begin
							//byte loaded to uart.  
							//uart_tx_empty will stay low until transmission complete
							rs232_tx_ld <= 0;
							rs232_tx_pending <= 1;
						end
					end				
				end
				TRANS_P1_YDIF: begin
					trig_rdy <= trig_rdy;
					//Transmit until done, then start next
					if (trans_en) begin
						if (trans_done) begin
							trans_en 	<= 0;
							trans_state <= TRANS_P1_SUM_FRAME;
						end
					end 
				end				
				TRANS_P1_SUM_FRAME: begin
					trig_rdy <= trig_rdy;
					//Send P1 sum frame byte directly to uart
					if (!rs232_tx_ld && rs232_tx_empty_b) begin
						if (rs232_tx_pending) begin
							//Transmission complete
							rs232_tx_pending <= 0;
							//Move to next state and enable DAQ_RAM transmission
							if (num_chans[2]) begin
								trans_en 	<= 1;
								trans_state <= TRANS_P1_SUM;
								end else begin
								trans_en 	<= 0;
								trans_state <= TRANS_P2_XDIF_FRAME;
								end
						end else begin
							//uart is empty.  Load byte to transmit
							rs232_tx_buffer <= 7'd20;
							rs232_tx_ld <= 1;
						end
					end else begin
						if (rs232_tx_ld && !rs232_tx_empty_b) begin
							//byte loaded to uart.  
							//uart_tx_empty will stay low until transmission complete
							rs232_tx_ld <= 0;
							rs232_tx_pending <= 1;
						end
					end				
				end
				TRANS_P1_SUM: begin
					trig_rdy <= trig_rdy;
					//Transmit until done, then move to default state
					if (trans_en) begin
						if (trans_done) begin
							trans_en 	<= 0;
							trans_state <= TRANS_P2_XDIF_FRAME;
						end
					end 
				end
				TRANS_P2_XDIF_FRAME: begin
					trig_rdy <= trig_rdy;
					//Send P2 xdif frame byte directly to uart
					if (!rs232_tx_ld && rs232_tx_empty_b) begin
						if (rs232_tx_pending) begin
							//Transmission complete
							rs232_tx_pending <= 0;
							//Move to next state and enable DAQ_RAM transmission
							if (num_chans[3]) begin
								trans_en 	<= 1;
								trans_state <= TRANS_P2_XDIF;
								end else begin
								trans_en 	<= 0;
								trans_state <= TRANS_P2_YDIF_FRAME;
								end
						end else begin
							//uart is empty.  Load byte to transmit
							rs232_tx_buffer <= 7'd21;
							rs232_tx_ld <= 1;
						end
					end else begin
						if (rs232_tx_ld && !rs232_tx_empty_b) begin
							//byte loaded to uart.  
							//uart_tx_empty will stay low until transmission complete
							rs232_tx_ld <= 0;
							rs232_tx_pending <= 1;
						end
					end				
				end
				TRANS_P2_XDIF: begin
					trig_rdy <= trig_rdy;
					//Transmit until done, then start next
					if (trans_en) begin
						if (trans_done) begin
							trans_en 	<= 0;
							trans_state <= TRANS_P2_YDIF_FRAME;
						end
					end 
				end
				TRANS_P2_YDIF_FRAME: begin
					trig_rdy <= trig_rdy;
					//Send P2 ydif frame byte directly to uart
					if (!rs232_tx_ld && rs232_tx_empty_b) begin
						if (rs232_tx_pending) begin
							rs232_tx_pending <= 0;
							if (num_chans[4]) begin
								trans_en 	<= 1;
								trans_state <= TRANS_P2_YDIF;
								end else begin
								trans_en 	<= 0;
								trans_state <= TRANS_P2_SUM_FRAME;
								end
						end else begin
							//uart is empty.  Load byte to transmit
							rs232_tx_buffer <= 7'd22;
							rs232_tx_ld <= 1;
						end
					end else begin
						if (rs232_tx_ld && !rs232_tx_empty_b) begin
							//byte loaded to uart.  
							//uart_tx_empty will stay low until transmission complete
							rs232_tx_ld <= 0;
							rs232_tx_pending <= 1;
						end
					end				
				end
				TRANS_P2_YDIF: begin
					trig_rdy <= trig_rdy;
					//Transmit until done, then start next
					if (trans_en) begin
						if (trans_done) begin
							trans_en 	<= 0;
							trans_state <= TRANS_P2_SUM_FRAME;
						end
					end 
				end				
				TRANS_P2_SUM_FRAME: begin
					trig_rdy <= trig_rdy;
					//Send P2 sum frame byte directly to uart
					if (!rs232_tx_ld && rs232_tx_empty_b) begin
						if (rs232_tx_pending) begin
							//Transmission complete
							rs232_tx_pending <= 0;
							//Move to next state and enable DAQ_RAM transmission
							if (num_chans[5]) begin
								trans_en 	<= 1;
								trans_state <= TRANS_P2_SUM;
								end else begin
								trans_en 	<= 0;
								trans_state <= TRANS_P3_XDIF_FRAME;
								end
						end else begin
							//uart is empty.  Load byte to transmit
							rs232_tx_buffer <= 7'd23;
							rs232_tx_ld <= 1;
						end
					end else begin
						if (rs232_tx_ld && !rs232_tx_empty_b) begin
							//byte loaded to uart.  
							//uart_tx_empty will stay low until transmission complete
							rs232_tx_ld <= 0;
							rs232_tx_pending <= 1;
						end
					end				
				end
				TRANS_P2_SUM: begin
					trig_rdy <= trig_rdy;
					//Transmit until done, then move to default state
					if (trans_en) begin
						if (trans_done) begin
							trans_en 	<= 0;
							trans_state <= TRANS_P3_XDIF_FRAME;
						end
					end 
				end
				TRANS_P3_XDIF_FRAME: begin
					trig_rdy <= trig_rdy;
					//Send P3 xdif frame byte directly to uart
					if (!rs232_tx_ld && rs232_tx_empty_b) begin
						if (rs232_tx_pending) begin
							//Transmission complete
							rs232_tx_pending <= 0;
							//Move to next state and enable DAQ_RAM transmission
							if (num_chans[6]) begin
								trans_en 	<= 1;
								trans_state <= TRANS_P3_XDIF;
								end else begin
								trans_en 	<= 0;
								trans_state <= TRANS_P3_YDIF_FRAME;
								end
						end else begin
							//uart is empty.  Load byte to transmit
							rs232_tx_buffer <= 7'd24;
							rs232_tx_ld <= 1;
						end
					end else begin
						if (rs232_tx_ld && !rs232_tx_empty_b) begin
							//byte loaded to uart.  
							//uart_tx_empty will stay low until transmission complete
							rs232_tx_ld <= 0;
							rs232_tx_pending <= 1;
						end
					end				
				end
				TRANS_P3_XDIF: begin
					trig_rdy <= trig_rdy;
					//Transmit until done, then start next
					if (trans_en) begin
						if (trans_done) begin
							trans_en 	<= 0;
							trans_state <= TRANS_P3_YDIF_FRAME;
						end
					end 
				end
				TRANS_P3_YDIF_FRAME: begin
					trig_rdy <= trig_rdy;
					//Send P3 ydif frame byte directly to uart
					if (!rs232_tx_ld && rs232_tx_empty_b) begin
						if (rs232_tx_pending) begin
							rs232_tx_pending <= 0;
							if (num_chans[7]) begin
								trans_en 	<= 1;
								trans_state <= TRANS_P3_YDIF;
								end else begin
								trans_en 	<= 0;
								trans_state <= TRANS_P3_SUM_FRAME;
								end
						end else begin
							//uart is empty.  Load byte to transmit
							rs232_tx_buffer <= 7'd25;
							rs232_tx_ld <= 1;
						end
					end else begin
						if (rs232_tx_ld && !rs232_tx_empty_b) begin
							//byte loaded to uart.  
							//uart_tx_empty will stay low until transmission complete
							rs232_tx_ld <= 0;
							rs232_tx_pending <= 1;
						end
					end				
				end
				TRANS_P3_YDIF: begin
					trig_rdy <= trig_rdy;
					//Transmit until done, then start next
					if (trans_en) begin
						if (trans_done) begin
							trans_en 	<= 0;
							trans_state <= TRANS_P3_SUM_FRAME;
						end
					end 
				end				
				TRANS_P3_SUM_FRAME: begin
					trig_rdy <= trig_rdy;
					//Send P3 sum frame byte directly to uart
					if (!rs232_tx_ld && rs232_tx_empty_b) begin
						if (rs232_tx_pending) begin
							//Transmission complete
							rs232_tx_pending <= 0;
							//Move to next state and enable DAQ_RAM transmission
							if (num_chans[8]) begin
								trans_en 	<= 1;
								trans_state <= TRANS_P3_SUM;
								end else begin
								trans_en 	<= 0;
								trans_state <= TRANS_DAC_K1_FRAME;
								end
						end else begin
							//uart is empty.  Load byte to transmit
							rs232_tx_buffer <= 7'd26;
							rs232_tx_ld <= 1;
						end
					end else begin
						if (rs232_tx_ld && !rs232_tx_empty_b) begin
							//byte loaded to uart.  
							//uart_tx_empty will stay low until transmission complete
							rs232_tx_ld <= 0;
							rs232_tx_pending <= 1;
						end
					end				
				end
				TRANS_P3_SUM: begin
					trig_rdy <= trig_rdy;
					//Transmit until done, and move to next state
					if (trans_en) begin
						if (trans_done) begin
							trans_en 	<= 0;
							trans_state <= TRANS_DAC_K1_FRAME;
						end
					end 
				end								
				TRANS_DAC_K1_FRAME: begin
					trig_rdy <= trig_rdy;
					if (!rs232_tx_ld && rs232_tx_empty_b) begin
						if (rs232_tx_pending) begin
							//Transmission complete
							rs232_tx_pending <= 0;
							//Move to next state and enable DAQ_RAM transmission
							trans_en 	<= 1;
							trans_state <= TRANS_DAC_K1;
						end else begin
							//uart is empty.  Load byte to transmit
							rs232_tx_buffer <= 7'd29;
							rs232_tx_ld <= 1;
						end
					end else begin
						if (rs232_tx_ld && !rs232_tx_empty_b) begin
							//byte loaded to uart.  
							//uart_tx_empty will stay low until transmission complete
							rs232_tx_ld <= 0;
							rs232_tx_pending <= 1;
						end
					end				
				end
				TRANS_DAC_K1: begin
					trig_rdy <= trig_rdy;
					//Transmit until done, and move to next state
					if (trans_en) begin
						if (trans_done) begin
							trans_en 	<= 0;
							trans_state <= TRANS_DAC_K2_FRAME;
						end
					end 
				end												
				TRANS_DAC_K2_FRAME: begin
					trig_rdy <= trig_rdy;
					if (!rs232_tx_ld && rs232_tx_empty_b) begin
						if (rs232_tx_pending) begin
							//Transmission complete
							rs232_tx_pending <= 0;
							//Move to next state and enable DAQ_RAM transmission
							trans_en 	<= 1;
							trans_state <= TRANS_DAC_K2;
						end else begin
							//uart is empty.  Load byte to transmit
							rs232_tx_buffer <= 7'd30;
							rs232_tx_ld <= 1;
						end
					end else begin
						if (rs232_tx_ld && !rs232_tx_empty_b) begin
							//byte loaded to uart.  
							//uart_tx_empty will stay low until transmission complete
							rs232_tx_ld <= 0;
							rs232_tx_pending <= 1;
						end
					end				
				end
				TRANS_DAC_K2: begin
					trig_rdy <= trig_rdy;
					//Transmit until done, and move to next state
					if (trans_en) begin
						if (trans_done) begin
							trans_en 	<= 0;
							trans_state <= TRANS_357_RB_FRAME;
						end
					end 
				end						
				TRANS_357_RB_FRAME: begin
					trig_rdy <= trig_rdy;
					//Send 357MHz readback frame byte directly to uart
					if (!rs232_tx_ld && rs232_tx_empty_b) begin
						if (rs232_tx_pending) begin
							//Transmission complete
							rs232_tx_pending <= 0;
							//Move to next state and enable control reg transmission
							trans_en 	<= 0;
							trans_state <= TRANS_40_RB_FRAME;
						end else begin
							//uart is empty.  Load byte to transmit
							rs232_tx_buffer <= 7'd27;
							rs232_tx_ld <= 1;
						end
					end else begin
						if (rs232_tx_ld && !rs232_tx_empty_b) begin
							//byte loaded to uart.  
							//uart_tx_empty will stay low until transmission complete
							rs232_tx_ld <= 0;
							rs232_tx_pending <= 1;
						end
					end				
				end
				/*TRANS_357_RB: begin
					//Transmit until done, then move to next state
					if (trans_en) begin
						if (trans_done) begin
							trans_en 	<= 0;
							trans_state <= TRANS_40_RB_FRAME;
						end
					end 
				end		*/		
				TRANS_40_RB_FRAME: begin
					trig_rdy <= trig_rdy;
					//Send 40MHz readback frame byte directly to uart
					if (!rs232_tx_ld && rs232_tx_empty_b) begin
						if (rs232_tx_pending) begin
							//Transmission complete
							rs232_tx_pending <= 0;
							//Move to next state and enable control reg transmission
							trans_en 	<= 1;
							trans_state <= TRANS_40_RB;
						end else begin
							//uart is empty.  Load byte to transmit
							rs232_tx_buffer <= 7'd28;
							rs232_tx_ld <= 1;
						end
					end else begin
						if (rs232_tx_ld && !rs232_tx_empty_b) begin
							//byte loaded to uart.  
							//uart_tx_empty will stay low until transmission complete
							rs232_tx_ld <= 0;
							rs232_tx_pending <= 1;
						end
					end				
				end
				TRANS_40_RB: begin
					trig_rdy <= trig_rdy;
					//Transmit until done, then send reset and move to default state
					if (trans_en) begin
						if (trans_done) begin
							trans_en 	<= 0;
							trans_state <= TRANS_MON_RB_FRAME;
						end
					end 
				end	
				TRANS_MON_RB_FRAME: begin
					trig_rdy <= trig_rdy;
					//Send monitor readback frame byte directly to uart
					if (!rs232_tx_ld && rs232_tx_empty_b) begin
						if (rs232_tx_pending) begin
							//Transmission complete
							rs232_tx_pending <= 0;
							//Move to next state and enable control reg transmission
							trans_en 	<= 1;
							trans_state <= TRANS_MON_RB;
						end else begin
							//uart is empty.  Load byte to transmit
							rs232_tx_buffer <= 7'd15;
							rs232_tx_ld <= 1;
						end
					end else begin
						if (rs232_tx_ld && !rs232_tx_empty_b) begin
							//byte loaded to uart.  
							//uart_tx_empty will stay low until transmission complete
							rs232_tx_ld <= 0;
							rs232_tx_pending <= 1;
						end
					end				
				end
				TRANS_MON_RB: begin
					trig_rdy <= trig_rdy;
					//Transmit until done, then send reset and move to default state
					if (trans_en) begin
						if (trans_done) begin
							trans_en 	<= 0;
							//rst_out 		<= 1;
							trans_state <= TRANS_TERM_BYTE;
						end
					end 
				end
				TRANS_TERM_BYTE: begin
				//Send monitor readback frame byte directly to uart
					if (!rs232_tx_ld && rs232_tx_empty_b) begin
						if (rs232_tx_pending) begin
							//Transmission complete
							rs232_tx_pending <= 0;
							//Move to next state and enable control reg transmission
							trans_en 	<= 0;
							rst_out		<= 1;
							trans_state <= TRANS_WAIT;
							trig_rdy <= 1'b1;
						end else begin
							//uart is empty.  Load byte to transmit
							rs232_tx_buffer <= 7'd14;
							rs232_tx_ld <= 1;
							trig_rdy <= trig_rdy;
						end
					end else begin
						if (rs232_tx_ld && !rs232_tx_empty_b) begin
							//byte loaded to uart.  
							//uart_tx_empty will stay low until transmission complete
							rs232_tx_ld <= 0;
							rs232_tx_pending <= 1;
							trig_rdy <= trig_rdy;
						end
					end				
				end
			endcase
		//end
	end
end

// Implement the 40ms 7-bit counter
reg [20:0]	cycle_count = 21'd0;
always @(posedge clk40) begin
	if (cycle_count == 21'd1600000) begin
		cycle_count <= 0;
		count_40ms <= count_40ms + 1;
	end else begin
		cycle_count <= cycle_count + 1;
	end
end

endmodule






//
//// *****************  dac_readback ******************************************
////
//// The dac output is loaded into a register array.  Each dac clock is used 
//// as a strobe to load the values at 357MHz.  The clocks are 5.6ns pulses,
//// so there will be 2 values clocked in per clock (i.e 6 per pulse, though each pair 
//// of values should be identical)
////
//// It contains transmission logic identical to the DAQ_RAM, and is triggered
//// last in the DAQ cycle to transmit its register contents as data
//
//module dac_readback(
//	reset,
//	tx_en,
//	tx_clk,
//	tx_data_ready,
//	tx_data,
//	tx_data_loaded,
//	tx_complete,
//	wr_clk,
//	wr_en,
//	wr_data
//);
//
//// Parameters
//parameter ARRAY_SIZE = 6;
//
//
//// Ports
//input				reset;
//input				tx_en;
//input				tx_clk;
//input				tx_data_loaded;
//output			tx_data_ready;
//output [7:0]	tx_data;
//output			tx_complete;
//input 			wr_clk;
//input 			wr_en;
//input  [13:0] 	wr_data;
//
//// Internal registers
//reg [10:0]  tx_cnt;
//reg			tx_data_ready;
//reg			tx_data_loaded1;
//reg			tx_data_loaded2;
//reg 			tx_complete;
//reg [7:0]	tx_data;
//reg [9:0]	wr_addr;
//
////Declare register array
//
