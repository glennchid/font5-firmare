`timescale 1ns / 1ps


// UART wants the LSB first

// RX modified to accept 40 MHz clock and receive at 115200 bps
// Note 40e6 / 115200 = 347.2222 and 347.2 / 2 = 173.6  ~= 174 cycles

// For 460800
// 40e6 / 460800 = 86.8 and 86.8 / 2 =~= 43

// For 230400
// 40e6 / 230400 = 173.6 and 173.6/2 = 86.8

// Modified for 460800 baud rate

module uart_tx (
	input reset,
	input clk,
	input [1:0] baud_rate,
	input ld_tx_data,
	input [7:0] tx_data,
	input tx_enable,
	(* IOB = "TRUE" *) output reg tx_out,
	output reg tx_empty
);

parameter ML505 = 0; //default to 0 if not specified

// Internal registers
reg [7:0] tx_reg;
//reg          tx_over_run    ;
reg [3:0] tx_cnt;
reg [9:0] baud_cnt;
reg baud_clk;

// UART TX Logic
always @ (posedge clk) begin
	if (reset) begin
		baud_clk <= 1'b0;
		baud_cnt <= 10'b0;
		tx_reg        <= 8'd0;
		tx_empty      <= 1'b1;
		//tx_over_run   <= 0;
		tx_out        <= 1'b1;
		tx_cnt        <= 4'd0;
	end else begin // if (reset)
		if (ML505) begin
			if (baud_cnt == 10'd868) begin
				baud_clk <= 1'b1;
				baud_cnt <= 10'd0;
			end else begin
				baud_clk <= 1'b0;
				baud_cnt <= baud_cnt + 1;
			end 
		end else begin
			case(baud_rate)
				2'd0: begin // 115200 Baud
					if (baud_cnt == 10'd347) begin
						baud_clk <= 1'b1;
						baud_cnt <= 10'd0;
					end else begin
						baud_clk <= 1'b0;
						baud_cnt <= baud_cnt + 1;
					end 
				end
				2'd1: begin
					if (baud_cnt == 10'd174) begin // 230400 Baud
						baud_clk <= 1'b1;
						baud_cnt <= 10'd0;
					end else begin
						baud_clk <= 1'b0;
						baud_cnt <= baud_cnt + 1;
					end 
				end
				2'd2: begin	
					if (baud_cnt == 10'd87) begin // 460800 Baud
						baud_clk <= 1'b1;
						baud_cnt <= 10'd0;
					end else begin
						baud_clk <= 1'b0;
						baud_cnt <= baud_cnt + 1;
					end 
				end
				default: begin // deafult to 115200 Baud
					if (baud_cnt == 10'd347) begin
						baud_clk <= 1'b1;
						baud_cnt <= 10'd0;
					end else begin
						baud_clk <= 1'b0;
						baud_cnt <= baud_cnt + 1;
					end 
				end
			endcase
		end //if (~ML505)
	
		if (tx_enable && baud_clk) begin
			if (ld_tx_data && tx_empty) begin
				tx_reg   <= tx_data;
				tx_empty <= 1'b0;
				tx_out <= 1'b0; //Send start bit immediately
				tx_cnt <= tx_cnt;
			  //tx_over_run <= 0; // um....	??
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

endmodule
