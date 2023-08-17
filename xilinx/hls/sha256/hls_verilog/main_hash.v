// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2020.2_AR73173 (64-bit)
// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// ==============================================================
`timescale 1 ns / 1 ps
module main_hash_ram (addr0, ce0, d0, we0, addr1, ce1, d1, we1,  clk, reset, ap_out);

parameter DWIDTH = 8;
parameter AWIDTH = 5;
parameter MEM_SIZE = 32;

input[AWIDTH-1:0] addr0;
input ce0;
input[DWIDTH-1:0] d0;
input we0;
input[AWIDTH-1:0] addr1;
input ce1;
input[DWIDTH-1:0] d1;
input we1;
input clk;
input reset;
output [255:0] ap_out;

reg [DWIDTH-1:0] ram0[0:MEM_SIZE-1];
reg [DWIDTH-1:0] ram1[0:MEM_SIZE-1];

integer i;

always @(posedge clk)  
begin 
  if(reset) begin
    for(i=0;i<MEM_SIZE;i=i+1) begin
      ram0[i] = 'b0;
      end
    end
  else begin
    if (ce0) begin
        if (we0) 
            ram0[addr0] <= d0; 
    end
  end
end


always @(posedge clk)  
begin 
  if(reset) begin
    for(i=0;i<MEM_SIZE;i=i+1) begin
      ram1[i] = 'b0;
      end
    end
  else begin
    if (ce1) begin
        if (we1) 
            ram1[addr1] <= d1; 
    end
  end
end


genvar j;
generate
for (j=0;j<MEM_SIZE;j=j+1) begin
  assign ap_out[j*8+7:j*8] = ram0[MEM_SIZE-j-1] | ram1[MEM_SIZE-j-1];
end
endgenerate


endmodule

`timescale 1 ns / 1 ps
module main_hash(
    reset,
    clk,
    address0,
    ce0,
    we0,
    d0,
    address1,
    ce1,
    we1,
    d1,
    ap_out);

parameter DataWidth = 32'd8;
parameter AddressRange = 32'd32;
parameter AddressWidth = 32'd5;
input reset;
input clk;
input[AddressWidth - 1:0] address0;
input ce0;
input we0;
input[DataWidth - 1:0] d0;
input[AddressWidth - 1:0] address1;
input ce1;
input we1;
input[DataWidth - 1:0] d1;
output [255:0] ap_out;



main_hash_ram main_hash_ram_U(
    .clk( clk ),
    .reset(reset),
    .addr0( address0 ),
    .ce0( ce0 ),
    .we0( we0 ),
    .d0( d0 ),
    .addr1( address1 ),
    .ce1( ce1 ),
    .we1( we1 ),
    .d1( d1 ),
    .ap_out(ap_out));

endmodule

