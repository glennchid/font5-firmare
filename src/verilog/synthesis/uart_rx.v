`timescale 1ns / 1ps


// UART wants the LSB first

// RX modified to accept 40 MHz clock and receive at 115200 bps
// Note 40e6 / 115200 = 347.2222 and 347.2 / 2 = 173.6  ~= 174 cycles

// For 460800
// 40e6 / 460800 = 86.8 and 86.8 / 2 =~= 43

// For 230400
// 40e6 / 230400 = 173.6 and 173.6/2 = 86.8

// Modified for 460800 baud rate

module uart_rx (	
	input reset,
	input clk,
	input [1:0] baud_rate,
	input uld_rx_data,
	output reg [7:0] rx_data,
	input rx_enable,
	input rx_in,
	output reg rx_empty
);

parameter ML505 = 0; //default to 0 if not specified


// Internal registers
reg [7:0]    rx_reg         ;
reg [9:0]    rx_sample_cnt  ;
reg [3:0]    rx_cnt         ;  
reg          rx_frame_err   ;
(* IOB = "TRUE" *) reg rx_d1;
reg          rx_d2          ;
reg          rx_busy        ;
//reg 			 rx_over_run	 ;



// UART RX Logic
always @ (posedge clk) begin
	if (reset) begin
		rx_reg        <= 8'd0; 
		rx_data       <= 8'd0;
		rx_sample_cnt <= 10'd0;
		rx_cnt        <= 4'd0;
		rx_frame_err  <= 1'b0;
		//rx_over_run   <= 0;
		rx_empty      <= 1'b1;
		rx_d1         <= 1'b1;
		rx_d2         <= 1'b1;
		rx_busy       <= 1'b0;
	end else begin
		if (rx_enable) begin // Receive data only when rx is enabled
			// Synchronize the asynch signal
			rx_d1 <= rx_in;
			rx_d2 <= rx_d1;
			if (!rx_busy && !rx_d2) begin 			// Check if just received start of frame
				rx_busy       <= 1'b1;
				//Start halfway through count for first (start) bit to find centre of bit
				if (ML505) rx_sample_cnt <= 434;  
				else begin
					case (baud_rate)
						2'd0:  rx_sample_cnt <= 174; // 115200 Baud	
						2'd1:  rx_sample_cnt <= 87; // 230400 Baud	
						2'd2:  rx_sample_cnt <= 43; // 460800 Baud	
						default:  rx_sample_cnt <= 174; // 115200 Baud	
					endcase
				end	
				rx_cnt        <= 1'b0;
				rx_frame_err <= rx_frame_err;
				rx_empty <= (uld_rx_data) ? 1'b1 : rx_empty;
				rx_reg <= 8'd0;
				rx_data <= rx_data;
			end else if (rx_busy) begin // Start of frame detected, Proceed with rest of data
				if (ML505) begin
					if (rx_sample_cnt == 10'd868) begin
						rx_sample_cnt <= 10'd0;
						rx_cnt <= rx_cnt + 1;
						if (rx_cnt==4'd0) begin
							rx_busy <= (rx_d2) ? 1'b0 : rx_busy;
							rx_frame_err <= rx_frame_err;
							rx_empty <= (uld_rx_data) ? 1'b1 : rx_empty;
							rx_reg <= rx_reg;
							rx_data <= rx_data;
						end else if (rx_cnt==4'd9) begin
							rx_busy <= 1'b0;
							rx_frame_err <= ~rx_d2;	
							rx_empty <= ~rx_d2;
							rx_reg <= rx_reg;
							rx_data <= rx_reg;
						end else begin
							rx_busy <= rx_busy;
							rx_reg[rx_cnt - 1] <= rx_d2;
							rx_empty <= (uld_rx_data) ? 1'b1 : rx_empty;
							rx_data <= rx_data;
							rx_frame_err <= rx_frame_err;
						end
					end else begin
						rx_sample_cnt <= rx_sample_cnt +1;
						rx_cnt <= rx_cnt;
						rx_busy <= rx_busy;
						rx_frame_err <= rx_frame_err;
						rx_empty <= (uld_rx_data) ? 1'b1 : rx_empty;
						rx_reg <= rx_reg;
						rx_data <= rx_data;
					end
				end else begin
					case (baud_rate) 
						2'd0: begin // 115200 Baud		
							if (rx_sample_cnt == 10'd347) begin
								rx_sample_cnt <= 10'd0;
								rx_cnt <= rx_cnt + 1;
								if (rx_cnt==4'd0) begin
									rx_busy <= (rx_d2) ? 1'b0 : rx_busy;
									rx_frame_err <= rx_frame_err;
									rx_empty <= (uld_rx_data) ? 1'b1 : rx_empty;
									rx_reg <= rx_reg;
									rx_data <= rx_data;
								end else if (rx_cnt==4'd9) begin
									rx_busy <= 1'b0;
									rx_frame_err <= ~rx_d2;	
									rx_empty <= ~rx_d2;
									rx_reg <= rx_reg;
									rx_data <= rx_reg;
								end else begin
									rx_busy <= rx_busy;
									rx_reg[rx_cnt - 1] <= rx_d2;
									rx_empty <= (uld_rx_data) ? 1'b1 : rx_empty;
									rx_data <= rx_data;
									rx_frame_err <= rx_frame_err;
								end
							end else begin
								rx_sample_cnt <= rx_sample_cnt +1;
								rx_cnt <= rx_cnt;
								rx_busy <= rx_busy;
								rx_frame_err <= rx_frame_err;
								rx_empty <= (uld_rx_data) ? 1'b1 : rx_empty;
								rx_reg <= rx_reg;
								rx_data <= rx_data;
							end
						end
						2'd1: begin // 230400 Baud		
							if (rx_sample_cnt == 10'd174) begin
								rx_sample_cnt <= 10'd0;
								rx_cnt <= rx_cnt + 1;
								if (rx_cnt==4'd0) begin
									rx_busy <= (rx_d2) ? 1'b0 : rx_busy;
									rx_frame_err <= rx_frame_err;
									rx_empty <= (uld_rx_data) ? 1'b1 : rx_empty;
									rx_reg <= rx_reg;
									rx_data <= rx_data;
								end else if (rx_cnt==4'd9) begin
									rx_busy <= 1'b0;
									rx_frame_err <= ~rx_d2;	
									rx_empty <= ~rx_d2;
									rx_reg <= rx_reg;
									rx_data <= rx_reg;
								end else begin
									rx_busy <= rx_busy;
									rx_reg[rx_cnt - 1] <= rx_d2;
									rx_empty <= (uld_rx_data) ? 1'b1 : rx_empty;
									rx_data <= rx_data;
									rx_frame_err <= rx_frame_err;
								end
							end else begin
								rx_sample_cnt <= rx_sample_cnt +1;
								rx_cnt <= rx_cnt;
								rx_busy <= rx_busy;
								rx_frame_err <= rx_frame_err;
								rx_empty <= (uld_rx_data) ? 1'b1 : rx_empty;
								rx_reg <= rx_reg;
								rx_data <= rx_data;
							end	
						end						
						2'd2: begin // 460800 Baud		
							if (rx_sample_cnt == 10'd87) begin
								rx_sample_cnt <= 10'd0;
								rx_cnt <= rx_cnt + 1;
								if (rx_cnt==4'd0) begin
									rx_busy <= (rx_d2) ? 1'b0 : rx_busy;
									rx_frame_err <= rx_frame_err;
									rx_empty <= (uld_rx_data) ? 1'b1 : rx_empty;
									rx_reg <= rx_reg;
									rx_data <= rx_data;
								end else if (rx_cnt==4'd9) begin
									rx_busy <= 1'b0;
									rx_frame_err <= ~rx_d2;	
									rx_empty <= ~rx_d2;
									rx_reg <= rx_reg;
									rx_data <= rx_reg;
								end else begin
									rx_busy <= rx_busy;
									rx_reg[rx_cnt - 1] <= rx_d2;
									rx_empty <= (uld_rx_data) ? 1'b1 : rx_empty;
									rx_data <= rx_data;
									rx_frame_err <= rx_frame_err;
								end
							end else begin
								rx_sample_cnt <= rx_sample_cnt +1;
								rx_cnt <= rx_cnt;
								rx_busy <= rx_busy;
								rx_frame_err <= rx_frame_err;
								rx_empty <= (uld_rx_data) ? 1'b1 : rx_empty;
								rx_reg <= rx_reg;
								rx_data <= rx_data;
							end		
						end						
						default: begin // 115200 Baud		
							if (rx_sample_cnt == 10'd347) begin
								rx_sample_cnt <= 10'd0;
								rx_cnt <= rx_cnt + 1;
								if (rx_cnt==4'd0) begin
									rx_busy <= (rx_d2) ? 1'b0 : rx_busy;
									rx_frame_err <= rx_frame_err;
									rx_empty <= (uld_rx_data) ? 1'b1 : rx_empty;
									rx_reg <= rx_reg;
									rx_data <= rx_data;
								end else if (rx_cnt==4'd9) begin
									rx_busy <= 1'b0;
									rx_frame_err <= ~rx_d2;	
									rx_empty <= ~rx_d2;
									rx_reg <= rx_reg;
									rx_data <= rx_reg;
								end else begin
									rx_busy <= rx_busy;
									rx_reg[rx_cnt - 1] <= rx_d2;
									rx_empty <= (uld_rx_data) ? 1'b1 : rx_empty;
									rx_data <= rx_data;
									rx_frame_err <= rx_frame_err;
								end
							end else begin
								rx_sample_cnt <= rx_sample_cnt +1;
								rx_cnt <= rx_cnt;
								rx_busy <= rx_busy;
								rx_frame_err <= rx_frame_err;
								rx_empty <= (uld_rx_data) ? 1'b1 : rx_empty;
								rx_reg <= rx_reg;
								rx_data <= rx_data;
							end
						end
					endcase
				end // if (~ML505)
			end else begin //if (~rx_busy)
				rx_reg        <= rx_reg; 
				rx_data       <= rx_data;
				rx_sample_cnt <= rx_sample_cnt;
				rx_cnt        <= rx_cnt;
				rx_frame_err  <= rx_frame_err;
				rx_empty <= (uld_rx_data) ? 1'b1 : rx_empty;
				rx_busy       <= rx_busy;
			end
		end else begin
			rx_reg        <= 8'd0; 
			rx_data       <= 8'd0;
			rx_sample_cnt <= 10'd0;
			rx_cnt        <= 4'd0;
			rx_frame_err  <= 1'b0;
			//rx_over_run   <= 0;
			rx_empty      <= 1'b1;
			rx_d1         <= 1'b1;
			rx_d2         <= 1'b1;
			rx_busy       <= 1'b0;	
		end	// if (~rx_enable)	
	end //if (~reset)		
end //always
		
endmodule
