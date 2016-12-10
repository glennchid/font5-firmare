integer i, j;

initial begin
	for (i=0; i < N_CTRL_REGS; i=i+1) ctrl_regs[i] = 0;
	for (j=0; j < N_CTRL_REGS; j=j+1) ctrl_regs_mem[j] = 0;
	`ifdef XILINX_ISIM
		//ctrl_regs[39]=7'b1011110; // {6'd47,1'b0}
		
		ctrl_regs[37]=7'd32;//32;
		ctrl_regs[38]=7'd0;//32;
		ctrl_regs[39]=7'd93; // if use_strobes enabled must multiply by 2 -- max decimal = 127  WAS 7'd94
		ctrl_regs[40]=7'b1100000; // {3'd3, 4'd0} was 7'b0110000
		ctrl_regs[41]=7'b0110111; // {7'd20} * 8 = 160 + 3 = 163!! was 7'b0010100
		
		ctrl_regs[43] = 7'd1;        	// FF-on
		ctrl_regs[44] = 7'd2;			// Const DAC on
		ctrl_regs[46] = 7'b0010000; 	// K1 const DAC = +4095
		ctrl_regs[47] = 7'd0;			// DAC1 phase
		ctrl_regs[48] = 7'd0;			// DAC2 phase
		ctrl_regs[49] = -7'sd32;			// K1 gain
		ctrl_regs[50] = 7'sd0;			// K2 gain
		//ctrl_regs[51] = 7'd0;
		ctrl_regs[51] = 7'b1101100; 	// ch1 and ch2 IIR filters on
		ctrl_regs[52] = 7'b0110000;
		ctrl_regs[111]=3'd7;				// Trigger threshold code
		ctrl_regs[119] = 7'b1111101; // top seven bits of ten-bit decimal "164" - # samples  WAS 7'b0010100
		ctrl_regs[120] = 7'b0001111; // [bottom three bits of above,  top four bits of channel select (ones hot)]  WAS 7'b0001111
		ctrl_regs[121] = 7'b1111110; // [bottom five bits of channel select (ones hot), top two bits of eight-bit decimal "164"
		ctrl_regs[122] = 7'b1001000; // [bottom six bits of above, trigSync_ext (ie. ring clock) enable]
		ctrl_regs[123] = 7'd1; 			// Run mode
		ctrl_regs[124] = 7'b0000100; // diodeGating = 1; oflowMode = 2(saturate); useDiode = 1;		
		ctrl_regs[125] = 7'd0;

		ctrl_regs_mem[37]=7'd32;
		ctrl_regs_mem[38]=7'd32;
		ctrl_regs_mem[39]=7'b1011001; //{start proc[6:0], use strobes}  = 44, 1
		ctrl_regs_mem[40]=7'b0110000;
		ctrl_regs_mem[41]=7'b0010100;
		ctrl_regs_mem[43] = 7'd1;        	// FF-on
		ctrl_regs_mem[44] = 7'd2;			// Const DAC on
		ctrl_regs_mem[47] = 7'd0;			// DAC1 phase
		ctrl_regs_mem[48] = 7'd0;			// DAC2 phase
		ctrl_regs_mem[49] = -7'sd64;			// K1 gain
		ctrl_regs_mem[50] = 7'sd32;			// K2 gain
		//ctrl_regs_mem[51] = 7'd2;
		ctrl_regs_mem[111]=3'd7;
		ctrl_regs_mem[119] = 7'b0010100; // top seven bits of ten-bit decimal "164"
		ctrl_regs_mem[120] = 7'b1001111; // [bottom three bits of above,  top four bits of channel select (ones hot)]
		ctrl_regs_mem[121] = 7'b1111110; // [bottom five bits of channel select (ones hot), top two bits of eight-bit decimal "164"
		ctrl_regs_mem[122] = 7'b1001000; // [bottom six bits of above, trigSync_ext (ie. ring clock) enable]
		ctrl_regs_mem[123] = 7'd1; 			// Run mode
		ctrl_regs_mem[124] = 7'b0001101; // diodeGating = 1; oflowMode = 2(saturate); useDiode = 1;
		ctrl_regs_mem[125] = 7'd0;


	`else
		ctrl_regs[51] = 7'd2; //Internal triggering disable
		ctrl_regs[96] = 7'd16; // CLK357-PLL bypass OFF
		ctrl_regs[111]=3'd7;
		ctrl_regs[119] = 7'b0010100; // top seven bits of ten-bit decimal "164"
		ctrl_regs[120] = 7'b1001111; // [bottom three bits of above,  top four bits of channel select (ones hot)]
		ctrl_regs[121] = 7'b1111110; // [bottom five bits of channel select (ones hot), top two bits of eight-bit decimal "164"
		ctrl_regs[122] = 7'b1001001; // [bottom six bits of above, trigSync_ext (ie. ring clock) enable]
		ctrl_regs[123] = 7'd1; 			// Run mode enabled
		ctrl_regs[124] = 7'b0001101; // diodeGating = 1; oflowMode = 2(saturate); useDiode = 1;

		ctrl_regs_mem[51] = 7'd2; // Internal triggering disable READBACK
		ctrl_regs[96] = 7'd16; // CLK357-PLL bypass ON READBACK
		ctrl_regs_mem[111]=3'd7;
		ctrl_regs_mem[119] = 7'b0010100; // top seven bits of ten-bit decimal "164"
		ctrl_regs_mem[120] = 7'b1001111; // [bottom three bits of above,  top four bits of channel select (ones hot)]
		ctrl_regs_mem[121] = 7'b1111110; // [bottom five bits of channel select (ones hot), top two bits of eight-bit decimal "164"
		ctrl_regs_mem[122] = 7'b1001000; // [bottom six bits of above, trigSync_ext (ie. ring clock) enable]
		ctrl_regs_mem[123] = 7'd1; 			// Run mode enabled READBACK
		ctrl_regs_mem[124] = 7'b0001101; // diodeGating = 1; oflowMode = 2(saturate); useDiode = 1;
	`endif
	end
	