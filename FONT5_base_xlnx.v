`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:24:59 10/24/2009 
// Design Name: 
// Module Name:    FONT5_9Chan 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
//
// Note: the XIL_PAR_ALLOW_LVDS_LOC_OVERRIDE environment variable was set to
// true to allow MAP to complete.  It complained that about 5 of the ch1
// data bits were connected backwards to the differential inputs, and would
// have the wrong polarity.  The env. var. overode this error
//
//////////////////////////////////////////////////////////////////////////////////
module FONT5_base_xlnx(
		input clk357_n,
		input clk357_p,
		input clk40_s,
		input ch1_drdy_n,
		input ch2_drdy_n,
		input ch3_drdy_n,
		input ch1_drdy_p,
		input ch2_drdy_p,
		input ch3_drdy_p,
		input signed [12:0] ch1_data_in_n,
		input signed [12:0] ch2_data_in_n,
		input signed [12:0] ch3_data_in_n,
		input signed [12:0] ch1_data_in_p,
		input signed [12:0] ch2_data_in_p,
		input signed [12:0] ch3_data_in_p,		
		input ch4_drdy_n,
		input ch5_drdy_n,
		input ch6_drdy_n,
		input ch4_drdy_p,
		input ch5_drdy_p,
		input ch6_drdy_p,
		input signed [12:0] ch4_data_in_n,
		input signed [12:0] ch5_data_in_n,
		input signed [12:0] ch6_data_in_n,
		input signed [12:0] ch4_data_in_p,
		input signed [12:0] ch5_data_in_p,
		input signed [12:0] ch6_data_in_p,		
		input ch7_drdy_n,
		input ch8_drdy_n,
		input ch9_drdy_n,
		input ch7_drdy_p,
		input ch8_drdy_p,
		input ch9_drdy_p,
		input signed [12:0] ch7_data_in_n,
		input signed [12:0] ch8_data_in_n,
		input signed [12:0] ch9_data_in_n,
		input signed [12:0] ch7_data_in_p,
		input signed [12:0] ch8_data_in_p,
		input signed [12:0] ch9_data_in_p,			
		input rs232_in,		
		//output amp_trig,
		//output amp_trig2,
		output adc_powerdown,
		output adc1_clk_n,
		output adc1_clk_p,
		output adc2_clk_n,
		output adc2_clk_p,
		output adc3_clk_n,
		output adc3_clk_p,
		output signed [12:0] dac1_out,
		output dac1_clk,	
		output signed [12:0] dac2_out,
		output dac2_clk,
//		output [12:0] dac3_out,
//		output dac3_clk,
//		output [12:0] dac4_out,
//		output dac4_clk,
		output rs232_out,
		output led0_out,
		output led1_out,
		output led2_out,
		output trim_cs_ld,
		output trim_sck,
		output trim_sdi,
		output diginput1A,
		output diginput1B,
		input diginput1,
		output diginput2A,
		output diginput2B,
		input diginput2,
		//output auxOutA,
		//output auxOutB
		output auxOutA1,
		output auxOutB1,
		output auxOutA2,
		output auxOutB2,
		(* PULLUP = "TRUE" *) input FONT5_detect
		//input FONT5_detect
		//diginput2_loopback
    );


//`include "H:\Firmware\FONT5_base\sources\verilog\definitions.vh"

//wire signed [12:0] dac1_out, dac2_out;
//wire dac1_clk, dac2_clk;
//assign dac3_out = dac1_out;
//assign dac4_out = dac2_out;
//assign dac3_clk = dac1_clk;
//assign dac4_clk = dac2_clk;


