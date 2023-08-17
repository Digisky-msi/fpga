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
module reset_tree #(
  parameter DELAY0 = 10,
  parameter DELAY1 = 10,
  parameter DELAY2 = 10)
(
  input clk,
  
  input rst0,
  input rst1,
  input rst2,
  
  output reg delay_rst0,
  output reg delay_rst1,
  output reg delay_rst2,
  
  output [3:0] stage
);

  reg [31:0] rst_cnt = 32'b0;
  reg [3:0]  wd_rst_cnt = 4'b0;
  reg        wd_rst;
  reg [3:0]  rst_stage;
  
  always @ (posedge clk) begin
    if (&wd_rst_cnt == 0) begin
      wd_rst_cnt <= wd_rst_cnt + 1;
      wd_rst <= 1'b1;
      end
    else
      wd_rst <= 1'b0;
    end
  
  
  always @ (posedge clk) begin
  if (wd_rst) begin
    rst_stage <= 4'b0001;
    delay_rst0 <= 1'b1;
    delay_rst1 <= 1'b1;
    delay_rst2 <= 1'b1;
    rst_cnt <= 32'b0;
    end
  else begin
    case (rst_stage)
      4'b0001 : begin
        if (!rst0) begin
          rst_cnt <= rst_cnt + 1;
          delay_rst0 <= 1'b1;
          delay_rst1 <= 1'b1;
          delay_rst2 <= 1'b1;
          if (rst_cnt == DELAY0) begin
            delay_rst0 <= 1'b0;
            rst_cnt <= 32'b0;
            rst_stage <= 4'b0010;
            end
          end
        end
        
      4'b0010 : begin
        if (!rst1) begin
          rst_cnt <= rst_cnt + 1;
          delay_rst1 <= 1'b1;
          delay_rst2 <= 1'b1;
          if (rst_cnt == DELAY1) begin
            delay_rst1 <= 1'b0;
            rst_cnt <= 32'b0;
            rst_stage <= 4'b0100;
            end
          end
        end
      
      4'b0100 : begin
        if (!rst2) begin
          rst_cnt <= rst_cnt + 1;
          delay_rst2 <= 1'b1;
          if (rst_cnt == DELAY2) begin
            delay_rst2 <= 1'b0;
            rst_cnt <= 32'b0;
            rst_stage <= 4'b1000;
            end
          end
        end
        
      4'b1000 : begin
        delay_rst0 <= 1'b0;
        delay_rst1 <= 1'b0;
        delay_rst2 <= 1'b0;
        end
        
      default : rst_stage <= 4'b0001;
      
      endcase
    end
  end
        
  assign stage = rst_stage;

endmodule
