#
#
#hw_build.tcl
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
################################################################
# START
################################################################

set proc_ip "RISCV32IM_MCU"
set proj_dir "test_proj"
set proj_name "proj_risc"
set bd_name "core_bd"

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project $proj_name ../$proj_dir -part xc7k325tffg900-2
   set_property board_part xilinx.com:kc705:part0:1.6 [current_project]
}

cd ../$proj_dir

set_property ip_repo_paths "../" [current_project]
update_ip_catalog

# CHANGE DESIGN NAME HERE
variable design_name
set design_name ${bd_name}

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES:
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips {xilinx.com:ip:axi_gpio:2.0}
   lappend list_check_ips xilinx.com:ip:axi_uart16550:2.0
   lappend list_check_ips xilinx.com:ip:proc_sys_reset:5.0
   lappend list_check_ips xilinx.com:ip:xlconstant:1.1
   lappend list_check_ips xilinx.com:ip:xlconcat:2.1
   lappend list_check_ips bluespec.com:ip:$proc_ip:E.1.0
   lappend list_check_ips bluespec.com:ip:xilinx_jtag:1.0
   lappend list_check_ips xilinx.com:ip:axi_bram_ctrl:4.1
   lappend list_check_ips xilinx.com:ip:blk_mem_gen:8.4

   set list_ips_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_msg_id "BD_TCL-1003" "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################

# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell proc_ip } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj






  # Create ports
  create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 sys_diff_clock
  create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 push_buttons_5bits
  create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 led_8bits
  create_bd_intf_port -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 rs232_uart
  
  # Create reset port
  set reset [ create_bd_port -dir I -type rst reset ]
  set_property -dict [ list \
   CONFIG.POLARITY ACTIVE_HIGH \
  ] $reset







  # Create instance: clk_wiz_0, and set properties
  set clk_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_0 ]
  set_property -dict [ list \
   CONFIG.CLKOUT1_JITTER {118.758} \
   CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {166.667} \
   CONFIG.CLKOUT1_PHASE_ERROR {98.575}  \
   CONFIG.CLKOUT2_JITTER {114.829} \
   CONFIG.CLKOUT2_PHASE_ERROR {98.575} \
   CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {200} \
   CONFIG.CLKOUT2_USED {true} \
   CONFIG.CLKOUT3_JITTER {135.981} \
   CONFIG.CLKOUT3_PHASE_ERROR {98.575} \
   CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {83.333} \
   CONFIG.CLKOUT3_USED {true} \
   CONFIG.CLK_IN1_BOARD_INTERFACE {sys_diff_clock} \
   CONFIG.MMCM_DIVCLK_DIVIDE {1}  \
   CONFIG.MMCM_CLKOUT0_DIVIDE_F {6.000}  \
   CONFIG.MMCM_CLKOUT1_DIVIDE {5}  \
   CONFIG.MMCM_CLKFBOUT_MULT_F {5.000}  \
   CONFIG.MMCM_CLKOUT2_DIVIDE {12} \
   CONFIG.NUM_OUT_CLKS {3} \
   CONFIG.RESET_BOARD_INTERFACE {Custom} \
   CONFIG.RESET_PORT {reset} \
   CONFIG.RESET_TYPE {ACTIVE_HIGH} \
   CONFIG.USE_BOARD_FLOW {true} \
 ] $clk_wiz_0

  # Create instance: proc_sys_reset_1, and set properties
  set proc_sys_reset_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_1 ]
  set_property -dict [ list \
   CONFIG.C_EXT_RESET_HIGH {1} \
   CONFIG.C_AUX_RESET_HIGH {1} \
   CONFIG.C_EXT_RST_WIDTH {4} \
   CONFIG.C_AUX_RST_WIDTH {4} \
   CONFIG.C_NUM_BUS_RST {1} \
   CONFIG.RESET_BOARD_INTERFACE {reset} \
 ] $proc_sys_reset_1

  # add NOT gate for MB_rst to bluespec reset_n
  set util_vector_logic_0 [create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_0 ]
  set_property -dict [list \
   CONFIG.C_SIZE {1} \
   CONFIG.C_OPERATION {not} \
   CONFIG.LOGO_FILE {data/sym_notgate.png} \
  ] $util_vector_logic_0


  # Create instance: bluespec_processor_0, and set properties
  set bluespec_processor_0 [ create_bd_cell -type ip -vlnv bluespec.com:ip:$proc_ip:E.1.0 bluespec_processor_0 ]
 


  # Create instance: axi_interconnect_0, and set properties
  set axi_interconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0 ]
  set_property -dict [ list \
   CONFIG.ENABLE_ADVANCED_OPTIONS {0} \
   CONFIG.NUM_MI {6} \
   CONFIG.NUM_SI {1} \
   CONFIG.S00_HAS_DATA_FIFO {2} \
   CONFIG.S01_HAS_DATA_FIFO {2} \
   CONFIG.S02_HAS_DATA_FIFO {2} \
   CONFIG.S03_HAS_DATA_FIFO {2} \
   CONFIG.S04_HAS_DATA_FIFO {2} \
   CONFIG.S05_HAS_DATA_FIFO {2} \
   CONFIG.STRATEGY {2} \
 ] $axi_interconnect_0

  # Create instance: axi_gpio_0, and set properties
  set axi_gpio_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0 ]
  set_property -dict [ list \
   CONFIG.C_ALL_INPUTS {1} \
   CONFIG.C_ALL_OUTPUTS_2 {1} \
   CONFIG.GPIO_BOARD_INTERFACE {push_buttons_5bits} \
   CONFIG.GPIO2_BOARD_INTERFACE {led_8bits} \
   CONFIG.C_INTERRUPT_PRESENT {1} \
   CONFIG.C_IS_DUAL {1} \
 ] $axi_gpio_0

  # Create instance: axi_uart16550_0, and set properties
  set axi_uart16550_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uart16550:2.0 axi_uart16550_0 ]
  set_property -dict [ list \
   CONFIG.UART_BOARD_INTERFACE {rs232_uart} \
  ] $axi_uart16550_0



  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
 ] $xlconstant_0

  # Create instance: xlconstant_1, and set properties (default value = 1)
  set xlconstant_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_1 ]



  # Create instance: xilinx_jtag_0, and set properties
  set xilinx_jtag_0 [ create_bd_cell -type ip -vlnv bluespec.com:ip:xilinx_jtag:1.0 xilinx_jtag_0 ]



  # Create instance: axi_bram_ctrl_0, and set properties
  set axi_bram_ctrl_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_ctrl_0 ]
  set_property -dict [ list \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.ECC_TYPE {Hamming} \
   CONFIG.SINGLE_PORT_BRAM {1} \
 ] $axi_bram_ctrl_0

  # Create instance: blk_mem_gen_0, and set properties
  set blk_mem_gen_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blk_mem_gen_0 ]
  set_property -dict [ list \
   CONFIG.Byte_Size {8} \
   CONFIG.EN_SAFETY_CKT {true} \
   CONFIG.Enable_32bit_Address {true} \
   CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
   CONFIG.Use_Byte_Write_Enable {true} \
   CONFIG.Use_RSTA_Pin {true} \
   CONFIG.use_bram_block {BRAM_Controller} \
 ] $blk_mem_gen_0

#  #Create VIO cell
#  set vio_0 [create_bd_cell -type ip -vlnv xilinx.com:ip:vio:3.0 vio_0]
#  set_property -dict [list \
#   CONFIG.C_NUM_PROBE_IN {1} \
#   CONFIG.C_NUM_PROBE_OUT {1} \
#   CONFIG.C_PROBE_IN0_WIDTH {1} \
#   CONFIG.C_PROBE_OUT0_WIDTH {1} \
#  ] $vio_0




  # Connect up the reset
  connect_bd_net -net ext_reset_in [get_bd_ports reset] \
   [get_bd_pins proc_sys_reset_1/ext_reset_in] 
#   [get_bd_pins vio_0/probe_in0] \
   
