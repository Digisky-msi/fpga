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
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
* IN NO EVENT SHALL DIGISKY MSI BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
* CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*
*
*/
`timescale 1ns / 1ps


module tb;
  //------------------------------------------------------------------------------
  //Global clocks / rstb
  //------------------------------------------------------------------------------

  //clock1
  wire clk_1;
  defparam utb_clk_1.period = 1e9 / 100e6;
  tb_clock utb_clk_1(
    .oCLK(    clk_1)
  );

  //clock2
  wire clk_2;
  defparam utb_clk_2.period = 1e9 / 200e6;
  tb_clock utb_clk_2(
    .oCLK(    clk_2)
  );

  //clock3
  wire clk_3;
  defparam utb_clk_3.period = 1e9 / 74250e3;
  tb_clock utb_clk_3(
    .oCLK(    clk_3)
  );

  //Basic reset
  wire  global_rst, global_rstb;
  defparam uglobal_rst.delay = 1000;
  tb_reset uglobal_rst (
    .oRST(  global_rst),
    .oRSTb(  global_rstb)
  );

  
  initial
  begin

    //Enable dumping
      $dumpfile("tb.vcd");
      $dumpvars(0,tb);

    //Run for this amount, then quit
      //#50000;
      //$finish;
  end

endmodule
