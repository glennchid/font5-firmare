generate 
		genvar i;
		for (i=0;i<=12;i=i+1) begin: IBUFDS_CH1_DATA 
			IBUFDS #(
				.CAPACITANCE("DONT_CARE"),
				.DIFF_TERM("TRUE"), 
				.IBUF_DELAY_VALUE("0"),
				.IFD_DELAY_VALUE("AUTO"), 
				.IOSTANDARD("DEFAULT") 
			) IBUFDS_CH1_DATA (
				.I(ch1_data_in_p[i]),
				.IB(ch1_data_in_n[i]), 
				.O(ch1_data_in[i])
			);
		end
		for (i=0;i<=12;i=i+1) begin: IBUFDS_CH2_DATA 
			IBUFDS #(
				.CAPACITANCE("DONT_CARE"),
				.DIFF_TERM("TRUE"), 
				.IBUF_DELAY_VALUE("0"),
				.IFD_DELAY_VALUE("AUTO"), 
				.IOSTANDARD("DEFAULT") 
			) IBUFDS_CH2_DATA (
				.I(ch2_data_in_p[i]),
				.IB(ch2_data_in_n[i]), 
				.O(ch2_data_in[i])
			);
		end
		for (i=0;i<=12;i=i+1) begin: IBUFDS_CH3_DATA 
			IBUFDS #(
				.CAPACITANCE("DONT_CARE"),
				.DIFF_TERM("TRUE"), 
				.IBUF_DELAY_VALUE("0"),
				.IFD_DELAY_VALUE("AUTO"), 
				.IOSTANDARD("DEFAULT") 
			) IBUFDS_CH3_DATA (
				.I(ch3_data_in_p[i]),
				.IB(ch3_data_in_n[i]), 
				.O(ch3_data_in[i])
			);
		end
		for (i=0;i<=12;i=i+1) begin: IBUFDS_CH4_DATA 
			IBUFDS #(
				.CAPACITANCE("DONT_CARE"),
				.DIFF_TERM("TRUE"), 
				.IBUF_DELAY_VALUE("0"),
				.IFD_DELAY_VALUE("AUTO"), 
				.IOSTANDARD("DEFAULT") 
			) IBUFDS_CH4_DATA (
				.I(ch4_data_in_p[i]),
				.IB(ch4_data_in_n[i]), 
				.O(ch4_data_in[i])
			);
		end
		for (i=0;i<=12;i=i+1) begin: IBUFDS_CH5_DATA 
			IBUFDS #(
				.CAPACITANCE("DONT_CARE"),
				.DIFF_TERM("TRUE"), 
				.IBUF_DELAY_VALUE("0"),
				.IFD_DELAY_VALUE("AUTO"), 
				.IOSTANDARD("DEFAULT") 
			) IBUFDS_CH5_DATA (
				.I(ch5_data_in_p[i]),
				.IB(ch5_data_in_n[i]), 
				.O(ch5_data_in[i])
			);
		end
		for (i=0;i<=12;i=i+1) begin: IBUFDS_CH6_DATA 
			IBUFDS #(
				.CAPACITANCE("DONT_CARE"),
				.DIFF_TERM("TRUE"), 
				.IBUF_DELAY_VALUE("0"),
				.IFD_DELAY_VALUE("AUTO"), 
				.IOSTANDARD("DEFAULT") 
			) IBUFDS_CH6_DATA (
				.I(ch6_data_in_p[i]),
				.IB(ch6_data_in_n[i]), 
				.O(ch6_data_in[i])
			);
		end
		for (i=0;i<=12;i=i+1) begin: IBUFDS_CH7_DATA 
			IBUFDS #(
				.CAPACITANCE("DONT_CARE"),
				.DIFF_TERM("TRUE"), 
				.IBUF_DELAY_VALUE("0"),
				.IFD_DELAY_VALUE("AUTO"), 
				.IOSTANDARD("DEFAULT") 
			) IBUFDS_CH7_DATA (
				.I(ch7_data_in_p[i]),
				.IB(ch7_data_in_n[i]), 
				.O(ch7_data_in[i])
			);
		end
		for (i=0;i<=12;i=i+1) begin: IBUFDS_CH8_DATA 
			IBUFDS #(
				.CAPACITANCE("DONT_CARE"),
				.DIFF_TERM("TRUE"), 
				.IBUF_DELAY_VALUE("0"),
				.IFD_DELAY_VALUE("AUTO"), 
				.IOSTANDARD("DEFAULT") 
			) IBUFDS_CH8_DATA (
				.I(ch8_data_in_p[i]),
				.IB(ch8_data_in_n[i]), 
				.O(ch8_data_in[i])
			);
		end
		for (i=0;i<=12;i=i+1) begin: IBUFDS_CH9_DATA 
			IBUFDS #(
				.CAPACITANCE("DONT_CARE"),
				.DIFF_TERM("TRUE"), 
				.IBUF_DELAY_VALUE("0"),
				.IFD_DELAY_VALUE("AUTO"), 
				.IOSTANDARD("DEFAULT") 
			) IBUFDS_CH1_DATA (
				.I(ch9_data_in_p[i]),
				.IB(ch9_data_in_n[i]), 
				.O(ch9_data_in[i])
			);
		end
endgenerate	