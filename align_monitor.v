`timescale 1ns / 1ps
// *****************  ALIGN_MONITOR  ******************************************
//
// Only operates when align_en is high
//
// On the 40MHz domain the main_count counts out 127 sets of samples.  In each 
// sampling routine, sample_trig is taken high and synched onto the 357 domain.
// The 357 domain then samples the data ready on consec. rising, falling, rising edges.
// These 3 samples are then synched back to the 40MHz logic, and added to a running count.
// If all of sample 1 are the same, all of sample 3 are opposite to sample 1, and
// approx. 50% of sample 2 are set, then the 357 phase wrt data ready (and hence adc data)
// is correct.  If not, the delay_modifier is changed.  This modification is applied
// to the IDELAY on the adc data/data ready inputs.
//
// One complication is that the overall phase of data ready is not known.  In order
// that the sampling is consistant over successive sample_trigs, we must force samples 1
// and 3 to always be on given data ready values. This is done by taking a zeroth sample
// on the first 357 rising edge after sample_trig.  If this is 0, then continue, else
// delay all by a cycle of 357 to get into the correct phase 
//
// When the delay modifier charnges, a strobe is sent for 1 40MHz cycle
//
// *Following commented out for now*
// Additional complication.  When the clock phase is set perfectly badly, then the 
// sample 0 value depends on the jitter.  This leads to random samping in all
// sample 1, 2 & 3!  Hence additional check is implemented if sample 2 is within
// threshold.  If sample3 count !=0 or sample2 count != 127 then prang the delay mod
//
//
// IODELAY ar 64 tap, or 6-bit.  The delay_modifier is a 7-bit 2's comp. number which
// is comined in the delay_calc module with some nominal delay
// i.e is from -64 upto +63
//

//
//////////////////////////////////////////////////////////////////////////////////
module align_monitor( 
		input clk357,
		input clk40,
		input rst,
		input align_en,
		input Q1,
		input Q2,
		output reg [6:0] delay_modifier,
		output reg delay_mod_strb,
		output reg [6:0] count1,		//Monitoring
		output reg [6:0] count2,		//Monitoring
		output reg [6:0] count3,		//Monitoring
		output reg monitor_strb
);

//Internal registers

//Taking sample_trig high initiates the sampling on 357 domain
reg sample_trig;
reg sample_trig_a;
reg sample_trig_b;
//reg delay_mod_strb;

reg [1:0] sample_state = 2'b00;

// For samples
reg samp0;
reg samp1;
reg samp2;
reg samp3;

//reg monitor_strb;

reg samples_rdy; //(added by GBC) handshaking signal on sampling clk domain to tell 
						//the slow domain that samples are ready to synchronise
reg samples_rdy_slow_a; // (added by GBC) synchroniser on slow domain
reg samples_rdy_slow_b; // (added by GBC) guards against metastability
//(* equivalent_register_removal = "no" *) reg align_en_a, align_en_b;
(* equivalent_register_removal = "no", shreg_extract = "no" *) reg align_en_slow_a, align_en_slow_b;
//sythesis attribute equivalent_register_removal of align_en_a is "no"
//sythesis attribute equivalent_register_removal of align_en_b is "no"
//sythesis attribute equivalent_register_removal of align_en_slow_a is "no"
//sythesis attribute equivalent_register_removal of align_en_slow_b is "no"

always @(posedge clk357) begin
	//align_en_a <= align_en;
	//align_en_b <= align_en_a;
	 //if (align_en_b) begin
		//Synchronise sample_trig
		sample_trig_a <= sample_trig;
		sample_trig_b <= sample_trig_a;
		//Take the samples if sample trig is high
		if (sample_trig_b) begin
			case (sample_state)
			2'd0: begin
				//Take zeroth sample
				samp0 <= Q1;
				samp1 <= samp1;
				samp2 <= samp2;
				samp3 <= samp3;
				sample_state <= 2'd1;
				samples_rdy <= samples_rdy;
				end
			2'd1: begin
				if (~samp0) begin
					//We are on the correct phase, so continue
					samp0 <= samp0;
					samp1 <= Q1;
					samp2 <= Q2;
					samp3 <= samp3;
					//Increment state
					sample_state <= 2'd2;
					samples_rdy <= samples_rdy;
				end else begin
					//Incorrect phase, so ignore this cycle and wait until next
					samp0 <= 0;
					samp1 <= samp1;
					samp2 <= samp2;
					samp3 <= samp3;
					sample_state <= sample_state;
					samples_rdy <= samples_rdy;
				end
				end
			2'd2: begin
				samp0 <= samp0;
				samp1 <= samp1;
				samp2 <= samp2;
				//Take third sample 
				samp3 <= Q1;
				//Increment state
				sample_state <= 2'd3;	
				samples_rdy <= 1'b1;
				end
			2'd3: begin // hold (wait) state
				samp0 <= samp0;
				samp1 <= samp1;
				samp2 <= samp2;
				samp3 <= samp3;
				sample_state <= sample_state;
				samples_rdy <= samples_rdy;
				end
			endcase
		end else begin
			samp0 <= samp0;
			samp1 <= samp1;
			samp2 <= samp2;
			samp3 <= samp3;
			//When sample_trig goes low, reset state
			sample_state <= 2'd0;
			samples_rdy <= 1'b0;
		end	//else (if ~sample_trig_b)
	 //end	//if (align_en)
	//end //else (if ~rst)
end //always


//This logic runs on 40MHz domain
//Assert sample_trig then synchronise the three samples to 40MHz
//Add the samples to three counters to track how many of each are set
//Do so n_samp times

//Secondly, increment or decrement the delay_modifier depending on whether 
//or not sample 2's count falls within a threshold range.  The sample1  and 3 counts
//determine which way to move (delay_modifier is twos comp)

//reg [6:0] delay_modifier;

reg samp1_a;
reg samp2_a;
reg samp3_a;
reg samp1_b;
reg samp2_b;
reg samp3_b;


//parameter counter_bits = 7;
//parameter n_samp = 127;
//parameter threshold_min = 20;
//parameter threshold_max = 107;
parameter counter_bits = 7;
parameter n_samp = 7'd31;
parameter threshold_min = 7'd5;
parameter threshold_max = 7'd26;
reg [counter_bits-1:0] main_count;
reg [counter_bits-1:0] samp1_count;
reg [counter_bits-1:0] samp2_count;
reg [counter_bits-1:0] samp3_count;

//To store the final sample counter values for monitoring purposes
//reg [counter_bits-1:0] count1_mon;
//reg [counter_bits-1:0] count2_mon;
//reg [counter_bits-1:0] count3_mon;

reg [1:0] state40 = 2'b00;
//reg [5:0] iteration_counter; // GBC added for testbenching

always @(posedge clk40) begin
	align_en_slow_a <= align_en;
	align_en_slow_b <= align_en_slow_a;
	if (rst) begin
		sample_trig <= 0;
		delay_modifier <= 0;
		samp1_a <= 0;
		samp2_a <= 0;
		samp3_a <= 0;
		samp1_b <= 0;
		samp2_b <= 0;
		samp3_b <= 0;
		main_count <= 0;
		samp1_count <= 0;
		samp2_count <= 0;
		samp3_count <= 0;
		state40 <= 0;
		delay_mod_strb <= 0;
		monitor_strb <= 0;
		samples_rdy_slow_a <= 1'b0;
		samples_rdy_slow_b <= 1'b0;
		count1 <= 7'd0;
		count2 <= 7'd0;
		count3 <= 7'd0;
		//iteration_counter <= 6'b0;
	end else begin
	 //align_en_slow_c <= align_en_slow_b;
	 if (align_en_slow_b) begin
	 //synchronise samples_rdy
	 samples_rdy_slow_a <= samples_rdy;
	 samples_rdy_slow_b <= samples_rdy_slow_a;
		if (main_count < n_samp) begin
			case (state40)
			2'b00: begin
				sample_trig <= 1; //Tell 357MHz logic to take some samples
				delay_modifier <= delay_modifier;
				samp1_a <= samp1_a;
				samp2_a <= samp2_a;
				samp3_a <= samp3_a;
				samp1_b <= samp1_b;
				samp2_b <= samp2_b;
				samp3_b <= samp3_b;
				main_count <= main_count;
				samp1_count <= samp1_count;
				samp2_count <= samp2_count;
				samp3_count <= samp3_count;
				state40 <= 2'b01;
				//Turn off the strobe
				delay_mod_strb <= 0;
				monitor_strb <= 0;
				count1 <= count1;
				count2 <= count2;
				count3 <= count3;	
				end
			2'b01: begin
				if (samples_rdy_slow_b) begin
					//Start synchronsing samples onto the 40MHz domain
					samp1_a <= samp1;
					samp2_a <= samp2;
					samp3_a <= samp3;
					sample_trig <= 0;
					state40 <= 2'b10;
					delay_modifier <= delay_modifier;
					samp1_b <= samp1_b;
					samp2_b <= samp2_b;
					samp3_b <= samp3_b;
					main_count <= main_count;
					samp1_count <= samp1_count;
					samp2_count <= samp2_count;
					samp3_count <= samp3_count;
					delay_mod_strb <= delay_mod_strb;
					monitor_strb <= monitor_strb;
					count1 <= count1;
					count2 <= count2;
					count3 <= count3;	
				end else begin // hold
					samp1_a <= samp1_a;
					samp2_a <= samp2_a;
					samp3_a <= samp3_a;
					sample_trig <= sample_trig;
					state40 <= state40;
					delay_modifier <= delay_modifier;
					samp1_b <= samp1_b;
					samp2_b <= samp2_b;
					samp3_b <= samp3_b;
					main_count <= main_count;
					samp1_count <= samp1_count;
					samp2_count <= samp2_count;
					samp3_count <= samp3_count;
					delay_mod_strb <= delay_mod_strb;
					monitor_strb <= monitor_strb;
					count1 <= count1;
					count2 <= count2;
					count3 <= count3;	
					end //else (if ~samples_rdy_slow_b)
				end
			2'b10: begin
				//Finish synching
				samp1_b <= samp1_a;
				samp2_b <= samp2_a;
				samp3_b <= samp3_a;
				state40 <= 2'b11;
				samp1_a <= samp1_a;
				samp2_a <= samp2_a;
				samp3_a <= samp3_a;
				sample_trig <= sample_trig;
				delay_modifier <= delay_modifier;
				main_count <= main_count;
				samp1_count <= samp1_count;
				samp2_count <= samp2_count;
				samp3_count <= samp3_count;
				delay_mod_strb <= delay_mod_strb;
				monitor_strb <= monitor_strb;
				count1 <= count1;
				count2 <= count2;
				count3 <= count3;	
				end
			2'b11: begin
				//Add to running totals
				samp1_count <= samp1_count + samp1_b;
				samp2_count <= samp2_count + samp2_b;
				samp3_count <= samp3_count + samp3_b;
				//Increment main counter and reset state
				main_count <= main_count + 1'b1;
				state40 <= 2'b00;
				sample_trig <= sample_trig;
				delay_modifier <= delay_modifier;
				samp1_a <= samp1_a;
				samp2_a <= samp2_a;
				samp3_a <= samp3_a;
				samp1_b <= samp1_b;
				samp2_b <= samp2_b;
				samp3_b <= samp3_b;
				delay_mod_strb <= delay_mod_strb;
				monitor_strb <= monitor_strb;
				count1 <= count1;
				count2 <= count2;
				count3 <= count3;	
				end
			endcase
		end else begin
			//Finished counting the samples
			//Must modify the delay if samp2_count is outside the threshold
			//Generally, unless the sampling point is well off, then all of sample 1
			//should be set or unset, and all of sample 3 the opposite
			//Just in case though, will take a majority decision for the possible case of the
			//sample point being well off the optimum position, allowing for correction
//			if (samp1_count >= samp2_count) begin
//				if (samp2_count < threshold_min)	delay_modifier = delay_modifier + (7'b1);
//				if (samp2_count > threshold_max)	delay_modifier = delay_modifier + (-7'b1);
//			end
//			if (samp1_count < samp2_count) begin
//				if (samp2_count < threshold_min)	delay_modifier = delay_modifier + (-7'b1);
//				if (samp2_count > threshold_max)	delay_modifier = delay_modifier + (7'b1);
//			end	
			
			//First check for 'perfect misphasing'
	//This was removed after tests at ATF showed occasional jumps by 20 saturating
	//the delays
	/*		if ( (samp1_count < threshold_max) || (samp3_count > threshold_min) ) begin
				//Hmmm.  Move delay_mod by half a 357 in which ever direction takes i closer
				//to zero to help avoid saturation
				if (delay_modifier[6]) begin
					//Negative
					delay_modifier <= delay_modifier + 7'd20;
					delay_mod_strb <= 1;		
				end else begin
					delay_modifier <= delay_modifier + (-7'd20);
					delay_mod_strb <= 1;		
				end
			end else begin */
			
				//Things see okay, so check whether samp2 is within threshold
				if ( (samp2_count < threshold_min) || (samp2_count > threshold_max) ) begin
					//Outside of threshold so modify but prevent wrap-around
					if (samp2_count > 16) begin
						if (delay_modifier != 7'b1000000) begin
							delay_modifier <= delay_modifier + (-7'b1);
							delay_mod_strb <= 1;
						end
					end else begin
						if (delay_modifier != 7'b0111111) begin
							delay_modifier <= delay_modifier + (7'b1);
							delay_mod_strb <= 1;				
						end
					end //else (if ~(samp2_count) > 64))
				end
		//	end

			//Store values for monitoring and output strobe
			//count1 <= {2'b00, samp1_count};
			//count2 <= {2'b00, samp2_count};
			//count3 <= {2'b00, samp3_count};	
			count1 <= samp1_count;
			count2 <= samp2_count;
			count3 <= samp3_count;					
			monitor_strb <= 1;
			samp1_a <= samp1_a;
			samp2_a <= samp2_a;
			samp3_a <= samp3_a;
			sample_trig <= sample_trig;
			state40 <= state40;
			samp1_b <= samp1_b;
			samp2_b <= samp2_b;
			samp3_b <= samp3_b;
			//iteration_counter <= iteration_counter + 1'b1; 
						
			//Additional check for 'perfect' misphasing
//			if ( (samp2_count < threshold_max) && (samp2_count > threshold_min) &&
//				( (samp1_count < 127) || (samp3_count > 0) ) ) begin
//					//Something ain't right.  Prang the delay by half a period in which
//					//ever direction takes it closer to zero
//					if (delay_modifier[6])
//						delay_modifier <= delay_modifier + 7'd20;
//					else
//						delay_modifier <= delay_modifier + (-7'd20);
//			end
			main_count <= 5'd0;
			samp1_count <= 5'd0;
			samp2_count <= 5'd0;
			samp3_count <= 5'd0;
		
			end //else (if ~(main_cnt < n_samp))
		end else begin // if (~align_en)
			count1 <= count1;
			count2 <= count2;
			count3 <= count3;
			sample_trig <= 1'b0;
			delay_modifier <= delay_modifier;
			samp1_a <= 1'b0;
			samp2_a <= 1'b0;
			samp3_a <= 1'b0;
			samp1_b <= 1'b0;
			samp2_b <= 1'b0;
			samp3_b <= 1'b0;
			main_count <= 5'd0;
			samp1_count <= 5'd0;
			samp2_count <= 5'd0;
			samp3_count <= 5'd0;
			state40 <= 2'b00;
			delay_mod_strb <= 1'b0;
			monitor_strb <= 1'b0;
			samples_rdy_slow_a <= 1'b0;
			samples_rdy_slow_b <= 1'b0;
			end // else if (~align_en)
	end //else (if ~rst)
end //always


//assign align_en_slow = align_en_slow_b & 

// Output the temp monitored counters
//assign count1 = count1_mon;
//assign count2 = count2_mon;
//assign count3 = count3_mon;

endmodule