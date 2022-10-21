/*
*
* zc706_pmod1_m_spi.v
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
* Modified for SPI LCD demo test 2022/10/19
*/
`timescale 1ns / 1ps

module zc706_pmod1_mspi(
// internal SPI interface
(* X_INTERFACE_INFO = "xilinx.com:interface:spi:1.0 SPI_0 SCK_I" *) output  SPI0_SCLK_I,
(* X_INTERFACE_INFO = "xilinx.com:interface:spi:1.0 SPI_0 SCK_O" *) input   SPI0_SCLK_O,
(* X_INTERFACE_INFO = "xilinx.com:interface:spi:1.0 SPI_0 SCK_T" *) input   SPI0_SCLK_T,

(* X_INTERFACE_INFO = "xilinx.com:interface:spi:1.0 SPI_0 IO0_I" *) output  SPI0_MOSI_I,
(* X_INTERFACE_INFO = "xilinx.com:interface:spi:1.0 SPI_0 IO0_O" *) input   SPI0_MOSI_O,
(* X_INTERFACE_INFO = "xilinx.com:interface:spi:1.0 SPI_0 IO0_T" *) input   SPI0_MOSI_T,

(* X_INTERFACE_INFO = "xilinx.com:interface:spi:1.0 SPI_0 IO1_I" *) output  SPI0_MISO_I,
(* X_INTERFACE_INFO = "xilinx.com:interface:spi:1.0 SPI_0 IO1_O" *) input   SPI0_MISO_O,
(* X_INTERFACE_INFO = "xilinx.com:interface:spi:1.0 SPI_0 IO1_T" *) input   SPI0_MISO_T,

(* X_INTERFACE_INFO = "xilinx.com:interface:spi:1.0 SPI_0 SS_I" *)  output  SPI0_SS_I,
(* X_INTERFACE_INFO = "xilinx.com:interface:spi:1.0 SPI_0 SS_O" *)  input   SPI0_SS_O,
(* X_INTERFACE_INFO = "xilinx.com:interface:spi:1.0 SPI_0 SS_T" *)  input   SPI0_SS_T,

input [3:0] LCD_CTRL,

// external pin interface
(* IOB = "TRUE" *) inout PMOD1_0,
(* IOB = "TRUE" *) inout PMOD1_1,
(* IOB = "TRUE" *) input PMOD1_2,
(* IOB = "TRUE" *) inout PMOD1_3,
(* IOB = "TRUE" *) output PMOD1_4,
(* IOB = "TRUE" *) output PMOD1_5,
(* IOB = "TRUE" *) output PMOD1_6,
(* IOB = "TRUE" *) output PMOD1_7

);
  
  assign SPI0_SCLK_I = 1'b0;//PMOD1_0;
  assign PMOD1_0 = (SPI0_SCLK_T)? 1'bz : SPI0_SCLK_O;

  assign SPI0_MOSI_I = 1'b0;//PMOD1_1;
  assign PMOD1_1 = (SPI0_MOSI_T)? 1'bz : SPI0_MOSI_O;
    
  assign SPI0_MISO_I = PMOD1_2;
  //assign PMOD1_2 = (SPI0_MISO_T)? 1'bz : SPI0_MISO_O;
  
  assign SPI0_SS_I = 1'b1;//PMOD1_3;
  assign PMOD1_3 = (SPI0_SS_T)? 1'bz : SPI0_SS_O;
  
  assign PMOD1_4 = LCD_CTRL[0];  //RSTL
  assign PMOD1_5 = LCD_CTRL[1];  //CSL
  assign PMOD1_6 = LCD_CTRL[2];  //D1C0
  assign PMOD1_7 = LCD_CTRL[3];  //BL = 1
  
  
endmodule
