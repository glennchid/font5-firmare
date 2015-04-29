module DriveOutput (
	input clk,
	input store_strb,
	input feedfwd_en,
	input use_strobes,
	input [9:0] start_proc,
	input [9:0] end_proc,
	input [4:0] Ldelay,
	input [1:0] opMode, //0 = sample-by-sample, 1 = constant DAC, 2 = Pulse mean removal //
	input signed [12:0] constDac_val,
	//input signed [29:0] din,
	input signed [24:0] din,
	input signed [6:0] gain,
	input DACclkPhase,
	input signed [6:0] IIRtapWeight,
	//input IIRbypass,
	//output reg signed [12:0] dout = 13'd0,
	//output reg DAC_en = 1'b0
	(* IOB = "true" *) output reg signed [12:0] dout = 13'd0, //For the sake of Iverilog!!
	(* IOB = "true" *) output reg DAC_en  = 1'b0 //ditto !
	//(* IOB = "true" *) output reg signed [12:0] dout_copy = 13'd0, //For the sake of Iverilog!!
	//(* IOB = "true" *) output reg DAC_en_copy  = 1'b0 //ditto !
);

//parameter offset_delay = 4'd8; //minimum latency 5 cycles with respect to store_strb in FF modules (2 from LUT & mult, 1 gain, 2 Ldelay)
parameter offset_delay = 4'd7; //with respect to store_strb at Ldelay entrance (5 from "loop' module, 2 from gain, 1 from RAM_strobes, -2 from internal)
//7 is to bring the latency down by one cycle - should be 5 from 'loop' + 2 from gain + 1 from P1_strobe (then minus 1 from the register on opgate)

// gain stage, delay, combi o/p block, o/p filtering, decimate and put out.
//reg signed [29:0] dinReg = 30'sd0;
//reg signed [24:0] dinReg = 25'sd0;
//reg signed [6:0] gainReg = 7'sd0;
(* shreg_extract = "no" *) reg signed [35:0] gain_mult = 36'sd0, gainMult_out = 36'sd0;
//reg signed [31:0] gain_mult = 32'sd0;//, gainMult_out = 32'sd0;
(* shreg_extract = "no" *) reg signed [12:0] amp_drive = 13'sd0;
//wire signed [12:0] amp_drive;

wire signed [12:0] amp_drive_del;

always @(posedge clk) begin
	//dinReg <= din;
	//gainReg <= gain;
	//gain_mult <= dinReg * gainReg;
	gain_mult <= din * gain;
	gainMult_out <= gain_mult;
	end

//ShiftReg #(32) latencyDelay (clk, gainMult_out[35:23], Ldelay, amp_drive_del);
ShiftReg #(32) latencyDelay (clk, gainMult_out[30:18], Ldelay, amp_drive_del);
//ShiftReg #(32) latencyDelay (clk, gain_mult[30:18], Ldelay, amp_drive_del);

wire storeStrbDel;
wire [5:0] strbDel;

assign strbDel = Ldelay + offset_delay;
//Delay the store strobe by required amount
StrbShifter #(64) StoreStrbDel (clk, store_strb, strbDel, storeStrbDel);


//Filter goes here ... umm, no just before DACs

//Form output gate

(* shreg_extract = "no" *) reg [9:0] opGate_ctr = 10'd0;
//wire [10:0] totalDelStart, totalDelEnd;
(* shreg_extract = "no" *) reg opGate = 1'b0;

//assign DACgate = offset_delay + Ldelay; //offset version of store strobe
//assign totalDelStart = offset_delay + Ldelay + start_proc;
//assign totalDelEnd = offset_delay + Ldelay + end_proc;


//sequential block for opGate
always @(posedge clk) begin
	opGate_ctr <= (storeStrbDel) ? opGate_ctr + 1'b1 : 11'd0;
	if (storeStrbDel) begin
		//(* full_case, parallel_case *) 
		case (opGate_ctr) 
			//totalDelStart: opGate <= 1'b1;	
			
			//totalDelEnd: opGate <= 1'b0;
			start_proc: opGate <= 1'b1;	
			end_proc: opGate <= 1'b0;
			default: opGate <= opGate;
		endcase
	end else begin
		opGate <= 1'b0;
		end
end

//combinatorial block for opGate
/*always @(posedge clk) opGate_ctr <= (storeStrbDel) ? opGate_ctr + 1'b1 : 11'd0;
always @(*) begin
	if (storeStrbDel) begin
		(* full_case, parallel_case *) 
		case (opGate_ctr) 
			//totalDelStart: opGate <= 1'b1;	
			
			//totalDelEnd: opGate <= 1'b0;
			start_proc: opGate = 1'b1;	
			end_proc: opGate = 1'b0;
			//default: opGate = opGate;
		endcase
	end else opGate = 1'b0;
end*/

