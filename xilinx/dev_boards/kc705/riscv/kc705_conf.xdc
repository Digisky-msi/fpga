#
#
#kc705_conf.xdc
#
#Copyright (C) Digisky Media Solutions Inc.  All rights reserved.
#
#Permission is hereby granted, free of charge, to any person
#obtaining a copy of this software and associated documentation
#files (the "Software"), to deal in the Software without restriction,
#including without limitation the rights to use, copy, modify, merge,
#publish, distribute, sublicense, and/or sell copies of the Software,
#and to permit persons to whom the Software is furnished to do so,
#subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included
#in all copies or substantial portions of the Software.
#
#Use of the Software is limited solely to applications:
#(a) running on a Xilinx device, or (b) that interact
#with a Xilinx device through a bus or interconnect.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
#IN NO EVENT SHALL DIGISKY MSI BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
#WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
#CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
#
#Modified for RISC-V Soft CPU demo 2022/11/23
#

set_property CONFIG_VOLTAGE                     2.5     [current_design]
set_property CFGBVS                             VCCO    [current_design]
set_property BITSTREAM.GENERAL.COMPRESS         TRUE    [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN  DIV-1   [current_design]
set_property BITSTREAM.CONFIG.BPI_SYNC_MODE     TYPE2   [current_design]
set_property config_mode                        BPI16   [current_design]
