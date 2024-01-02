#
#
#config.xdc
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
#Modified for KC705 multiboot demo 2023/12/12
#

#where value2 is the voltage provided to configuration bank 0 - VCCO_0
set_property CONFIG_VOLTAGE                       2.5           [current_design]
#where value1 is either VCCO or GND
set_property CFGBVS                               VCCO          [current_design]
#Bitstream settings
set_property BITSTREAM.GENERAL.COMPRESS           TRUE          [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN    DISABLE       [ current_design ]
set_property BITSTREAM.CONFIG.CONFIGRATE          33            [ current_design ]
set_property CONFIG_MODE                          SPIx4         [ current_design ]
#Bitstream next boot
set_property BITSTREAM.CONFIG.NEXT_CONFIG_ADDR    0X00200000    [current_design]
set_property BITSTREAM.CONFIG.NEXT_CONFIG_REBOOT  ENABLE        [current_design]
set_property BITSTREAM.CONFIG.CONFIGFALLBACK      ENABLE        [current_design]
set_property BITSTREAM.CONFIG.TIMER_CFG           32'h000B98C0  [current_design]
