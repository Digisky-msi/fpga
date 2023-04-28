/*
*
* max10_top.v
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

// Version log
// - v0014 clean MAX10 dev board
// - v0019 add NIOS


`timescale 1 ps / 1 ps
module  max10_top (
  //Reset and Clocks
  input          fpga_resetn,
  input          clk_ddr3_100_p,  // 100MHz
  input          clk_50_max10,    // ref clock 50MHz
  input          clk_25_max10,    // 25MHz
  input          clk_lvds_125_p,  // 124.999MHz
  input          clk_10_adc,      // 10MHz

  //LED PB DIPSW
  output  [4:0]  user_led,
  input   [3:0]  user_pb,
  input   [4:0]  user_dipsw,

  //USB
  input          usb_resetn,
  input          usb_wrn,
  input          usb_rdn,
  input          usb_oen,
  inout   [1:0]  usb_addr,
  inout   [7:0]  usb_data,
  output         usb_full,
  output         usb_empty,
  inout          usb_scl,
  inout          usb_sda,
  input          usb_clk,

  //DDR3
//  output  [13:0] ddr3_a,
//  output  [2:0]  ddr3_ba,
//  output  [0:0]  ddr3_clk_p,
//  output  [0:0]  ddr3_clk_n,
//  output  [0:0]  ddr3_cke,
//  output  [0:0]  ddr3_csn,
//  output  [2:0]  ddr3_dm,
//  output  [0:0]  ddr3_rasn,
//  output  [0:0]  ddr3_casn,
//  output  [0:0]  ddr3_wen,
//  output         ddr3_resetn,
//  inout   [23:0] ddr3_dq,
//  inout   [2:0]  ddr3_dqs_p,
//  //inout [2:0]  ddr3_dqs_n,
//  output  [0:0]  ddr3_odt,

  //Dual Ethernet
  output         enet_mdc,
  inout          enet_mdio,
  input          eneta_rx_clk,
  output         eneta_tx_en,
  output         eneta_gtx_clk,
  input   [3:0]  eneta_rx_d,
  output  [3:0]  eneta_tx_d,
  input          eneta_rx_dv,
  output         eneta_resetn,  
  input          eneta_led_link100,
  input          enetb_rx_clk,
  output         enetb_tx_en,  
  output         enetb_gtx_clk,
  input   [3:0]  enetb_rx_d,
  output  [3:0]  enetb_tx_d,
  input          enetb_rx_dv,
  output         enetb_resetn,
  input          enetb_led_link100,

  //UART
  input          uart_rx,
  output         uart_tx,

  //HSMC
  input   [2:1]  hsmc_clk_in_p,
  input          hsmc_clk_in0,
  output  [2:1]  hsmc_clk_out_p,
  inout   [3:0]  hsmc_d,
  input   [16:0] hsmc_rx_d_p,
  output  [16:0] hsmc_tx_d_p,
  inout          hsmc_scl,
  inout          hsmc_sda,
  output         hsmc_clk_out0,
  input          hsmc_prsntn,

  //HDMI
  inout          hdmi_scl,
  inout          hdmi_sda,
  output         hdmi_tx_clk,
  output  [23:0] hdmi_tx_d,
  output         hdmi_tx_de,
  output         hdmi_tx_hs,
  output         hdmi_tx_int,
  output         hdmi_tx_vs,

  //PMOD
  inout   [7:0]  pmoda_io,
  inout   [7:0]  pmodb_io,

  //QSPI
  output         qspi_clk,
  inout   [3:0]  qspi_io,
  output         qspi_csn,

  //DAC
  output         dac_sync,
  output         dac_sclk,
  output         dac_din,

  //ADC
//  input   [8:1]  adc1in,
//  input   [8:1]  adc2in,

  //Security and Safe settings
  output         ip_sequrity,
  output         jtag_safe
  );

  //------- FW Version ----------
  localparam FW_VER = 8'd19;
  wire [7:0] SW_VER;
  
  vio u_vio_version(
		.probe(       {FW_VER, SW_VER})  //  probes.probe
	);
  //------

  //------- NIOS ----------
  wire pll_clk50m;
  wire [31:0] pio_in, pio_out;
  
	nios u0 (
		.clk_clk          (clk_50_max10),          //        clk.clk
		.reset_reset_n    (fpga_resetn),    //      reset.reset_n
		.pll_clk50m_clk   (pll_clk50m),   // pll_clk50m.clk
		.uart_0_rxd       (uart_rx),       //     uart_0.rxd
		.uart_0_txd       (uart_tx),       //           .txd
		.pio_0_in_export  (pio_in),  //   pio_0_in.export
		.pio_1_out_export (pio_out)  //  pio_1_out.export
	);
  //------
  assign SW_VER = pio_out[7:0];


  //------- measure clock freq ----------
  wire [79:0] clk_freq;
  wire [7:0]  ctrl;
  
  measure_freq_block # (
    .NUM_CLK(4),
    .C_REF_FREQ(50000000)) u_mea
  (
    .i_ref_clk(       pll_clk50m),
    .i_meas_clk(      {clk_ddr3_100_p, clk_25_max10, clk_lvds_125_p, clk_10_adc}),
    .o_meas_clk_freq( clk_freq)
  );

	vio2 u_vio_freq (
		.probe (          clk_freq),  // probes.probe [79:0]
    .source(          ctrl)
	);
  //------
  assign pio_in[19:0] = clk_freq[19:0];


  //------- toggle LEDs ----------
  reg  [31:0] led_toggle;
  
  assign user_led = ~led_toggle[29:25];
  
  always @ (posedge pll_clk50m) begin
    if (!fpga_resetn)
	   led_toggle <= 32'b0;
    else
	   led_toggle <= led_toggle + 1;
    end
  //------
	 
  



endmodule
