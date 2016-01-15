`timescale 1ns / 1ps


// UART wants the LSB first

// RX modified to accept 40 MHz clock and receive at 115200 bps
// Note 40e6 / 115200 = 347.2222 and 347.2 / 2 = 173.6  ~= 174 cycles

// For 460800
// 40e6 / 460800 = 86.8 and 86.8 / 2 =~= 43

// For 230400
// 40e6 / 230400 = 173.6 and 173.6/2 = 86.8

// Modified for 460800 baud rate

module uart2_tx #(parameter WIDTH = 8, parameter real BAUD = 9600) (
	input reset,
	input clk,
	//input [1:0] baud_rate,
	input ld_tx_data,
	input [WIDTH-1:0] tx_data,
	input tx_enable,
	(* IOB = "TRUE" *) output reg tx_out = 1'b1,
	output reg tx_empty = 1'b1
);

//parameter ML505 = 0; //default to 0 if not specified

`ifdef ML505 localparam real CLK_FREQ = 100e6;
`else localparam real CLK_FREQ = 40e6;
`endif

localparam BAUD_CNT_SIZE = bits_to_fit(CLK_FREQ/BAUD);
localparam BIT_CNT_SIZE = bits_to_fit(WIDTH+2);
localparam [BAUD_CNT_SIZE-1:0] FRAME_WIDTH = CLK_FREQ/BAUD;

// Internal registers
reg [WIDTH-1:0] tx_reg = {WIDTH{1'b0}};
reg [BIT_CNT_SIZE-1:0] tx_cnt = {BIT_CNT_SIZE{1'b0}};
reg [BAUD_CNT_SIZE-1:0] baud_cnt = {BAUD_CNT_SIZE{1'b0}};
reg baud_clk = 1'b0;

// UART TX Logic
always @ (posedge clk) begin
	if (reset) begin
		baud_clk 		<= 1'b0;
		baud_cnt 		<= {BAUD_CNT_SIZE{1'b0}};
		tx_reg       	<= {WIDTH{1'b0}};
		tx_empty      	<= 1'b1;
		tx_out        	<= 1'b1;
		tx_cnt        	<= {BIT_CNT_SIZE{1'b0}};
	end else begin // if (reset)
		if (baud_cnt == FRAME_WIDTH) begin
			baud_clk <= 1'b1;
			baud_cnt <= {BAUD_CNT_SIZE{1'b0}};
		end else begin
			baud_clk <= 1'b0;
			baud_cnt <= baud_cnt + 1'b1;
		end 
		
	
		if (tx_enable && baud_clk) begin
			if (ld_tx_data && tx_empty) begin
				tx_reg   <= tx_data;
				tx_empty <= 1'b0;
				tx_out <= 1'b0; //Send start bit immediately
				tx_cnt <= tx_cnt;
			end else if (!tx_empty) begin
				tx_reg <= tx_reg;
				if (tx_cnt == 4'd8) begin
					tx_cnt <= 4'd0;
					tx_out <= 1'b1;
					tx_empty <= 1'b1;
				end else begin
					tx_cnt <= tx_cnt + 1;
					tx_out <= tx_reg[tx_cnt];
					tx_empty <= tx_empty;
				end
			end else begin
				tx_reg <= tx_reg;
				tx_cnt <= tx_cnt;
				tx_out <= tx_out;
				tx_empty <= tx_empty;
			end
		end else begin
			tx_reg <= tx_reg;
			tx_cnt <= tx_cnt;
			tx_out <= tx_out;
			tx_empty <= tx_empty;
		end //if (~(tx_enable && baud_clk))
	end //if (~reset)
end //always

function integer bits_to_fit;
  input [31:0] value;
  for (bits_to_fit=0; value>0; bits_to_fit=bits_to_fit+1)
    value = value >> 1;
endfunction

endmodule
