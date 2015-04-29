`timescale 1ns / 1ps


////////// ** DAQ_RAM ** /////////////////////////////////////////////////////
//
// This module is a self-contained RAM and control logic module for DAQ
//
// Loading:
//  Sending data along with a wr_en strobe will write data to the next available RAM
//   address.  The writing is done at the system frequency to Port A
//
// Transmitting:
//  The transmission logic runs at 40 MHz.  Setting trans_en begins transmitting.
//  Once begun, tx_cnt is zero and used to address RAM Port B.  tx_data_rdy is asserted
//   until tx_data_loaded goes high (this occurs once the UART is loaded)
//  Then, tx_data_rdy is deasserted and the tx_cnt incremented.
//  Once trans_cnt == 2*write_cnt, then tx_complete is asserted and everything stops
//  When tx_en goes low, all transmit logic is reset
//
//  The data output is {1 ramportB}, where the MSB 1 signifies a data byte
//
//  Also, treat tx_data_loaded signal as async.  It will come from the UART

module DAQ_RAM(
	reset,
	tx_en,
	tx_clk,
	tx_data_ready,
	tx_data,
	tx_data_loaded,
	tx_complete,
	wr_clk,
	wr_en,
	wr_data
);

// Ports
input				reset;
input				tx_en;
input				tx_clk;
input				tx_data_loaded;
output			tx_data_ready;
//output reg [7:0]	tx_data;
output reg [6:0]	tx_data = 7'd0;
output			tx_complete;
input 			wr_clk;
input 			wr_en;
input  [13:0] 	wr_data;

// Internal registers
reg [10:0]  tx_cnt = 11'd0;
reg			tx_data_ready = 1'b0;
reg			tx_data_loaded1 = 1'b0;
reg			tx_data_loaded2 = 1'b0;
reg 			tx_complete = 1'b0;
//reg [7:0]	tx_data;
reg [9:0]	wr_addr = 10'd0;



// Internal wires 
wire [6:0]  ram_out;

// Pipeline the incoming data and strobe to ease timing
reg wr_en_a = 1'b0, wr_en_b = 1'b0, wr_en_c = 1'b0, wr_en_d = 1'b0;
reg [13:0] wr_data_a = 14'd0, wr_data_b = 14'd0, wr_data_c = 14'd0, wr_data_d = 14'd0;
reg reset_a = 1'b0, reset_b = 1'b0;
always@(posedge wr_clk) begin
	wr_en_a <= wr_en;
	// synthesis attribute shreg_extract of wr_en_a is "no";
	wr_en_b <= wr_en_a;
	// synthesis attribute shreg_extract of wr_en_b is "no";
	wr_en_c <= wr_en_b;
	// synthesis attribute shreg_extract of wr_en_c is "no";
	wr_en_d <= wr_en_c;
	// synthesis attribute shreg_extract of wr_en_d is "no";
	wr_data_a <= wr_data;
	// synthesis attribute shreg_extract of wr_data_a is "no";
	wr_data_b <= wr_data_a;
	// synthesis attribute shreg_extract of wr_data_b is "no";
	wr_data_c <= wr_data_b;
	// synthesis attribute shreg_extract of wr_data_c is "no";
	wr_data_d <= wr_data_c;
	// synthesis attribute shreg_extract of wr_data_d is "no";
	reset_a <= reset;
	reset_b <= reset_a;
end

/*sdp_ram_10x14_11x7 RAM1 (
	.clka(wr_clk),
	.dina(wr_data_d),
	.addra(wr_addr),
	.wea(wr_en_d),
	.clkb(tx_clk),
	.addrb(tx_cnt), 
	.doutb(ram_out)
);*/

/*reg [6:0] Mem [0:2047];

always @(posedge wr_clk) 
	if (wr_en_d) begin
		Mem[{wr_addr, 1'b1}] = wr_data_d[13:7];
		Mem[{wr_addr, 1'b0}] = wr_data_d[6:0];
	end
always @(posedge tx_clk) tx_data <= Mem[tx_cnt];
*/

DAQ_MEM MEM (
  .clka(wr_clk), // input clka
  .wea(wr_en_d), // input [0 : 0] wea
  .addra(wr_addr), // input [9 : 0] addra
  .dina(wr_data_d), // input [13 : 0] dina
  .clkb(tx_clk), // input clkb
  .addrb(tx_cnt), // input [10 : 0] addrb
  .doutb(ram_out) // output [6 : 0] doutb
);


//Logic to track of current write address
always @(posedge wr_clk) begin
	if (reset_b) begin
		wr_addr <= 0;
	end else begin			
		if (wr_en_d) begin
			wr_addr <= wr_addr + 1;
		end
	end
end


//Logic to transmit contents of RAM
always @(posedge tx_clk) begin
	//tx_data <= Mem[tx_cnt];
	if (reset) begin
		tx_cnt <= 0;
		tx_data_ready <= 0;
		tx_data_loaded1 <= 0;
		tx_data_loaded2 <= 0;
		tx_complete <= 0;
	end else begin
		//tx_data_loaded is asserted by the UART once it has loaded the current
		//data word.  Since the UART operates on the baud clock domain, synchronise
		tx_data_loaded1 <= tx_data_loaded;
		tx_data_loaded2 <= tx_data_loaded1;
		if (!tx_complete) begin
			if (tx_en) begin
				//Transmission of RAM contents enabled
				if (!tx_data_ready && !tx_data_loaded2) begin
					if (tx_cnt == (2*wr_addr)) begin
							//We have transmitted the data from the last address
							tx_complete <= 1;
					end else begin
						//Load the data from RAM address currently specified by tx_cnt
						tx_data_ready <= 1;
					end
				end else begin
					if (tx_data_ready && tx_data_loaded2) begin
						//Data word has been loaded to the uart.  tx_data_loaded will stay 
						//high until the UART transmission has finished
						tx_data_ready <= 0;
						tx_cnt <= tx_cnt + 1;
					end
				end
			end
		end else begin
			//Transmission is complete.  Wait for enable to go low, then reset tx logic
			if (!tx_en) begin
				tx_cnt <= 0;
				tx_complete <= 0;
			end
		end
	end
end
			
// Logic to append leading 1 to ram output to designate as data word
//always @(posedge tx_clk) tx_data <= {1'b1, ram_out};
always @(posedge tx_clk) tx_data <= ram_out;
//always @(posedge tx_clk) tx_data <= Mem[tx_cnt];


endmodule

