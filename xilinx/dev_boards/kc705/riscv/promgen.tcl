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
#Modified for RISC-V Soft CPU demo 2022/11/23
#
launch_runs impl_1 -to_step write_bitstream -jobs 6
wait_on_run impl_1 -quiet

set work_dir [get_property DIRECTORY [current_project]]
set project [get_projects]
cd $work_dir/$project.runs

write_cfgmem -format mcs -interface bpix16 -size 128 -loadbit "up 0x0 impl_1/${bd_name}_wrapper.bit" -file ${bd_name}_wrapper.mcs -force
