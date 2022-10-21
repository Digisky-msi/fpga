#
#
#zc706_pmod1_m_spi.v
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
#Modified for SPI LCD demo test 2022/10/19
#

set_property PACKAGE_PIN AJ21  [get_ports PMOD1_0]
set_property PACKAGE_PIN AK21  [get_ports PMOD1_1]
set_property PACKAGE_PIN AB21  [get_ports PMOD1_2]
set_property PACKAGE_PIN AB16  [get_ports PMOD1_3]
set_property PACKAGE_PIN Y20   [get_ports PMOD1_4]
set_property PACKAGE_PIN AA20  [get_ports PMOD1_5]
set_property PACKAGE_PIN AC18  [get_ports PMOD1_6]
set_property PACKAGE_PIN AC19  [get_ports PMOD1_7]

set_property IOSTANDARD LVCMOS25 [get_ports PMOD1_0]
set_property IOSTANDARD LVCMOS25 [get_ports PMOD1_1]
set_property IOSTANDARD LVCMOS25 [get_ports PMOD1_2]
set_property IOSTANDARD LVCMOS25 [get_ports PMOD1_3]
set_property IOSTANDARD LVCMOS25 [get_ports PMOD1_4]
set_property IOSTANDARD LVCMOS25 [get_ports PMOD1_5]
set_property IOSTANDARD LVCMOS25 [get_ports PMOD1_6]
set_property IOSTANDARD LVCMOS25 [get_ports PMOD1_7]
