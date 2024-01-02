#
#
#io_top.xdc
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

#------------------------------------------------------------------------------------------
# I/O standards and pin locations
#------------------------------------------------------------------------------------------
#

# Bank 33: 200MHz
set_property VCCAUX_IO DONTCARE [get_ports sys_clk_p]
set_property IOSTANDARD DIFF_SSTL15 [get_ports sys_clk_p]
set_property LOC AD12 [get_ports sys_clk_p]

# Bank 33: 
set_property VCCAUX_IO DONTCARE [get_ports sys_clk_n]
set_property IOSTANDARD DIFF_SSTL15 [get_ports sys_clk_n]
#set_property LOC AD11 [get_ports sys_clk_n]


#----------------------------------------
# DIP Switch
#----------------------------------------
set_property IOSTANDARD LVCMOS25 [get_ports dip_sw0]
set_property LOC Y29 [get_ports dip_sw0]

#----------------------------------------
# QSPI
#----------------------------------------
set_property IOSTANDARD LVCMOS25 [get_ports SPI_CS_L]
set_property LOC U19 [get_ports SPI_CS_L]
set_property SLEW SLOW [get_ports SPI_CS_L]
set_property DRIVE 4 [get_ports SPI_CS_L]

set_property IOSTANDARD LVCMOS25 [get_ports SPI_Q0]
set_property LOC P24 [get_ports SPI_Q0]
set_property SLEW SLOW [get_ports SPI_Q0]
set_property DRIVE 4 [get_ports SPI_Q0]

set_property IOSTANDARD LVCMOS25 [get_ports SPI_Q1]
set_property LOC R25 [get_ports SPI_Q1]
set_property SLEW SLOW [get_ports SPI_Q1]
set_property DRIVE 4 [get_ports SPI_Q1]

set_property IOSTANDARD LVCMOS25 [get_ports SPI_Q2]
set_property LOC R20 [get_ports SPI_Q2]
set_property SLEW SLOW [get_ports SPI_Q2]
set_property DRIVE 4 [get_ports SPI_Q2]

set_property IOSTANDARD LVCMOS25 [get_ports SPI_Q3]
set_property LOC R21 [get_ports SPI_Q3]
set_property SLEW SLOW [get_ports SPI_Q3]
set_property DRIVE 4 [get_ports SPI_Q3]

#-------------------------------------
# LED Status Pinout   (bottom to top)
#-------------------------------------
set_property IOSTANDARD LVCMOS15 [get_ports {led[0]}]
set_property SLEW SLOW [get_ports {led[0]}]
set_property DRIVE 4 [get_ports {led[0]}]
set_property LOC AB8 [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS15 [get_ports {led[1]}]
set_property SLEW SLOW [get_ports {led[1]}]
set_property DRIVE 4 [get_ports {led[1]}]
set_property LOC AA8 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS15 [get_ports {led[2]}]
set_property SLEW SLOW [get_ports {led[2]}]
set_property DRIVE 4 [get_ports {led[2]}]
set_property LOC AC9 [get_ports {led[2]}]
set_property IOSTANDARD LVCMOS15 [get_ports {led[3]}]
set_property SLEW SLOW [get_ports {led[3]}]
set_property DRIVE 4 [get_ports {led[3]}]
set_property LOC AB9 [get_ports {led[3]}]

set_property IOSTANDARD LVCMOS25 [get_ports {led[4]}]
set_property SLEW SLOW [get_ports {led[4]}]
set_property DRIVE 4 [get_ports {led[4]}]
set_property LOC AE26 [get_ports {led[4]}]
set_property IOSTANDARD LVCMOS25 [get_ports {led[5]}]
set_property SLEW SLOW [get_ports {led[5]}]
set_property DRIVE 4 [get_ports {led[5]}]
set_property LOC G19 [get_ports {led[5]}]
set_property IOSTANDARD LVCMOS25 [get_ports {led[6]}]
set_property SLEW SLOW [get_ports {led[6]}]
set_property DRIVE 4 [get_ports {led[6]}]
set_property LOC E18 [get_ports {led[6]}]
set_property IOSTANDARD LVCMOS25 [get_ports {led[7]}]
set_property SLEW SLOW [get_ports {led[7]}]
set_property DRIVE 4 [get_ports {led[7]}]
set_property LOC F16 [get_ports {led[7]}]

