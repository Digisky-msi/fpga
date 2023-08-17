// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2020.2_AR73173 (64-bit)
// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// ==============================================================
`timescale 1 ns / 1 ps
module main_p_str_rom (
addr0, ce0, q0, clk);

parameter DWIDTH = 8;
parameter AWIDTH = 6;
parameter MEM_SIZE = 56;

input[AWIDTH-1:0] addr0;
input ce0;
output reg[DWIDTH-1:0] q0;
input clk;

reg [DWIDTH-1:0] ram[0:MEM_SIZE-1];

initial begin
    $readmemh("rom_init.mem", ram);
end



always @(posedge clk)  
begin 
    if (ce0) 
    begin
        q0 <= ram[addr0];
    end
end



endmodule

`timescale 1 ns / 1 ps
module main_p_str(
    reset,
    clk,
    address0,
    ce0,
    q0);

parameter DataWidth = 32'd8;
parameter AddressRange = 32'd56;
parameter AddressWidth = 32'd6;
input reset;
input clk;
input[AddressWidth - 1:0] address0;
input ce0;
output[DataWidth - 1:0] q0;



main_p_str_rom main_p_str_rom_U(
    .clk( clk ),
    .addr0( address0 ),
    .ce0( ce0 ),
    .q0( q0 ));

endmodule

