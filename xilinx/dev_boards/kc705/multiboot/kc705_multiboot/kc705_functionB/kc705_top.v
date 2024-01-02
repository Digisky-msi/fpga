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
  output [7:0] led,

  output  SPI_CS_L,
  inout    SPI_Q0,  
  inout    SPI_Q1,  
  inout    SPI_Q2,  
  inout    SPI_Q3  


);
  wire clk_100m;
  wire clk_33m;
  wire pll_locked;
  reg [19:0] por_cnt;
  reg reset;
  wire sys_reset;
  
  reg  [29:0] clk_100m_cnt;
  
  clk_wiz_0 uclk_inst(
    .clk_out1(clk_100m),
    .clk_out2(clk_33m),
    .clk_in1_p(sys_clk_p),
    .clk_in1_n(sys_clk_n),
    .locked(pll_locked)
  );


  always @ (posedge clk_100m) begin
    if(!pll_locked) begin
      por_cnt <= 20'b0;
      reset <= 1'b1;
      end
    else begin
      if(por_cnt == 20'hFFFFF)
        reset <= 1'b0;
      else
        por_cnt <= por_cnt + 1;
      end
    end
  
  always @ (posedge clk_100m) begin
    clk_100m_cnt <= clk_100m_cnt + 1'b1;
  end
  
  wire spi_w;
  reg spi_w_d;
  reg spi_w_trig;
  
spi_rev_sel_k7 rev_inst
  (
    .spiclk   (clk_33m),
    .reset    (reset),
    .iSelect  (dip_sw0),
    .oSys_rst (sys_reset),
    .oWR_done (spi_w),

    .SPI_CS_L (SPI_CS_L),
    .SPI_Q0   (SPI_Q0),
    .SPI_Q1   (SPI_Q1),
    .SPI_Q2   (SPI_Q2),
    .SPI_Q3   (SPI_Q3)

  );
  
  always @ (posedge clk_33m) begin
    if(reset) begin
      spi_w_d <= 1'b0;
      spi_w_trig <= 1'b0;
      end
    else begin
      spi_w_d <= spi_w;
      if(~spi_w_d & spi_w)
        spi_w_trig <= 1'b1;
      else if (sw_c) begin
        spi_w_d <= 1'b0;
        spi_w_trig <= 1'b0;
        end
      end
    end
  
  assign led = {clk_100m_cnt[25:19], spi_w_trig}; // faster
  
    
    
endmodule