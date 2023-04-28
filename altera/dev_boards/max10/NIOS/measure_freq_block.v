/*
*
* measure_freq_block.v
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
* (a) running on a Intel device, or (b) that interact
* with a Intel device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
* IN NO EVENT SHALL DIGISKY MSI BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
* CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*
*
* Modified for MAX10 NIOS demo test 2023/04/27
*/

`timescale 1ns/1ps

module measure_freq_block # (
  parameter NUM_CLK = 2,
  parameter C_REF_FREQ = 100000000)
(
  input                       i_ref_clk,
  input   [NUM_CLK-1:0]       i_meas_clk,
  output reg [20*NUM_CLK-1:0] o_meas_clk_freq
);

  localparam REF_CLK_DIV_100 = C_REF_FREQ/100 - 1;
  
  reg ten_miliseconds;
  reg [19:0] ref_clk_cnt;
  
  always @ (posedge i_ref_clk) begin
    if (ref_clk_cnt == REF_CLK_DIV_100) begin
      ten_miliseconds <= 1'b1;
      ref_clk_cnt <= 20'b0;
      end
    else begin
      ten_miliseconds <= 1'b0;
      ref_clk_cnt <= ref_clk_cnt + 1;
      end
    end
    
  reg [4*NUM_CLK-1:0] meas_clk_div_cnt;
  reg [NUM_CLK-1:0]   meas_clk_div_10;
  reg [3*NUM_CLK-1:0] meas_clk_div_10_sync;
  reg [20*NUM_CLK-1:0]meas_clk_cnt;
  wire [NUM_CLK-1:0]  meas_clk_div_10_rise;
  
genvar i;
generate
  for (i=0;i<NUM_CLK;i=i+1) begin : gen_loop
  
    // divide the measured clock by 10
    always @ (posedge i_meas_clk[i]) begin
      if (meas_clk_div_cnt[i*4+3:i*4] > 8) begin
        meas_clk_div_cnt[i*4+3:i*4] <= 4'b0;
        meas_clk_div_10[i] <= 1'b0;
        end
      else if (meas_clk_div_cnt[i*4+3:i*4] == 4) begin
        meas_clk_div_cnt[i*4+3:i*4] <= meas_clk_div_cnt[i*4+3:i*4] + 1;
        meas_clk_div_10[i] <= 1'b1;
        end
      else
        meas_clk_div_cnt[i*4+3:i*4] <= meas_clk_div_cnt[i*4+3:i*4] + 1;
      end
      
    // sync the meas_clk_div_10 into ref_clk domain
    always @ (posedge i_ref_clk) begin
      meas_clk_div_10_sync[i*3+2:i*3] <= {meas_clk_div_10_sync[i*3+1:i*3], meas_clk_div_10[i]};
      end
      
    assign meas_clk_div_10_rise[i] = meas_clk_div_10_sync[i*3+1] & ~meas_clk_div_10_sync[i*3+2];
    
    // process the measuring counter in ref_clk domain
    always @ (posedge i_ref_clk) begin
      if (ten_miliseconds) begin
        o_meas_clk_freq[i*20+19:i*20] <= meas_clk_cnt[i*20+19:i*20];
        meas_clk_cnt[i*20+19:i*20] <= 20'b0;
        end
      else if (meas_clk_div_10_rise[i]) begin
        meas_clk_cnt[i*20+19:i*20] <= meas_clk_cnt[i*20+19:i*20] + 1;
        end
      end
      
  
  end
endgenerate
      



endmodule