supply0 gnd;
supply1 vcc;
//signal declarations for slow clock (on-board oscillator)
wire clk40_ibufg, dcm200_rst, clk200, clk40_dcm, dcm200_locked, clk40_blk, idelayctrl_rdy;
//(* clock_buffer = "BUFG" *) wire clk40;
wire clk40;
//signal declarations for fast clock (external) 
//(* clock_buffer = "BUFG" *) wire clk357_delayed;
//wire clk357_delayed;
wire clk357_ibufg, pll_clk357_fb, pll_clk357_locked, clk357_bufg, clk357_delayed;
//(* clock_buffer = "BUFG" *) wire clk357_pll; 
wire clk357_pll; 
wire clk357_idelay_ce, clk357_idelay_rst, idelay_rst;
//(* clock_buffer = "BUFGMUX" *) wire clk357;
wire clk357;
wire ch1_drdy, ch2_drdy, ch3_drdy, ch4_drdy, ch5_drdy, ch6_drdy, ch7_drdy, ch8_drdy, ch9_drdy;
wire delay_calc_strb1, delay_calc_strb2, delay_calc_strb3, delay_trig1, delay_trig2, delay_trig3, adc1_drdy_delay_ce, adc2_drdy_delay_ce, adc3_drdy_delay_ce;
wire ch1_drdy_out, ch2_drdy_out, ch3_drdy_out, ch4_drdy_out, ch5_drdy_out, ch6_drdy_out, ch7_drdy_out, ch8_drdy_out, ch9_drdy_out;
wire adc1_clk_delay_ce, adc2_clk_delay_ce, adc3_clk_delay_ce;
wire adc1_data_delay_ce, adc2_data_delay_ce, adc3_data_delay_ce;
wire adc1_clk, adc2_clk, adc3_clk;
wire signed [12:0] ch1_data_in, ch2_data_in, ch3_data_in, ch4_data_in, ch5_data_in, ch6_data_in, ch7_data_in, ch8_data_in, ch9_data_in;
wire signed [12:0] ch1_data_in_del, ch2_data_in_del, ch3_data_in_del, ch4_data_in_del, ch5_data_in_del, ch6_data_in_del, ch7_data_in_del, ch8_data_in_del, ch9_data_in_del;
wire IDDR1_Q1, IDDR1_Q2, IDDR2_Q1, IDDR2_Q2, IDDR3_Q1, IDDR3_Q2;

//Detect board variant and configure AUX_OUTS
//wire auxOutA, auxOutB;
//assign auxOutA1 = (FONT5_detect) ? auxOutA : 1'bz;
//assign auxOutB1 = (FONT5_detect) ? auxOutB : 1'bz;
//assign auxOutA2 = (FONT5_detect) ? 1'bz : ~auxOutA; // NB: auxOuts on FONT5A boards use inverting buffers
//assign auxOutB2 = (FONT5_detect) ? 1'bz : ~auxOutB; // NB: auxOuts on FONT5A boards use inverting buffers
//assign auxOutA2 = auxOutA;
//assign auxOutB2 = auxOutB;

//DCM config reset
wire config_rst;
DCM_config_rst ConfigRst1(clk40_ibufg, config_rst);

//DCM for 200 MHz
DCM1 DCM200 (
    .CLKIN_IN(clk40_s), 
    //.RST_IN(dcm200_rst), 
	 .RST_IN(config_rst),
    .CLKFX_OUT(clk200), 
    .CLKIN_IBUFG_OUT(clk40_ibufg), 
    .CLK0_OUT(clk40_dcm), 
    .LOCKED_OUT(dcm200_locked)
    );

// %%%%%%%%%%%%%%%   40MHz INPUT - 200MHz gen - IDELAYCTRL  %%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

// **** Input buffer for 40Mz on-board oscillator ****
// Note the clk40_ibufg clocks the reset logic since it is present during DCM reset,
// and the UART & Decoder for the same reason

BUFGCE BUFGCE_DCM_CLK40 (
	.O(clk40),
	.CE(~clk40_blk),
	.I(clk40_dcm)
);

//assign clk40 = (clk40_blk) ? 1'b0 : clk40_dcm;

// **** IDELAYCTRL instantiation ****
// Single instantiation template for all IODELAYS
IDELAYCTRL IDELAYCTRL1 (
	.RDY(idelayctrl_rdy),		
	.REFCLK(clk200),
	.RST(~dcm200_locked)
);

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%   357MHz INPUT   %%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

wire fastClk_int, dcm360_locked;
//(* clock_buffer = "BUFG" *) wire fastClk_ext;
wire fastClk_ext;



//Internal clock DCM
DCM2 DCM360(
    .CLKIN_IN(clk40_ibufg), 
    //.RST_IN(dcm200_rst), 
	 .RST_IN(config_rst),
    .CLKFX_OUT(fastClk_int), 
    .CLK0_OUT(), 
    .LOCKED_OUT(dcm360_locked)
    );


