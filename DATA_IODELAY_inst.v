generate
	genvar j;
	for (j=0;j<=12;j=j+1) begin: IODELAY_CH1_DATA
		IODELAY # (
			.DELAY_SRC("I"),
			.HIGH_PERFORMANCE_MODE("TRUE"),
			.IDELAY_TYPE("VARIABLE"),
			.IDELAY_VALUE(0),
			.ODELAY_VALUE(0),
			.REFCLK_FREQUENCY(200.0),
			.SIGNAL_PATTERN("CLOCK")
		) IODELAY_CH1_DATA (
		.DATAOUT(ch1_data_in_del[j]), 
		.C(clk40),
		.CE(adc1_data_delay_ce), 
		.DATAIN(gnd),		// Must be grounded
		.IDATAIN(ch1_data_in[j]),
		.INC(1'b1), 		// Always increment
		.ODATAIN(),			// Unused
		.RST(delay_calc_strb1 | delay_trig1),
		.T(vcc) 			// 1==INPUT/INTERNAL	0==OUTPUT
		);
		end
	for (j=0;j<=12;j=j+1) begin: IODELAY_CH2_DATA
		IODELAY # (
			.DELAY_SRC("I"),
			.HIGH_PERFORMANCE_MODE("TRUE"),
			.IDELAY_TYPE("VARIABLE"),
			.IDELAY_VALUE(0),
			.ODELAY_VALUE(0),
			.REFCLK_FREQUENCY(200.0),
			.SIGNAL_PATTERN("CLOCK")
		) IODELAY_CH2_DATA (
		.DATAOUT(ch2_data_in_del[j]), 
		.C(clk40),
		.CE(adc1_data_delay_ce), 
		.DATAIN(gnd),		// Must be grounded
		.IDATAIN(ch2_data_in[j]),
		.INC(1'b1), 		// Always increment
		.ODATAIN(),			// Unused
		.RST(delay_calc_strb1 | delay_trig1),
		.T(vcc) 			// 1==INPUT/INTERNAL	0==OUTPUT
		);
		end
	for (j=0;j<=12;j=j+1) begin: IODELAY_CH3_DATA
		IODELAY # (
			.DELAY_SRC("I"),
			.HIGH_PERFORMANCE_MODE("TRUE"),
			.IDELAY_TYPE("VARIABLE"),
			.IDELAY_VALUE(0),
			.ODELAY_VALUE(0),
			.REFCLK_FREQUENCY(200.0),
			.SIGNAL_PATTERN("CLOCK")
		) IODELAY_CH3_DATA (
		.DATAOUT(ch3_data_in_del[j]), 
		.C(clk40),
		.CE(adc1_data_delay_ce), 
		.DATAIN(gnd),		// Must be grounded
		.IDATAIN(ch3_data_in[j]),
		.INC(1'b1), 		// Always increment
		.ODATAIN(),			// Unused
		.RST(delay_calc_strb1 | delay_trig1),
		.T(vcc) 			// 1==INPUT/INTERNAL	0==OUTPUT
		);		
		end
	for (j=0;j<=12;j=j+1) begin: IODELAY_CH4_DATA
		IODELAY # (
			.DELAY_SRC("I"),
			.HIGH_PERFORMANCE_MODE("TRUE"),
			.IDELAY_TYPE("VARIABLE"),
			.IDELAY_VALUE(0),
			.ODELAY_VALUE(0),
			.REFCLK_FREQUENCY(200.0),
			.SIGNAL_PATTERN("CLOCK")
		) IODELAY_CH4_DATA (
		.DATAOUT(ch4_data_in_del[j]), 
		.C(clk40),
		.CE(adc2_data_delay_ce), 
		.DATAIN(gnd),		// Must be grounded
		.IDATAIN(ch4_data_in[j]),
		.INC(1'b1), 		// Always increment
		.ODATAIN(),			// Unused
		.RST(delay_calc_strb2 | delay_trig2),
		.T(vcc) 			// 1==INPUT/INTERNAL	0==OUTPUT
		);	
		end
	for (j=0;j<=12;j=j+1) begin: IODELAY_CH5_DATA
		IODELAY # (
			.DELAY_SRC("I"),
			.HIGH_PERFORMANCE_MODE("TRUE"),
			.IDELAY_TYPE("VARIABLE"),
			.IDELAY_VALUE(0),
			.ODELAY_VALUE(0),
			.REFCLK_FREQUENCY(200.0),
			.SIGNAL_PATTERN("CLOCK")
		) IODELAY_CH5_DATA (
		.DATAOUT(ch5_data_in_del[j]), 
		.C(clk40),
		.CE(adc2_data_delay_ce), 
		.DATAIN(gnd),		// Must be grounded
		.IDATAIN(ch5_data_in[j]),
		.INC(1'b1), 		// Always increment
		.ODATAIN(),			// Unused
		.RST(delay_calc_strb2 | delay_trig2),
		.T(vcc) 			// 1==INPUT/INTERNAL	0==OUTPUT
		);	
		end
	for (j=0;j<=12;j=j+1) begin: IODELAY_CH6_DATA
		IODELAY # (
			.DELAY_SRC("I"),
			.HIGH_PERFORMANCE_MODE("TRUE"),
			.IDELAY_TYPE("VARIABLE"),
			.IDELAY_VALUE(0),
			.ODELAY_VALUE(0),
			.REFCLK_FREQUENCY(200.0),
			.SIGNAL_PATTERN("CLOCK")
		) IODELAY_CH6_DATA (
		.DATAOUT(ch6_data_in_del[j]), 
		.C(clk40),
		.CE(adc2_data_delay_ce), 
		.DATAIN(gnd),		// Must be grounded
		.IDATAIN(ch6_data_in[j]),
		.INC(1'b1), 		// Always increment
		.ODATAIN(),			// Unused
		.RST(delay_calc_strb2 | delay_trig2),
		.T(vcc) 			// 1==INPUT/INTERNAL	0==OUTPUT
		);			
		end
	for (j=0;j<=12;j=j+1) begin: IODELAY_CH7_DATA
		IODELAY # (
			.DELAY_SRC("I"),
			.HIGH_PERFORMANCE_MODE("TRUE"),
			.IDELAY_TYPE("VARIABLE"),
			.IDELAY_VALUE(0),
			.ODELAY_VALUE(0),
			.REFCLK_FREQUENCY(200.0),
			.SIGNAL_PATTERN("CLOCK")
		) IODELAY_CH7_DATA (
		.DATAOUT(ch7_data_in_del[j]), 
		.C(clk40),
		.CE(adc3_data_delay_ce), 
		.DATAIN(gnd),		// Must be grounded
		.IDATAIN(ch7_data_in[j]),
		.INC(1'b1), 		// Always increment
		.ODATAIN(),			// Unused
		.RST(delay_calc_strb3 | delay_trig3),
		.T(vcc) 			// 1==INPUT/INTERNAL	0==OUTPUT
		);		
		end
	for (j=0;j<=12;j=j+1) begin: IODELAY_CH8_DATA
		IODELAY # (
			.DELAY_SRC("I"),
			.HIGH_PERFORMANCE_MODE("TRUE"),
			.IDELAY_TYPE("VARIABLE"),
			.IDELAY_VALUE(0),
			.ODELAY_VALUE(0),
			.REFCLK_FREQUENCY(200.0),
			.SIGNAL_PATTERN("CLOCK")
		) IODELAY_CH8_DATA (
		.DATAOUT(ch8_data_in_del[j]), 
		.C(clk40),
		.CE(adc3_data_delay_ce), 
		.DATAIN(gnd),		// Must be grounded
		.IDATAIN(ch8_data_in[j]),
		.INC(1'b1), 		// Always increment
		.ODATAIN(),			// Unused
		.RST(delay_calc_strb3 | delay_trig3),
		.T(vcc) 			// 1==INPUT/INTERNAL	0==OUTPUT
		);		
		end
	for (j=0;j<=12;j=j+1) begin: IODELAY_CH9_DATA
		IODELAY # (
			.DELAY_SRC("I"),
			.HIGH_PERFORMANCE_MODE("TRUE"),
			.IDELAY_TYPE("VARIABLE"),
			.IDELAY_VALUE(0),
			.ODELAY_VALUE(0),
			.REFCLK_FREQUENCY(200.0),
			.SIGNAL_PATTERN("CLOCK")
		) IODELAY_CH9_DATA (
		.DATAOUT(ch9_data_in_del[j]), 
		.C(clk40),
		.CE(adc3_data_delay_ce), 
		.DATAIN(gnd),		// Must be grounded
		.IDATAIN(ch9_data_in[j]),
		.INC(1'b1), 		// Always increment
		.ODATAIN(),			// Unused
		.RST(delay_calc_strb3 | delay_trig3),
		.T(vcc) 			// 1==INPUT/INTERNAL	0==OUTPUT
		);		
		end
endgenerate