//Combi o/p block

reg feedfwd_en_a = 0, feedfwd_en_b = 0; //PIPELINE REGISTERS
reg signed [12:0] amp_drive_b = 13'sd0; //PIPELINE REGISTER
always @(posedge clk) begin
	feedfwd_en_a <= feedfwd_en;
	feedfwd_en_b <= feedfwd_en_a;
	amp_drive_b <= amp_drive;
	end


always @(*) begin
	//if (~storeStrbDel) amp_drive = 13'd0; //FF_en condition not necessary - 09/10/14
	//if (~storeStrbDel || ~feedfwd_en_b) amp_drive = 13'd0;
	//if (~storeStrbDel || ~feedfwd_en) amp_drive = 13'd0;
	//else if (opGate || ~use_strobes)
	if (storeStrbDel && (opGate || ~use_strobes))
		(* full_case, parallel_case *) //recoded 09/10/14
		case (opMode) 	//Need to include saturation detection here, this will be evident from the filter output - could just look for overflows!
		2'd0: amp_drive = amp_drive_del;
		2'd1: amp_drive = constDac_val;
		default: amp_drive = 13'd0;
		endcase
	else amp_drive = 13'd0;
end

// Filter here now - input is amp_drive

wire signed [12:0] amp_drive_AD, amp_drive_out;

antiDroopIIR #(16) antiDroopIIR_DAC(
	.clk(clk),
	.trig(store_strb),
	//.din(amp_drive),
	.din(amp_drive_b),
	.tapWeight(IIRtapWeight),
	.accClr_en(1'b1),
	.oflowClr(),
	.oflowDetect(),
	.dout(amp_drive_AD)
);

//assign amp_drive_out = (~IIRbypass) ? amp_drive_b : amp_drive_AD;
assign amp_drive_out = amp_drive_AD;

//Decimate and put out

(* shreg_extract = "no" *) reg clk_tog = 1'b0; //1-bit toggle
(* shreg_extract = "no" *) reg storeStrbDel_a = 1'b0, storeStrbDel_b = 1'b0, storeStrbDel_c = 1'b0, storeStrbDel_d = 1'b0, storeStrbDel_e = 1'b0;
wire clearDAC;
wire output_en;

assign clearDAC = storeStrbDel_e & ~storeStrbDel_d; //DAC must be cleared at least one cycle after the storeStrDeb goes low to avoi doubloe pulsing the DAC clk
//assign output_en = (~IIRbypass) ? storeStrbDel_a : storeStrbDel_c; // Compensate with the three cycle delay through the filter or delay of 1 without filter
assign output_en = storeStrbDel_c; // Compensate with the three cycle delay through the filter or delay of 1 without filter


always @(posedge clk) begin
	storeStrbDel_a <= storeStrbDel;
	storeStrbDel_b <= storeStrbDel_a;	
	storeStrbDel_c <= storeStrbDel_b;	
	storeStrbDel_d <= storeStrbDel_c;	
	storeStrbDel_e <= storeStrbDel_d;	
	if (clearDAC && feedfwd_en_b) begin
	//if (clearDAC && feedfwd_en) begin
		//dout <= dout; //seems  a bit dangerous to assume that the amp_drive will be cancelled at the correct time!
		dout <= 13'd0;
		//dout_copy <= 13'd0;
		DAC_en <= 1'b1;
		//DAC_en_copy <= 1'b1;
		clk_tog <= clk_tog;
	//end else if (storeStrbDel && feedfwd_en_b) begin
	//end else if (storeStrbDel && feedfwd_en) begin
	end else if (output_en && feedfwd_en_b) begin
		clk_tog <= ~clk_tog;
		DAC_en <= clk_tog ^ DACclkPhase;
		//DAC_en_copy <= clk_tog ^ DACclkPhase;
		dout <= (clk_tog) ? dout : amp_drive_out;
		//dout_copy <= (clk_tog) ? dout : amp_drive_out;
	end else begin
		dout <= 13'd0;
		//dout_copy <= 13'd0;
		DAC_en <= 1'b0;
		//DAC_en_copy <= 1'b0;
		clk_tog <= 1'b0;
	end
end

/*always @(posedge clk) begin
	storeStrbDel_a <= storeStrbDel;
	storeStrbDel_b <= storeStrbDel_a;	
	if (clearDAC) begin
		dout <= dout;
		DAC_en <= 1'b1;
		clk_tog <= clk_tog;
	end else if (~storeStrbDel) begin
		dout <= 13'd0;
		DAC_en <= 1'b0;
		clk_tog <= 1'b0;
	end else begin
		clk_tog <= ~clk_tog;
		DAC_en <= clk_tog ^ DACclkPhase;
		dout <= (clk_tog) ? dout : amp_drive;
	end
end*/

endmodule


