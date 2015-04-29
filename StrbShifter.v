module StrbShifter(
	input clk,
	input din,
	input [5:0] tap,
	(* shreg_extract = "no" *) output reg dout = 1'b0
);

parameter SRL_SIZE = 64;

(* shreg_extract = "yes" *) reg dsh_in [0:SRL_SIZE-1];
//reg [12:0] dsh_in [0:SRL_SIZE-1];

//reg [12:0] dsh_out;
integer n;
`ifdef XILINX_ISIM
	integer i;
	initial for (i=0; i < SRL_SIZE; i=i+1) dsh_in[i]=13'd0; // for simulation ONLY
`endif
always @(posedge clk) begin
	dsh_in[0] <= din;
	//for (i=1; i < SRL_SIZE; i=i+1) dsh_in[i] <= dsh_in[i-1];
	for (n=SRL_SIZE-1; n > 0; n=n-1) dsh_in[n] <= dsh_in[n-1];
	//dsh_in[1:SRL_SIZE-1] <= dsh_in[0:SRL_SIZE-2];
	dout <= dsh_in[tap];
end

endmodule