// **** Differential input buffer for the master 357MHz clock ****
/*IBUFGDS #(
	.DIFF_TERM("TRUE"),
	.IOSTANDARD("DEFAULT")
) IBUFGDS_CLK357 (
	.O(clk357_ibufg), 
	.I(clk357_p),
	.IB(clk357_n)
);*/



IBUFDS #(	//changed to IBUFDS - 16/3/15
	.DIFF_TERM("TRUE"),
	.IOSTANDARD("DEFAULT")
) IBUFGDS_CLK357 (
	.O(clk357_ibufg), 
	.I(clk357_p),
	.IB(clk357_n)
);

//Instance pll_clkSwitch
//wire fastClk_sel, clkSwitch_out, pll_rst;
//pll_clkSwitch clkSwitch1(clk40, fastClk_sel, clkSwitch_out, pll_rst); //Custom-VCD on fastClk_sel


// **** PLL for master 357MHz clock ****
// Configured as a jitter filter (low bandwidth, internal feedback)
// VCO frequency 2*357MHz
// Output via global clock buffer as required
PLL_BASE #(
	.BANDWIDTH("LOW"), //Better jitter filter performance (V5 user guide)
	.CLKFBOUT_MULT(2),
	.CLKFBOUT_PHASE(0.0),
	.CLKIN_PERIOD(2.8), // ns
	.CLKOUT0_DIVIDE(2),
	.CLKOUT0_DUTY_CYCLE(0.5),
	.CLKOUT0_PHASE(0.0), 
	.CLKOUT1_DIVIDE(1), 
	.CLKOUT1_DUTY_CYCLE(0.5), 
	.CLKOUT1_PHASE(0.0),
	.CLKOUT2_DIVIDE(1), 
	.CLKOUT2_DUTY_CYCLE(0.5), 
	.CLKOUT2_PHASE(0.0),
	.CLKOUT3_DIVIDE(1),
	.CLKOUT3_DUTY_CYCLE(0.5),
	.CLKOUT3_PHASE(0.0), 
	.CLKOUT4_DIVIDE(1),
	.CLKOUT4_DUTY_CYCLE(0.5),
	.CLKOUT4_PHASE(0.0),
	.CLKOUT5_DIVIDE(1),
	.CLKOUT5_DUTY_CYCLE(0.5),
	.CLKOUT5_PHASE(0.0),
	.COMPENSATION("SYSTEM_SYNCHRONOUS"),
	.DIVCLK_DIVIDE(1),
	.REF_JITTER(0.100) // Input reference jitter *LEFT AT DEFAULT*
) PLL_CLK357 (
	.CLKFBOUT(pll_clk357_fb), 	// Internal feedback signal
	.CLKOUT0(clk357_pll),
	//.CLKOUT0(fastClk_ext),
	.CLKOUT1(),
	.CLKOUT2(),
	.CLKOUT3(),
	.CLKOUT4(),
	.CLKOUT5(),
	.LOCKED(pll_clk357_locked),
	.CLKFBIN(pll_clk357_fb), 	// Internal feedback signal
	//.CLKIN(clk357_ibufg),
	.CLKIN(clk357_bufg),
	//.CLKIN(clk357_delayed),
	.RST(dcm200_rst)
);

// PLL_ADV: Phase-Lock Loop Clock Circuit 
   //          Virtex-5
   // Xilinx HDL Language Template, version 14.7
   
