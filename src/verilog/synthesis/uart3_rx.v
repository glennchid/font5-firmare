`timescale 1ns / 1ps


// UART wants the LSB first

// RX modified to accept 40 MHz clock and receive at 115200 bps
// Note 40e6 / 115200 = 347.2222 and 347.2 / 2 = 173.6  ~= 174 cycles

// For 460800
// 40e6 / 460800 = 86.8 and 86.8 / 2 =~= 43

// For 230400
// 40e6 / 230400 = 173.6 and 173.6/2 = 86.8

// Modified for 460800 baud rate

module uart3_rx #(parameter real CLK_FREQ = 357e6, parameter real BAUD = 9600, parameter WIDTH = 8, parameter PARITY = 0, parameter STOP_BITS = 1) (	
	//input reset,
	input clk,
	input uld_rx_data,
	output reg [WIDTH-1:0] rx_data = {WIDTH{1'b0}},
	//input rx_enable,
	input rx_in,
	output reg byte_rdy = 1'b0
);

//Variable/custom Baud rate little-endian 8N1 UART-RX

`include "bits_to_fit.v"

//`ifdef ML505 localparam real CLK_FREQ = 100e6;
//`else localparam real CLK_FREQ = 40e6;
//`endif

localparam CLK16X_CNT_SIZE = bits_to_fit(CLK_FREQ/(16*BAUD));
localparam BIT_CNT_SIZE = bits_to_fit(WIDTH+PARITY+STOP_BITS+1);

localparam [CLK16X_CNT_SIZE-1:0] CLK16X_WIDTH = CLK_FREQ/(16*BAUD);
//localparam [BAUD_CNT_SIZE-1:0] FRAME_MIDPOINT = FRAME_WIDTH/2;


// Internal registers
reg [WIDTH-1:0]    rx_reg = {WIDTH{1'b0}};
reg [CLK16X_CNT_SIZE-1:0]    rx_sample_cnt = {CLK16X_CNT_SIZE{1'b0}};
reg [BIT_CNT_SIZE-1:0]    rx_cnt = {BIT_CNT_SIZE{1'b0}};  
reg [3:0] Baud_ctr = 4'd0;
(* ASYNC_REG = "true" *) reg          rx_da = 1'b1, rx_db = 1'b1;
reg          rx_busy = 1'b0;

// UART RX Logic - with 16X Baud Clock
always @ (posedge clk) begin
	// Synchronize the asynch signal
	rx_da <= rx_in;
	rx_db <= rx_da;
	// drive the ouptut register when requested
	rx_data <= (uld_rx_data) ? rx_reg : rx_data;

	/*if (reset) begin
		rx_sample_cnt <= {BAUD_CNT_SIZE{1'b0}};
		rx_cnt        <= {BIT_CNT_SIZE{1'b0}};
		byte_rdy		  <= 1'b0;
		rx_busy       <= 1'b0;
	end else begin // if (~reset)*/
	if (rx_busy) begin //drive logic, counters etc
		if (rx_sample_cnt == CLK16X_WIDTH) begin
			rx_sample_cnt <= {CLK16X_CNT_SIZE{1'b0}};
			Baud_ctr <= Baud_ctr + 1'b1;
			rx_cnt <= (Baud_ctr == 4'd15) ? rx_cnt + 1'b1 : rx_cnt;
			if (Baud_ctr == 4'd7)
				case(rx_cnt)
					{BIT_CNT_SIZE{1'b0}}: begin
						rx_busy <= ~rx_db;
						byte_rdy <= (uld_rx_data) ? 1'b0 : byte_rdy;
					end
					WIDTH+PARITY+STOP_BITS: begin
						rx_busy <= 1'b0;
						byte_rdy <= rx_db;
					end
					default: begin
						rx_reg[rx_cnt - 1'b1] <= rx_db;
						byte_rdy <= (uld_rx_data) ? 1'b0 : byte_rdy;
					end
				endcase
			else /*if (Baud_ctr!=7) */ byte_rdy <= (uld_rx_data) ? 1'b0 : byte_rdy;
		end else begin // if (rx_sample_cnt != CLK16X_WIDTH)
			rx_sample_cnt <= rx_sample_cnt + 1'b1;
			byte_rdy <= (uld_rx_data) ? 1'b0 : byte_rdy;
		end
	end else begin //if (~rx_busy)
		rx_busy <= ~rx_db; //detect space on line as start of START bit
		rx_sample_cnt <= {CLK16X_CNT_SIZE{1'b0}};
		Baud_ctr <= 4'd0;
		rx_cnt <= 1'b0;	 
		byte_rdy <= (uld_rx_data) ? 1'b0 : byte_rdy;
	end // if (~rx_busy)
	//end //if (~reset)		
end //always
				
endmodule
