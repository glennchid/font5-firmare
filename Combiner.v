`timescale 1ns/100ps

module Combiner(
	input clk,
	input signed [15:0] din,
	//input mode,
	input integ,
	input bypass,
	//input [9:0] gateEnd,
	//(* equivalent_register_removal = "no" *) output reg signed [15:0] dout = 16'h0000
	output signed [15:0] dout
);

`include "bits_to_fit.v"

//parameter real CLK_FREQ = 192e6; // SiS digitisers - 192 MHz
parameter real CLK_FREQ = 357e6; // FONT5A board - 357 MHz
parameter real SUB_PULSE_LENGTH = 280e-9; // Factor 4 - 280 ns sub-pulse length
//localparam integer COMB_FACT = 4; // Factor 4 combination

localparam integer SUB_PULSE_CNT_SIZE = bits_to_fit(CLK_FREQ * SUB_PULSE_LENGTH);
//localparam SUB_PULSE_CNT_SIZE = $clog2(CLK_FREQ * SUB_PULSE_LENGTH + 1); //NB: Icarus verilog understand the clog2 system CUF but not user functions!!!
//localparam [SUB_PULSE_CNT_SIZE-1:0] SUB_PULSE_CNT = CLK_FREQ * SUB_PULSE_LENGTH;

//reg [SUB_PULSE_CNT_SIZE-1:0] subPulseCtr = {SUB_PULSE_CNT_SIZE{1'b0}};

//parameter SRL_SIZE = 64;

localparam [SUB_PULSE_CNT_SIZE-1:0] SRL_SIZE = (CLK_FREQ * SUB_PULSE_LENGTH);

reg signed [17:0] dsh [0:SRL_SIZE-1]; // 18-bits necessary for Factor 4 combination //

integer i, n;
initial for (i=0; i < SRL_SIZE; i=i+1) dsh[i] = 18'h00000;

//MUXY for uncombined beam
wire signed [17:0] din_mux = (bypass) ? {din, 2'b00} : {{2{din[15]}}, din} + dsh[SRL_SIZE-1];


always @(posedge clk) begin
/*	if (intergrating) begin //ACC/CLR !!
		dsh[0] <= din + dsh[SRL_SIZE-1];
		for (n=SRL_SIZE-1; n > 0; n=n-1) dsh[n] <= dsh[n-1];
	end else begin
		for (n=SRL_SIZE-1; n > 0; n=n-1) dsh[n] <= 20'h0; // not synthesisible, must shift-in the zero
		dout <= dsh[SRL_SIZE-1]; */

	//Begin combiner unit
	/*
	dout <= (bypass) ? din : dsh[SRL_SIZE-1];
	dsh[0] <= (integ) ? din + dsh[SRL_SIZE-1] : 20'h0; //control (integ) must be set to correct sample range
	for (n=SRL_SIZE-1; n > 0; n=n-1) dsh[n] <= dsh[n-1]; */
	//End combiner
	//NO THIS iS WRONG, output needs to be din + dsh

	//dout <= (bypass) ? din : din + dsh[SRL_SIZE-1];
	dsh[0] <= (integ) ? din_mux : 18'h00000; // MUXY to clear SR when not interleaving
	//dsh[0] <= (bypass) ? {din, 2'b00} : {{2{din[15]}}, din} + dsh[SRL_SIZE-1]; //MUXY for uncombined beam
	for (n=SRL_SIZE-1; n > 0; n=n-1) dsh[n] <= dsh[n-1]; // Implement Shift Rgegister
	//dout <= dsh[0][17:2]; // Bit-select top 16 bits and present on output
end

assign dout =  dsh[1][17:2];

endmodule
