//`define INCLUDE_TESTBENCH

`define DOUBLE_CONTROL_REGS

`define 14BIT_GAIN

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