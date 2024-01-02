/*
*
* kc705_top.v
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
* Modified for KC705 multiboot demo 2023/12/12
*/
`timescale 1ns / 1ps

module kc705_top(
  // 200MHz for DDR3
  input sys_clk_p,
  input sys_clk_n,
  
  //DIP switch
  input dip_sw0,
  
  // LEDs
  output [7:0] led

);
  wire clk_100m;
  reg  [29:0] clk_100m_cnt;
  
  clk_wiz_0 uclk_inst(
    .clk_out1(clk_100m),
    .clk_in1_p(sys_clk_p),
    .clk_in1_n(sys_clk_n)
  );


  always @ (posedge clk_100m) begin
    clk_100m_cnt <= clk_100m_cnt + 1'b1;
  end
  
  assign led = {clk_100m_cnt[26],~clk_100m_cnt[26],clk_100m_cnt[26],~clk_100m_cnt[26],clk_100m_cnt[26],~clk_100m_cnt[26],dip_sw0,dip_sw0};
  
    
endmodule