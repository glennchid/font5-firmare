module ShiftReg(
	input clk,
	input signed [12:0] din,
	input [4:0] tap,
	(* shreg_extract = "no" *) output reg signed [12:0] dout = 13'sd0
);

parameter SRL_SIZE = 32;
parameter INIT = 13'sd0;

(* shreg_extract = "yes" *) reg signed [12:0] dsh_in [0:SRL_SIZE-1];
//reg [12:0] dsh_in [0:SRL_SIZE-1];

//reg [12:0] dsh_out;
integer n;
`ifdef XILINX_ISIM
integer i;
initial for (i=0; i < SRL_SIZE; i=i+1) dsh_in[i]= INIT; // for simulation ONLY
`endif
always @(posedge clk) begin
	dsh_in[0] <= din;
	//for (i=1; i < SRL_SIZE; i=i+1) dsh_in[i] <= dsh_in[i-1];
	for (n=SRL_SIZE-1; n > 0; n=n-1) dsh_in[n] <= dsh_in[n-1];
	//dsh_in[1:SRL_SIZE-1] <= dsh_in[0:SRL_SIZE-2];
	dout <= dsh_in[tap];
	//dout <= (tap == 5'd1) ? din : dsh_in[tap-5'd2];
//	case (tap)
//	5'd0: dout <= 13'sd0;
//	5'd1: dout <= din;
//	default: dout <= dsh_in[tap-5'd2];
//	endcase
end

endmodule