/*   PLL_ADV #(
      .BANDWIDTH("OPTIMIZED"),  // "HIGH", "LOW" or "OPTIMIZED" 
      .CLKFBOUT_MULT(2),        // Multiplication factor for all output clocks
      .CLKFBOUT_PHASE(0.0),     // Phase shift (degrees) of all output clocks
      .CLKIN1_PERIOD(2.800),    // Clock period (ns) of input clock on CLKIN1
      .CLKIN2_PERIOD(2.778),    // Clock period (ns) of input clock on CLKIN2
      .CLKOUT0_DIVIDE(1),       // Division factor for CLKOUT0 (1 to 128)
      .CLKOUT0_DUTY_CYCLE(0.5), // Duty cycle for CLKOUT0 (0.01 to 0.99)
      .CLKOUT0_PHASE(0.0),      // Phase shift (degrees) for CLKOUT0 (0.0 to 360.0)
      .CLKOUT1_DIVIDE(1),       // Division factor for CLKOUT1 (1 to 128)
      .CLKOUT1_DUTY_CYCLE(0.5), // Duty cycle for CLKOUT1 (0.01 to 0.99)
      .CLKOUT1_PHASE(0.0),      // Phase shift (degrees) for CLKOUT1 (0.0 to 360.0)
      .CLKOUT2_DIVIDE(1),       // Division factor for CLKOUT2 (1 to 128)
      .CLKOUT2_DUTY_CYCLE(0.5), // Duty cycle for CLKOUT2 (0.01 to 0.99)
      .CLKOUT2_PHASE(0.0),      // Phase shift (degrees) for CLKOUT2 (0.0 to 360.0)
      .CLKOUT3_DIVIDE(1),       // Division factor for CLKOUT3 (1 to 128)
      .CLKOUT3_DUTY_CYCLE(0.5), // Duty cycle for CLKOUT3 (0.01 to 0.99)
      .CLKOUT3_PHASE(0.0),      // Phase shift (degrees) for CLKOUT3 (0.0 to 360.0)
      .CLKOUT4_DIVIDE(1),       // Division factor for CLKOUT4 (1 to 128)
      .CLKOUT4_DUTY_CYCLE(0.5), // Duty cycle for CLKOUT4 (0.01 to 0.99)
      .CLKOUT4_PHASE(0.0),      // Phase shift (degrees) for CLKOUT4 (0.0 to 360.0)
      .CLKOUT5_DIVIDE(1),       // Division factor for CLKOUT5 (1 to 128)
      .CLKOUT5_DUTY_CYCLE(0.5), // Duty cycle for CLKOUT5 (0.01 to 0.99)
      .CLKOUT5_PHASE(0.0),      // Phase shift (degrees) for CLKOUT5 (0.0 to 360.0)
      .COMPENSATION("SYSTEM_SYNCHRONOUS"), // "SYSTEM_SYNCHRONOUS", 
                                //   "SOURCE_SYNCHRONOUS", "INTERNAL", "EXTERNAL", 
                                //   "DCM2PLL", "PLL2DCM" 
      .DIVCLK_DIVIDE(1),        // Division factor for all clocks (1 to 52)
      .EN_REL("FALSE"),         // Enable release (PMCD mode only)
      .PLL_PMCD_MODE("FALSE"),  // PMCD Mode, TRUE/FASLE
      .REF_JITTER(0.100),       // Input reference jitter (0.000 to 0.999 UI%)
      .RST_DEASSERT_CLK("CLKIN1") // In PMCD mode, clock to synchronize RST release
   ) PLL_ADV_inst (
      .CLKFBDCM(),      // Output feedback signal used when PLL feeds a DCM
      .CLKFBOUT(pll_clk357_fb),      // General output feedback signal
      .CLKOUT0(clk357_pll),        // One of six general clock output signals
      .CLKOUT1(),        // One of six general clock output signals
      .CLKOUT2(),        // One of six general clock output signals
      .CLKOUT3(),        // One of six general clock output signals
      .CLKOUT4(),        // One of six general clock output signals
      .CLKOUT5(),        // One of six general clock output signals
      .CLKOUTDCM0(),  // One of six clock outputs to connect to the DCM
      .CLKOUTDCM1(),  // One of six clock outputs to connect to the DCM
      .CLKOUTDCM2(),  // One of six clock outputs to connect to the DCM
      .CLKOUTDCM3(),  // One of six clock outputs to connect to the DCM
      .CLKOUTDCM4(),  // One of six clock outputs to connect to the DCM
      .CLKOUTDCM5(),  // One of six clock outputs to connect to the DCM
      .DO(),                  // Dynamic reconfig data output (16-bits)
      .DRDY(),              // Dynamic reconfig ready output
      .LOCKED(pll_clk357_locked),          // Active high PLL lock signal
      .CLKFBIN(pll_clk357_fb),        // Clock feedback input
      .CLKIN1(clk357_ibufg),          // Primary clock input
      .CLKIN2(fastClk_int),          // Secondary clock input
      .CLKINSEL(clkSwitch_out),      // Selects '1' = CLKIN1, '0' = CLKIN2
      .DADDR(),            // Dynamic reconfig address input (5-bits)
      .DCLK(),              // Dynamic reconfig clock input
      .DEN(),                // Dynamic reconfig enable input
      .DI(),                  // Dynamic reconfig data input (16-bits)
      .DWE(),                // Dynamic reconfig write enable input
      .REL(),                // Clock release input (PMCD mode only)
      .RST(pll_rst | dcm200_rst)                 // Asynchronous PLL reset
   );*/

