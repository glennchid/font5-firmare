module chanOffsetMUX (	
	input clk,
	input signed [12:0] chanOffset,
	input [3:0] chanOffsetSel,
	output reg signed [12:0] chan1_offset = 13'sd0, // program static offsets here!
	output reg signed [12:0] chan2_offset = 13'sd0,
	output reg signed [12:0] chan3_offset = 13'sd0,
	output reg signed [12:0] chan4_offset = 13'sd0,
	output reg signed [12:0] chan5_offset = 13'sd0,
	output reg signed [12:0] chan6_offset = 13'sd0,
	output reg signed [12:0] chan7_offset = 13'sd0,
	output reg signed [12:0] chan8_offset = 13'sd0,
	output reg signed [12:0] chan9_offset = 13'sd0
	);

(* async_reg = "TRUE" *) reg signed [12:0] chanOffset_a = 13'sd0, chanOffset_b = 13'sd0;
(* async_reg = "TRUE" *) reg [3:0] chanOffsetSel_a = 4'h0, chanOffsetSel_b = 4'h0;
 
always @(posedge clk) begin
	chanOffset_a <= chanOffset;
	chanOffset_b <= chanOffset_a;
	chanOffsetSel_a <= chanOffsetSel;
	chanOffsetSel_b <= chanOffsetSel_a;
	/*chan1_offset <= chan1_offset;
	chan2_offset <= chan2_offset;
	chan3_offset <= chan3_offset;
	chan4_offset <= chan4_offset;
	chan5_offset <= chan5_offset;
	chan6_offset <= chan6_offset;
	chan7_offset <= chan7_offset;
	chan8_offset <= chan8_offset;
	chan9_offset <= chan9_offset;*/

	(* full_case, parallel_case *)
	case (chanOffsetSel_b)
	4'h1: begin
		chan1_offset <= chanOffset_b;
		chan2_offset <= chan2_offset;
		chan3_offset <= chan3_offset;
		chan4_offset <= chan4_offset;
		chan5_offset <= chan5_offset;
		chan6_offset <= chan6_offset;
		chan7_offset <= chan7_offset;
		chan8_offset <= chan8_offset;
		chan9_offset <= chan9_offset;
		end
	4'h2: begin
		chan1_offset <= chan1_offset;
		chan2_offset <= chanOffset_b;
		chan3_offset <= chan3_offset;
		chan4_offset <= chan4_offset;
		chan5_offset <= chan5_offset;
		chan6_offset <= chan6_offset;
		chan7_offset <= chan7_offset;
		chan8_offset <= chan8_offset;
		chan9_offset <= chan9_offset;
		end
	4'h3: begin
		chan1_offset <= chan1_offset;
		chan2_offset <= chan2_offset;
		chan3_offset <= chanOffset_b;
		chan4_offset <= chan4_offset;
		chan5_offset <= chan5_offset;
		chan6_offset <= chan6_offset;
		chan7_offset <= chan7_offset;
		chan8_offset <= chan8_offset;
		chan9_offset <= chan9_offset;
		end
	4'h4: begin
		chan1_offset <= chan1_offset;
		chan2_offset <= chan2_offset;
		chan3_offset <= chan3_offset;
		chan4_offset <= chanOffset_b;
		chan5_offset <= chan5_offset;
		chan6_offset <= chan6_offset;
		chan7_offset <= chan7_offset;
		chan8_offset <= chan8_offset;
		chan9_offset <= chan9_offset;
		end
	4'h5: begin
		chan1_offset <= chan1_offset;
		chan2_offset <= chan2_offset;
		chan3_offset <= chan3_offset;
		chan4_offset <= chan4_offset;
		chan5_offset <= chanOffset_b;
		chan6_offset <= chan6_offset;
		chan7_offset <= chan7_offset;
		chan8_offset <= chan8_offset;
		chan9_offset <= chan9_offset;
		end
	4'h6: begin
		chan1_offset <= chan1_offset;
		chan2_offset <= chan2_offset;
		chan3_offset <= chan3_offset;
		chan4_offset <= chan4_offset;
		chan5_offset <= chan5_offset;
		chan6_offset <= chanOffset_b;
		chan7_offset <= chan7_offset;
		chan8_offset <= chan8_offset;
		chan9_offset <= chan9_offset;
		end
	4'h7: begin
		chan1_offset <= chan1_offset;
		chan2_offset <= chan2_offset;
		chan3_offset <= chan3_offset;
		chan4_offset <= chan4_offset;
		chan5_offset <= chan5_offset;
		chan6_offset <= chan6_offset;
		chan7_offset <= chanOffset_b;
		chan8_offset <= chan8_offset;
		chan9_offset <= chan9_offset;
		end
	4'h8: begin
		chan1_offset <= chan1_offset;
		chan2_offset <= chan2_offset;
		chan3_offset <= chan3_offset;
		chan4_offset <= chan4_offset;
		chan5_offset <= chan5_offset;
		chan6_offset <= chan6_offset;
		chan7_offset <= chan7_offset;
		chan8_offset <= chanOffset_b;
		chan9_offset <= chan9_offset;
		end
	4'h9: begin
		chan1_offset <= chan1_offset;
		chan2_offset <= chan2_offset;
		chan3_offset <= chan3_offset;
		chan4_offset <= chan4_offset;
		chan5_offset <= chan5_offset;
		chan6_offset <= chan6_offset;
		chan7_offset <= chan7_offset;
		chan8_offset <= chan8_offset;
		chan9_offset <= chanOffset_b;
		end
	default: begin
		chan1_offset <= chan1_offset;
		chan2_offset <= chan2_offset;
		chan3_offset <= chan3_offset;
		chan4_offset <= chan4_offset;
		chan5_offset <= chan5_offset;
		chan6_offset <= chan6_offset;
		chan7_offset <= chan7_offset;
		chan8_offset <= chan8_offset;
		chan9_offset <= chan9_offset;
		end
	endcase
end

endmodule
