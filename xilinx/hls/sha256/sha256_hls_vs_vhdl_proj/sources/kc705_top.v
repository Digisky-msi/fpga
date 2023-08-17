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
module kc705_top(

  input fpga_reset,
  
  // 200MHz for DDR3
  input sys_clk_p,
  input sys_clk_n,
  
  //BPI clock [66MHz]
  input emcclk,
  
  // SI5324 output
  output rec_clk_p,
  output rec_clk_n,
  
  // SI5324 input [not config]
  input mgt1160_si5324_p,
  input mgt1160_si5324_n,
  
  // SGMII Ethernet [125MHz]
  input mgt1170_sgmii_p,
  input mgt1170_sgmii_n,
  
  // User clock 10~810MHz [156.25MHz]
  input user_clk_p,
  input user_clk_n,
  
  // LEDs
  output [7:0] led

);
  localparam [7:0] build_num = 8'h4;
  
  wire clk_200m;
  wire clk_100m;
  wire gtrefclk_1160;
  wire gtrefclk_1170;
  wire user_clk;
  wire emc_clk;
  wire [19:0] gtrefclk_1160_freq;
  wire [19:0] gtrefclk_1170_freq;
  wire [19:0] user_clk_freq;
  wire [19:0] emc_clk_freq;
  
  wire [29:0] clk_100m_cnt;
  
  wire probe_out0, probe_out1, probe_out2, probe_out3; 
  
  wire rst0, rst1, rst2;
  wire [3:0] rst_stage;
  wire dbg_rst = probe_out0 | fpga_reset;
  
  clk_wiz_0 uclk_inst(
    .clk_out1(clk_100m),
    .clk_in1_p(sys_clk_p),
    .clk_in1_n(sys_clk_n)
  );

  reset_tree #(.DELAY0(100),.DELAY1(100),.DELAY2(100)) u_rst
  (
    .clk(clk_100m),
    .rst0(1'b0),
    .rst1(rst0),
    .rst2(rst1),
    .delay_rst0(rst0),
    .delay_rst1(rst1),
    .delay_rst2(rst2),
    .stage(rst_stage)
  );
  
  
  IBUFDS_GTE2 uIBUFDS_GTE2_1160  (.O(gtrefclk_1160),  .I(mgt1160_si5324_p), .IB(mgt1160_si5324_n), .ODIV2(), .CEB(1'b0));
  IBUFDS_GTE2 uIBUFDS_GTE2_1170  (.O(gtrefclk_1170),  .I(mgt1170_sgmii_p),  .IB(mgt1170_sgmii_n),  .ODIV2(), .CEB(1'b0));
  IBUFDS uIBUFUSER (.O(user_clk), .I(user_clk_p), .IB(user_clk_n));
  IBUF uIBUF (.O(emc_clk),  .I(emcclk));
  
  OBUFDS uOBUFDS_REC_CLOCK_0 (.O(rec_clk_p), .OB(rec_clk_n), .I(emc_clk));

  measure_clk_frequency # (.C_REF_FREQ(100000000)) mcf_inst0 (
    .i_reset           (rst0 | dbg_rst),// active high reset
    .i_ref_clk         (clk_100m),// fixed reference clock
    .i_meas_clk        (gtrefclk_1160),// clock to be measured
    .o_meas_clk_freq   (gtrefclk_1160_freq),// frequency in kHz
    .o_ten_miliseconds ()// ten milisecond pulse (in ref_clk domain)
  );

  measure_clk_frequency # (.C_REF_FREQ(100000000)) mcf_inst1 (
    .i_reset           (rst0 | dbg_rst),// active high reset
    .i_ref_clk         (clk_100m),// fixed reference clock
    .i_meas_clk        (gtrefclk_1170),// clock to be measured
    .o_meas_clk_freq   (gtrefclk_1170_freq),// frequency in kHz
    .o_ten_miliseconds ()// ten milisecond pulse (in ref_clk domain)
  );

  measure_clk_frequency # (.C_REF_FREQ(100000000)) mcf_inst2 (
    .i_reset           (rst0 | dbg_rst),// active high reset
    .i_ref_clk         (clk_100m),// fixed reference clock
    .i_meas_clk        (user_clk),// clock to be measured
    .o_meas_clk_freq   (user_clk_freq),// frequency in kHz
    .o_ten_miliseconds ()// ten milisecond pulse (in ref_clk domain)
  );

  measure_clk_frequency # (.C_REF_FREQ(100000000)) mcf_inst3 (
    .i_reset           (rst0 | dbg_rst),// active high reset
    .i_ref_clk         (clk_100m),// fixed reference clock
    .i_meas_clk        (emc_clk),// clock to be measured
    .o_meas_clk_freq   (emc_clk_freq),// frequency in kHz
    .o_ten_miliseconds ()// ten milisecond pulse (in ref_clk domain)
  );

  counter30bit u_cnt(
    .clk(clk_100m),
    .rst(rst1 | dbg_rst),
    .count(clk_100m_cnt)
  );

  assign led = clk_100m_cnt[29:22];
  
  
  //UUT ============================= //UUT
  wire triger;
  wire [31:0] result;
  
  //UUT HLS main
  wire ap_start = triger;
  wire ap_done;
  wire ap_idle;
  wire ap_ready;
  wire [31:0] ap_return;
  wire [255:0] ap_out;

  main u_main(
    .ap_clk(clk_100m),
    .ap_rst(rst2 | dbg_rst),
    .ap_start(ap_start),
    .ap_done(ap_done),
    .ap_idle(ap_idle),
    .ap_ready(ap_ready),
    .ap_out(ap_out),
    .ap_return(ap_return)
  );

  //UUT wolf
  wire [255:0] sha_out;
  wire [63:0]  sha_in = {triger, 63'b0};
  wire ready;
  
  wolf_sha256 u(
    .clk_i(clk_100m),
    .rst_i(rst2 | dbg_rst),
    .sha_in(sha_in),
    .ready(ready),
    .sha_out(sha_out)
  );
  
  sha_test u_test(
    .clk(clk_100m),
    .rst(rst2 | dbg_rst),
    .cnt_in(clk_100m_cnt),
    .triger_out(triger),
    .sha0_ready(ap_done),
    .sha0_value(ap_out),
    .sha1_ready(ready),
    .sha1_value(sha_out),
    .result_out(result)
  );

  //UUT ============================= //UUT
  
  // debug info
  wire [7:0] build = build_num;
  vio_0 vio_inst(
    .clk         (clk_100m             ),
    .probe_in0   (gtrefclk_1160_freq   ),
    .probe_in1   (gtrefclk_1170_freq   ),
    .probe_in2   (user_clk_freq        ),
    .probe_in3   (emc_clk_freq         ),
    .probe_in4   (build                ),
    .probe_in5   ({rst2, rst1, rst0, rst_stage}),
    .probe_in6   (result               ),
    
    
    
    .probe_out0  (probe_out0            ),
    .probe_out1  (probe_out1            ),
    .probe_out2  (probe_out2            ),
    .probe_out3  (probe_out3            )
  );
    
    
    
    
endmodule