BUFG BUFG_PLL_CLK357 (
	.O(clk357_bufg),
	//.I(clk357_pll)
	.I(clk357_delayed)
);

// **** IDELAY for the master 357MHz clock ****

IODELAY # (
	//.DELAY_SRC("DATAIN"),
	.DELAY_SRC("I"),
	.HIGH_PERFORMANCE_MODE("TRUE"),
	.IDELAY_TYPE("VARIABLE"),
	.IDELAY_VALUE(0),
	.ODELAY_VALUE(0),
	.REFCLK_FREQUENCY(200.0),
	.SIGNAL_PATTERN("CLOCK")
) IODELAY_MASTER_CLK357 (
	//.DATAOUT(clk357_bufg),
	//.DATAOUT(fastClk_ext),
	.DATAOUT(clk357_delayed), 	
	.C(clk40),
	.CE(clk357_idelay_ce), 
	//.DATAIN(clk357_bufg),		
	//.DATAIN(clk357_pll),		
	//.IDATAIN(clk357_ibufg),		
	//.IDATAIN(gnd),	// Must be grounded
	.IDATAIN(clk357_ibufg),	// Must be grounded
	.INC(1'b1), 		// Always increment
	.ODATAIN(gnd),	// Must be grounded		
	.RST(clk357_idelay_rst | idelay_rst),	//Reset when modifying delay or as part of full reset
	.T(vcc) 			// 1==INPUT/INTERNAL	0==OUTPUT
);


// **** Final global clock buffer for 357MHz distribution ****

/*BUFG BUFG_CLK357 (
	.O(fastClk_ext),
	//.O(clk357),
	//.I(clk357_delayed)
	.I(clk357_pll)
);
*/
wire clkPLL_sel;

BUFGMUX_CTRL BUFG_CLK357 (
      .O(fastClk_ext),    // Clock MUX output
      .I0(clk357_pll),  // Clock0 input
		//.I0(clk357_delayed),  // Clock0 input
      .I1(clk357_bufg),  // Clock1 input
      .S(clkPLL_sel)     // Clock select input
		//.S(1'b0)     // Clock select input
   );

//wire fastClk_sel;

BUFGMUX_CTRL BUFGMUX_CTRL_inst (
      .O(clk357),    // Clock MUX output
      .I0(fastClk_ext),  // Clock0 input
		//.I0(clk357_delayed),  // Clock0 input
      .I1(fastClk_int),  // Clock1 input
      .S(fastClk_sel)     // Clock select input
   );
	
//assign clk357 = (fastClk_sel) ? fastClk_int : fastClk_ext; 

//Instantiate IBUFDS and IODELAYs for the incoming DATA, DRDY, and ADC clocks

`include "DRDY_IBUFDS_inst.v"
`include "DRDY_IDELAY_inst.v"

	IODELAY # (
		.DELAY_SRC("DATAIN"),
		.HIGH_PERFORMANCE_MODE("TRUE"),
		.IDELAY_TYPE("VARIABLE"),
		.IDELAY_VALUE(0),
		.ODELAY_VALUE(0),
		.REFCLK_FREQUENCY(200.0),
		.SIGNAL_PATTERN("CLOCK")
	) adc1_clk_odelay (
	.DATAOUT(adc1_clk), 
	.C(clk40),
	.CE(adc1_clk_delay_ce), 
	.DATAIN(clk357),		
	.IDATAIN(gnd),	// Must be grounded
	.INC(1'b1), 		// Always increment
	.ODATAIN(gnd),	// Must be grounded		
	.RST(delay_calc_strb1 | delay_trig1),
	.T(vcc) 			// 1==INPUT/INTERNAL	0==OUTPUT
	);
	IODELAY # (
		.DELAY_SRC("DATAIN"),
		.HIGH_PERFORMANCE_MODE("TRUE"),
		.IDELAY_TYPE("VARIABLE"),
		.IDELAY_VALUE(0),
		.ODELAY_VALUE(0),
		.REFCLK_FREQUENCY(200.0),
		.SIGNAL_PATTERN("CLOCK")
	) adc2_clk_odelay (
	.DATAOUT(adc2_clk), 
	.C(clk40),
	.CE(adc2_clk_delay_ce), 
	.DATAIN(clk357),		
	.IDATAIN(gnd),	// Must be grounded
	.INC(1'b1), 		// Always increment
	.ODATAIN(gnd),	// Must be grounded		
	.RST(delay_calc_strb2 | delay_trig2),
	.T(vcc) 			// 1==INPUT/INTERNAL	0==OUTPUT
	);
	IODELAY # (
		.DELAY_SRC("DATAIN"),
		.HIGH_PERFORMANCE_MODE("TRUE"),
		.IDELAY_TYPE("VARIABLE"),
		.IDELAY_VALUE(0),
		.ODELAY_VALUE(0),
		.REFCLK_FREQUENCY(200.0),
		.SIGNAL_PATTERN("CLOCK")
	) adc3_clk_odelay (
	.DATAOUT(adc3_clk), 
	.C(clk40),
	.CE(adc3_clk_delay_ce), 
	.DATAIN(clk357),		
	.IDATAIN(gnd),	// Must be grounded
	.INC(1'b1), 		// Always increment
	.ODATAIN(gnd),	// Must be grounded		
	.RST(delay_calc_strb3 | delay_trig3),
	.T(vcc) 			// 1==INPUT/INTERNAL	0==OUTPUT
	);
	
`include "DATA_IBUFDS_inst.v"
`include "DATA_IODELAY_inst.v"

//wire adc1_clk_buf;
//assign adc1_clk_buf = adc1_clk & pad_support;

wire run;

// **** Differential output buffers for ADC group clocks ****
OBUFDS #(
	//.IOSTANDARD("DEFAULT")
	.IOSTANDARD("LVPECL_25")
) OBUFDS_ADC1 (
	.O(adc1_clk_p), 
	.OB(adc1_clk_n), 
	.I(adc1_clk & run)
	//.I(adc1_clk)
);

