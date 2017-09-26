`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   13:07:30 07/02/2014
// Design Name:   FONT5_base
// Module Name:   H:/Firmware/FONT5_base/ISE13/FONT5_base/font5_base_TB.v
// Project Name:  FONT5_base
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: FONT5_base
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module RebeccaTB;

//`include "H:\Firmware\FONT5_base\sources\verilog\definitions.vh"

parameter CH1_BITFLIP = (13'b1011010000101 ^ -13'sd4096);
parameter CH2_BITFLIP = (13'b0101110001000 ^ -13'sd4096);
parameter CH4_BITFLIP = (13'b0111100000000 ^ -13'sd4096);
parameter CH5_BITFLIP = (13'b0100110011010 ^ -13'sd4096);

//assign ch3_bitflip = 13'b0001011110100;


	// Inputs
	reg clk357;
	reg clk40;
	reg clk40_ibufg;
	reg signed [12:0] ch1_data_in_del;
	reg signed [12:0] ch2_data_in_del;
	reg  [12:0] ch3_data_in_del;
	reg [12:0] ch4_data_in_del;
	reg  [12:0] ch5_data_in_del;
	reg  [12:0] ch6_data_in_del;
	reg [12:0] ch7_data_in_del;
	reg  [12:0] ch8_data_in_del;
	reg  [12:0] ch9_data_in_del;
   reg signed  [12:0] ch1_data_in_del1 [0:8199];
	reg signed [12:0] ch2_data_in_del1 [0:8199];
	reg [12:0] ch3_data_in_del1 [0:8199];
	reg [12:0] ch4_data_in_del1 [0:8199];
	reg  [12:0] ch5_data_in_del1 [0:8199];
	reg  [12:0] ch6_data_in_del1 [0:8199];
	reg [12:0] ch7_data_in_del1 [0:8199];
	reg  [12:0] ch8_data_in_del1 [0:8199];
	reg  [12:0] ch9_data_in_del1 [0:8199];
	reg rs232_in;
	reg diginput1;
	reg diginput2;
	reg dcm200_locked;
	reg idelayctrl_rdy;
	reg pll_clk357_locked;
	reg dcm360_locked;
	reg IDDR1_Q1;
	reg IDDR1_Q2;
	reg IDDR2_Q1;
	reg IDDR2_Q2;
	reg IDDR3_Q1;
	reg IDDR3_Q2;

	// Outputs
	wire adc_powerdown;
	wire iddr_ce;
	wire [12:0] dac1_out;
	wire dac1_clk;
	wire [12:0] dac2_out;
	wire dac2_clk;
	wire rs232_out;
	wire led0_out;
	wire led1_out;
	wire led2_out;
	wire trim_cs_ld;
	wire trim_sck;
	wire trim_sdi;
	wire diginput1A;
	wire diginput1B;
	wire diginput2A;
	wire diginput2B;
	wire auxOutA;
	wire auxOutB;
	wire dcm200_rst;
	wire clk_blk;
	wire clk357_idelay_ce;
	wire clk357_idelay_rst;
	wire idelay_rst;
	wire fastClk_sel;
	wire clkPLL_sel;
	wire run;
	wire delay_calc_strb1;
	wire delay_calc_strb2;
	wire delay_calc_strb3;
	wire delay_trig1;
	wire delay_trig2;
	wire delay_trig3;
	wire adc1_drdy_delay_ce;
	wire adc2_drdy_delay_ce;
	wire adc3_drdy_delay_ce;
	wire adc1_clk_delay_ce;
	wire adc2_clk_delay_ce;
	wire adc3_clk_delay_ce;
	wire adc1_data_delay_ce;
	wire adc2_data_delay_ce;
	wire adc3_data_delay_ce;

	// Instantiate the Unit Under Test (UUT)
	FONT5_base uut (
		.clk357(clk357), 
		.clk40(clk40), 
		.clk40_ibufg(clk40_ibufg), 
		.ch1_data_in_del(ch1_data_in_del ^ CH1_BITFLIP), 
		.ch2_data_in_del(ch2_data_in_del ^ CH2_BITFLIP), 
		.ch3_data_in_del(ch3_data_in_del), 
		.ch4_data_in_del(ch4_data_in_del ^ CH4_BITFLIP), 
		.ch5_data_in_del(ch5_data_in_del ^ CH5_BITFLIP), 
		.ch6_data_in_del(ch6_data_in_del), 
		.ch7_data_in_del(ch7_data_in_del), 
		.ch8_data_in_del(ch8_data_in_del), 
		.ch9_data_in_del(ch9_data_in_del), 
		.rs232_in(rs232_in), 
		.adc_powerdown(adc_powerdown), 
		.iddr_ce(iddr_ce),
		.dac1_out(dac1_out), 
		.dac1_clk(dac1_clk), 
		.dac2_out(dac2_out), 
		.dac2_clk(dac2_clk), 
		.rs232_out(rs232_out), 
		.led0_out(led0_out), 
		.led1_out(led1_out), 
		.led2_out(led2_out), 
		.trim_cs_ld(trim_cs_ld), 
		.trim_sck(trim_sck), 
		.trim_sdi(trim_sdi), 
		.diginput1A(diginput1A), 
		.diginput1B(diginput1B), 
		.diginput1(diginput1), 
		.diginput2A(diginput2A), 
		.diginput2B(diginput2B), 
		.diginput2(diginput2), 
		.auxOutA(auxOutA), 
		.auxOutB(auxOutB), 
		//.dcm200_rst(dcm200_rst), 
		.dcm200_locked(dcm200_locked), 
		.clk_blk(clk_blk), 
		.idelayctrl_rdy(idelayctrl_rdy), 
		//.pll_clk357_locked(pll_clk357_locked), 
		.clk357_idelay_ce(clk357_idelay_ce), 
		.clk357_idelay_rst(clk357_idelay_rst), 
		.idelay_rst(idelay_rst), 
		//.dcm360_locked(dcm360_locked), 
		//.fastClk_sel(fastClk_sel), 
		//.clkPLL_sel_a(clkPLL_sel),
		.run(run),
		.delay_calc_strb1(delay_calc_strb1), 
		.delay_calc_strb2(delay_calc_strb2), 
		.delay_calc_strb3(delay_calc_strb3), 
		.delay_trig1(delay_trig1), 
		.delay_trig2(delay_trig2), 
		.delay_trig3(delay_trig3), 
		.adc1_drdy_delay_ce(adc1_drdy_delay_ce), 
		.adc2_drdy_delay_ce(adc2_drdy_delay_ce), 
		.adc3_drdy_delay_ce(adc3_drdy_delay_ce), 
		.adc1_clk_delay_ce(adc1_clk_delay_ce), 
		.adc2_clk_delay_ce(adc2_clk_delay_ce), 
		.adc3_clk_delay_ce(adc3_clk_delay_ce), 
		.adc1_data_delay_ce(adc1_data_delay_ce), 
		.adc2_data_delay_ce(adc2_data_delay_ce), 
		.adc3_data_delay_ce(adc3_data_delay_ce), 
		.IDDR1_Q1(IDDR1_Q1), 
		.IDDR1_Q2(IDDR1_Q2), 
		.IDDR2_Q1(IDDR2_Q1), 
		.IDDR2_Q2(IDDR2_Q2), 
		.IDDR3_Q1(IDDR3_Q1), 
		.IDDR3_Q2(IDDR3_Q2),
		.store_strb(store_strb)
	);

	/*integer fid;
	reg [12:0] k = 13'd0;
	reg [12:0] Mem[0:499], Mem2[0:499];*/
	
	
