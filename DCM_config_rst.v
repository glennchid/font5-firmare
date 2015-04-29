`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:21:24 07/18/2012 
// Design Name: 
// Module Name:    DCM_config_rst 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module DCM_config_rst(
	 input clkin,
    output config_rst
    );

FDS flop1 (.D(1'b0),.C(clkin),.Q(out1),.S(1'b0));
FD flop2 (.D(out1),.C(clkin),.Q(out2));
FD flop3 (.D(out2),.C(clkin),.Q(out3));
FD flop4 (.D(out3),.C(clkin),.Q(out4));

assign config_rst = (out2 | out3 | out4);

endmodule