#  connect_bd_net -net vio_out0 [get_bd_pins vio_0/probe_out0] [get_bd_pins proc_sys_reset_1/aux_reset_in]
  
  connect_bd_net -net mb_rst [get_bd_pins proc_sys_reset_1/mb_reset] [get_bd_pins util_vector_logic_0/Op1]
  connect_bd_net -net bs_rst_n [get_bd_pins util_vector_logic_0/Res] [get_bd_pins bluespec_processor_0/RST_N]

  connect_bd_net -net reset_network [get_bd_pins proc_sys_reset_1/peripheral_aresetn] \
   [get_bd_pins axi_gpio_0/s_axi_aresetn] \
   [get_bd_pins axi_uart16550_0/s_axi_aresetn] \
   [get_bd_pins xilinx_jtag_0/rst_n] \
   [get_bd_pins axi_interconnect_0/ARESETN] \
   [get_bd_pins axi_interconnect_0/M00_ARESETN] \
   [get_bd_pins axi_interconnect_0/M01_ARESETN] \
   [get_bd_pins axi_interconnect_0/M02_ARESETN] \
   [get_bd_pins axi_interconnect_0/M03_ARESETN] \
   [get_bd_pins axi_interconnect_0/M04_ARESETN] \
   [get_bd_pins axi_interconnect_0/M05_ARESETN] \
   [get_bd_pins axi_interconnect_0/S00_ARESETN] \
   [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn]

  connect_bd_net -net dmi_reset_in [get_bd_pins xilinx_jtag_0/reset] [get_bd_pins bluespec_processor_0/TRST]

  # Connect up the clock
  connect_bd_intf_net -intf_net clk_in1_0_1 [get_bd_intf_ports sys_diff_clock] [get_bd_intf_pins clk_wiz_0/CLK_IN1_D]
  connect_bd_net -net clk_network [get_bd_pins clk_wiz_0/clk_out3] \
   [get_bd_pins axi_gpio_0/s_axi_aclk] \
   [get_bd_pins axi_interconnect_0/ACLK] \
   [get_bd_pins axi_interconnect_0/M00_ACLK] \
   [get_bd_pins axi_interconnect_0/M01_ACLK] \
   [get_bd_pins axi_interconnect_0/M02_ACLK] \
   [get_bd_pins axi_interconnect_0/M03_ACLK] \
   [get_bd_pins axi_interconnect_0/M04_ACLK] \
   [get_bd_pins axi_interconnect_0/M05_ACLK] \
   [get_bd_pins axi_interconnect_0/S00_ACLK] \
   [get_bd_pins axi_uart16550_0/s_axi_aclk] \
   [get_bd_pins proc_sys_reset_1/slowest_sync_clk] \
   [get_bd_pins bluespec_processor_0/CLK] \
   [get_bd_pins xilinx_jtag_0/clk] \
   [get_bd_pins axi_bram_ctrl_0/s_axi_aclk]