integer i;
integer trigger_counter;

	initial begin
//		$readmemh("diodeAD.dat", Mem);
//		$readmemh("mixer_ad.dat", Mem2);
//		fid = $fopen("simOut.dat");
		// Initialize Inputs
		clk357 = 0;
		clk40 = 0;
		clk40_ibufg = 0;
		ch1_data_in_del = 13'sd0;
		ch2_data_in_del = 13'sd0;
		ch3_data_in_del = 0;
		ch4_data_in_del = 13'sd0;
		ch5_data_in_del = 13'sd0;
		ch6_data_in_del = 0;
		ch7_data_in_del = 0;
		ch8_data_in_del = 0;
		ch9_data_in_del = 0;
		rs232_in = 0;
		diginput1 = 0;
		diginput2 = 0;
		dcm200_locked = 0;
		idelayctrl_rdy = 0;
		pll_clk357_locked = 0;
		dcm360_locked = 0;
		IDDR1_Q1 = 0;
		IDDR1_Q2 = 0;
		IDDR2_Q1 = 0;
		IDDR2_Q2 = 0;
		IDDR3_Q1 = 0;
		IDDR3_Q2 = 0;
//		i=0;
		trigger_counter=0;
		end
		
		
		

//		// Wait 100 ns for global reset to finish
//		#100;
//        
//		// Add stimulus here
//		
//		#28;
//		//ch1_data_in_del = 13'sd1000; 
//		//ch2_data_in_del = -13'sd4000;
//		ch2_data_in_del = 13'sd2048; 
//		ch1_data_in_del = -13'sd256;
//		ch4_data_in_del = 13'sd500;
//		ch5_data_in_del = 13'sd0;
//		
//		#280; ch2_data_in_del = 13'sd1024;
//		#280; ch2_data_in_del = 13'sd512;
//		#280; ch2_data_in_del = -13'sd512;
//		#280; ch2_data_in_del = 13'sd0;
//
//		
//		//ch1_data_in_del = 13'sd1250; 
//		//ch2_data_in_del = -13'sd250;
////		#1120;
////		ch1_data_in_del = 13'sd0; 
////		ch2_data_in_del = 13'sd0;
////		ch4_data_in_del = 13'sd0; 
////		ch5_data_in_del = 13'sd0;
//		
//				
//	end
      
	initial forever #1.4 clk357 = ~clk357;
	initial forever #12.5 clk40 = ~clk40;
