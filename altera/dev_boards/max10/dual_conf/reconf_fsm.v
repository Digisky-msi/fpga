/*
*
* reconf_fsm.v
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



`timescale 1 ps / 1 ps
module  reconf_fsm (
  input  i_clk,
  input  i_rstn,
  input  i_reconf_en,
  input  i_conf_sel
  
);

  localparam [9:0] IDLE      = 10'b0000000001;
  localparam [9:0] START     = 10'b0000000010;
  localparam [9:0] WR_EN     = 10'b0000000100;
  localparam [9:0] WR_CLR    = 10'b0000001000;
  localparam [9:0] RD_BUSY   = 10'b0000010000;
  localparam [9:0] RD_EN     = 10'b0000100000;
  localparam [9:0] RD_EN2    = 10'b0001000000;
  localparam [9:0] TRIG      = 10'b0010000000;
  localparam [9:0] WR2_EN    = 10'b0100000000;
  localparam [9:0] WR2_CLR   = 10'b1000000000;

  reg [9:0]  sta;
  reg en_d, en_dd, en_trig;
  
  always @ (posedge i_clk) begin
    en_d <= i_reconf_en;
    en_dd <= en_d;
    en_trig <= ~en_dd & en_d;
    end
    
  reg  [2:0]  dc_addr;
  reg         dc_read;
  reg         dc_write;
  reg  [31:0] dc_writedata;
  wire [31:0] dc_readdata;

  always @ (posedge i_clk, negedge i_rstn) begin
    if (!i_rstn) begin
      sta <= IDLE;
      dc_addr <= 3'd0;
      dc_read <= 1'b0;
      dc_write <= 1'b0;
      dc_writedata <= 32'h0;
      end
    else begin
      case (sta)
        IDLE : begin
            dc_addr <= 3'd0;
            dc_read <= 1'b0;
            dc_write <= 1'b0;
            dc_writedata <= 32'h0;
            if (en_trig)
              sta <= START;
          end

        START : begin
            dc_addr <= 3'd1;  // offset 1
            dc_write <= 1'b0;
            dc_writedata <= {30'h0, i_conf_sel, 1'b1}; // enable overwrite
            sta <= WR_EN;
          end

        WR_EN : begin
            dc_write <= 1'b1;
            sta <= WR_CLR;
          end

        WR_CLR : begin
            dc_write <= 1'b0;
            sta <= RD_BUSY;
          end

        RD_BUSY : begin
            dc_addr <= 3'd2; // busy
            dc_read <= 1'b0;
            sta <= RD_EN;
          end

        RD_EN : begin
            dc_read <= 1'b1;
            sta <= RD_EN2;
          end

        RD_EN2 : begin
            dc_read <= 1'b0;
            if (dc_readdata[0])
              sta <= RD_BUSY;
            else
              sta <= TRIG;
          end
          
        TRIG : begin
            dc_addr <= 3'd0;  // offset 0
            dc_write <= 1'b0;
            dc_writedata <= {31'h0, 1'b1}; // trigger reconfig
            sta <= WR2_EN;
          end

        WR2_EN : begin
            dc_write <= 1'b1;
//            sta <= WR2_CLR;      // FPGA should be done right here
          end

        WR2_CLR : begin
            dc_write <= 1'b0;
            sta <= IDLE;
          end

        default : sta <= IDLE;
      endcase
      end
    end

  
  dual_conf u_conf(
		.avmm_rcv_address(      dc_addr),       // avalon.address [2:0]
		.avmm_rcv_read(         dc_read),       //        read
		.avmm_rcv_writedata(    dc_writedata),  //        writedata [31:0]
		.avmm_rcv_write(        dc_write),      //        write
		.avmm_rcv_readdata(     dc_readdata),   //        readdata [31:0]
		.clk(       i_clk),                     // clk.clk
		.nreset(    i_rstn)                     // nreset.reset_n
	);

  
  
endmodule
