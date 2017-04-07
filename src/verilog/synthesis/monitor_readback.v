`timescale 1ns / 1ps
// *****************  monitor_readback ******************************************
//
// Accepts several readback inputs (7-bits), which are clocked into registers
// on the 40MHz
//
// It contains transmission logic identical to the DAQ_RAM, and is triggered
// last in the DAQ cycle to transmit its register contents as data
//

module monitor_readback(
	clk,
	rst,
	tx_en,
	//tx_clk,
	tx_data_ready,
	tx_data,
	tx_data_loaded,
	tx_complete,
	rb0,
	rb1,
	rb2,
	rb3,
	rb4,
	rb5,
	rb6,
	rb7,
	rb8,
	rb9,
	rb10,
	rb11,
	//rb12
	rb12,
	rb13,
	rb14
);

//parameter N_READBACKS = 13;
parameter N_READBACKS = 15;

// Ports
input					clk;
input					rst;
input					tx_en;
//input					tx_clk;
input					tx_data_loaded;
output	reg		tx_data_ready;
output [6:0]	tx_data;
output	reg		tx_complete;
input	  [6:0]		rb0;
input	  [6:0]		rb1;
input	  [6:0]		rb2;
input	  [6:0]		rb3;
input	  [6:0]		rb4;
input	  [6:0]		rb5;
input	  [6:0]		rb6;
input	  [6:0]		rb7;
input	  [6:0]		rb8;
input	  [6:0]		rb9;
input	  [6:0]		rb10;
input	  [6:0]		rb11;
input	  [6:0]		rb12;
input	  [6:0]		rb13;
input	  [6:0]		rb14;

// Registers
reg [6:0] readbacks_a [0:N_READBACKS-1];
reg [6:0] readbacks_b [0:N_READBACKS-1];

// For for loop
integer i;

always @(posedge clk) begin
	if (rst) begin
		for (i=0; i < N_READBACKS; i=i+1) begin
			readbacks_a[i] <= 0;
			readbacks_b[i] <= 0;
		end
	end else begin
		// Synchronise readbacks
		readbacks_a[0]		<=	rb0;
		readbacks_a[1]		<=	rb1;
		readbacks_a[2]		<=	rb2;
		readbacks_a[3]		<=	rb3;
		readbacks_a[4]		<=	rb4;
		readbacks_a[5]		<=	rb5;
		readbacks_a[6]		<=	rb6;
		readbacks_a[7]		<=	rb7;
		readbacks_a[8]		<=	rb8;
		readbacks_a[9]		<=	rb9;
		readbacks_a[10]	<=	rb10;
		readbacks_a[11]	<=	rb11;
		readbacks_a[12]	<=	rb12;
		readbacks_a[13]	<=	rb13;
		readbacks_a[14]	<=	rb14;
		for (i=0; i < N_READBACKS; i=i+1) begin
			readbacks_b[i] <= readbacks_a[i];
		end
	end
end

// Readback logic.  This works as the DAQ RAM readback.  Each readback is
// stepped trhough in turn, with its data presented until transmitted by the uart
reg [4:0]   tx_cnt;
//reg			tx_data_ready;
reg			tx_data_loaded1;
reg			tx_data_loaded2;
//reg 			tx_complete;
//reg [7:0]	tx_data;
//always @(posedge tx_clk) begin
always @(posedge clk) begin
	if (rst) begin
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
					if (tx_cnt == N_READBACKS) begin
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
				tx_data_ready <= 0;
				tx_data_loaded1 <= 0;
				tx_data_loaded2 <= 0;
				tx_complete <= 0;
			end
		end
	end
end
			
// Logic to append leading 1 to ram output to designate as data word
//always @(posedge tx_clk) tx_data <= {1'b1, readbacks_b[tx_cnt]};

assign tx_data = readbacks_b[tx_cnt];

endmodule