OBUFDS #(
	//.IOSTANDARD("DEFAULT")
	.IOSTANDARD("LVPECL_25")
) OBUFDS_ADC2 (
	.O(adc2_clk_p), 
	.OB(adc2_clk_n), 
	.I(adc2_clk & run)
	//.I(adc2_clk)
);

OBUFDS #(
	//.IOSTANDARD("DEFAULT")
	.IOSTANDARD("LVPECL_25")
) OBUFDS_ADC3 (
	.O(adc3_clk_p), 
	.OB(adc3_clk_n), 
	.I(adc3_clk & run)
	//.I(adc3_clk)
);

wire drdy1 = ch1_drdy_out; //to keep with the logical names for changing this dynamically
wire drdy2 = ch4_drdy_out;
wire drdy3 = ch7_drdy_out;


// Instantiate the double data input in the IOB
IDDR #(
	.DDR_CLK_EDGE("OPPOSITE_EDGE"), 
	.INIT_Q1(1'b0),
	.INIT_Q2(1'b0),
	.SRTYPE("ASYNC")
) DRDY_IDDR1 (
	.Q1(IDDR1_Q1),
	.Q2(IDDR1_Q2),
	.C(clk357), 
	.CE(1'b1), 
	.D(drdy1),
	.R(dcm200_rst),
	.S(1'b0) 
);

IDDR #(
	.DDR_CLK_EDGE("OPPOSITE_EDGE"), 
	.INIT_Q1(1'b0),
	.INIT_Q2(1'b0),
	.SRTYPE("ASYNC")
) DRDY_IDDR2 (
	.Q1(IDDR2_Q1),
	.Q2(IDDR2_Q2),
	.C(clk357), 
	.CE(1'b1), 
	.D(drdy2),
	.R(dcm200_rst),
	.S(1'b0) 
);

IDDR #(
	.DDR_CLK_EDGE("OPPOSITE_EDGE"), 
	.INIT_Q1(1'b0),
	.INIT_Q2(1'b0),
	.SRTYPE("ASYNC")
) DRDY_IDDR3 (
	.Q1(IDDR3_Q1),
	.Q2(IDDR3_Q2),
	.C(clk357), 
	.CE(1'b1), 
	.D(drdy3),
	.R(dcm200_rst),
	.S(1'b0) 
);

//Instance the auxOut selection module
wire auxOutA, auxOutB;
auxOut_select auxOut_select(clk357, FONT5_detect, auxOutA, auxOutB, auxOutA1, auxOutB1, auxOutA2, auxOutB2);

//Instantiate the top level module

FONT5_base FONT5_base_top (
    .clk357(clk357), 
	 .clk40(clk40),
    .clk40_ibufg(clk40_ibufg), 
    .ch1_data_in_del(ch1_data_in_del), 
    .ch2_data_in_del(ch2_data_in_del), 
    .ch3_data_in_del(ch3_data_in_del), 
    .ch4_data_in_del(ch4_data_in_del), 
    .ch5_data_in_del(ch5_data_in_del), 
    .ch6_data_in_del(ch6_data_in_del), 
    .ch7_data_in_del(ch7_data_in_del), 
    .ch8_data_in_del(ch8_data_in_del), 
    .ch9_data_in_del(ch9_data_in_del), 
    .rs232_in(rs232_in), 
	 //.amp_trig(amp_trig),
	 //.amp_trig2(amp_trig2),
    .adc_powerdown(adc_powerdown), 
	 .dac1_out(dac1_out),
	 .dac1_clk(dac1_clk),
	 .dac2_out(dac2_out),
	 .dac2_clk(dac2_clk),
	 //.dac3_out(dac3_out),
	 //.dac3_clk(dac3_clk),
	 //.dac4_out(dac4_out),
	 //.dac4_clk(dac4_clk),
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
	 //.diginput2_loopback(diginput2_loopback),
	 .dcm200_rst(dcm200_rst), //output to xlnx
	 .dcm200_locked(dcm200_locked), //input to top
	 .clk_blk(clk40_blk), //output to xlnx
	 .idelayctrl_rdy(idelayctrl_rdy), //input to top
	 .pll_clk357_locked(pll_clk357_locked), //input to top
	 .clk357_idelay_ce(clk357_idelay_ce), //output to xlnx
	 .clk357_idelay_rst(clk357_idelay_rst), //output to xlnx
	 .idelay_rst(idelay_rst), //output to xlnx
	 .dcm360_locked(dcm360_locked), //input to top
	 .fastClk_sel(fastClk_sel), //output to xlnx
	 .clkPLL_sel_a(clkPLL_sel), // output to xlnx
	 .run(run), //output to xlnx
	 .delay_calc_strb1(delay_calc_strb1), //output to xlnx from ADC_block
	 .delay_calc_strb2(delay_calc_strb2), //output to xlnx from ADC_block
	 .delay_calc_strb3(delay_calc_strb3), //output to xlnx from ADC_block
	 .delay_trig1(delay_trig1), //output to xlnx from top (UART decoder)
	 .delay_trig2(delay_trig2), //output to xlnx from top (UART decoder)
	 .delay_trig3(delay_trig3), //output to xlnx from top (UART decoder)
	 .adc1_drdy_delay_ce(adc1_drdy_delay_ce), //output to xlnx from ADC_block
	 .adc2_drdy_delay_ce(adc2_drdy_delay_ce), //output to xlnx from ADC_block
	 .adc3_drdy_delay_ce(adc3_drdy_delay_ce), //output to xlnx from ADC_block
	 .adc1_clk_delay_ce(adc1_clk_delay_ce), //output to xlnx from ADC_block
	 .adc2_clk_delay_ce(adc2_clk_delay_ce), //output to xlnx from ADC_block
	 .adc3_clk_delay_ce(adc3_clk_delay_ce), //output to xlnx from ADC_block
	 .adc1_data_delay_ce(adc1_data_delay_ce), //output to xlnx from ADC_block
	 .adc2_data_delay_ce(adc2_data_delay_ce), //output to xlnx from ADC_block
	 .adc3_data_delay_ce(adc3_data_delay_ce), //output to xlnx from ADC_block
	 .IDDR1_Q1(IDDR1_Q1), //input to top (to Alignment monitors via ADC block)
	 .IDDR1_Q2(IDDR1_Q2), //input to top (to Alignment monitors via ADC block)
	 .IDDR2_Q1(IDDR2_Q1), //input to top (to Alignment monitors via ADC block)
	 .IDDR2_Q2(IDDR2_Q2), //input to top (to Alignment monitors via ADC block)
	 .IDDR3_Q1(IDDR3_Q1), //input to top (to Alignment monitors via ADC block)
	 .IDDR3_Q2(IDDR3_Q2) //input to top (to Alignment monitors via ADC block)
    );
endmodule 