initial begin
$readmemb("tempai.txt",ch4_data_in_del1);
$readmemb("tempaq.txt",ch5_data_in_del1);
$readmemb("tempbi.txt",ch1_data_in_del1);
$readmemb("tempbq.txt",ch2_data_in_del1);
$readmemb("tempci.txt",ch7_data_in_del1);
$readmemb("tempcq.txt",ch8_data_in_del1);
$readmemb("tempq.txt",ch9_data_in_del1);
end
	
	
always @ (negedge clk357) 
begin
if (store_strb==0) begin
//    ai_in <= 0;
//    bi_in<=0;
//	 ci_in<=0;
//	 aq_in <=0;
//	 bq_in<=0;
//	 cq_in<=0;
//	 sel[1] <=1;
//	 sel[0] <=0;
		ch1_data_in_del <= 13'sd0;
		ch2_data_in_del <= 13'sd0;
		ch3_data_in_del <= 0;
		ch4_data_in_del <= 13'sd0;
		ch5_data_in_del <= 13'sd0;
		ch6_data_in_del <= 0;
		ch7_data_in_del <= 0;
		ch8_data_in_del <= 0;
		ch9_data_in_del <= 0;
      i<=(4*trigger_counter+2)*164;
end else begin 
		ch1_data_in_del = ch1_data_in_del1[i];
		ch2_data_in_del = ch2_data_in_del1[i];
//		ch3_data_in_del = ch3_data_in_del1[i];
		ch4_data_in_del = ch4_data_in_del1[i];
		ch5_data_in_del = ch5_data_in_del1[i];
//		ch6_data_in_del = ch6_data_in_del1[i];
		ch7_data_in_del = ch7_data_in_del1[i+5];
		ch8_data_in_del = ch8_data_in_del1[i+5];
		ch9_data_in_del = ch9_data_in_del1[i+10];
//ai_in<=ai_in1[i];
//aq_in<=aq_in1[i];
//bi_in<=bi_in1[i];
//bq_in<=bq_in1[i];
//ci_in<=ci_in1[i+5];
//cq_in<=cq_in1[i+5];
//q_signal<=q_signal1[i+10]; 
i<=i+1;
end
end

always @ (posedge store_strb) begin
#1 trigger_counter=trigger_counter+1;


end
		/*always @(posedge clk357) begin
			ch1_data_in_del <= Mem[k];
			ch2_data_in_del <= Mem2[k];
			k <=  k + 1'b1;
			$fwrite(fid,"%h\n", dac1_out);
			if (k==13'd499) begin
				$fclose(fid);
				$finish;
			end
		end	*/
		
endmodule

