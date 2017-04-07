`timescale 1ns / 1ps

///////////////// ** ctrl_reg_readback ** //////////////////////////////////////////
//
// This module contains the control registers for the font5 9 channel daq firmware
// Clocked at 40MHz
//
// It consists of 7-bit registers, 5-bit addresses
// Data, data strobe and address to be written are all to be provided 'asynchronously'
// and brought onto this clock domain (40 MHz, note signals also provided @40 MHz



module ctrl_reg_readback #(parameter CR_WIDTH=6, N_CTRL_REGS=64) (	
	input					clk,
	input					rst,
	input					tx_en,
	input					tx_data_loaded,
	output reg			tx_data_ready,
	output reg			tx_complete,
	output reg [CR_WIDTH-1:0]  tx_cnt
);

// Readback logic.  This works as the DAQ RAM readback.  Each ctrl reg is
// stepped trhough in turn, with its data presented until transmitted by the uart

always @(posedge clk) begin
	if (rst) begin
		tx_cnt <= 0;
		tx_data_ready <= 0;
		tx_complete <= 0;
	end else begin
		//tx_data_loaded is asserted by the UART once it has loaded the current
		//data word.  Since the UART operates on the baud clock domain, synchronise
		if (!tx_complete && tx_en) begin //Transmission of RAM contents enabled
			if (tx_data_ready && tx_data_loaded) begin //Data word has been loaded to the uart.  tx_data_loaded will stay high until the UART transmission has finished							
				tx_data_ready <= 0;
				if (tx_cnt == N_CTRL_REGS-1) begin //We have transmitted the data from the last address
					tx_complete <= 1; 
					tx_cnt <= tx_cnt;
					end
				else begin
					tx_complete <= tx_complete;
					tx_cnt <= tx_cnt + 1;
					end
				end
			else begin
				tx_complete <= tx_complete;
				tx_cnt <= tx_cnt;
				tx_data_ready <= (!tx_data_ready && !tx_data_loaded) ? 1 : tx_data_ready; //Load the data from RAM address currently specified by tx_cnt
			end
		end else if (tx_complete && !tx_en) begin //Transmission is complete.  Wait for enable to go low, then reset tx logic
			tx_cnt <= 0;
			tx_data_ready <= 0;
			tx_complete <= 0;
		end else begin
			tx_data_ready <= tx_data_ready;
			tx_complete <= tx_complete;
			tx_cnt <= tx_cnt;
		end
	end // if (~rst)
end //always

endmodule
