#
#
#promgen.tcl
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
write_cfgmem -format mcs -interface spix4 -size 16 -loadbit "up 0x0 kc705_clear/project_1.runs/impl_1/kc705_top.bit up 0x200000 kc705_functionA/project_1.runs/impl_1/kc705_top.bit up 0x400000 kc705_functionB/project_1.runs/impl_1/kc705_top.bit" -file kc705_tri.mcs -force

write_cfgmem -format mcs -interface spix4 -size 16 -loadbit "up 0x0 kc705_clear/project_1.runs/impl_1/kc705_top.bit up 0x200000 kc705_functionA/project_1.runs/impl_1/kc705_top.bit up" -file kc705_dual.mcs -force
