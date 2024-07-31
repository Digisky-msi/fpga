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
//------------------------------------------------------------------------------
// File name:  tb_clock.v
// Title    :  Simulation clock
//------------------------------------------------------------------------------
`timescale 1 ns/1 ps


//******************************************************************************
//  Clock Source
//  - generates free running clock based upon a clock frequency or period
//  - randomizes the initial edge to create a phase difference from other clocks
//******************************************************************************
module tb_clock (
   output oCLK
);

parameter period = 1e9 / 27e6;  //27Mhz @ this timescale
parameter delay = 1;		//Add some delay


reg clk;

//------------------------------------------------------
// Begin Module
//------------------------------------------------------
   initial begin
      clk = 0;
      #delay;
      forever #(period/2) clk = ~clk;
   end

assign oCLK = clk;
endmodule

