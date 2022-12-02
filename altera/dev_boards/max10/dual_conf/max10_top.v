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
* Modified for MAX10 dual-conf demo test 2022/12/01
*/

// Version log
// - v0.1 initial, toggle LED, check ID, dual image
// - v0.2 CFM1, same feature

`timescale 1 ps / 1 ps
module  max10_top (
        //Reset and Clocks
        input          fpga_resetn,
        input          clk_ddr3_100_p,
        input          clk_50_max10,
        input          clk_25_max10,
        input          clk_lvds_125_p,
        input          clk_10_adc,
		
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
//        output  [13:0] ddr3_a,
//        output  [2:0]  ddr3_ba,
//        output  [0:0]  ddr3_clk_p,
//        output  [0:0]  ddr3_clk_n,
//        output  [0:0]  ddr3_cke,
//        output  [0:0]  ddr3_csn,
//        output  [2:0]  ddr3_dm,
//        output  [0:0]  ddr3_rasn,
//        output  [0:0]  ddr3_casn,
//        output  [0:0]  ddr3_wen,
//        output         ddr3_resetn,
//        inout   [23:0] ddr3_dq,
//        inout   [2:0]  ddr3_dqs_p,
//        //inout [2:0]  ddr3_dqs_n,
//        output  [0:0]  ddr3_odt,
		
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
//        input   [8:1]  adc1in,
//        input   [8:1]  adc2in,
		
        //Security and Safe settings
        output         ip_sequrity,
        output         jtag_safe
        );

  localparam VERSION = 8'h02;
  
  //------- detect chip ID, get version ----------
  wire        id_valid;
  wire [63:0] chipid;
  
  chip_id uchipid(
		.clkin(       clk_50_max10),      //  clkin.clk
		.reset(       !fpga_resetn),      //  reset.reset
		.data_valid(  id_valid), // output.valid
		.chip_id(     chipid)     //       .data [63:0]
	);
  //------



  //------- toggle LEDs ----------
  reg  [31:0] led_toggle;
  
//  assign user_led = ~led_toggle[24:20]; // CFM0 image fast LED
  assign user_led = ~led_toggle[29:25]; // CFM1 image slow LED
  
  always @ (posedge clk_50_max10) begin
    if (!fpga_resetn)
	   led_toggle <= 32'b0;
    else
	   led_toggle <= led_toggle + 1;
    end
  //------
	 
  

  //------- dual config ----------
  wire conf_en;
  wire conf_sel;
  wire [1:0] conf_out;
  
  assign conf_sel = conf_out[1];
  assign conf_en = conf_out[0];

  reconf_fsm u_reconf(
    .i_clk(       clk_50_max10),
    .i_rstn(      fpga_resetn),
    .i_reconf_en( conf_en),
    .i_conf_sel(  conf_sel)
  );
  //------

	
  src_prob0 u_vio(
		.probe(     {chipid, 3'b0, id_valid, VERSION}),  //  probes.probe 76
		.source(    conf_out)  // sources.source 2
	);


endmodule
