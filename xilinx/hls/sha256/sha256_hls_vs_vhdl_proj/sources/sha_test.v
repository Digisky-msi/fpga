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
module sha_test(
  input clk,
  input rst,
  input [29:0] cnt_in,
  output triger_out,
  input sha0_ready,
  input [255:0] sha0_value,
  input sha1_ready,
  input [255:0] sha1_value,
  output [31:0] result_out
  
);

  reg triger;
  reg triger_d;
  wire triger_rise = ~triger_d & triger;
  
  reg sha0_d, sha0_dd, sha0_ddd;
  wire sha0_rise;
  reg sha1_d, sha1_dd, sha1_ddd;
  wire sha1_rise;
  
  reg [29:0] sha0_cnt, sha1_cnt, cnt_diff;
  reg sha0_later;
  reg [255:0] sha0, sha1;
  reg match;
  
  always @ (posedge clk) begin
    if (rst) begin
      triger <= 1'b0;
      triger_d <= 1'b0;
      end
    else begin
      triger_d <= triger;
      if(cnt_in == 30'd2000)
        triger <= 1'b1;
      else if(cnt_in == 30'd2100)
        triger <= 1'b0;
      end
    end

  always @ (posedge clk) begin
    if(rst | triger_rise) begin
      sha0_d <= 1'b0;
      sha0_dd <= 1'b0;
      sha0_ddd <= 1'b0;
      sha1_d <= 1'b0;
      sha1_dd <= 1'b0;
      sha1_ddd <= 1'b0;
      end
    else begin
      sha0_d <= sha0_ready;
      sha0_dd <= sha0_d;
      sha0_ddd <= sha0_dd;
      sha1_d <= sha1_ready;
      sha1_dd <= sha1_d;
      sha1_ddd <= sha1_dd;
      end
    end
    
  assign sha0_rise = ~sha0_dd & sha0_d;
  assign sha1_rise = ~sha1_dd & sha1_d;
  
  always @ (posedge clk) begin
    if(rst | triger_rise) begin
      sha0_cnt <= 30'b0;
      sha1_cnt <= 30'b0;
      cnt_diff <= 30'b0;
      sha0_later <= 1'b0;
      sha0 <= 256'b0;
      sha1 <= 256'b0;
      match <= 1'b0;
      end
    else begin
      if(sha0_rise) begin
        sha0_cnt <= cnt_in;
        sha0 <= sha0_value;
        end
        
      if(sha1_rise) begin
        sha1_cnt <= cnt_in;
        sha1 <= sha1_value;
        end
        
      if(sha0_ddd & sha1_ddd) begin
        if(sha0 == sha1)
          match <= 1'b1;
        else
          match <= 1'b0;
          
        if(sha0_cnt > sha1_cnt) begin
          cnt_diff <= sha0_cnt - sha1_cnt;
          sha0_later <= 1'b1;
          end
        else begin
          cnt_diff <= sha1_cnt - sha0_cnt;
          sha0_later <= 1'b0;
          end
        end
      end
    end
      

  assign triger_out = triger;
  assign result_out = {match, sha0_later, cnt_diff};

sha_ila u_ila(
  .clk(clk),
  .probe0(rst),
  .probe1(triger_rise),
  .probe2(sha0_rise),
  .probe3(sha1_rise),
  .probe4(sha0_value),
  .probe5(sha0_cnt),
  .probe6(sha1_value),
  .probe7(sha1_cnt),
  .probe8(cnt_diff)
  
);

endmodule
