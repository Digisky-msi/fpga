/*
*
*
* Copyright (C) Digisky Media Solutions Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person
* obtaining a copy of this software and associated documentation
* files (the "Software"), to deal in the Software without restriction,
* including without limitation the rights to use, copy, modify, merge,
* publish, distribute, sublicense, and/or sell copies of the Software,
* and to permit persons to whom the Software is furnished to do so,
* subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included
* in all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or (b) that interact
* with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
* IN NO EVENT SHALL DIGISKY MSI BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
* CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*
*
* Modified for SHA256 HLS demo test 2023/08/17
*/
`timescale 1ns/1ps

module sha256 (
  input   clk_i,
  input   rst_i,
  input [63:0]   sha_in,
  output         ready,
  output [255:0] sha_out
);

  parameter [511:0] data = {32'h000001b8,   // fix 440 bits, last 8-bit use for termination
                            32'h00000000,
                            32'h20202080,   // terminate bit
                            32'h20202020,   // space for secret (51 char)
                            32'h20202020,
                            32'h20202020,
                            32'h20202020,
                            32'h20202020,
                            32'h20202020,
                            32'h20202020,
                            32'h20202020,
                            32'h20202020,
                            32'h20202020,
                            32'h20202020,
                            32'h20202020,
                            32'h61626364};  // space for challenge (4 char)
  
  //SHA = "60f55acae84181f3c806cea59180bae64a82efa5b4fe44126362282af85077b2"
  
  wire [3:0]  addr;
  reg [31:0]  sha_reg;
  
  reg trig_d, trig_dd;
  wire update;
  
  always @ (posedge clk_i) begin
    if (rst_i) begin
      trig_d <= 1'b0;
      trig_dd <= 1'b0;
      end
    else begin
      trig_d <= sha_in[63];   //rising edge trigger update
      trig_dd <= trig_d;
      end
    end
    
  assign update = ~trig_dd & trig_d;
  
  
sha256 u(
  .clk    (clk_i),
  .reset  (rst_i),
  .enable (1'b1),

  .ready  (ready),
  .update (update),

  .word_address (addr),
  .word_input   (sha_reg),

  .hash_output (sha_out),

  .debug_port ()
  );
  
  always @ (*) begin
        case (addr)
          4'h0 :  sha_reg <= data[31: 0];//sha_in[31: 0];
          4'h1 :  sha_reg <= data[63: 32];
          4'h2 :  sha_reg <= data[95: 64];
          4'h3 :  sha_reg <= data[127: 96];
          4'h4 :  sha_reg <= data[159: 128];
          4'h5 :  sha_reg <= data[191: 160];
          4'h6 :  sha_reg <= data[223: 192];
          4'h7 :  sha_reg <= data[255: 224];
          4'h8 :  sha_reg <= data[287: 256];
          4'h9 :  sha_reg <= data[319: 288];
          4'ha :  sha_reg <= data[351: 320];
          4'hb :  sha_reg <= data[383: 352];
          4'hc :  sha_reg <= data[415: 384];
          4'hd :  sha_reg <= data[447: 416];
          4'he :  sha_reg <= data[479: 448];
          4'hf :  sha_reg <= data[511: 480];
          default : sha_reg <= 32'b0;
        endcase
    end
  
endmodule