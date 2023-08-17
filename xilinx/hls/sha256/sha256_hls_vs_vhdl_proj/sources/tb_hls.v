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
`timescale 1ns / 1ps


module tb_hls;
  //------------------------------------------------------------------------------
  //Global clocks / rstb
  //------------------------------------------------------------------------------

  //clock1
  wire clk_1;
  defparam utb_clk_1.period = 1e9 / 100e6;
  tb_clock utb_clk_1(
    .oCLK(    clk_1)
  );

  //Basic reset
  wire  global_rst;
  defparam uglobal_rst.delay = 1000;
  tb_reset uglobal_rst (
    .oRST(  global_rst),
    .oRSTb(  )
  );

  //UUT HLS main
  reg  ap_start;
  wire ap_done;
  wire ap_idle;
  wire ap_ready;
  wire [31:0] ap_return;

  main u_main(
    .ap_clk(clk_1),
    .ap_rst(global_rst),
    .ap_start(ap_start),
    .ap_done(ap_done),
    .ap_idle(ap_idle),
    .ap_ready(ap_ready),
    .ap_return(ap_return)
  );

  //UUT wolf
  wire [255:0] sha_out;
  reg [63:0] sha_in;
  wire ready;
  
  wolf_sha256 u(
  .clk_i(clk_1),
  .rst_i(global_rst),
  .sha_in(sha_in),
  .ready(ready),
  .sha_out(sha_out)
);


  
  initial
  begin

    //Enable dumping
      $dumpfile("tb_hls.vcd");
      $dumpvars(0,tb_hls);

    //Run for this amount, then quit
    ap_start = 1'b0;
    sha_in = 0;
    #2000;
    ap_start = 1'b1;
    sha_in = 64'h8000000030318000;
    #100;
    ap_start = 1'b0;
    sha_in = 64'h0000000000000000;
    
      //#50000;
      //$finish;
  end

endmodule
