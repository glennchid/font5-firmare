module antiDroopIIR (
	input clk,
	input trig,
	input signed [12:0] din,
	input signed [6:0] tapWeight,
	input accClr_en,
	input oflowClr,
	output reg oflowDetect = 1'd0,
	output reg signed [15:0] dout = 16'sd0);

parameter IIR_scale = 15; // define the scaling factor for the IIR multiplier, eg for 0.002 (din = 63, IIR_scale = 15).

//`define ADDPIPEREG

reg signed [12:0] din_del = 13'sd0;
`ifdef ADDPIPEREG reg signed [12:0] din_del_b = 13'sd0;
`endif
reg signed [47:0] tap = 48'sd0;
reg signed [19:0] multreg = 20'sd0;

(* equivalent_register_removal = "no" *) reg trig_a = 1'b0, trig_b = 1'b0;
wire trig_edge = trig_a & ~trig_b;
//reg trig_edge = 1'b0;
reg signed [6:0] tapWeight_a = 7'sd0, tapWeight_b = 7'sd0;

always @(posedge clk) begin
	//trig_edge <= trig_a & ~trig_b;
	tapWeight_a <= tapWeight;
	tapWeight_b <= tapWeight_a;
	trig_a <= trig;
	trig_b <= trig_a;
	din_del <= din;
	`ifdef ADDPIPEREG
		din_del_b <= din_del;
		multreg <= din_del*tapWeight_b;
		dout <= {din_del_b, 3'b000} + tap[IIR_scale+12:IIR_scale-3];
	`else
		multreg <= din*tapWeight_b;
		dout <= {din_del, 3'b000} + tap[IIR_scale+12:IIR_scale-3];
	`endif
	if (trig_edge && accClr_en) tap <= 48'd0;
	else tap <= multreg + tap;
	//tap <= din*tapWeight + tap;
	if (oflowDetect && oflowClr) oflowDetect <= 1'b0;
	//else if ((~& tap[47:IIR_scale+12]) || (& ~tap[47:IIR_scale+12])) oflowDetect <= 1'b1;
	//else if ((~& tap[47:IIR_scale+12]) || (& tap[47:IIR_scale+12])) oflowDetect <= 1'b1;
	else if (^ tap[IIR_scale+13:IIR_scale+12]) oflowDetect <= 1'b1;
	else oflowDetect <= oflowDetect;
end

endmodule
