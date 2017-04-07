//`define INCLUDE_TESTBENCH

`define DOUBLE_CONTROL_REGS

`define GAINRES_14

//`define FASTCLK_192MHZ

`ifdef FASTCLK_192MHZ
	parameter FASTCLK_PERIOD = 5.208; 
`else
	parameter FASTCLK_PERIOD = 2.800;
`endif

//`define UART2_SELF_CHECK

//`define ADDPIPEREGS

//`define DISABLE_AUXOUTS

/*`define LOAD_ATF_DEFAULTS

`ifdef LOAD_ATF_DEFAULTS
	`include "H:\Firmware\FONT5_base\sources\verilog\ctrl_regs_init_ATF.v"
	//`define DISABLE_AUXOUTS
`else
	`include "H:\Firmware\FONT5_base\sources\verilog\ctrl_regs_init.v"
`endif
*/