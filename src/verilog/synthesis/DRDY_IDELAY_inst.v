	IODELAY # (
		.DELAY_SRC("I"),
		.HIGH_PERFORMANCE_MODE("TRUE"),
		.IDELAY_TYPE("VARIABLE"),
		.IDELAY_VALUE(0),
		.ODELAY_VALUE(0),
		.REFCLK_FREQUENCY(200.0),
		.SIGNAL_PATTERN("CLOCK")
	) ch1_drdy_idelay (
	.DATAOUT(ch1_drdy_out), 
	.C(clk40),
	.CE(adc1_drdy_delay_ce), 
	.DATAIN(gnd),		// Must be grounded
	.IDATAIN(ch1_drdy),
	.INC(1'b1), 		// Always increment
	.ODATAIN(),			// Unused
	.RST(delay_calc_strb1 | delay_trig1),
	.T(vcc) 			// 1==INPUT/INTERNAL	0==OUTPUT
	);
	IODELAY # (
		.DELAY_SRC("I"),
		.HIGH_PERFORMANCE_MODE("TRUE"),
		.IDELAY_TYPE("VARIABLE"),
		.IDELAY_VALUE(0),
		.ODELAY_VALUE(0),
		.REFCLK_FREQUENCY(200.0),
		.SIGNAL_PATTERN("CLOCK")
	) ch2_drdy_idelay (
	.DATAOUT(ch2_drdy_out), 
	.C(clk40),
	.CE(adc1_drdy_delay_ce), 
	.DATAIN(gnd),		// Must be grounded
	.IDATAIN(ch2_drdy),
	.INC(1'b1), 		// Always increment
	.ODATAIN(),			// Unused
	.RST(delay_calc_strb1 | delay_trig1),
	.T(vcc) 			// 1==INPUT/INTERNAL	0==OUTPUT
	);
	IODELAY # (
		.DELAY_SRC("I"),
		.HIGH_PERFORMANCE_MODE("TRUE"),
		.IDELAY_TYPE("VARIABLE"),
		.IDELAY_VALUE(0),
		.ODELAY_VALUE(0),
		.REFCLK_FREQUENCY(200.0),
		.SIGNAL_PATTERN("CLOCK")
	) ch3_drdy_idelay (
	.DATAOUT(ch3_drdy_out), 
	.C(clk40),
	.CE(adc1_drdy_delay_ce), 
	.DATAIN(gnd),		// Must be grounded
	.IDATAIN(ch3_drdy),
	.INC(1'b1), 		// Always increment
	.ODATAIN(),			// Unused
	.RST(delay_calc_strb1 | delay_trig1),
	.T(vcc) 			// 1==INPUT/INTERNAL	0==OUTPUT
	);	
	IODELAY # (
		.DELAY_SRC("I"),
		.HIGH_PERFORMANCE_MODE("TRUE"),
		.IDELAY_TYPE("VARIABLE"),
		.IDELAY_VALUE(0),
		.ODELAY_VALUE(0),
		.REFCLK_FREQUENCY(200.0),
		.SIGNAL_PATTERN("CLOCK")
	) ch4_drdy_idelay (
	.DATAOUT(ch4_drdy_out), 
	.C(clk40),
	.CE(adc2_drdy_delay_ce), 
	.DATAIN(gnd),		// Must be grounded
	.IDATAIN(ch4_drdy),
	.INC(1'b1), 		// Always increment
	.ODATAIN(),			// Unused
	.RST(delay_calc_strb2 | delay_trig2),
	.T(vcc) 			// 1==INPUT/INTERNAL	0==OUTPUT
	);
	IODELAY # (
		.DELAY_SRC("I"),
		.HIGH_PERFORMANCE_MODE("TRUE"),
		.IDELAY_TYPE("VARIABLE"),
		.IDELAY_VALUE(0),
		.ODELAY_VALUE(0),
		.REFCLK_FREQUENCY(200.0),
		.SIGNAL_PATTERN("CLOCK")
	) ch5_drdy_idelay (
	.DATAOUT(ch5_drdy_out), 
	.C(clk40),
	.CE(adc2_drdy_delay_ce), 
	.DATAIN(gnd),		// Must be grounded
	.IDATAIN(ch5_drdy),
	.INC(1'b1), 		// Always increment
	.ODATAIN(),			// Unused
	.RST(delay_calc_strb2 | delay_trig2),
	.T(vcc) 			// 1==INPUT/INTERNAL	0==OUTPUT
	);
	IODELAY # (
		.DELAY_SRC("I"),
		.HIGH_PERFORMANCE_MODE("TRUE"),
		.IDELAY_TYPE("VARIABLE"),
		.IDELAY_VALUE(0),
		.ODELAY_VALUE(0),
		.REFCLK_FREQUENCY(200.0),
		.SIGNAL_PATTERN("CLOCK")
	) ch6_drdy_idelay (
	.DATAOUT(ch6_drdy_out), 
	.C(clk40),
	.CE(adc2_drdy_delay_ce), 
	.DATAIN(gnd),		// Must be grounded
	.IDATAIN(ch6_drdy),
	.INC(1'b1), 		// Always increment
	.ODATAIN(),			// Unused
	.RST(delay_calc_strb2 | delay_trig2),
	.T(vcc) 			// 1==INPUT/INTERNAL	0==OUTPUT
	);	
	IODELAY # (
		.DELAY_SRC("I"),
		.HIGH_PERFORMANCE_MODE("TRUE"),
		.IDELAY_TYPE("VARIABLE"),
		.IDELAY_VALUE(0),
		.ODELAY_VALUE(0),
		.REFCLK_FREQUENCY(200.0),
		.SIGNAL_PATTERN("CLOCK")
	) ch7_drdy_idelay (
	.DATAOUT(ch7_drdy_out), 
	.C(clk40),
	.CE(adc3_drdy_delay_ce), 
	.DATAIN(gnd),		// Must be grounded
	.IDATAIN(ch7_drdy),
	.INC(1'b1), 		// Always increment
	.ODATAIN(),			// Unused
	.RST(delay_calc_strb3 | delay_trig3),
	.T(vcc) 			// 1==INPUT/INTERNAL	0==OUTPUT
	);
	IODELAY # (
		.DELAY_SRC("I"),
		.HIGH_PERFORMANCE_MODE("TRUE"),
		.IDELAY_TYPE("VARIABLE"),
		.IDELAY_VALUE(0),
		.ODELAY_VALUE(0),
		.REFCLK_FREQUENCY(200.0),
		.SIGNAL_PATTERN("CLOCK")
	) ch8_drdy_idelay (
	.DATAOUT(ch8_drdy_out), 
	.C(clk40),
	.CE(adc3_drdy_delay_ce), 
	.DATAIN(gnd),		// Must be grounded
	.IDATAIN(ch8_drdy),
	.INC(1'b1), 		// Always increment
	.ODATAIN(),			// Unused
	.RST(delay_calc_strb3 | delay_trig3),
	.T(vcc) 			// 1==INPUT/INTERNAL	0==OUTPUT
	);
	IODELAY # (
		.DELAY_SRC("I"),
		.HIGH_PERFORMANCE_MODE("TRUE"),
		.IDELAY_TYPE("VARIABLE"),
		.IDELAY_VALUE(0),
		.ODELAY_VALUE(0),
		.REFCLK_FREQUENCY(200.0),
		.SIGNAL_PATTERN("CLOCK")
	) ch9_drdy_idelay (
	.DATAOUT(ch9_drdy_out), 
	.C(clk40),
	.CE(adc3_drdy_delay_ce), 
	.DATAIN(gnd),		// Must be grounded
	.IDATAIN(ch9_drdy),
	.INC(1'b1), 		// Always increment
	.ODATAIN(),			// Unused
	.RST(delay_calc_strb3 | delay_trig3),
	.T(vcc) 			// 1==INPUT/INTERNAL	0==OUTPUT
	);		