#   [get_bd_pins vio_0/clk]


  # Create AXI interface connections
  connect_bd_intf_net -intf_net axi_interconnect_0_M00_AXI [get_bd_intf_pins axi_interconnect_0/M00_AXI] [get_bd_intf_pins axi_uart16550_0/S_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M01_AXI [get_bd_intf_pins axi_interconnect_0/M01_AXI] [get_bd_intf_pins axi_gpio_0/S_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M02_AXI [get_bd_intf_pins axi_interconnect_0/M02_AXI] [get_bd_intf_pins axi_bram_ctrl_0/S_AXI]
  connect_bd_intf_net -intf_net bluespec_processor_0_dmem [get_bd_intf_pins axi_interconnect_0/S00_AXI] [get_bd_intf_pins bluespec_processor_0/master1]

  # Connect JTAG
  connect_bd_intf_net -intf_net jtag_connection [get_bd_intf_pins xilinx_jtag_0/jtag] [get_bd_intf_pins bluespec_processor_0/jtag]
  
  # Connect BRAM
  connect_bd_intf_net -intf_net axi_bram_ctrl_0_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_0/BRAM_PORTA]


  # GPIO interrupt connection. Reenable after adding PLIC
  # connect_bd_net -net axi_gpio_0_ip2intc_irpt [get_bd_pins axi_gpio_0/ip2intc_irpt] [get_bd_pins xlconcat_0/In2]
  #
  # UART interrupt connection. Reenable after adding PLIC
  # connect_bd_net -net axi_uart16550_0_ip2intc_irpt [get_bd_pins axi_uart16550_0/ip2intc_irpt] [get_bd_pins xlconcat_0/In0]
  #
  # Reintroduce with PLIC. This will be interrupt input to the PLIC
  # connect_bd_net -net xlconcat_0_dout [get_bd_pins bluespec_processor_0/cpu_external_interrupt_req] [get_bd_pins xlconcat_0/dout]
  #

  # Connect the GPIOs to pads
  connect_bd_intf_net -intf_net axi_gpio_0_gpio2_io_o [get_bd_intf_ports led_8bits] [get_bd_intf_pins axi_gpio_0/GPIO2]
  connect_bd_intf_net -intf_net axi_gpio_0_gpio_io_i [get_bd_intf_ports push_buttons_5bits] [get_bd_intf_pins axi_gpio_0/GPIO]

  # Connect UART to pads
  connect_bd_intf_net -intf_net rs232_uart_1 [get_bd_intf_ports rs232_uart] [get_bd_intf_pins axi_uart16550_0/UART]

  # tie high
  connect_bd_net -net tiehigh [get_bd_pins xlconstant_1/dout] [get_bd_pins proc_sys_reset_1/dcm_locked]
  
  # tie low
  connect_bd_net -net tielow [get_bd_pins xlconstant_0/dout] \
   [get_bd_pins axi_uart16550_0/freeze] \
   [get_bd_pins proc_sys_reset_1/mb_debug_sys_rst] \
   [get_bd_pins clk_wiz_0/reset] \
   [get_bd_pins proc_sys_reset_1/aux_reset_in]
  
  # Tie off CPU interrupt pins. The interrupt pins will be reconnected after
  # introducing the PLIC and CLINT.
  connect_bd_net [get_bd_pins bluespec_processor_0/ext_interrupt] [get_bd_pins xlconstant_0/dout]
  connect_bd_net [get_bd_pins bluespec_processor_0/sw_interrupt] [get_bd_pins xlconstant_0/dout]
  connect_bd_net [get_bd_pins bluespec_processor_0/timer_interrupt] [get_bd_pins xlconstant_0/dout]






  # Create address segments
  create_bd_addr_seg -range 0x00001000 -offset 0x62300000 [get_bd_addr_spaces bluespec_processor_0/master1] [get_bd_addr_segs axi_uart16550_0/S_AXI/Reg] SEG_axi_uart16550_0_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x6FFF0000 [get_bd_addr_spaces bluespec_processor_0/master1] [get_bd_addr_segs axi_gpio_0/S_AXI/Reg] SEG_axi_gpio_0_Reg

  assign_bd_address [get_bd_addr_segs {axi_bram_ctrl_0/S_AXI/Mem0 }]
  set_property offset 0x70000000 [get_bd_addr_segs {bluespec_processor_0/master1/SEG_axi_bram_ctrl_0_Mem0}]
  set_property range  0x00002000 [get_bd_addr_segs {bluespec_processor_0/master1/SEG_axi_bram_ctrl_0_Mem0}]


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  regenerate_bd_layout
  save_bd_design
  
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design "" $proc_ip

make_wrapper -files [get_files ${proj_name}.srcs/sources_1/bd/${bd_name}/${bd_name}.bd] -top
add_files -norecurse ${proj_name}.gen/sources_1/bd/${bd_name}/hdl/${bd_name}_wrapper.v

# --------
# Synthesis and Implementation runs
# --------
# Create 'synth_1' run (if not found)
if {[string equal [get_runs -quiet synth_1] ""]} {
    create_run -name synth_1
}

# set the current synth run
current_run -synthesis [get_runs synth_1]

# Create 'impl_1' run (if not found)
if {[string equal [get_runs -quiet impl_1] ""]} {
    create_run -name impl_1 -parent_run synth_1
}

# set the current impl run
current_run -implementation [get_runs impl_1]

# prepare for bitgen run
exec cp ../RISCV32IM_MCU_Eval/promgen.tcl promgen.tcl
exec cp ../RISCV32IM_MCU_Eval/kc705_conf.xdc kc705_conf.xdc

add_files -fileset constrs_1 -norecurse kc705_conf.xdc

#below command moved to promgen
#launch_runs impl_1 -to_step write_bitstream -jobs 6


