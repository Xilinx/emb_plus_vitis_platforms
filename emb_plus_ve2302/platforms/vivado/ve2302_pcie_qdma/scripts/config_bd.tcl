# Copyright (C) 2023 - 2024 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

################################################################
# This is a generated script based on design: ve2302_pcie_qdma
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source ve2302_pcie_qdma_script.tcl


# The design that will be created by this Tcl script contains the following
# block design container source references:
# ulp

# Please add the sources before sourcing this Tcl script.

# Set design_name
variable design_name
set design_name $proj_name

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
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
 }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

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

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\
xilinx.com:ip:versal_cips:*\
xilinx.com:ip:axi_noc:*\
xilinx.com:ip:axi_dbg_hub:*\
xilinx.com:ip:axi_firewall:*\
xilinx.com:ip:smartconnect:*\
xilinx.com:ip:axi_uartlite:*\
xilinx.com:ip:util_vector_logic:*\
xilinx.com:ip:xlconstant:*\
xilinx.com:ip:hw_discovery:*\
xilinx.com:ip:mailbox:*\
xilinx.com:ip:cmd_queue:*\
xilinx.com:ip:xlconcat:*\
xilinx.com:ip:xlslice:*\
xilinx.com:ip:uuid_register:*\
xilinx.com:ip:axi_register_slice:*\
xilinx.com:ip:proc_sys_reset:*\
xilinx.com:ip:util_reduced_logic:*\
xilinx.com:ip:axi_gpio:*\
xilinx.com:ip:axi_intc:*\
xilinx.com:ip:clk_wizard:*\
xilinx.com:ip:shell_utils_ucc:*\
xilinx.com:ip:pfm_irq_ctlr:*\
xilinx.com:ip:qdma:*\
xilinx.com:ip:pcie_versal:*\
xilinx.com:ip:pcie_phy_versal:*\
xilinx.com:ip:util_ds_buf:*\
xilinx.com:ip:gt_quad_base:*\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

##################################################################
# CHECK Block Design Container Sources
##################################################################
set bCheckSources 1
set list_bdc_active "ulp_training"
set list_bdc_dfx "ulp"

array set map_bdc_missing {}
set map_bdc_missing(ACTIVE) ""
set map_bdc_missing(DFX) ""
set map_bdc_missing(BDC) ""

if { $bCheckSources == 1 } {
   set list_check_srcs "\
ulp \
ulp_training \
"

   common::send_gid_msg -ssname BD::TCL -id 2056 -severity "INFO" "Checking if the following sources for block design container exist in the project: $list_check_srcs .\n\n"

   foreach src $list_check_srcs {
      if { [can_resolve_reference $src] == 0 } {
         if { [lsearch $list_bdc_active $src] != -1 } {
            set map_bdc_missing(ACTIVE) "$map_bdc_missing(ACTIVE) $src"
         } elseif { [lsearch $list_bdc_dfx $src] != -1 } {
            set map_bdc_missing(DFX) "$map_bdc_missing(DFX) $src"
         } else {
            set map_bdc_missing(BDC) "$map_bdc_missing(BDC) $src"
         }
      }
   }

   if { [llength $map_bdc_missing(ACTIVE)] > 0 } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2057 -severity "ERROR" "The following source(s) of Active variants are not found in the project: $map_bdc_missing(ACTIVE)" }
      common::send_gid_msg -ssname BD::TCL -id 2060 -severity "INFO" "Please add source files for the missing source(s) above."
      set bCheckIPsPassed 0
   }
   if { [llength $map_bdc_missing(DFX)] > 0 } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2058 -severity "ERROR" "The following source(s) of DFX variants are not found in the project: $map_bdc_missing(DFX)" }
      common::send_gid_msg -ssname BD::TCL -id 2060 -severity "INFO" "Please add source files for the missing source(s) above."
      set bCheckIPsPassed 0
   }
   if { [llength $map_bdc_missing(BDC)] > 0 } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2059 -severity "WARNING" "The following source(s) of variants are not found in the project: $map_bdc_missing(BDC)" }
      common::send_gid_msg -ssname BD::TCL -id 2060 -severity "INFO" "Please add source files for the missing source(s) above."
   }
}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################

# Hierarchical cell: qdma_0_support
proc create_hier_cell_qdma_0_support { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_qdma_0_support() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 pcie_refclk

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 pcie_mgt

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m_axis_cq

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m_axis_rc

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:pcie_cfg_fc_rtl:1.1 pcie_cfg_fc

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:pcie3_cfg_interrupt_rtl:1.0 pcie_cfg_interrupt

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:pcie3_cfg_msg_received_rtl:1.0 pcie_cfg_mesg_rcvd

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:pcie3_cfg_mesg_tx_rtl:1.0 pcie_cfg_mesg_tx

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis_cc

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis_rq

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:pcie5_cfg_control_rtl:1.0 pcie_cfg_control

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:pcie4_cfg_msix_rtl:1.0 pcie_cfg_external_msix_without_msi

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:pcie4_cfg_mgmt_rtl:1.0 pcie_cfg_mgmt

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:pcie5_cfg_status_rtl:1.0 pcie_cfg_status

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:pcie3_transmit_fc_rtl:1.0 pcie_transmit_fc

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:pcie3_cfg_ext_rtl:1.0 pcie_cfg_ext

  # Create pins
  create_bd_pin -dir I -type rst sys_reset
  create_bd_pin -dir O phy_rdy_out
  create_bd_pin -dir O -type clk user_clk
  create_bd_pin -dir O user_lnk_up
  create_bd_pin -dir O -type rst user_reset

  # Create instance: gt_quad_0, and set properties
  set gt_quad_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:gt_quad_base gt_quad_0 ]
  set_property -dict [list \
    CONFIG.PORTS_INFO_DICT {LANE_SEL_DICT {PROT0 {RX0 RX1 RX2 RX3 TX0 TX1 TX2 TX3}} GT_TYPE GTYP REG_CONF_INTF APB3_INTF BOARD_PARAMETER { }} \
    CONFIG.PROT_OUTCLK_VALUES {CH0_RXOUTCLK 250 CH0_TXOUTCLK 500 CH1_RXOUTCLK 250 CH1_TXOUTCLK 500 CH2_RXOUTCLK 250 CH2_TXOUTCLK 500 CH3_RXOUTCLK 250 CH3_TXOUTCLK 500} \
    CONFIG.REFCLK_STRING {HSCLK0_LCPLLGTREFCLK0 refclk_PROT0_R0_100_MHz_unique1 HSCLK0_RPLLGTREFCLK0 refclk_PROT0_R0_100_MHz_unique1 HSCLK1_LCPLLGTREFCLK0 refclk_PROT0_R0_100_MHz_unique1 HSCLK1_RPLLGTREFCLK0\
refclk_PROT0_R0_100_MHz_unique1} \
  ] $gt_quad_0

  # Create instance: pcie, and set properties
  set pcie [ create_bd_cell -type ip -vlnv xilinx.com:ip:pcie_versal pcie ]
  set_property -dict [list \
    CONFIG.mode_selection {Advanced} \
    CONFIG.AXISTEN_IF_CQ_ALIGNMENT_MODE {Address_Aligned} \
    CONFIG.AXISTEN_IF_RQ_ALIGNMENT_MODE {DWORD_Aligned} \
    CONFIG.MSI_X_OPTIONS {MSI-X_External} \
    CONFIG.PF0_AER_CAP_ECRC_GEN_AND_CHECK_CAPABLE {false} \
    CONFIG.PF0_AER_ENABLED {true} \
    CONFIG.PF0_DEVICE_ID {5700} \
    CONFIG.PF0_DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE {false} \
    CONFIG.PF0_INTERRUPT_PIN {INTA} \
    CONFIG.PF0_LINK_STATUS_SLOT_CLOCK_CONFIG {true} \
    CONFIG.PF0_MSIX_CAP_PBA_BIR {BAR_3:2} \
    CONFIG.PF0_MSIX_CAP_PBA_OFFSET {00034000} \
    CONFIG.PF0_MSIX_CAP_TABLE_BIR {BAR_3:2} \
    CONFIG.PF0_MSIX_CAP_TABLE_OFFSET {00030000} \
    CONFIG.PF0_MSIX_CAP_TABLE_SIZE {01F} \
    CONFIG.PF0_PM_CAP_PMESUPPORT_D0 {true} \
    CONFIG.PF0_PM_CAP_PMESUPPORT_D1 {true} \
    CONFIG.PF0_PM_CAP_PMESUPPORT_D3HOT {true} \
    CONFIG.PF0_PM_CAP_SUPP_D1_STATE {true} \
    CONFIG.PF0_REVISION_ID {00} \
    CONFIG.PF0_SRIOV_VF_DEVICE_ID {C038} \
    CONFIG.PF0_SUBSYSTEM_ID {000E} \
    CONFIG.PF0_SUBSYSTEM_VENDOR_ID {10EE} \
    CONFIG.PF0_Use_Class_Code_Lookup_Assistant {false} \
    CONFIG.PF1_DEVICE_ID {5701} \
    CONFIG.PF1_INTERRUPT_PIN {INTA} \
    CONFIG.PF1_MSIX_CAP_PBA_BIR {BAR_1:0} \
    CONFIG.PF1_MSIX_CAP_PBA_OFFSET {00034000} \
    CONFIG.PF1_MSIX_CAP_TABLE_BIR {BAR_1:0} \
    CONFIG.PF1_MSIX_CAP_TABLE_OFFSET {00030000} \
    CONFIG.PF1_MSIX_CAP_TABLE_SIZE {01F} \
    CONFIG.PF1_REVISION_ID {00} \
    CONFIG.PF1_SUBSYSTEM_ID {000E} \
    CONFIG.PF1_SUBSYSTEM_VENDOR_ID {10EE} \
    CONFIG.PF1_Use_Class_Code_Lookup_Assistant {false} \
    CONFIG.PL_LINK_CAP_MAX_LINK_SPEED {8.0_GT/s} \
    CONFIG.PL_LINK_CAP_MAX_LINK_WIDTH {X4} \
    CONFIG.REF_CLK_FREQ {100_MHz} \
    CONFIG.SRIOV_CAP_ENABLE {false} \
    CONFIG.TL_PF_ENABLE_REG {2} \
    CONFIG.acs_ext_cap_enable {true} \
    CONFIG.all_speeds_all_sides {YES} \
    CONFIG.axisten_freq {125} \
    CONFIG.axisten_if_enable_client_tag {true} \
    CONFIG.axisten_if_enable_msg_route {1EFFF} \
    CONFIG.axisten_if_enable_msg_route_override {true} \
    CONFIG.axisten_if_width {256_bit} \
    CONFIG.cfg_ext_if {true} \
    CONFIG.cfg_mgmt_if {true} \
    CONFIG.copy_pf0 {false} \
    CONFIG.dedicate_perst {true} \
    CONFIG.device_port_type {PCI_Express_Endpoint_device} \
    CONFIG.en_dbg_descramble {false} \
    CONFIG.en_ext_clk {FALSE} \
    CONFIG.en_l23_entry {false} \
    CONFIG.en_parity {false} \
    CONFIG.en_transceiver_status_ports {false} \
    CONFIG.enable_auto_rxeq {False} \
    CONFIG.enable_ccix {FALSE} \
    CONFIG.enable_code {0000} \
    CONFIG.enable_dvsec {FALSE} \
    CONFIG.enable_gen4 {true} \
    CONFIG.enable_ibert {false} \
    CONFIG.enable_jtag_dbg {false} \
    CONFIG.enable_more_clk {false} \
    CONFIG.ext_pcie_cfg_space_enabled {true} \
    CONFIG.ext_xvc_vsec_enable {false} \
    CONFIG.extended_tag_field {true} \
    CONFIG.insert_cips {false} \
    CONFIG.lane_order {Bottom} \
    CONFIG.legacy_ext_pcie_cfg_space_enabled {false} \
    CONFIG.mode_selection {Advanced} \
    CONFIG.pcie_blk_locn {X0Y0} \
    CONFIG.pcie_link_debug {false} \
    CONFIG.pcie_link_debug_axi4_st {false} \
    CONFIG.pf0_aer_enabled {true} \
    CONFIG.pf0_ari_enabled {true} \
    CONFIG.pf0_bar0_64bit {true} \
    CONFIG.pf0_bar0_enabled {true} \
    CONFIG.pf0_bar0_prefetchable {true} \
    CONFIG.pf0_bar0_scale {Megabytes} \
    CONFIG.pf0_bar0_size {256} \
    CONFIG.pf0_bar2_64bit {true} \
    CONFIG.pf0_bar2_enabled {true} \
    CONFIG.pf0_bar2_prefetchable {true} \
    CONFIG.pf0_bar2_scale {Kilobytes} \
    CONFIG.pf0_bar2_size {256} \
    CONFIG.pf0_bar2_type {Memory} \
    CONFIG.pf0_bar4_enabled {false} \
    CONFIG.pf0_bar5_enabled {false} \
    CONFIG.pf0_base_class_menu {Memory_controller} \
    CONFIG.pf0_class_code_base {12} \
    CONFIG.pf0_class_code_interface {00} \
    CONFIG.pf0_class_code_sub {00} \
    CONFIG.pf0_dev_cap_max_payload {512_bytes} \
    CONFIG.pf0_dll_feature_cap_enabled {false} \
    CONFIG.pf0_expansion_rom_enabled {false} \
    CONFIG.pf0_margining_cap_enabled {false} \
    CONFIG.pf0_msi_enabled {false} \
    CONFIG.pf0_msix_enabled {true} \
    CONFIG.pf0_pl16_cap_enabled {false} \
    CONFIG.pf0_sub_class_interface_menu {Other_memory_controller} \
    CONFIG.pf0_vc_cap_enabled {false} \
    CONFIG.pf1_bar0_64bit {true} \
    CONFIG.pf1_bar0_enabled {true} \
    CONFIG.pf1_bar0_prefetchable {true} \
    CONFIG.pf1_bar0_scale {Kilobytes} \
    CONFIG.pf1_bar0_size {256} \
    CONFIG.pf1_bar2_64bit {true} \
    CONFIG.pf1_bar2_enabled {true} \
    CONFIG.pf1_bar2_prefetchable {true} \
    CONFIG.pf1_bar2_scale {Megabytes} \
    CONFIG.pf1_bar2_size {128} \
    CONFIG.pf1_bar2_type {Memory} \
    CONFIG.pf1_bar4_enabled {false} \
    CONFIG.pf1_bar5_enabled {false} \
    CONFIG.pf1_base_class_menu {Memory_controller} \
    CONFIG.pf1_class_code_base {12} \
    CONFIG.pf1_class_code_interface {00} \
    CONFIG.pf1_class_code_sub {00} \
    CONFIG.pf1_expansion_rom_enabled {false} \
    CONFIG.pf1_msi_enabled {false} \
    CONFIG.pf1_msix_enabled {true} \
    CONFIG.pf1_sriov_bar5_prefetchable {false} \
    CONFIG.pf1_sub_class_interface_menu {Other_memory_controller} \
    CONFIG.pf1_vendor_id {10EE} \
    CONFIG.pipe_line_stage {2} \
    CONFIG.pipe_sim {false} \
    CONFIG.replace_uram_with_bram {false} \
    CONFIG.sys_reset_polarity {ACTIVE_LOW} \
    CONFIG.userclk2_freq {125} \
    CONFIG.vendor_id {10EE} \
    CONFIG.vfg0_msix_enabled {false} \
    CONFIG.vfg1_msix_enabled {false} \
    CONFIG.warm_reboot_sbr_fix {false} \
    CONFIG.xlnx_ref_board {emb-plus-vpr-4616} \
  ] $pcie

  # Create instance: pcie_phy, and set properties
  set pcie_phy [ create_bd_cell -type ip -vlnv xilinx.com:ip:pcie_phy_versal pcie_phy ]
  set_property -dict [list \
    CONFIG.PL_LINK_CAP_MAX_LINK_SPEED {8.0_GT/s} \
    CONFIG.PL_LINK_CAP_MAX_LINK_WIDTH {X4} \
    CONFIG.aspm {No_ASPM} \
    CONFIG.async_mode {SRNS} \
    CONFIG.disable_double_pipe {YES} \
    CONFIG.en_gt_pclk {false} \
    CONFIG.ins_loss_profile {Add-in_Card} \
    CONFIG.lane_order {Bottom} \
    CONFIG.lane_reversal {false} \
    CONFIG.phy_async_en {true} \
    CONFIG.phy_coreclk_freq {500_MHz} \
    CONFIG.phy_refclk_freq {100_MHz} \
    CONFIG.phy_userclk2_freq {125_MHz} \
    CONFIG.phy_userclk_freq {125_MHz} \
    CONFIG.pipeline_stages {2} \
    CONFIG.sim_model {NO} \
    CONFIG.tx_preset {4} \
  ] $pcie_phy


  # Create instance: const_1b1, and set properties
  set const_1b1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant const_1b1 ]
  set_property -dict [list \
    CONFIG.CONST_VAL {1} \
    CONFIG.CONST_WIDTH {1} \
  ] $const_1b1


  # Create instance: bufg_gt_sysclk, and set properties
  set bufg_gt_sysclk [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf bufg_gt_sysclk ]
  set_property -dict [list \
    CONFIG.C_BUFG_GT_SYNC {true} \
    CONFIG.C_BUF_TYPE {BUFG_GT} \
  ] $bufg_gt_sysclk


  # Create instance: refclk_ibuf, and set properties
  set refclk_ibuf [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf refclk_ibuf ]
  set_property CONFIG.C_BUF_TYPE {IBUFDSGTE} $refclk_ibuf


  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins refclk_ibuf/CLK_IN_D] [get_bd_intf_pins pcie_refclk]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins pcie_phy/pcie_mgt] [get_bd_intf_pins pcie_mgt]
  connect_bd_intf_net -intf_net Conn3 [get_bd_intf_pins pcie/m_axis_cq] [get_bd_intf_pins m_axis_cq]
  connect_bd_intf_net -intf_net Conn4 [get_bd_intf_pins pcie/m_axis_rc] [get_bd_intf_pins m_axis_rc]
  connect_bd_intf_net -intf_net Conn5 [get_bd_intf_pins pcie/pcie_cfg_fc] [get_bd_intf_pins pcie_cfg_fc]
  connect_bd_intf_net -intf_net Conn6 [get_bd_intf_pins pcie/pcie_cfg_interrupt] [get_bd_intf_pins pcie_cfg_interrupt]
  connect_bd_intf_net -intf_net Conn7 [get_bd_intf_pins pcie/pcie_cfg_mesg_rcvd] [get_bd_intf_pins pcie_cfg_mesg_rcvd]
  connect_bd_intf_net -intf_net Conn8 [get_bd_intf_pins pcie/pcie_cfg_mesg_tx] [get_bd_intf_pins pcie_cfg_mesg_tx]
  connect_bd_intf_net -intf_net Conn9 [get_bd_intf_pins pcie/s_axis_cc] [get_bd_intf_pins s_axis_cc]
  connect_bd_intf_net -intf_net Conn10 [get_bd_intf_pins pcie/s_axis_rq] [get_bd_intf_pins s_axis_rq]
  connect_bd_intf_net -intf_net Conn11 [get_bd_intf_pins pcie/pcie_cfg_control] [get_bd_intf_pins pcie_cfg_control]
  connect_bd_intf_net -intf_net Conn12 [get_bd_intf_pins pcie/pcie_cfg_external_msix_without_msi] [get_bd_intf_pins pcie_cfg_external_msix_without_msi]
  connect_bd_intf_net -intf_net Conn13 [get_bd_intf_pins pcie/pcie_cfg_mgmt] [get_bd_intf_pins pcie_cfg_mgmt]
  connect_bd_intf_net -intf_net Conn14 [get_bd_intf_pins pcie/pcie_cfg_status] [get_bd_intf_pins pcie_cfg_status]
  connect_bd_intf_net -intf_net Conn15 [get_bd_intf_pins pcie/pcie_transmit_fc] [get_bd_intf_pins pcie_transmit_fc]
  connect_bd_intf_net -intf_net gt_quad_0_GT0_BUFGT [get_bd_intf_pins pcie_phy/GT_BUFGT] [get_bd_intf_pins gt_quad_0/GT0_BUFGT]
  connect_bd_intf_net -intf_net gt_quad_0_GT_Serial [get_bd_intf_pins pcie_phy/GT0_Serial] [get_bd_intf_pins gt_quad_0/GT_Serial]
  connect_bd_intf_net -intf_net pcie_phy_GT_RX0 [get_bd_intf_pins pcie_phy/GT_RX0] [get_bd_intf_pins gt_quad_0/RX0_GT_IP_Interface]
  connect_bd_intf_net -intf_net pcie_phy_GT_RX1 [get_bd_intf_pins pcie_phy/GT_RX1] [get_bd_intf_pins gt_quad_0/RX1_GT_IP_Interface]
  connect_bd_intf_net -intf_net pcie_phy_GT_RX2 [get_bd_intf_pins pcie_phy/GT_RX2] [get_bd_intf_pins gt_quad_0/RX2_GT_IP_Interface]
  connect_bd_intf_net -intf_net pcie_phy_GT_RX3 [get_bd_intf_pins pcie_phy/GT_RX3] [get_bd_intf_pins gt_quad_0/RX3_GT_IP_Interface]
  connect_bd_intf_net -intf_net pcie_phy_GT_TX0 [get_bd_intf_pins pcie_phy/GT_TX0] [get_bd_intf_pins gt_quad_0/TX0_GT_IP_Interface]
  connect_bd_intf_net -intf_net pcie_phy_GT_TX1 [get_bd_intf_pins pcie_phy/GT_TX1] [get_bd_intf_pins gt_quad_0/TX1_GT_IP_Interface]
  connect_bd_intf_net -intf_net pcie_phy_GT_TX2 [get_bd_intf_pins pcie_phy/GT_TX2] [get_bd_intf_pins gt_quad_0/TX2_GT_IP_Interface]
  connect_bd_intf_net -intf_net pcie_phy_GT_TX3 [get_bd_intf_pins pcie_phy/GT_TX3] [get_bd_intf_pins gt_quad_0/TX3_GT_IP_Interface]
  connect_bd_intf_net -intf_net pcie_phy_gt_rxmargin_q0 [get_bd_intf_pins pcie_phy/gt_rxmargin_q0] [get_bd_intf_pins gt_quad_0/gt_rxmargin_intf]
  connect_bd_intf_net -intf_net pcie_phy_mac_rx [get_bd_intf_pins pcie_phy/phy_mac_rx] [get_bd_intf_pins pcie/phy_mac_rx]
  connect_bd_intf_net -intf_net pcie_phy_mac_tx [get_bd_intf_pins pcie_phy/phy_mac_tx] [get_bd_intf_pins pcie/phy_mac_tx]
  connect_bd_intf_net -intf_net pcie_phy_phy_mac_command [get_bd_intf_pins pcie_phy/phy_mac_command] [get_bd_intf_pins pcie/phy_mac_command]
  connect_bd_intf_net -intf_net pcie_phy_phy_mac_rx_margining [get_bd_intf_pins pcie_phy/phy_mac_rx_margining] [get_bd_intf_pins pcie/phy_mac_rx_margining]
  connect_bd_intf_net -intf_net pcie_phy_phy_mac_status [get_bd_intf_pins pcie_phy/phy_mac_status] [get_bd_intf_pins pcie/phy_mac_status]
  connect_bd_intf_net -intf_net pcie_phy_phy_mac_tx_drive [get_bd_intf_pins pcie_phy/phy_mac_tx_drive] [get_bd_intf_pins pcie/phy_mac_tx_drive]
  connect_bd_intf_net -intf_net pcie_phy_phy_mac_tx_eq [get_bd_intf_pins pcie_phy/phy_mac_tx_eq] [get_bd_intf_pins pcie/phy_mac_tx_eq]
  connect_bd_intf_net -intf_net pcie_cfg_ext [get_bd_intf_pins pcie/pcie_cfg_ext] [get_bd_intf_pins pcie_cfg_ext]

  # Create port connections
  connect_bd_net -net bufg_gt_sysclk_BUFG_GT_O [get_bd_pins bufg_gt_sysclk/BUFG_GT_O] [get_bd_pins pcie_phy/phy_refclk]
  connect_bd_net -net bufg_gt_sysclk_BUFG_GT_O [get_bd_pins bufg_gt_sysclk/BUFG_GT_O] [get_bd_pins gt_quad_0/apb3clk]
  connect_bd_net -net bufg_gt_sysclk_BUFG_GT_O [get_bd_pins bufg_gt_sysclk/BUFG_GT_O] [get_bd_pins pcie/sys_clk]
  connect_bd_net -net const_1b1_dout [get_bd_pins const_1b1/dout] [get_bd_pins bufg_gt_sysclk/BUFG_GT_CE]
  connect_bd_net -net gt_quad_0_ch0_phyready [get_bd_pins gt_quad_0/ch0_phyready] [get_bd_pins pcie_phy/ch0_phyready]
  connect_bd_net -net gt_quad_0_ch0_phystatus [get_bd_pins gt_quad_0/ch0_phystatus] [get_bd_pins pcie_phy/ch0_phystatus]
  connect_bd_net -net gt_quad_0_ch0_rxoutclk [get_bd_pins gt_quad_0/ch0_rxoutclk] [get_bd_pins pcie_phy/gt_rxoutclk]
  connect_bd_net -net gt_quad_0_ch0_txoutclk [get_bd_pins gt_quad_0/ch0_txoutclk] [get_bd_pins pcie_phy/gt_txoutclk]
  connect_bd_net -net gt_quad_0_ch1_phyready [get_bd_pins gt_quad_0/ch1_phyready] [get_bd_pins pcie_phy/ch1_phyready]
  connect_bd_net -net gt_quad_0_ch1_phystatus [get_bd_pins gt_quad_0/ch1_phystatus] [get_bd_pins pcie_phy/ch1_phystatus]
  connect_bd_net -net gt_quad_0_ch2_phyready [get_bd_pins gt_quad_0/ch2_phyready] [get_bd_pins pcie_phy/ch2_phyready]
  connect_bd_net -net gt_quad_0_ch2_phystatus [get_bd_pins gt_quad_0/ch2_phystatus] [get_bd_pins pcie_phy/ch2_phystatus]
  connect_bd_net -net gt_quad_0_ch3_phyready [get_bd_pins gt_quad_0/ch3_phyready] [get_bd_pins pcie_phy/ch3_phyready]
  connect_bd_net -net gt_quad_0_ch3_phystatus [get_bd_pins gt_quad_0/ch3_phystatus] [get_bd_pins pcie_phy/ch3_phystatus]
  connect_bd_net -net pcie_pcie_ltssm_state [get_bd_pins pcie/pcie_ltssm_state] [get_bd_pins pcie_phy/pcie_ltssm_state]
  connect_bd_net -net pcie_phy_gt_pcieltssm [get_bd_pins pcie_phy/gt_pcieltssm] [get_bd_pins gt_quad_0/pcieltssm]
  connect_bd_net -net pcie_phy_gtrefclk [get_bd_pins pcie_phy/gtrefclk] [get_bd_pins gt_quad_0/GT_REFCLK0]
  connect_bd_net -net pcie_phy_pcierstb [get_bd_pins pcie_phy/pcierstb] [get_bd_pins gt_quad_0/ch0_pcierstb]
  connect_bd_net -net pcie_phy_pcierstb [get_bd_pins pcie_phy/pcierstb] [get_bd_pins gt_quad_0/ch1_pcierstb]
  connect_bd_net -net pcie_phy_pcierstb [get_bd_pins pcie_phy/pcierstb] [get_bd_pins gt_quad_0/ch2_pcierstb]
  connect_bd_net -net pcie_phy_pcierstb [get_bd_pins pcie_phy/pcierstb] [get_bd_pins gt_quad_0/ch3_pcierstb]
  connect_bd_net -net pcie_phy_phy_coreclk [get_bd_pins pcie_phy/phy_coreclk] [get_bd_pins pcie/phy_coreclk]
  connect_bd_net -net pcie_phy_phy_mcapclk [get_bd_pins pcie_phy/phy_mcapclk] [get_bd_pins pcie/phy_mcapclk]
  connect_bd_net -net pcie_phy_phy_pclk [get_bd_pins pcie_phy/phy_pclk] [get_bd_pins pcie/phy_pclk]
  connect_bd_net -net pcie_phy_phy_pclk [get_bd_pins pcie_phy/phy_pclk] [get_bd_pins gt_quad_0/ch0_txusrclk]
  connect_bd_net -net pcie_phy_phy_pclk [get_bd_pins pcie_phy/phy_pclk] [get_bd_pins gt_quad_0/ch1_txusrclk]
  connect_bd_net -net pcie_phy_phy_pclk [get_bd_pins pcie_phy/phy_pclk] [get_bd_pins gt_quad_0/ch2_txusrclk]
  connect_bd_net -net pcie_phy_phy_pclk [get_bd_pins pcie_phy/phy_pclk] [get_bd_pins gt_quad_0/ch3_txusrclk]
  connect_bd_net -net pcie_phy_phy_pclk [get_bd_pins pcie_phy/phy_pclk] [get_bd_pins gt_quad_0/ch0_rxusrclk]
  connect_bd_net -net pcie_phy_phy_pclk [get_bd_pins pcie_phy/phy_pclk] [get_bd_pins gt_quad_0/ch1_rxusrclk]
  connect_bd_net -net pcie_phy_phy_pclk [get_bd_pins pcie_phy/phy_pclk] [get_bd_pins gt_quad_0/ch2_rxusrclk]
  connect_bd_net -net pcie_phy_phy_pclk [get_bd_pins pcie_phy/phy_pclk] [get_bd_pins gt_quad_0/ch3_rxusrclk]
  connect_bd_net -net pcie_phy_phy_userclk [get_bd_pins pcie_phy/phy_userclk] [get_bd_pins pcie/phy_userclk]
  connect_bd_net -net pcie_phy_phy_userclk2 [get_bd_pins pcie_phy/phy_userclk2] [get_bd_pins pcie/phy_userclk2]
  connect_bd_net -net pcie_phy_rdy_out [get_bd_pins pcie/phy_rdy_out] [get_bd_pins phy_rdy_out]
  connect_bd_net -net pcie_user_clk [get_bd_pins pcie/user_clk] [get_bd_pins user_clk]
  connect_bd_net -net pcie_user_lnk_up [get_bd_pins pcie/user_lnk_up] [get_bd_pins user_lnk_up]
  connect_bd_net -net pcie_user_reset [get_bd_pins pcie/user_reset] [get_bd_pins user_reset]
  connect_bd_net -net refclk_ibuf_IBUF_DS_ODIV2 [get_bd_pins refclk_ibuf/IBUF_DS_ODIV2] [get_bd_pins bufg_gt_sysclk/BUFG_GT_I]
  connect_bd_net -net refclk_ibuf_IBUF_OUT [get_bd_pins refclk_ibuf/IBUF_OUT] [get_bd_pins pcie_phy/phy_gtrefclk]
  connect_bd_net -net refclk_ibuf_IBUF_OUT [get_bd_pins refclk_ibuf/IBUF_OUT] [get_bd_pins pcie/sys_clk_gt]
  connect_bd_net -net sys_reset_1 [get_bd_pins sys_reset] [get_bd_pins pcie_phy/phy_rst_n]
  connect_bd_net -net sys_reset_1 [get_bd_pins sys_reset] [get_bd_pins pcie/sys_reset]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Hierarchical cell: ert_support
proc create_hier_cell_ert_support { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_ert_support() - Empty argument(s)!"}
     return
 }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
 }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
 }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_cu_done_intc0


  # Create pins
  create_bd_pin -dir I -type clk clk_pl_axi
  create_bd_pin -dir O irq_cu_completion
  create_bd_pin -dir I -from 31 -to 0 -type intr kernel_interupts_stc
  create_bd_pin -dir I -type rst resetn_pl_axi

  # Create instance: axi_intc_0_31, and set properties
  set axi_intc_0_31 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_intc axi_intc_0_31 ]
  set_property -dict [ list \
   CONFIG.C_IRQ_CONNECTION {1} \
   CONFIG.C_KIND_OF_INTR.VALUE_SRC {USER} \
   CONFIG.C_KIND_OF_INTR {0x00000001} \
   CONFIG.C_IRQ_IS_LEVEL {0} \
 ] $axi_intc_0_31

  # Create instance: slice_0_15, and set properties
  set slice_0_15 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice slice_0_15 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {15} \
   CONFIG.DIN_TO {0} \
   CONFIG.DIN_WIDTH {32} \
   CONFIG.DOUT_WIDTH {16} \
 ] $slice_0_15

  # Create instance: slice_16_31, and set properties
  set slice_16_31 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice slice_16_31 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {31} \
   CONFIG.DIN_TO {16} \
   CONFIG.DIN_WIDTH {32} \
   CONFIG.DOUT_WIDTH {16} \
 ] $slice_16_31

  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat xlconcat_0 ]

  # Create interface connections
  connect_bd_intf_net -intf_net s_axi_cu_done_intc0_1 [get_bd_intf_pins s_axi_cu_done_intc0] [get_bd_intf_pins axi_intc_0_31/s_axi]

  # Create port connections
  connect_bd_net -net axi_intc_0_31_irq [get_bd_pins axi_intc_0_31/irq] [get_bd_pins irq_cu_completion]
  connect_bd_net -net clk_pl_axi_net [get_bd_pins clk_pl_axi] [get_bd_pins axi_intc_0_31/s_axi_aclk]
  connect_bd_net -net kernel_interupts_stc_1 [get_bd_pins kernel_interupts_stc] [get_bd_pins slice_0_15/Din]
  connect_bd_net -net kernel_interupts_stc_1 [get_bd_pins kernel_interupts_stc] [get_bd_pins slice_16_31/Din]
  connect_bd_net -net resetn_pl_axi_net [get_bd_pins resetn_pl_axi] [get_bd_pins axi_intc_0_31/s_axi_aresetn]
  connect_bd_net -net slice_0_15_Dout [get_bd_pins slice_0_15/Dout] [get_bd_pins xlconcat_0/In0]
  connect_bd_net -net slice_16_31_Dout [get_bd_pins slice_16_31/Dout] [get_bd_pins xlconcat_0/In1]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins xlconcat_0/dout] [get_bd_pins axi_intc_0_31/intr]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: base_clocking
proc create_hier_cell_base_clocking { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_base_clocking() - Empty argument(s)!"}
     return
 }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
 }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
 }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_pr_reset_cntl
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_swctrl_reset_cntl

  # Create pins
  create_bd_pin -dir I -type clk clk_pcie
  create_bd_pin -dir I -type clk clk_pl_axi
  create_bd_pin -dir I -type clk clk_pl_pcie
  create_bd_pin -dir I -type clk clk_freerun
  create_bd_pin -dir I -type rst resetn_pcie
  create_bd_pin -dir O -from 0 -to 0 -type rst resetn_pcie_sync
  create_bd_pin -dir I -type rst resetn_pl_axi
  create_bd_pin -dir O -from 0 -to 0 -type rst resetn_pl_axi_sync
  create_bd_pin -dir O -from 0 -to 0 -type rst resetn_pl_pcie_pr
  create_bd_pin -dir O -from 0 -to 0 -type rst resetn_pr
  create_bd_pin -dir O -from 0 -to 0 -type rst resetn_pl_freerun
  create_bd_pin -dir O force_reset_enable
  create_bd_pin -dir I force_reset_result

  create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio -set_params [ list \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_DOUT_DEFAULT {0x0} \
    CONFIG.C_GPIO_WIDTH {1} \
    CONFIG.C_IS_DUAL {1} \
    CONFIG.C_ALL_INPUTS_2 {1} \
    CONFIG.C_GPIO2_WIDTH {1} \
    ] force_reset_gpio

  # Create instance: pcie_reset_sync, and set properties
  set pcie_reset_sync [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset pcie_reset_sync ]
  set_property -dict [ list \
   CONFIG.C_AUX_RST_WIDTH {1} \
   CONFIG.C_EXT_RST_WIDTH {1} \
 ] $pcie_reset_sync

  # Create instance: pl_pcie_reset_gpio_sync, and set properties
  set pl_pcie_reset_gpio_sync [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset pl_pcie_reset_gpio_sync ]
  set_property -dict [ list \
   CONFIG.C_AUX_RST_WIDTH {1} \
   CONFIG.C_EXT_RST_WIDTH {1} \
 ] $pl_pcie_reset_gpio_sync

  # Create instance: pl_reset_sync, and set properties
  set pl_reset_sync [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset pl_reset_sync ]
  set_property -dict [ list \
   CONFIG.C_AUX_RST_WIDTH {1} \
   CONFIG.C_EXT_RST_WIDTH {1} \
 ] $pl_reset_sync

  # Create instance: pl_reset_freerun_sync, and set properties
  set pl_reset_freerun_sync [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset pl_reset_freerun_sync ]
  set_property -dict [ list \
   CONFIG.C_AUX_RST_WIDTH {1} \
   CONFIG.C_EXT_RST_WIDTH {1} \
 ] $pl_reset_freerun_sync

  # Create instance: pr_or_reset, and set properties
  set pr_or_reset [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_reduced_logic pr_or_reset ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {or} \
   CONFIG.C_SIZE {2} \
   CONFIG.LOGO_FILE {data/sym_orgate.png} \
 ] $pr_or_reset

  # Create instance: pr_reset_gpio, and set properties
  set pr_reset_gpio [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio pr_reset_gpio ]
  set_property -dict [ list \
   CONFIG.C_ALL_INPUTS_2 {1} \
   CONFIG.C_ALL_OUTPUTS {1} \
   CONFIG.C_DOUT_DEFAULT {0x00000000} \
   CONFIG.C_GPIO2_WIDTH {2} \
   CONFIG.C_GPIO_WIDTH {2} \
   CONFIG.C_IS_DUAL {1} \
 ] $pr_reset_gpio

  # Create instance: pr_reset_gpio_sync, and set properties
  set pr_reset_gpio_sync [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset pr_reset_gpio_sync ]
  set_property -dict [ list \
   CONFIG.C_AUX_RST_WIDTH {1} \
   CONFIG.C_EXT_RST_WIDTH {1} \
 ] $pr_reset_gpio_sync

  # Create interface connections
  connect_bd_intf_net -intf_net s_axi_pr_reset_cntl_1 [get_bd_intf_pins s_axi_pr_reset_cntl] [get_bd_intf_pins pr_reset_gpio/S_AXI]
  connect_bd_intf_net -intf_net s_axi_swctrl_reset_cntl_1 [get_bd_intf_pins s_axi_swctrl_reset_cntl] [get_bd_intf_pins force_reset_gpio/S_AXI]

  # Create port connections
  connect_bd_net -net clk_freerun_net [get_bd_pins clk_freerun] [get_bd_pins pl_reset_freerun_sync/slowest_sync_clk]
  connect_bd_net -net clk_pcie_net [get_bd_pins clk_pcie] [get_bd_pins pcie_reset_sync/slowest_sync_clk]
  connect_bd_net -net clk_pl_axi_net [get_bd_pins clk_pl_axi] [get_bd_pins pl_reset_sync/slowest_sync_clk]
  connect_bd_net -net clk_pl_axi_net [get_bd_pins clk_pl_axi] [get_bd_pins pr_reset_gpio/s_axi_aclk]
  connect_bd_net -net clk_pl_axi_net [get_bd_pins clk_pl_axi] [get_bd_pins pr_reset_gpio_sync/slowest_sync_clk]
  connect_bd_net -net clk_pl_axi_net [get_bd_pins clk_pl_axi] [get_bd_pins force_reset_gpio/s_axi_aclk]
  connect_bd_net -net clk_pl_pcie_net [get_bd_pins clk_pl_pcie] [get_bd_pins pl_pcie_reset_gpio_sync/slowest_sync_clk]
  connect_bd_net -net force_reset_gpio_gpio_io_o [get_bd_pins force_reset_gpio/gpio_io_o] [get_bd_pins force_reset_enable]
  connect_bd_net -net force_reset_result_1 [get_bd_pins force_reset_result] [get_bd_pins force_reset_gpio/gpio2_io_i]
  connect_bd_net -net pcie_reset_sync_interconnect_aresetn [get_bd_pins pcie_reset_sync/interconnect_aresetn] [get_bd_pins resetn_pcie_sync]
  connect_bd_net -net pl_pcie_reset_gpio_sync_interconnect_aresetn [get_bd_pins pl_pcie_reset_gpio_sync/interconnect_aresetn] [get_bd_pins resetn_pl_pcie_pr]
  connect_bd_net -net pl_reset_freerun_sync_interconnect_aresetn [get_bd_pins pl_reset_freerun_sync/interconnect_aresetn] [get_bd_pins resetn_pl_freerun]
  connect_bd_net -net pl_reset_sync_interconnect_aresetn [get_bd_pins pl_reset_sync/interconnect_aresetn] [get_bd_pins resetn_pl_axi_sync]
  connect_bd_net -net pl_reset_sync_interconnect_aresetn [get_bd_pins pl_reset_sync/interconnect_aresetn] [get_bd_pins pl_pcie_reset_gpio_sync/ext_reset_in]
  connect_bd_net -net pl_reset_sync_interconnect_aresetn [get_bd_pins pl_reset_sync/interconnect_aresetn] [get_bd_pins pr_reset_gpio/s_axi_aresetn]
  connect_bd_net -net pl_reset_sync_interconnect_aresetn [get_bd_pins pl_reset_sync/interconnect_aresetn] [get_bd_pins pr_reset_gpio_sync/ext_reset_in]
  connect_bd_net -net pl_reset_sync_interconnect_aresetn [get_bd_pins pl_reset_sync/interconnect_aresetn] [get_bd_pins force_reset_gpio/s_axi_aresetn]
  connect_bd_net -net pr_or_reset_Res [get_bd_pins pr_or_reset/Res] [get_bd_pins pl_pcie_reset_gpio_sync/aux_reset_in]
  connect_bd_net -net pr_or_reset_Res [get_bd_pins pr_or_reset/Res] [get_bd_pins pr_reset_gpio_sync/aux_reset_in]
  connect_bd_net -net pr_reset_gpio_gpio_io_o [get_bd_pins pr_reset_gpio/gpio_io_o] [get_bd_pins pr_or_reset/Op1]
  connect_bd_net -net pr_reset_gpio_gpio_io_o [get_bd_pins pr_reset_gpio/gpio_io_o] [get_bd_pins pr_reset_gpio/gpio2_io_i]
  connect_bd_net -net pr_reset_gpio_sync_interconnect_aresetn [get_bd_pins pr_reset_gpio_sync/interconnect_aresetn] [get_bd_pins resetn_pr]
  connect_bd_net -net resetn_pcie_1 [get_bd_pins resetn_pcie] [get_bd_pins pcie_reset_sync/ext_reset_in]
  connect_bd_net -net resetn_pl_axi_1 [get_bd_pins resetn_pl_axi] [get_bd_pins pl_reset_sync/ext_reset_in]
  connect_bd_net -net resetn_pl_axi_1 [get_bd_pins resetn_pl_axi] [get_bd_pins pl_reset_freerun_sync/ext_reset_in]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: dfx_decoupling
proc create_hier_cell_dfx_decoupling { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_dfx_decoupling() - Empty argument(s)!"}
     return
 }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
 }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
 }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 BLP_S_AXI_CTRL_USER_00
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 ULP_M_AXI_CTRL_USER_00

  # Create pins
  create_bd_pin -dir O -from 32 -to 0 -type intr blp_m_irq_kernel_00
  create_bd_pin -dir O -from 0 -to 0 -type intr blp_m_dbg_hub_fw_00
  create_bd_pin -dir I -type clk blp_s_aclk_ctrl_00
  create_bd_pin -dir I -type clk clk_pl_pcie
  create_bd_pin -dir I -from 0 -to 0 -type rst blp_s_aresetn_pcie_reset_00
  create_bd_pin -dir I -from 0 -to 0 -type rst blp_s_aresetn_pr_reset_00
  create_bd_pin -dir O -from 0 -to 0 -type rst ulp_m_aresetn_pcie_reset_00
  create_bd_pin -dir O -from 0 -to 0 -type rst ulp_m_aresetn_pr_reset_00
  create_bd_pin -dir I -from 32 -to 0 -type intr ulp_s_irq_kernel_00
  create_bd_pin -dir I -type intr ulp_s_dbg_hub_fw_00
  create_bd_pin -dir I -type clk blp_s_aclk_ext_tog_kernel_00
  create_bd_pin -dir I -type clk blp_s_aclk_ext_tog_kernel_01
  create_bd_pin -dir I -from 0 -to 0 -type rst blp_s_aresetn_ext_tog_kernel_00
  create_bd_pin -dir I -from 0 -to 0 -type rst blp_s_aresetn_ext_tog_kernel_01
  create_bd_pin -dir I -from 0 -to 0 blp_s_ext_tog_ctrl_kernel_00_out
  create_bd_pin -dir I -from 0 -to 0 blp_s_ext_tog_ctrl_kernel_01_out
  create_bd_pin -dir O -from 0 -to 0 ulp_m_ext_tog_ctrl_kernel_00_out
  create_bd_pin -dir O -from 0 -to 0 ulp_m_ext_tog_ctrl_kernel_01_out
  create_bd_pin -dir I -from 0 -to 0 ulp_s_ext_tog_ctrl_kernel_00_in
  create_bd_pin -dir I -from 0 -to 0 ulp_s_ext_tog_ctrl_kernel_01_in
  create_bd_pin -dir O -from 0 -to 0 blp_m_ext_tog_ctrl_kernel_00_in
  create_bd_pin -dir O -from 0 -to 0 blp_m_ext_tog_ctrl_kernel_01_in
  create_bd_pin -dir I -from 0 -to 0 ulp_s_ext_tog_ctrl_kernel_00_enable
  create_bd_pin -dir I -from 0 -to 0 ulp_s_ext_tog_ctrl_kernel_01_enable
  create_bd_pin -dir O -from 0 -to 0 blp_m_ext_tog_ctrl_kernel_00_enable
  create_bd_pin -dir O -from 0 -to 0 blp_m_ext_tog_ctrl_kernel_01_enable

  save_bd_design

  # Create instance: ip_aresetn_pcie_reset_00, and set properties
  set ip_aresetn_pcie_reset_00 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ff ip_aresetn_pcie_reset_00 ]
  set_property -dict [ list \
   CONFIG.C_R_INVERTED {0} \
 ] $ip_aresetn_pcie_reset_00

  # Create instance: ip_aresetn_pr_reset_00, and set properties
  set ip_aresetn_pr_reset_00 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ff ip_aresetn_pr_reset_00 ]
  set_property -dict [ list \
   CONFIG.C_R_INVERTED {0} \
 ] $ip_aresetn_pr_reset_00

  # Create instance: ip_aresetn_ext_tog_kernel_00, and set properties
  set ip_aresetn_ext_tog_kernel_00 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ff ip_aresetn_ext_tog_kernel_00 ]
  set_property -dict [ list \
   CONFIG.C_R_INVERTED {0} \
 ] $ip_aresetn_ext_tog_kernel_00

  # Create instance: ip_aresetn_ext_tog_kernel_01, and set properties
  set ip_aresetn_ext_tog_kernel_01 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ff ip_aresetn_ext_tog_kernel_01 ]
  set_property -dict [ list \
   CONFIG.C_R_INVERTED {0} \
 ] $ip_aresetn_ext_tog_kernel_01

  # Create instance: ip_ext_tog_ctrl_kernel_00_out, and set properties
  set ip_ext_tog_ctrl_kernel_00_out [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ff ip_ext_tog_ctrl_kernel_00_out ]

  # Create instance: ip_ext_tog_ctrl_kernel_01_out, and set properties
  set ip_ext_tog_ctrl_kernel_01_out [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ff ip_ext_tog_ctrl_kernel_01_out ]

  # Create instance: ip_ext_tog_ctrl_kernel_00_in, and set properties
  set ip_ext_tog_ctrl_kernel_00_in [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ff ip_ext_tog_ctrl_kernel_00_in ]

  # Create instance: ip_ext_tog_ctrl_kernel_01_in, and set properties
  set ip_ext_tog_ctrl_kernel_01_in [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ff ip_ext_tog_ctrl_kernel_01_in ]

  # Create instance: ip_ext_tog_ctrl_kernel_00_enable, and set properties
  set ip_ext_tog_ctrl_kernel_00_enable [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ff ip_ext_tog_ctrl_kernel_00_enable ]

  # Create instance: ip_ext_tog_ctrl_kernel_01_enable, and set properties
  set ip_ext_tog_ctrl_kernel_01_enable [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ff ip_ext_tog_ctrl_kernel_01_enable ]

  # Create instance: ip_irq_kernel_00, and set properties
  set ip_irq_kernel_00 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ff ip_irq_kernel_00 ]

  # Create instance: ip_irq_dbg_fw_00, and set properties
  set ip_irq_dbg_fw_00 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ff ip_irq_dbg_fw_00 ]

  # Create instance: s_ip_axi_ctrl_user_00, and set properties
  set s_ip_axi_ctrl_user_00 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_register_slice s_ip_axi_ctrl_user_00 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {64} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {0} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {1} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.MAX_BURST_LENGTH {1} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PROTOCOL {AXI4LITE} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.SUPPORTS_NARROW_BURST {0} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
 ] $s_ip_axi_ctrl_user_00

  # Create interface connections
  connect_bd_intf_net -intf_net BLP_S_AXI_CTRL_USER_00_1 [get_bd_intf_pins BLP_S_AXI_CTRL_USER_00] [get_bd_intf_pins s_ip_axi_ctrl_user_00/S_AXI]
  connect_bd_intf_net -intf_net s_ip_axi_ctrl_user_00_M_AXI [get_bd_intf_pins ULP_M_AXI_CTRL_USER_00] [get_bd_intf_pins s_ip_axi_ctrl_user_00/M_AXI]

  # Create port connections
  connect_bd_net -net blp_s_aclk_ctrl_00_1 [get_bd_pins blp_s_aclk_ctrl_00] [get_bd_pins ip_aresetn_pr_reset_00/clk]
  connect_bd_net -net blp_s_aclk_ctrl_00_1 [get_bd_pins blp_s_aclk_ctrl_00] [get_bd_pins ip_irq_kernel_00/clk]
  connect_bd_net -net blp_s_aclk_ctrl_00_1 [get_bd_pins blp_s_aclk_ctrl_00] [get_bd_pins s_ip_axi_ctrl_user_00/aclk]
  connect_bd_net -net blp_s_aclk_ext_tog_kernel_00_net [get_bd_pins blp_s_aclk_ext_tog_kernel_00] [get_bd_pins ip_aresetn_ext_tog_kernel_00/clk]
  connect_bd_net -net blp_s_aclk_ext_tog_kernel_00_net [get_bd_pins blp_s_aclk_ext_tog_kernel_00] [get_bd_pins ip_ext_tog_ctrl_kernel_00_out/clk]
  connect_bd_net -net blp_s_aclk_ext_tog_kernel_00_net [get_bd_pins blp_s_aclk_ext_tog_kernel_00] [get_bd_pins ip_ext_tog_ctrl_kernel_00_in/clk]
  connect_bd_net -net blp_s_aclk_ext_tog_kernel_00_net [get_bd_pins blp_s_aclk_ext_tog_kernel_00] [get_bd_pins ip_ext_tog_ctrl_kernel_00_enable/clk]
  connect_bd_net -net blp_s_aclk_ext_tog_kernel_01_net [get_bd_pins blp_s_aclk_ext_tog_kernel_01] [get_bd_pins ip_aresetn_ext_tog_kernel_01/clk]
  connect_bd_net -net blp_s_aclk_ext_tog_kernel_01_net [get_bd_pins blp_s_aclk_ext_tog_kernel_01] [get_bd_pins ip_ext_tog_ctrl_kernel_01_out/clk]
  connect_bd_net -net blp_s_aclk_ext_tog_kernel_01_net [get_bd_pins blp_s_aclk_ext_tog_kernel_01] [get_bd_pins ip_ext_tog_ctrl_kernel_01_in/clk]
  connect_bd_net -net blp_s_aclk_ext_tog_kernel_01_net [get_bd_pins blp_s_aclk_ext_tog_kernel_01] [get_bd_pins ip_ext_tog_ctrl_kernel_01_enable/clk]
  connect_bd_net -net blp_s_aclk_pcie_00_1 [get_bd_pins clk_pl_pcie] [get_bd_pins ip_aresetn_pcie_reset_00/clk]
  connect_bd_net -net blp_s_aclk_pcie_00_1 [get_bd_pins clk_pl_pcie] [get_bd_pins ip_irq_dbg_fw_00/clk]
  connect_bd_net -net blp_s_aresetn_ext_tog_kernel_00_net [get_bd_pins blp_s_aresetn_ext_tog_kernel_00] [get_bd_pins ip_aresetn_ext_tog_kernel_00/D]
  connect_bd_net -net blp_s_aresetn_ext_tog_kernel_01_net [get_bd_pins blp_s_aresetn_ext_tog_kernel_01] [get_bd_pins ip_aresetn_ext_tog_kernel_01/D]
  connect_bd_net -net blp_s_aresetn_pcie_reset_00_1 [get_bd_pins blp_s_aresetn_pcie_reset_00] [get_bd_pins ip_aresetn_pcie_reset_00/D]
  connect_bd_net -net blp_s_aresetn_pr_reset_00_1 [get_bd_pins blp_s_aresetn_pr_reset_00] [get_bd_pins ip_aresetn_pr_reset_00/D]
  connect_bd_net -net blp_s_aresetn_pr_reset_00_1 [get_bd_pins blp_s_aresetn_pr_reset_00] [get_bd_pins s_ip_axi_ctrl_user_00/aresetn]
  connect_bd_net -net blp_s_ext_tog_ctrl_kernel_00_out_net [get_bd_pins blp_s_ext_tog_ctrl_kernel_00_out] [get_bd_pins ip_ext_tog_ctrl_kernel_00_out/D]
  connect_bd_net -net blp_s_ext_tog_ctrl_kernel_01_out_net [get_bd_pins blp_s_ext_tog_ctrl_kernel_01_out] [get_bd_pins ip_ext_tog_ctrl_kernel_01_out/D]
  connect_bd_net -net ip_aresetn_ext_tog_kernel_00_q [get_bd_pins ip_aresetn_ext_tog_kernel_00/Q] [get_bd_pins ip_ext_tog_ctrl_kernel_00_out/reset]
  connect_bd_net -net ip_aresetn_ext_tog_kernel_00_q [get_bd_pins ip_aresetn_ext_tog_kernel_00/Q] [get_bd_pins ip_ext_tog_ctrl_kernel_00_in/reset]
  connect_bd_net -net ip_aresetn_ext_tog_kernel_00_q [get_bd_pins ip_aresetn_ext_tog_kernel_00/Q] [get_bd_pins ip_ext_tog_ctrl_kernel_00_enable/reset]
  connect_bd_net -net ip_aresetn_ext_tog_kernel_01_q [get_bd_pins ip_aresetn_ext_tog_kernel_01/Q] [get_bd_pins ip_ext_tog_ctrl_kernel_01_out/reset]
  connect_bd_net -net ip_aresetn_ext_tog_kernel_01_q [get_bd_pins ip_aresetn_ext_tog_kernel_01/Q] [get_bd_pins ip_ext_tog_ctrl_kernel_01_in/reset]
  connect_bd_net -net ip_aresetn_ext_tog_kernel_01_q [get_bd_pins ip_aresetn_ext_tog_kernel_01/Q] [get_bd_pins ip_ext_tog_ctrl_kernel_01_enable/reset]
  connect_bd_net -net ip_aresetn_pcie_reset_00_q [get_bd_pins ip_aresetn_pcie_reset_00/Q] [get_bd_pins ulp_m_aresetn_pcie_reset_00]
  connect_bd_net -net ip_aresetn_pcie_reset_00_q [get_bd_pins ip_aresetn_pcie_reset_00/Q] [get_bd_pins ip_irq_dbg_fw_00/reset]
  connect_bd_net -net ip_aresetn_pr_reset_00_q [get_bd_pins ip_aresetn_pr_reset_00/Q] [get_bd_pins ulp_m_aresetn_pr_reset_00]
  connect_bd_net -net ip_aresetn_pr_reset_00_q [get_bd_pins ip_aresetn_pr_reset_00/Q] [get_bd_pins ip_irq_kernel_00/reset]
  connect_bd_net -net ip_ext_tog_ctrl_kernel_00_enable_q [get_bd_pins ip_ext_tog_ctrl_kernel_00_enable/Q] [get_bd_pins blp_m_ext_tog_ctrl_kernel_00_enable]
  connect_bd_net -net ip_ext_tog_ctrl_kernel_00_in_q [get_bd_pins ip_ext_tog_ctrl_kernel_00_in/Q] [get_bd_pins blp_m_ext_tog_ctrl_kernel_00_in]
  connect_bd_net -net ip_ext_tog_ctrl_kernel_00_out_q [get_bd_pins ip_ext_tog_ctrl_kernel_00_out/Q] [get_bd_pins ulp_m_ext_tog_ctrl_kernel_00_out]
  connect_bd_net -net ip_ext_tog_ctrl_kernel_01_enable_q [get_bd_pins ip_ext_tog_ctrl_kernel_01_enable/Q] [get_bd_pins blp_m_ext_tog_ctrl_kernel_01_enable]
  connect_bd_net -net ip_ext_tog_ctrl_kernel_01_in_q [get_bd_pins ip_ext_tog_ctrl_kernel_01_in/Q] [get_bd_pins blp_m_ext_tog_ctrl_kernel_01_in]
  connect_bd_net -net ip_ext_tog_ctrl_kernel_01_out_q [get_bd_pins ip_ext_tog_ctrl_kernel_01_out/Q] [get_bd_pins ulp_m_ext_tog_ctrl_kernel_01_out]
  connect_bd_net -net ip_irq_dbg_fw_00_q [get_bd_pins ip_irq_dbg_fw_00/Q] [get_bd_pins blp_m_dbg_hub_fw_00]
  connect_bd_net -net ip_irq_kernel_00_q [get_bd_pins ip_irq_kernel_00/Q] [get_bd_pins blp_m_irq_kernel_00]
  connect_bd_net -net ulp_s_dbg_hub_fw_00_1 [get_bd_pins ulp_s_dbg_hub_fw_00] [get_bd_pins ip_irq_dbg_fw_00/D]
  connect_bd_net -net ulp_s_ext_tog_ctrl_kernel_00_enable_net [get_bd_pins ulp_s_ext_tog_ctrl_kernel_00_enable] [get_bd_pins ip_ext_tog_ctrl_kernel_00_enable/D]
  connect_bd_net -net ulp_s_ext_tog_ctrl_kernel_00_in_net [get_bd_pins ulp_s_ext_tog_ctrl_kernel_00_in] [get_bd_pins ip_ext_tog_ctrl_kernel_00_in/D]
  connect_bd_net -net ulp_s_ext_tog_ctrl_kernel_01_enable_net [get_bd_pins ulp_s_ext_tog_ctrl_kernel_01_enable] [get_bd_pins ip_ext_tog_ctrl_kernel_01_enable/D]
  connect_bd_net -net ulp_s_ext_tog_ctrl_kernel_01_in_net [get_bd_pins ulp_s_ext_tog_ctrl_kernel_01_in] [get_bd_pins ip_ext_tog_ctrl_kernel_01_in/D]
  connect_bd_net -net ulp_s_irq_kernel_00_1 [get_bd_pins ulp_s_irq_kernel_00] [get_bd_pins ip_irq_kernel_00/D]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Hierarchical cell: ulp_clocking
proc create_hier_cell_ulp_clocking { parentCell nameHier } {

 variable script_folder

 if { $parentCell eq "" || $nameHier eq "" } {
    catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_ulp_clocking() - Empty argument(s)!"}
    return
 }

 # Get object for parentCell
 set parentObj [get_bd_cells $parentCell]
 if { $parentObj == "" } {
    catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
    return
 }

 # Make sure parentObj is hier blk
 set parentType [get_property TYPE $parentObj]
 if { $parentType ne "hier" } {
    catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
    return
 }

 # Save current instance; Restore later
 set oldCurInst [current_bd_instance .]

 # Set parent object as current
 current_bd_instance $parentObj

 # Create cell and set as current instance
 set hier_obj [create_bd_cell -type hier $nameHier]
 current_bd_instance $hier_obj

 # Create interface pins
 create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_ctrl_ucc
 create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_clk_wiz_0
 create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_clk_wiz_1

 # Create pins
 create_bd_pin -dir I -type clk aclk_ctrl
 create_bd_pin -dir I -type clk aclk_freerun
 create_bd_pin -dir O -type clk aclk_kernel_00
 create_bd_pin -dir O -type clk aclk_ext_tog_kernel_00
 create_bd_pin -dir O -type clk aclk_kernel_01
 create_bd_pin -dir O -type clk aclk_ext_tog_kernel_01
 create_bd_pin -dir I -type clk aclk_pcie
 create_bd_pin -dir I -type rst aresetn_ctrl
 create_bd_pin -dir O -from 0 -to 0 -type rst aresetn_ext_tog_kernel_00
 create_bd_pin -dir O -from 0 -to 0 -type rst aresetn_ext_tog_kernel_01
 create_bd_pin -dir I -type rst aresetn_pcie
 create_bd_pin -dir I -type rst aresetn_freerun
 create_bd_pin -dir I ext_tog_ctrl_kernel_00_enable
 create_bd_pin -dir I ext_tog_ctrl_kernel_00_in
 create_bd_pin -dir O ext_tog_ctrl_kernel_00_out
 create_bd_pin -dir I ext_tog_ctrl_kernel_01_enable
 create_bd_pin -dir I ext_tog_ctrl_kernel_01_in
 create_bd_pin -dir O ext_tog_ctrl_kernel_01_out

 # Create instance: shell_utils_ucc, and set properties
 set shell_utils_ucc [ create_bd_cell -type ip -vlnv xilinx.com:ip:shell_utils_ucc shell_utils_ucc ]
 set_property -dict [ list \
  CONFIG.FREQ_CNT_REF_CLK_HZ {33333} \
] $shell_utils_ucc

 # Create instance: clkwiz_aclk_kernel_00, and set properties
 set clkwiz_aclk_kernel_00 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wizard clkwiz_aclk_kernel_00 ]
 set_property -dict [ list \
  CONFIG.CLKOUT_DRIVES {No_buffer,BUFG,BUFG,BUFG,BUFG,BUFG,BUFG} \
  CONFIG.CLKOUT_REQUESTED_OUT_FREQUENCY {300,100.000,100.000,100.000,100.000,100.000,100.000} \
  CONFIG.PRIM_SOURCE {No_buffer} \
  CONFIG.USE_DYN_RECONFIG {true} \
  CONFIG.USE_LOCKED {true} \
  CONFIG.USE_POWER_DOWN {true} \
  CONFIG.USE_RESET {true} \
] $clkwiz_aclk_kernel_00

 # Create instance: clkwiz_aclk_kernel_01, and set properties
 set clkwiz_aclk_kernel_01 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wizard clkwiz_aclk_kernel_01 ]
 set_property -dict [ list \
  CONFIG.CLKOUT_DRIVES {No_buffer,BUFG,BUFG,BUFG,BUFG,BUFG,BUFG} \
  CONFIG.CLKOUT_REQUESTED_OUT_FREQUENCY {250,100.000,100.000,100.000,100.000,100.000,100.000} \
  CONFIG.PRIM_SOURCE {No_buffer} \
  CONFIG.USE_DYN_RECONFIG {true} \
  CONFIG.USE_LOCKED {true} \
  CONFIG.USE_POWER_DOWN {true} \
  CONFIG.USE_RESET {true} \
] $clkwiz_aclk_kernel_01

 # Create instance: gnd1, and set properties
 set gnd1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant gnd1 ]
 set_property -dict [ list \
  CONFIG.CONST_WIDTH {1} \
  CONFIG.CONST_VAL {0} \
] $gnd1

  # Create interface connections
  connect_bd_intf_net -intf_net s_axi_clk_wiz_0_1 [get_bd_intf_pins s_axi_clk_wiz_0] [get_bd_intf_pins clkwiz_aclk_kernel_00/s_axi_lite]
  connect_bd_intf_net -intf_net s_axi_clk_wiz_1_1 [get_bd_intf_pins s_axi_clk_wiz_1] [get_bd_intf_pins clkwiz_aclk_kernel_01/s_axi_lite]
  connect_bd_intf_net -intf_net s_axi_ctrl_ucc_1 [get_bd_intf_pins s_axi_ctrl_ucc] [get_bd_intf_pins shell_utils_ucc/S_AXI_CTRL_MGMT]

  # Create port connections
  connect_bd_net -net aclk_ctrl_1 [get_bd_pins aclk_ctrl] [get_bd_pins shell_utils_ucc/aclk_ctrl]
  connect_bd_net -net aclk_freerun_1 [get_bd_pins aclk_freerun] [get_bd_pins shell_utils_ucc/aclk_freerun]
  connect_bd_net -net aclk_freerun_1 [get_bd_pins aclk_freerun] [get_bd_pins clkwiz_aclk_kernel_00/clk_in1]
  connect_bd_net -net aclk_freerun_1 [get_bd_pins aclk_freerun] [get_bd_pins clkwiz_aclk_kernel_01/clk_in1]
  connect_bd_net -net aclk_freerun_1 [get_bd_pins aclk_freerun] [get_bd_pins clkwiz_aclk_kernel_00/s_axi_aclk]
  connect_bd_net -net aclk_freerun_1 [get_bd_pins aclk_freerun] [get_bd_pins clkwiz_aclk_kernel_01/s_axi_aclk]
  connect_bd_net -net aclk_pcie_1 [get_bd_pins aclk_pcie] [get_bd_pins shell_utils_ucc/aclk_pcie]

  connect_bd_net -net aresetn_freerun_sync [get_bd_pins aresetn_freerun] [get_bd_pins clkwiz_aclk_kernel_00/s_axi_aresetn]
  connect_bd_net -net aresetn_freerun_sync [get_bd_pins aresetn_freerun] [get_bd_pins clkwiz_aclk_kernel_01/s_axi_aresetn]
  connect_bd_net -net aresetn_ctrl_sync [get_bd_pins aresetn_ctrl] [get_bd_pins shell_utils_ucc/aresetn_ctrl]
  connect_bd_net -net clkwiz_aclk_kernel_00_clk_out1 [get_bd_pins clkwiz_aclk_kernel_00/clk_out1] [get_bd_pins shell_utils_ucc/clk_in_kernel_00]
  connect_bd_net -net clkwiz_aclk_kernel_00_locked [get_bd_pins clkwiz_aclk_kernel_00/locked] [get_bd_pins shell_utils_ucc/clk_kernel_00_locked]
  connect_bd_net -net clkwiz_aclk_kernel_01_clk_out1 [get_bd_pins clkwiz_aclk_kernel_01/clk_out1] [get_bd_pins shell_utils_ucc/clk_in_kernel_01]
  connect_bd_net -net clkwiz_aclk_kernel_01_locked [get_bd_pins clkwiz_aclk_kernel_01/locked] [get_bd_pins shell_utils_ucc/clk_kernel_01_locked]
  connect_bd_net -net ext_tog_ctrl_kernel_00_enable_1 [get_bd_pins ext_tog_ctrl_kernel_00_enable] [get_bd_pins shell_utils_ucc/ext_tog_ctrl_kernel_00_enable]
  connect_bd_net -net ext_tog_ctrl_kernel_00_in_1 [get_bd_pins ext_tog_ctrl_kernel_00_in] [get_bd_pins shell_utils_ucc/ext_tog_ctrl_kernel_00_in]
  connect_bd_net -net ext_tog_ctrl_kernel_01_enable_1 [get_bd_pins ext_tog_ctrl_kernel_01_enable] [get_bd_pins shell_utils_ucc/ext_tog_ctrl_kernel_01_enable]
  connect_bd_net -net ext_tog_ctrl_kernel_01_in_1 [get_bd_pins ext_tog_ctrl_kernel_01_in] [get_bd_pins shell_utils_ucc/ext_tog_ctrl_kernel_01_in]
  connect_bd_net -net gnd1_dout [get_bd_pins gnd1/dout] [get_bd_pins shell_utils_ucc/shutdown_clocks]
  connect_bd_net -net shell_utils_ucc_aclk_ext_tog_kernel_00 [get_bd_pins shell_utils_ucc/aclk_ext_tog_kernel_00] [get_bd_pins aclk_ext_tog_kernel_00]
  connect_bd_net -net shell_utils_ucc_aclk_ext_tog_kernel_01 [get_bd_pins shell_utils_ucc/aclk_ext_tog_kernel_01] [get_bd_pins aclk_ext_tog_kernel_01]
  connect_bd_net -net shell_utils_ucc_aclk_kernel_00 [get_bd_pins shell_utils_ucc/aclk_kernel_00] [get_bd_pins aclk_kernel_00]
  connect_bd_net -net shell_utils_ucc_aclk_kernel_01 [get_bd_pins shell_utils_ucc/aclk_kernel_01] [get_bd_pins aclk_kernel_01]
  connect_bd_net -net shell_utils_ucc_ext_tog_ctrl_kernel_00_out [get_bd_pins shell_utils_ucc/ext_tog_ctrl_kernel_00_out] [get_bd_pins ext_tog_ctrl_kernel_00_out]
  connect_bd_net -net shell_utils_ucc_ext_tog_ctrl_kernel_01_out [get_bd_pins shell_utils_ucc/ext_tog_ctrl_kernel_01_out] [get_bd_pins ext_tog_ctrl_kernel_01_out]
  connect_bd_net -net shell_utils_ucc_power_down [get_bd_pins shell_utils_ucc/power_down] [get_bd_pins clkwiz_aclk_kernel_01/power_down]
  connect_bd_net -net shell_utils_ucc_power_down [get_bd_pins shell_utils_ucc/power_down] [get_bd_pins clkwiz_aclk_kernel_00/power_down]
  connect_bd_net -net shell_utils_ucc_rst_async_kernel_00 [get_bd_pins shell_utils_ucc/rst_async_kernel_00] [get_bd_pins aresetn_ext_tog_kernel_00]
  connect_bd_net -net shell_utils_ucc_rst_async_kernel_01 [get_bd_pins shell_utils_ucc/rst_async_kernel_01] [get_bd_pins aresetn_ext_tog_kernel_01]

 # Restore current instance
 current_bd_instance $oldCurInst
}

# Hierarchical cell: blp_logic
proc create_hier_cell_blp_logic { parentCell nameHier} {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_blp_logic() - Empty argument(s)!"}
     return
 }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
 }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
 }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 m_axi_user_ctrl

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_apu

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_mgmt_ctrl

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_mgmt_data

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_rpu

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_user_ctrl

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:pcie3_cfg_ext_rtl:1.0 s_pcie4_cfg_ext

  # Create pins
  create_bd_pin -dir I -from 32 -to 0 Din
  create_bd_pin -dir O -type clk clk_kernel0
  create_bd_pin -dir O -type clk clk_kernel1
  create_bd_pin -dir I -type clk clk_pcie
  create_bd_pin -dir I -type clk clk_pl_axi
  create_bd_pin -dir I -type clk clk_pl_pcie
  create_bd_pin -dir I -type clk clk_pl_ref
  create_bd_pin -dir O -type intr irq_debug_uart_rpu
  create_bd_pin -dir O -type intr irq_debug_uart_apu
  create_bd_pin -dir O -type intr irq_gcq_m2r
  create_bd_pin -dir O -type intr irq_gcq_a2r
  create_bd_pin -dir O -type intr irq_gcq_r2a
  create_bd_pin -dir O -type intr irq_gcq_apu
  create_bd_pin -dir O -type intr irq_cu_completion
  create_bd_pin -dir O -type intr irq_firewall_user
  create_bd_pin -dir I -from 0 -to 0 -type rst resetn_pcie
  create_bd_pin -dir I -type rst resetn_pl_axi
  create_bd_pin -dir O -from 0 -to 0 -type rst resetn_pl_pcie_pr
  create_bd_pin -dir O -from 0 -to 0 -type rst resetn_pr
  create_bd_pin -dir O -type clk aclk_ext_tog_kernel_00
  create_bd_pin -dir O -type clk aclk_ext_tog_kernel_01
  create_bd_pin -dir O -from 0 -to 0 -type rst aresetn_ext_tog_kernel_00
  create_bd_pin -dir O -from 0 -to 0 -type rst aresetn_ext_tog_kernel_01
  create_bd_pin -dir O ext_tog_ctrl_kernel_00_out
  create_bd_pin -dir O ext_tog_ctrl_kernel_01_out
  create_bd_pin -dir I ext_tog_ctrl_kernel_00_enable
  create_bd_pin -dir I ext_tog_ctrl_kernel_01_enable
  create_bd_pin -dir I ext_tog_ctrl_kernel_00_in
  create_bd_pin -dir I ext_tog_ctrl_kernel_01_in
  create_bd_pin -dir O force_reset_enable
  create_bd_pin -dir I force_reset_result
  create_bd_pin -dir O irq_vld
  create_bd_pin -dir O irq_vec
  create_bd_pin -dir O irq_fnc
  create_bd_pin -dir I irq_fail
  create_bd_pin -dir I irq_ack

  # Create instance: axi_blp_dbg_hub, and set properties
  set axi_blp_dbg_hub [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dbg_hub axi_blp_dbg_hub ]
  set_property -dict [ list \
   CONFIG.C_AXI_DATA_WIDTH {128} \
   CONFIG.C_NUM_DEBUG_CORES {0} \
 ] $axi_blp_dbg_hub


  # Create instance: axi_firewall_user, and set properties
  set axi_firewall_user [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_firewall axi_firewall_user ]
  set_property -dict [ list \
   CONFIG.MASK_ERR_RESP {1} \
  ] $axi_firewall_user

  # Create instance: axi_ic_apu, and set properties
  set axi_ic_apu [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect axi_ic_apu ]
  set_property -dict [list \
    CONFIG.NUM_CLKS {1} \
    CONFIG.NUM_MI {5} \
    CONFIG.NUM_SI {1} \
  ] $axi_ic_apu


  # Create instance: axi_ic_plmgmt, and set properties
  set axi_ic_plmgmt [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect axi_ic_plmgmt ]
  set_property -dict [list \
    CONFIG.NUM_MI {7} \
    CONFIG.NUM_SI {1} \
  ] $axi_ic_plmgmt

  # Create instance: axi_ic_pluser, and set properties
  set axi_ic_pluser [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect axi_ic_pluser ]
  set_property -dict [list \
    CONFIG.NUM_MI {5} \
    CONFIG.NUM_SI {1} \
  ] $axi_ic_pluser

  # Create instance: axi_ic_rpu, and set properties
  set axi_ic_rpu [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect axi_ic_rpu ]
  set_property -dict [list \
    CONFIG.NUM_CLKS {3} \
    CONFIG.NUM_MI {10} \
    CONFIG.NUM_SI {1} \
  ] $axi_ic_rpu


  # Create instance: axi_uart_apu0, and set properties
  set axi_uart_apu0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite axi_uart_apu0 ]
  set_property -dict [list CONFIG.C_BAUDRATE {230400}] ${axi_uart_apu0}



  # Create instance: axi_uart_mgmt_apu0, and set properties
  set axi_uart_mgmt_apu0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite axi_uart_mgmt_apu0 ]
  set_property -dict [list CONFIG.C_BAUDRATE {230400}] ${axi_uart_mgmt_apu0}


  # Create instance: axi_uart_mgmt_rpu, and set properties
  set axi_uart_mgmt_rpu [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite axi_uart_mgmt_rpu ]
  set_property -dict [list CONFIG.C_BAUDRATE {230400}] ${axi_uart_mgmt_rpu}

  # Create instance: axi_uart_rpu, and set properties
  set axi_uart_rpu [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite axi_uart_rpu ]
  set_property -dict [list CONFIG.C_BAUDRATE {230400}] ${axi_uart_rpu}

  # Create instance: base_clocking
  create_hier_cell_base_clocking $hier_obj base_clocking

  # Create instance: ert_support
  create_hier_cell_ert_support $hier_obj ert_support

  # Create instance: gate_user_or, and set properties
  set gate_user_or [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic gate_user_or ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {or} \
   CONFIG.C_SIZE {1} \
 ] $gate_user_or

  # Create instance: irq_const, and set properties
  set irq_const [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant irq_const ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
   CONFIG.CONST_WIDTH {1} \
 ] $irq_const

  set hw_discovery [ create_bd_cell -type ip -vlnv xilinx.com:ip:hw_discovery hw_discovery ]
  set_property -dict [list \
    CONFIG.C_CAP_BASE_ADDR {0x600} \
    CONFIG.C_MANUAL {1} \
    CONFIG.C_NUM_PFS {2} \
    CONFIG.C_PF0_ENDPOINT_NAMES {ep_blp_rom_00 {type 0x50 reserve 0x0} ep_mailbox_mgmt_00 {type 0x53 reserve 0x3} ep_xgq_mgmt_to_rpu_sq_pi_00 {type 0x54 reserve 0x0} ep_xgq_payload_mgmt_00 {type 0x55 reserve\
0x0}} \
    CONFIG.C_PF0_ENTRY_ADDR_0 {0x000002010000} \
    CONFIG.C_PF0_ENTRY_ADDR_1 {0x000002000000} \
    CONFIG.C_PF0_ENTRY_ADDR_2 {0x000008000000} \
    CONFIG.C_PF0_ENTRY_ADDR_3 {0x000002002000} \
    CONFIG.C_PF0_ENTRY_MAJOR_VERSION_0 {1} \
    CONFIG.C_PF0_ENTRY_MAJOR_VERSION_1 {1} \
    CONFIG.C_PF0_ENTRY_MAJOR_VERSION_2 {1} \
    CONFIG.C_PF0_ENTRY_MINOR_VERSION_0 {2} \
    CONFIG.C_PF0_ENTRY_RSVD0_1 {0x3} \
    CONFIG.C_PF0_ENTRY_TYPE_0 {0x54} \
    CONFIG.C_PF0_ENTRY_TYPE_1 {0x53} \
    CONFIG.C_PF0_ENTRY_TYPE_2 {0x55} \
    CONFIG.C_PF0_ENTRY_TYPE_3 {0x50} \
    CONFIG.C_PF0_ENTRY_VERSION_TYPE_0 {0x01} \
    CONFIG.C_PF0_ENTRY_VERSION_TYPE_1 {0x01} \
    CONFIG.C_PF0_ENTRY_VERSION_TYPE_2 {0x01} \
    CONFIG.C_PF0_ENTRY_VERSION_TYPE_3 {0x01} \
    CONFIG.C_PF0_LOW_OFFSET {0x0200100} \
    CONFIG.C_PF0_NUM_SLOTS_BAR_LAYOUT_TABLE {4} \
    CONFIG.C_PF1_BAR_INDEX {2} \
    CONFIG.C_PF1_ENDPOINT_NAMES {ep_mailbox_user_00 {type 0x53 reserve 0x1}} \
    CONFIG.C_PF1_ENTRY_ADDR_0 {0x000002000000} \
    CONFIG.C_PF1_ENTRY_BAR_0 {2} \
    CONFIG.C_PF1_ENTRY_MAJOR_VERSION_0 {1} \
    CONFIG.C_PF1_ENTRY_RSVD0_0 {0x1} \
    CONFIG.C_PF1_ENTRY_TYPE_0 {0x53} \
    CONFIG.C_PF1_ENTRY_VERSION_TYPE_0 {0x01} \
    CONFIG.C_PF1_LOW_OFFSET {0x0200100} \
  ] $hw_discovery


  # Create instance: pfm_irq_ctlr, and set properties
  set pfm_irq_ctlr [ create_bd_cell -type ip -vlnv xilinx.com:ip:pfm_irq_ctlr pfm_irq_ctlr ]
  set_property -dict [list \
    CONFIG.NUM_OF_IRQ_PF0 {1} \
    CONFIG.NUM_OF_IRQ_PF1 {1} \
    CONFIG.NUM_OF_PFS {2} \
    CONFIG.CPM_TYPE {0} \
  ] $pfm_irq_ctlr



  # Create instance: pf_mailbox, and set properties
  set pf_mailbox [ create_bd_cell -type ip -vlnv xilinx.com:ip:mailbox pf_mailbox ]

  # Create instance: uuid_register, and set properties
  set uuid_register [ create_bd_cell -type ip -vlnv xilinx.com:ip:uuid_register uuid_register ]

  # Create instance: ulp_clocking
  create_hier_cell_ulp_clocking $hier_obj ulp_clocking

  # Create instance: gcq_r2a, and set properties
  set gcq_r2a [ create_bd_cell -type ip -vlnv xilinx.com:ip:cmd_queue gcq_r2a ]

  # Create instance: gcq_m2r, and set properties
  set gcq_m2r [ create_bd_cell -type ip -vlnv xilinx.com:ip:cmd_queue gcq_m2r ]

  # Create instance: gcq_u2a_0, and set properties
  set gcq_u2a_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:cmd_queue gcq_u2a_0 ]

  # Create instance: xlconcat_irq_vec, and set properties
  set xlconcat_irq_vec [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat xlconcat_irq_vec ]
  set_property -dict [ list \
   CONFIG.NUM_PORTS {7} \
 ] $xlconcat_irq_vec

  # Create instance: xlslice_kernel_interrupts, and set properties
  set xlslice_kernel_interrupts [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice xlslice_kernel_interrupts ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {31} \
   CONFIG.DIN_TO {0} \
   CONFIG.DIN_WIDTH {128} \
   CONFIG.DOUT_WIDTH {32} \
 ] $xlslice_kernel_interrupts

set axi_intc_uart_apu [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_intc axi_intc_uart_apu ]
  set_property -dict [ list \
   CONFIG.C_IRQ_CONNECTION {1} \
   CONFIG.C_KIND_OF_INTR.VALUE_SRC {USER} \
   CONFIG.C_KIND_OF_INTR {0x00000001} \
   CONFIG.C_IRQ_IS_LEVEL {0} \
 ] $axi_intc_uart_apu

   set xlconcat_uart_apu [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat xlconcat_uart_apu ]
  set_property -dict [ list \
   CONFIG.NUM_PORTS {2} \
 ] $xlconcat_uart_apu

set axi_intc_gcq_apu [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_intc axi_intc_gcq_apu ]
  set_property -dict [ list \
   CONFIG.C_IRQ_CONNECTION {1} \
   CONFIG.C_KIND_OF_INTR.VALUE_SRC {USER} \
   CONFIG.C_KIND_OF_INTR {0x00000001} \
   CONFIG.C_IRQ_IS_LEVEL {0} \
 ] $axi_intc_gcq_apu

  # Create interface connections
  connect_bd_intf_net -intf_net axi_firewall_user_M_AXI [get_bd_intf_pins m_axi_user_ctrl] [get_bd_intf_pins axi_firewall_user/M_AXI]
  connect_bd_intf_net -intf_net axi_ic_apu_M00_AXI [get_bd_intf_pins axi_ic_apu/M00_AXI] [get_bd_intf_pins gcq_r2a/S01_AXI]
  connect_bd_intf_net -intf_net axi_ic_apu_M01_AXI [get_bd_intf_pins axi_ic_apu/M01_AXI] [get_bd_intf_pins axi_uart_apu0/S_AXI]
  connect_bd_intf_net -intf_net axi_ic_apu_M02_AXI [get_bd_intf_pins axi_ic_apu/M02_AXI] [get_bd_intf_pins gcq_u2a_0/S01_AXI]
  connect_bd_intf_net -intf_net axi_ic_apu_M03_AXI [get_bd_intf_pins axi_ic_apu/M03_AXI] [get_bd_intf_pins axi_intc_uart_apu/s_axi]
  connect_bd_intf_net -intf_net axi_ic_apu_M04_AXI [get_bd_intf_pins axi_intc_gcq_apu/s_axi] [get_bd_intf_pins axi_ic_apu/M04_AXI]
  connect_bd_intf_net -intf_net axi_ic_plmgmt_M00_AXI [get_bd_intf_pins axi_ic_plmgmt/M00_AXI] [get_bd_intf_pins pf_mailbox/S0_AXI]
  connect_bd_intf_net -intf_net axi_ic_plmgmt_M01_AXI [get_bd_intf_pins axi_ic_plmgmt/M01_AXI] [get_bd_intf_pins hw_discovery/s_axi_ctrl_pf0]
  connect_bd_intf_net -intf_net axi_ic_plmgmt_M02_AXI [get_bd_intf_pins axi_ic_plmgmt/M02_AXI] [get_bd_intf_pins uuid_register/S1_AXI]
  connect_bd_intf_net -intf_net axi_ic_plmgmt_M03_AXI [get_bd_intf_pins axi_ic_plmgmt/M03_AXI] [get_bd_intf_pins gcq_m2r/S00_AXI]
  connect_bd_intf_net -intf_net axi_ic_plmgmt_M04_AXI [get_bd_intf_pins axi_ic_plmgmt/M04_AXI] [get_bd_intf_pins axi_uart_mgmt_rpu/S_AXI]
  connect_bd_intf_net -intf_net axi_ic_plmgmt_M05_AXI [get_bd_intf_pins axi_ic_plmgmt/M05_AXI] [get_bd_intf_pins axi_uart_mgmt_apu0/S_AXI]
  connect_bd_intf_net -intf_net axi_ic_plmgmt_M06_AXI [get_bd_intf_pins axi_ic_plmgmt/M06_AXI] [get_bd_intf_pins base_clocking/s_axi_swctrl_reset_cntl]
  connect_bd_intf_net -intf_net axi_ic_pluser_M00_AXI [get_bd_intf_pins axi_ic_pluser/M00_AXI] [get_bd_intf_pins pf_mailbox/S1_AXI]
  connect_bd_intf_net -intf_net axi_ic_pluser_M01_AXI [get_bd_intf_pins axi_ic_pluser/M01_AXI] [get_bd_intf_pins hw_discovery/s_axi_ctrl_pf1]
  connect_bd_intf_net -intf_net axi_ic_pluser_M02_AXI [get_bd_intf_pins axi_ic_pluser/M02_AXI] [get_bd_intf_pins axi_firewall_user/S_AXI]
  connect_bd_intf_net -intf_net axi_ic_pluser_M03_AXI [get_bd_intf_pins axi_ic_pluser/M03_AXI] [get_bd_intf_pins ert_support/s_axi_cu_done_intc0]
  connect_bd_intf_net -intf_net axi_ic_pluser_M04_AXI [get_bd_intf_pins axi_ic_pluser/M04_AXI] [get_bd_intf_pins gcq_u2a_0/S00_AXI]
  connect_bd_intf_net -intf_net axi_ic_rpu_M00_AXI [get_bd_intf_pins axi_ic_rpu/M00_AXI] [get_bd_intf_pins axi_firewall_user/S_AXI_CTL]
  connect_bd_intf_net -intf_net axi_ic_rpu_M01_AXI [get_bd_intf_pins axi_ic_rpu/M01_AXI] [get_bd_intf_pins gcq_m2r/S01_AXI]
  connect_bd_intf_net -intf_net axi_ic_rpu_M02_AXI [get_bd_intf_pins axi_ic_rpu/M02_AXI] [get_bd_intf_pins gcq_r2a/S00_AXI]
  connect_bd_intf_net -intf_net axi_ic_rpu_M03_AXI [get_bd_intf_pins axi_ic_rpu/M03_AXI] [get_bd_intf_pins axi_uart_rpu/S_AXI]
  connect_bd_intf_net -intf_net axi_ic_rpu_M04_AXI [get_bd_intf_pins axi_ic_rpu/M04_AXI] [get_bd_intf_pins base_clocking/s_axi_pr_reset_cntl]
  connect_bd_intf_net -intf_net axi_ic_rpu_M05_AXI [get_bd_intf_pins axi_ic_rpu/M05_AXI] [get_bd_intf_pins ulp_clocking/s_axi_ctrl_ucc]
  connect_bd_intf_net -intf_net axi_ic_rpu_M06_AXI [get_bd_intf_pins axi_ic_rpu/M06_AXI] [get_bd_intf_pins ulp_clocking/s_axi_clk_wiz_0]
  connect_bd_intf_net -intf_net axi_ic_rpu_M07_AXI [get_bd_intf_pins axi_ic_rpu/M07_AXI] [get_bd_intf_pins ulp_clocking/s_axi_clk_wiz_1]
  connect_bd_intf_net -intf_net axi_ic_rpu_M08_AXI [get_bd_intf_pins axi_ic_rpu/M08_AXI] [get_bd_intf_pins pfm_irq_ctlr/S_AXI]
  connect_bd_intf_net -intf_net axi_ic_rpu_M09_AXI [get_bd_intf_pins axi_ic_rpu/M09_AXI] [get_bd_intf_pins uuid_register/S0_AXI]
  connect_bd_intf_net -intf_net s_axi_apu_1 [get_bd_intf_pins s_axi_apu] [get_bd_intf_pins axi_ic_apu/S00_AXI]
  connect_bd_intf_net -intf_net s_axi_mgmt_ctrl_1 [get_bd_intf_pins s_axi_mgmt_ctrl] [get_bd_intf_pins axi_ic_plmgmt/S00_AXI]
  connect_bd_intf_net -intf_net s_axi_mgmt_data_1 [get_bd_intf_pins s_axi_mgmt_data] [get_bd_intf_pins axi_blp_dbg_hub/S_AXI]
  connect_bd_intf_net -intf_net s_axi_rpu_1 [get_bd_intf_pins s_axi_rpu] [get_bd_intf_pins axi_ic_rpu/S00_AXI]
  connect_bd_intf_net -intf_net s_axi_user_ctrl_1 [get_bd_intf_pins s_axi_user_ctrl] [get_bd_intf_pins axi_ic_pluser/S00_AXI]
  connect_bd_intf_net -intf_net s_pcie4_cfg_ext_1 [get_bd_intf_pins s_pcie4_cfg_ext] [get_bd_intf_pins hw_discovery/s_pcie4_cfg_ext]

  # Create port connections
  connect_bd_net -net Din_1 [get_bd_pins Din] [get_bd_pins xlslice_kernel_interrupts/Din]
  connect_bd_net -net axi_firewall_user_mi_r_error [get_bd_pins axi_firewall_user/mi_r_error] [get_bd_pins gate_user_or/Op2]
  connect_bd_net -net axi_firewall_user_mi_w_error [get_bd_pins axi_firewall_user/mi_w_error] [get_bd_pins gate_user_or/Op1]
  connect_bd_net -net axi_uart_apu0_interrupt [get_bd_pins axi_uart_apu0/interrupt] [get_bd_pins xlconcat_uart_apu/In0]
  connect_bd_net -net axi_uart_apu0_tx [get_bd_pins axi_uart_apu0/tx] [get_bd_pins axi_uart_mgmt_apu0/rx]
  connect_bd_net -net axi_uart_apu_interrupt [get_bd_pins axi_intc_uart_apu/irq] [get_bd_pins irq_debug_uart_apu]
  connect_bd_net -net axi_uart_apu_interrupt_concat [get_bd_pins xlconcat_uart_apu/dout] [get_bd_pins axi_intc_uart_apu/intr]
  connect_bd_net -net axi_uart_mgmt_apu0_tx [get_bd_pins axi_uart_mgmt_apu0/tx] [get_bd_pins axi_uart_apu0/rx]
  connect_bd_net -net axi_uart_mgmt_rpu_tx [get_bd_pins axi_uart_mgmt_rpu/tx] [get_bd_pins axi_uart_rpu/rx]
  connect_bd_net -net axi_uart_rpu_interrupt [get_bd_pins axi_uart_rpu/interrupt] [get_bd_pins irq_debug_uart_rpu]
  connect_bd_net -net axi_uart_rpu_tx [get_bd_pins axi_uart_rpu/tx] [get_bd_pins axi_uart_mgmt_rpu/rx]
  connect_bd_net -net base_clocking_force_reset_enable [get_bd_pins base_clocking/force_reset_enable] [get_bd_pins force_reset_enable]
  connect_bd_net -net clk_pcie_net [get_bd_pins clk_pcie] [get_bd_pins base_clocking/clk_pcie]
  connect_bd_net -net clk_pcie_net [get_bd_pins clk_pcie] [get_bd_pins hw_discovery/aclk_pcie]
  connect_bd_net -net clk_pcie_net [get_bd_pins clk_pcie] [get_bd_pins pfm_irq_ctlr/aclk]
  connect_bd_net -net clk_pl_axi_net [get_bd_pins clk_pl_axi] [get_bd_pins axi_blp_dbg_hub/aclk]
  connect_bd_net -net clk_pl_axi_net [get_bd_pins clk_pl_axi] [get_bd_pins axi_firewall_user/aclk]
  connect_bd_net -net clk_pl_axi_net [get_bd_pins clk_pl_axi] [get_bd_pins axi_ic_apu/aclk]
  connect_bd_net -net clk_pl_axi_net [get_bd_pins clk_pl_axi] [get_bd_pins axi_ic_plmgmt/aclk]
  connect_bd_net -net clk_pl_axi_net [get_bd_pins clk_pl_axi] [get_bd_pins axi_ic_pluser/aclk]
  connect_bd_net -net clk_pl_axi_net [get_bd_pins clk_pl_axi] [get_bd_pins axi_ic_rpu/aclk]
  connect_bd_net -net clk_pl_axi_net [get_bd_pins clk_pl_axi] [get_bd_pins axi_uart_apu0/s_axi_aclk]
  connect_bd_net -net clk_pl_axi_net [get_bd_pins clk_pl_axi] [get_bd_pins axi_uart_mgmt_apu0/s_axi_aclk]
  connect_bd_net -net clk_pl_axi_net [get_bd_pins clk_pl_axi] [get_bd_pins axi_uart_mgmt_rpu/s_axi_aclk]
  connect_bd_net -net clk_pl_axi_net [get_bd_pins clk_pl_axi] [get_bd_pins axi_uart_rpu/s_axi_aclk]
  connect_bd_net -net clk_pl_axi_net [get_bd_pins clk_pl_axi] [get_bd_pins base_clocking/clk_pl_axi]
  connect_bd_net -net clk_pl_axi_net [get_bd_pins clk_pl_axi] [get_bd_pins ert_support/clk_pl_axi]
  connect_bd_net -net clk_pl_axi_net [get_bd_pins clk_pl_axi] [get_bd_pins hw_discovery/aclk_ctrl]
  connect_bd_net -net clk_pl_axi_net [get_bd_pins clk_pl_axi] [get_bd_pins pf_mailbox/S0_AXI_ACLK]
  connect_bd_net -net clk_pl_axi_net [get_bd_pins clk_pl_axi] [get_bd_pins pf_mailbox/S1_AXI_ACLK]
  connect_bd_net -net clk_pl_axi_net [get_bd_pins clk_pl_axi] [get_bd_pins uuid_register/S_AXI_ACLK]
  connect_bd_net -net clk_pl_axi_net [get_bd_pins clk_pl_axi] [get_bd_pins ulp_clocking/aclk_ctrl]
  connect_bd_net -net clk_pl_axi_net [get_bd_pins clk_pl_axi] [get_bd_pins gcq_r2a/aclk]
  connect_bd_net -net clk_pl_axi_net [get_bd_pins clk_pl_axi] [get_bd_pins gcq_m2r/aclk]
  connect_bd_net -net clk_pl_axi_net [get_bd_pins clk_pl_axi] [get_bd_pins gcq_u2a_0/aclk]
  connect_bd_net -net clk_pl_axi_net [get_bd_pins clk_pl_axi] [get_bd_pins axi_intc_uart_apu/s_axi_aclk]
  connect_bd_net -net clk_pl_axi_net [get_bd_pins clk_pl_axi] [get_bd_pins axi_intc_gcq_apu/s_axi_aclk]
  connect_bd_net -net clk_pl_pcie_net [get_bd_pins clk_pl_pcie] [get_bd_pins axi_ic_rpu/aclk1]
  connect_bd_net -net clk_pl_pcie_net [get_bd_pins clk_pl_pcie] [get_bd_pins base_clocking/clk_pl_pcie]
  connect_bd_net -net clk_pl_pcie_net [get_bd_pins clk_pl_pcie] [get_bd_pins ulp_clocking/aclk_pcie]
  connect_bd_net -net clk_pl_ref_net [get_bd_pins clk_pl_ref] [get_bd_pins base_clocking/clk_freerun]
  connect_bd_net -net clk_pl_ref_net [get_bd_pins clk_pl_ref] [get_bd_pins ulp_clocking/aclk_freerun]
  connect_bd_net -net clk_pl_ref_net [get_bd_pins clk_pl_ref] [get_bd_pins axi_ic_rpu/aclk2]
  connect_bd_net -net ert_support_irq_cu_completion [get_bd_pins ert_support/irq_cu_completion] [get_bd_pins irq_cu_completion]
  connect_bd_net -net force_reset_result_1 [get_bd_pins force_reset_result] [get_bd_pins base_clocking/force_reset_result]
  connect_bd_net -net gate_user_or_Res [get_bd_pins gate_user_or/Res] [get_bd_pins irq_firewall_user]
  connect_bd_net -net gcq_a2r_irq [get_bd_pins gcq_r2a/irq_cq] [get_bd_pins irq_gcq_a2r]
  connect_bd_net -net gcq_a2u_irq_0 [get_bd_pins gcq_u2a_0/irq_cq] [get_bd_pins pfm_irq_ctlr/irq_in_1]
  connect_bd_net -net gcq_apu_irq [get_bd_pins axi_intc_gcq_apu/irq] [get_bd_pins irq_gcq_apu]
  connect_bd_net -net gcq_m2r_irq [get_bd_pins gcq_m2r/irq_sq] [get_bd_pins irq_gcq_m2r]
  connect_bd_net -net gcq_r2a_irq [get_bd_pins gcq_r2a/irq_sq] [get_bd_pins irq_gcq_r2a]
  connect_bd_net -net gcq_u2a_irq_0 [get_bd_pins gcq_u2a_0/irq_sq] [get_bd_pins axi_intc_gcq_apu/intr]
  connect_bd_net -net irq_const_dout [get_bd_pins irq_const/dout] [get_bd_pins pfm_irq_ctlr/irq_in_0]
  connect_bd_net -net irq_const_dout [get_bd_pins irq_const/dout] [get_bd_pins xlconcat_irq_vec/In1]
  connect_bd_net -net irq_const_dout [get_bd_pins irq_const/dout] [get_bd_pins xlconcat_irq_vec/In2]
  connect_bd_net -net irq_const_dout [get_bd_pins irq_const/dout] [get_bd_pins xlconcat_irq_vec/In3]
  connect_bd_net -net irq_const_dout [get_bd_pins irq_const/dout] [get_bd_pins xlconcat_irq_vec/In4]
  connect_bd_net -net irq_const_dout [get_bd_pins irq_const/dout] [get_bd_pins xlconcat_irq_vec/In5]
  connect_bd_net -net irq_const_dout [get_bd_pins irq_const/dout] [get_bd_pins xlconcat_irq_vec/In6]
  connect_bd_net -net kernel_interupts_stc_1 [get_bd_pins xlslice_kernel_interrupts/Dout] [get_bd_pins ert_support/kernel_interupts_stc]
  connect_bd_net -net pfm_irq_ctlr_irq_ack [get_bd_pins irq_ack] [get_bd_pins pfm_irq_ctlr/irq_ack]
  connect_bd_net -net pfm_irq_ctlr_irq_fail [get_bd_pins irq_fail] [get_bd_pins pfm_irq_ctlr/irq_fail]
  connect_bd_net -net pfm_irq_ctlr_irq_fnc [get_bd_pins pfm_irq_ctlr/irq_fnc] [get_bd_pins irq_fnc]
  connect_bd_net -net xlconcat_irq_vec_dout [get_bd_pins xlconcat_irq_vec/dout] [get_bd_pins irq_vec]
  connect_bd_net -net pfm_irq_ctlr_irq_vec [get_bd_pins pfm_irq_ctlr/irq_vec] [get_bd_pins xlconcat_irq_vec/In0]
  connect_bd_net -net pfm_irq_ctlr_irq_vld [get_bd_pins pfm_irq_ctlr/irq_vld] [get_bd_pins irq_vld]
  connect_bd_net -net resetn_pcie_sync_net [get_bd_pins base_clocking/resetn_pcie_sync] [get_bd_pins hw_discovery/aresetn_pcie]
  connect_bd_net -net resetn_pcie_sync_net [get_bd_pins base_clocking/resetn_pcie_sync] [get_bd_pins pfm_irq_ctlr/aresetn]
  connect_bd_net -net resetn_pl_axi_net [get_bd_pins resetn_pl_axi] [get_bd_pins base_clocking/resetn_pl_axi]
  create_bd_net resetn_pl_axi_sync_net
  connect_bd_net -net [get_bd_nets resetn_pl_axi_sync_net] [get_bd_pins base_clocking/resetn_pl_axi_sync]
  connect_bd_net -net [get_bd_nets resetn_pl_axi_sync_net] [get_bd_pins axi_blp_dbg_hub/aresetn]
  connect_bd_net -net [get_bd_nets resetn_pl_axi_sync_net] [get_bd_pins axi_firewall_user/aresetn]
  connect_bd_net -net [get_bd_nets resetn_pl_axi_sync_net] [get_bd_pins axi_ic_plmgmt/aresetn]
  connect_bd_net -net [get_bd_nets resetn_pl_axi_sync_net] [get_bd_pins axi_ic_pluser/aresetn]
  connect_bd_net -net [get_bd_nets resetn_pl_axi_sync_net] [get_bd_pins axi_ic_rpu/aresetn]
  connect_bd_net -net [get_bd_nets resetn_pl_axi_sync_net] [get_bd_pins axi_uart_apu0/s_axi_aresetn]
  connect_bd_net -net [get_bd_nets resetn_pl_axi_sync_net] [get_bd_pins axi_uart_mgmt_apu0/s_axi_aresetn]
  connect_bd_net -net [get_bd_nets resetn_pl_axi_sync_net] [get_bd_pins axi_uart_mgmt_rpu/s_axi_aresetn]
  connect_bd_net -net [get_bd_nets resetn_pl_axi_sync_net] [get_bd_pins axi_uart_rpu/s_axi_aresetn]
  connect_bd_net -net [get_bd_nets resetn_pl_axi_sync_net] [get_bd_pins base_clocking/resetn_pcie]
  connect_bd_net -net [get_bd_nets resetn_pl_axi_sync_net] [get_bd_pins ert_support/resetn_pl_axi]
  connect_bd_net -net [get_bd_nets resetn_pl_axi_sync_net] [get_bd_pins hw_discovery/aresetn_ctrl]
  connect_bd_net -net [get_bd_nets resetn_pl_axi_sync_net] [get_bd_pins pf_mailbox/S0_AXI_ARESETN]
  connect_bd_net -net [get_bd_nets resetn_pl_axi_sync_net] [get_bd_pins pf_mailbox/S1_AXI_ARESETN]
  connect_bd_net -net [get_bd_nets resetn_pl_axi_sync_net] [get_bd_pins uuid_register/S_AXI_ARESETN]
  connect_bd_net -net [get_bd_nets resetn_pl_axi_sync_net] [get_bd_pins ulp_clocking/aresetn_ctrl]
  connect_bd_net -net [get_bd_nets resetn_pl_axi_sync_net] [get_bd_pins gcq_r2a/aresetn]
  connect_bd_net -net [get_bd_nets resetn_pl_axi_sync_net] [get_bd_pins gcq_m2r/aresetn]
  connect_bd_net -net [get_bd_nets resetn_pl_axi_sync_net] [get_bd_pins gcq_u2a_0/aresetn]
  connect_bd_net -net [get_bd_nets resetn_pl_axi_sync_net] [get_bd_pins axi_intc_uart_apu/s_axi_aresetn]
  connect_bd_net -net [get_bd_nets resetn_pl_axi_sync_net] [get_bd_pins axi_intc_gcq_apu/s_axi_aresetn]
  connect_bd_net -net [get_bd_nets resetn_pl_axi_sync_net] [get_bd_pins axi_ic_apu/aresetn]
  connect_bd_net -net resetn_pl_pcie_pr_net [get_bd_pins base_clocking/resetn_pl_pcie_pr] [get_bd_pins resetn_pl_pcie_pr]
  connect_bd_net -net resetn_pl_pcie_pr_net [get_bd_pins base_clocking/resetn_pl_pcie_pr] [get_bd_pins ulp_clocking/aresetn_pcie]
  connect_bd_net -net resetn_pr_net [get_bd_pins base_clocking/resetn_pr] [get_bd_pins resetn_pr]
  connect_bd_net -net aresetn_freerun [get_bd_pins base_clocking/resetn_pl_freerun] [get_bd_pins ulp_clocking/aresetn_freerun]
  connect_bd_net -net ulp_clocking_aclk_ext_tog_kernel_00 [get_bd_pins ulp_clocking/aclk_ext_tog_kernel_00] [get_bd_pins aclk_ext_tog_kernel_00]
  connect_bd_net -net ulp_clocking_aclk_ext_tog_kernel_01 [get_bd_pins ulp_clocking/aclk_ext_tog_kernel_01] [get_bd_pins aclk_ext_tog_kernel_01]
  connect_bd_net -net ulp_clocking_aclk_kernel_00 [get_bd_pins ulp_clocking/aclk_kernel_00] [get_bd_pins clk_kernel0]
  connect_bd_net -net ulp_clocking_aclk_kernel_01 [get_bd_pins ulp_clocking/aclk_kernel_01] [get_bd_pins clk_kernel1]
  connect_bd_net -net ulp_clocking_aresetn_ext_tog_kernel_00 [get_bd_pins ulp_clocking/aresetn_ext_tog_kernel_00] [get_bd_pins aresetn_ext_tog_kernel_00]
  connect_bd_net -net ulp_clocking_aresetn_ext_tog_kernel_01 [get_bd_pins ulp_clocking/aresetn_ext_tog_kernel_01] [get_bd_pins aresetn_ext_tog_kernel_01]
  connect_bd_net -net ulp_clocking_ext_tog_ctrl_kernel_00_enable [get_bd_pins ext_tog_ctrl_kernel_00_enable] [get_bd_pins ulp_clocking/ext_tog_ctrl_kernel_00_enable]
  connect_bd_net -net ulp_clocking_ext_tog_ctrl_kernel_00_in [get_bd_pins ext_tog_ctrl_kernel_00_in] [get_bd_pins ulp_clocking/ext_tog_ctrl_kernel_00_in]
  connect_bd_net -net ulp_clocking_ext_tog_ctrl_kernel_00_out [get_bd_pins ulp_clocking/ext_tog_ctrl_kernel_00_out] [get_bd_pins ext_tog_ctrl_kernel_00_out]
  connect_bd_net -net ulp_clocking_ext_tog_ctrl_kernel_01_enable [get_bd_pins ext_tog_ctrl_kernel_01_enable] [get_bd_pins ulp_clocking/ext_tog_ctrl_kernel_01_enable]
  connect_bd_net -net ulp_clocking_ext_tog_ctrl_kernel_01_in [get_bd_pins ext_tog_ctrl_kernel_01_in] [get_bd_pins ulp_clocking/ext_tog_ctrl_kernel_01_in]
  connect_bd_net -net ulp_clocking_ext_tog_ctrl_kernel_01_out [get_bd_pins ulp_clocking/ext_tog_ctrl_kernel_01_out] [get_bd_pins ext_tog_ctrl_kernel_01_out]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: blp
proc create_hier_cell_blp { parentCell nameHier} {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_blp() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 ULP_M_AXI_CTRL_USER_00
  set_property APERTURES {{{0x202_0000_0000 32M}}} [get_bd_intf_pins ULP_M_AXI_CTRL_USER_00]


  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 pcie_refclk

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 gt_pciea0

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 ULP_M_INI_AIE_00

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:inimm_rtl:1.0 ULP_S_INI_MC_00

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:inimm_rtl:1.0 ULP_S_INI_MC_01

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:inimm_rtl:1.0 ULP_S_INI_MC_02

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 ULP_M_INI_DBG_00


  # Create pins
  create_bd_pin -dir O -type clk ulp_m_aclk_ctrl_00
  create_bd_pin -dir O -type clk ulp_m_aclk_kernel_00
  create_bd_pin -dir O -type clk ulp_m_aclk_kernel_01
  create_bd_pin -dir O -type clk ulp_m_aclk_pcie_00
  create_bd_pin -dir O -from 0 -to 0 -type rst ulp_m_aresetn_pcie_reset_00
  create_bd_pin -dir O -from 0 -to 0 -type rst ulp_m_aresetn_pr_reset_00
  create_bd_pin -dir I -from 32 -to 0 -type intr ulp_s_irq_kernel_00
  create_bd_pin -dir O -type clk ulp_m_aclk_ext_tog_kernel_00
  create_bd_pin -dir O -type clk ulp_m_aclk_ext_tog_kernel_01
  create_bd_pin -dir O ulp_m_ext_tog_ctrl_kernel_00_out
  create_bd_pin -dir O ulp_m_ext_tog_ctrl_kernel_01_out
  create_bd_pin -dir I ulp_s_ext_tog_ctrl_kernel_00_enable
  create_bd_pin -dir I ulp_s_ext_tog_ctrl_kernel_01_enable
  create_bd_pin -dir I ulp_s_ext_tog_ctrl_kernel_00_in
  create_bd_pin -dir I ulp_s_ext_tog_ctrl_kernel_01_in
  create_bd_pin -dir I -type intr ulp_s_dbg_hub_fw_00

##################################################################
# Board Automation
##################################################################

set cips [ create_bd_cell -type ip -vlnv xilinx.com:ip:versal_cips cips ]

apply_bd_automation -rule xilinx.com:bd_rule:cips \
  -config { \
    board_preset {Yes} \
    boot_config {Custom} \
    configure_noc {Add new AXI NoC} \
    debug_config {JTAG} \
    design_flow {Full System} \
    mc_type {LPDDR} \
    num_mc_ddr {None} \
    num_mc_lpddr {1} \
    pl_clocks {2} \
    pl_resets {1} \
  }  $cips

# Copy NOC as axi_noc_mc_1x to keep all the DDR settings
copy_bd_objs /blp  [get_bd_cells {axi_noc_0}]
set_property name axi_noc_mc_1x [get_bd_cells /blp/axi_noc_1]

# Change settings to use INI ports and match settings used in non-automated flow
# Also add anything the partition metadata script needs to see
startgroup
set_property -dict [list \
  CONFIG.MC_CH_INTERLEAVING_SIZE {256_Bytes} \
  CONFIG.NUM_NSI {8} \
  CONFIG.NUM_SI {0} \
  CONFIG.CONTROLLERTYPE {LPDDR4_SDRAM} \
  CONFIG.MC_CHAN_REGION1 {DDR_CH1} \
] [get_bd_cells axi_noc_mc_1x]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}}] [get_bd_intf_pins /blp/axi_noc_mc_1x/S00_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_1 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}}] [get_bd_intf_pins /blp/axi_noc_mc_1x/S01_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_2 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}}] [get_bd_intf_pins /blp/axi_noc_mc_1x/S02_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_3 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}}] [get_bd_intf_pins /blp/axi_noc_mc_1x/S03_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_1 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} CONFIG.INI_STRATEGY {load}] [get_bd_intf_pins /blp/axi_noc_mc_1x/S04_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_2 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} CONFIG.INI_STRATEGY {load}] [get_bd_intf_pins /blp/axi_noc_mc_1x/S05_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_3 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} CONFIG.INI_STRATEGY {load}] [get_bd_intf_pins /blp/axi_noc_mc_1x/S06_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}}] [get_bd_intf_pins /blp/axi_noc_mc_1x/S07_INI]
endgroup

# Turn off memory controller in NOC attached to CIPS directly and match settings in non-automated flow
set_property name axi_noc_ic [get_bd_cells axi_noc_0]
set_property -dict [list \
  CONFIG.CH0_LPDDR4_0_BOARD_INTERFACE {Custom} \
  CONFIG.CH1_LPDDR4_0_BOARD_INTERFACE {Custom} \
  CONFIG.NUM_CLKS {9} \
  CONFIG.NUM_MC {0} \
  CONFIG.NUM_MI {4} \
  CONFIG.NUM_NMI {7} \
  CONFIG.NUM_SI {8} \
  CONFIG.sys_clk0_BOARD_INTERFACE {Custom} \
] [get_bd_cells axi_noc_ic]

set_property -dict [list CONFIG.CATEGORY {pl} CONFIG.CONNECTIONS {M03_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}} M06_INI {read_bw {500} write_bw {500}} M00_INI {read_bw {500} write_bw {500}}}] [get_bd_intf_pins /blp/axi_noc_ic/S06_AXI]
set_property -dict [list CONFIG.CONNECTIONS {M01_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}} M02_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}} M04_INI {read_bw {500} write_bw {500}} M00_INI {read_bw {500} write_bw {500}}}] [get_bd_intf_pins /blp/axi_noc_ic/S01_AXI]
set_property -dict [list CONFIG.CONNECTIONS {M01_INI {read_bw {500} write_bw {500}} M01_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}} M02_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}} M04_INI {read_bw {500} write_bw {500}}}] [get_bd_intf_pins /blp/axi_noc_ic/S02_AXI]
set_property -dict [list CONFIG.CONNECTIONS {M02_INI {read_bw {500} write_bw {500}} M01_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}} M02_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}} M04_INI {read_bw {500} write_bw {500}}}] [get_bd_intf_pins /blp/axi_noc_ic/S03_AXI]
set_property -dict [list CONFIG.CATEGORY {ps_cci} CONFIG.CONNECTIONS {M01_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}} M03_INI {read_bw {500} write_bw {500}} M02_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}} M04_INI {read_bw {500} write_bw {500}}}] [get_bd_intf_pins /blp/axi_noc_ic/S04_AXI]
set_property -dict [list CONFIG.CONNECTIONS {M03_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}} M06_INI {read_bw {500} write_bw {500}} M04_INI {read_bw {500} write_bw {500}} M00_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}} M00_INI {read_bw {500} write_bw {500}}}] [get_bd_intf_pins /blp/axi_noc_ic/S05_AXI]
set_property -dict [list CONFIG.CATEGORY {ps_rpu} CONFIG.CONNECTIONS {M00_INI {read_bw {500} write_bw {500}}}] [get_bd_intf_pins /blp/axi_noc_ic/S06_AXI]
set_property -dict [list CONFIG.CONNECTIONS {M03_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}} M06_INI {read_bw {500} write_bw {500}} M01_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}} M02_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}} M05_INI {read_bw {500} write_bw {500}} M00_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}}] [get_bd_intf_pins /blp/axi_noc_ic/S07_AXI]

# Make the connections
connect_bd_intf_net [get_bd_intf_pins lpddr4_clk1] [get_bd_intf_pins axi_noc_mc_1x/sys_clk0]
connect_bd_intf_net [get_bd_intf_pins ch0_lpddr4_trip1] [get_bd_intf_pins axi_noc_mc_1x/CH0_LPDDR4_0]
connect_bd_intf_net [get_bd_intf_pins ch1_lpddr4_trip1] [get_bd_intf_pins axi_noc_mc_1x/CH1_LPDDR4_0]

# Change some of CIPs configuratons to match use case
  set_property -dict [list \
    CONFIG.PS_PMC_CONFIG { \
      PMC_CRP_PL0_REF_CTRL_FREQMHZ {100} \
      PMC_CRP_PL1_REF_CTRL_FREQMHZ {33.3333333} \
      PS_IRQ_USAGE \
      { \
        {CH0 1} {CH1 1} {CH2 1} {CH3 1} {CH4 1} {CH5 0} {CH6 0} {CH7 0} \
        {CH8 1} {CH9 1} {CH10 1} {CH11 1} {CH12 1} {CH13 0} {CH14 0} {CH15 0} \
      } \
      PS_USE_FPD_CCI_NOC {1} \
      PS_USE_FPD_CCI_NOC0 {1} \
      PS_USE_M_AXI_FPD {1} \
      PS_USE_M_AXI_LPD {1} \
      PS_USE_NOC_LPD_AXI0 {1} \
      SMON_ALARMS {Set_Alarms_On} \
      SMON_ENABLE_TEMP_AVERAGING {0} \
      SMON_INTERFACE_TO_USE {I2C} \
      SMON_MEAS10 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 4.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {4 V unipolar}} {NAME VCCO_302} {SUPPLY_NUM 8}} \
      SMON_MEAS11 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 4.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {4 V unipolar}} {NAME VCCO_500} {SUPPLY_NUM 7}} \
      SMON_MEAS18 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCCO_703} {SUPPLY_NUM 9}} \
      SMON_MEAS20 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCC_PMC} {SUPPLY_NUM 2}} \
      SMON_MEAS21 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCC_PSFP} {SUPPLY_NUM 3}} \
      SMON_MEAS22 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCC_PSLP} {SUPPLY_NUM 4}} \
      SMON_MEAS24 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCC_SOC} {SUPPLY_NUM 5}} \
      SMON_MEAS25 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 1.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {1 V unipolar}} {NAME VP_VN} {SUPPLY_NUM 6}} \
      SMON_MEAS6 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCCAUX} {SUPPLY_NUM 0}} \
      SMON_MEAS7 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCCAUX_PMC} {SUPPLY_NUM 1}} \
      SMON_TEMP_AVERAGING_SAMPLES {0} \
      SMON_VAUX_CH0 {{ALARM_ENABLE 0} {ALARM_LOWER 0} {ALARM_UPPER 1} {AVERAGE_EN 0} {ENABLE 1} {IO_N LPD_MIO25_502} {IO_P LPD_MIO24_502} {MODE {1 V unipolar}} {NAME VAUX_CH0} {SUPPLY_NUM 10}} \
    } \
  ] $cips


  set_property -dict [ list \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.APERTURES {{0x201_0000_0000 2G}} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /blp/axi_noc_ic/M00_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.APERTURES {{0x202_0000_0000 1G}} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /blp/axi_noc_ic/M01_AXI]

  set_property -dict [ list \
   CONFIG.APERTURES {{0x201_0000_0000 1G}} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /blp/axi_noc_ic/M02_AXI]

  set_property -dict [ list \
   CONFIG.APERTURES {{0x201_0000_0000 1G}} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /blp/axi_noc_ic/M03_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.CONNECTIONS {M03_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}} M06_INI {read_bw {500} write_bw {500}} M00_INI {read_bw {800} write_bw {800}}} \
   CONFIG.DEST_IDS {M03_AXI:0x40} \
   CONFIG.REMAPS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /blp/axi_noc_ic/S06_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.CONNECTIONS {M01_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}} M04_INI {read_bw {500} write_bw {500}} M02_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}} M00_INI {read_bw {800} write_bw {800}}} \
   CONFIG.DEST_IDS {M01_AXI:0x1c0:M02_AXI:0x240} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_cci} \
 ] [get_bd_intf_pins /blp/axi_noc_ic/S00_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.CONNECTIONS {M01_INI {read_bw {800} write_bw {800}} M01_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}} M04_INI {read_bw {500} write_bw {500}} M02_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} \
   CONFIG.DEST_IDS {M01_AXI:0x1c0:M02_AXI:0x240} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_cci} \
 ] [get_bd_intf_pins /blp/axi_noc_ic/S01_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.CONNECTIONS {M02_INI {read_bw {800} write_bw {800}} M01_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}} M04_INI {read_bw {500} write_bw {500}} M02_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} \
   CONFIG.DEST_IDS {M01_AXI:0x1c0:M02_AXI:0x240} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_cci} \
 ] [get_bd_intf_pins /blp/axi_noc_ic/S02_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.CONNECTIONS {M03_INI {read_bw {800} write_bw {800}} M01_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}} M04_INI {read_bw {500} write_bw {500}} M02_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} \
   CONFIG.DEST_IDS {M01_AXI:0x1c0:M02_AXI:0x240} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_cci} \
 ] [get_bd_intf_pins /blp/axi_noc_ic/S03_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.CONNECTIONS {M03_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}} M06_INI {read_bw {500} write_bw {500}} M04_INI {read_bw {500} write_bw {500}} M02_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}} M00_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}} M00_INI {read_bw {800} write_bw {800}}} \
   CONFIG.DEST_IDS {M03_AXI:0x40:M02_AXI:0x240:M00_AXI:0x140} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_pmc} \
 ] [get_bd_intf_pins /blp/axi_noc_ic/S05_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.CONNECTIONS {M00_INI {read_bw {800} write_bw {800}}} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_rpu} \
 ] [get_bd_intf_pins /blp/axi_noc_ic/S04_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M03_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}} M06_INI {read_bw {500} write_bw {500}} M01_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}} M02_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}} M05_INI {read_bw {500} write_bw {500}} M00_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} \
   CONFIG.DEST_IDS {M03_AXI:0x40:M01_AXI:0x1c0:M02_AXI:0x240:M00_AXI:0x140} \
   CONFIG.REMAPS {M05_INI {{0x201_0800_0000 0x000_3800_0000 128M}} M05_INI {{0x202_0600_0000 0x000_3600_0000 16M}}} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /blp/axi_noc_ic/S07_AXI]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {} \
 ] [get_bd_pins /blp/axi_noc_ic/aclk0]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S01_AXI} \
 ] [get_bd_pins /blp/axi_noc_ic/aclk1]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S02_AXI} \
 ] [get_bd_pins /blp/axi_noc_ic/aclk2]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S03_AXI} \
 ] [get_bd_pins /blp/axi_noc_ic/aclk3]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S04_AXI} \
 ] [get_bd_pins /blp/axi_noc_ic/aclk4]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S05_AXI} \
 ] [get_bd_pins /blp/axi_noc_ic/aclk5]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S06_AXI} \
 ] [get_bd_pins /blp/axi_noc_ic/aclk6]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M01_AXI:M02_AXI:M03_AXI} \
 ] [get_bd_pins /blp/axi_noc_ic/aclk7]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M00_AXI:S00_AXI:S07_AXI} \
 ] [get_bd_pins /blp/axi_noc_ic/aclk8]


  set_property -dict [ list \
   CONFIG.CONNECTIONS {MC_0 { read_bw {15000} write_bw {15000} read_avg_burst {64} write_avg_burst {64}}} \
  ] [get_bd_intf_pins /blp/axi_noc_mc_1x/S00_INI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {MC_1 { read_bw {15000} write_bw {15000} read_avg_burst {64} write_avg_burst {64}}} \
  ] [get_bd_intf_pins /blp/axi_noc_mc_1x/S01_INI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {MC_2 { read_bw {15000} write_bw {15000} read_avg_burst {64} write_avg_burst {64}}} \
  ] [get_bd_intf_pins /blp/axi_noc_mc_1x/S02_INI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {MC_3 { read_bw {15000} write_bw {15000} read_avg_burst {64} write_avg_burst {64}}} \
  ] [get_bd_intf_pins /blp/axi_noc_mc_1x/S03_INI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
   CONFIG.CONNECTIONS {MC_1 { read_bw {17280} write_bw {17280} read_avg_burst {64} write_avg_burst {64}}} \
  ] [get_bd_intf_pins /blp/axi_noc_mc_1x/S04_INI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
   CONFIG.CONNECTIONS {MC_2 { read_bw {17280} write_bw {17280} read_avg_burst {64} write_avg_burst {64}}} \
  ] [get_bd_intf_pins /blp/axi_noc_mc_1x/S05_INI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
   CONFIG.CONNECTIONS {MC_3 { read_bw {17280} write_bw {17280} read_avg_burst {64} write_avg_burst {64}}} \
  ] [get_bd_intf_pins /blp/axi_noc_mc_1x/S06_INI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} \
  ] [get_bd_intf_pins /blp/axi_noc_mc_1x/S07_INI]

  # Create instance: force_reset_concat_0, and set properties
  set force_reset_concat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat force_reset_concat_0 ]

  # Create instance: force_reset_and_0, and set properties
  set force_reset_and_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_reduced_logic force_reset_and_0 ]
  set_property CONFIG.C_SIZE {2} $force_reset_and_0


  # Create instance: force_reset_not_0, and set properties
  set force_reset_not_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic force_reset_not_0 ]
  set_property -dict [list \
    CONFIG.C_OPERATION {not} \
    CONFIG.C_SIZE {1} \
  ] $force_reset_not_0


  # Create instance: qdma_0, and set properties
  set qdma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:qdma qdma_0 ]
  set_property -dict [list \
    CONFIG.MAILBOX_ENABLE {false} \
    CONFIG.MSI_X_OPTIONS {MSI-X_External} \
    CONFIG.PF0_MSIX_CAP_TABLE_SIZE_qdma {01F} \
    CONFIG.PF1_MSIX_CAP_TABLE_SIZE_qdma {01F} \
    CONFIG.SRIOV_CAP_ENABLE {false} \
    CONFIG.all_speeds_all_sides {YES} \
    CONFIG.axi_data_width {256_bit} \
    CONFIG.axibar_notranslate {false} \
    CONFIG.axist_bypass_en {true} \
    CONFIG.axisten_freq {125} \
    CONFIG.barlite_mb_pf1 {0} \
    CONFIG.copy_pf0 {false} \
    CONFIG.csr_axilite_slave {true} \
    CONFIG.dma_intf_sel_qdma {AXI_MM} \
    CONFIG.en_axi_st_qdma {false} \
    CONFIG.en_bridge_slv {false} \
    CONFIG.mode_selection {Advanced} \
    CONFIG.num_queues {512} \
    CONFIG.pf0_Use_Class_Code_Lookup_Assistant_qdma {false} \
    CONFIG.pf0_bar0_64bit_qdma {true} \
    CONFIG.pf0_bar0_prefetchable_qdma {true} \
    CONFIG.pf0_bar0_scale_qdma {Megabytes} \
    CONFIG.pf0_bar0_size_qdma {256} \
    CONFIG.pf0_bar0_type_qdma {AXI_Bridge_Master} \
    CONFIG.pf0_bar2_64bit_qdma {true} \
    CONFIG.pf0_bar2_prefetchable_qdma {true} \
    CONFIG.pf0_bar2_scale_qdma {Kilobytes} \
    CONFIG.pf0_bar2_size_qdma {256} \
    CONFIG.pf0_bar2_type_qdma {DMA} \
    CONFIG.pf0_class_code_base_qdma {12} \
    CONFIG.pf0_class_code_sub_qdma {00} \
    CONFIG.pf0_device_id {5700} \
    CONFIG.pf0_pciebar2axibar_0 {0x0000020100000000} \
    CONFIG.pf0_pciebar2axibar_2 {0x0000000000000000} \
    CONFIG.pf0_subsystem_id {000e} \
    CONFIG.pf1_bar0_64bit_qdma {true} \
    CONFIG.pf1_bar0_prefetchable_qdma {true} \
    CONFIG.pf1_bar0_scale_qdma {Kilobytes} \
    CONFIG.pf1_bar0_size_qdma {256} \
    CONFIG.pf1_bar0_type_qdma {DMA} \
    CONFIG.pf1_bar2_64bit_qdma {true} \
    CONFIG.pf1_bar2_prefetchable_qdma {true} \
    CONFIG.pf1_bar2_scale_qdma {Megabytes} \
    CONFIG.pf1_bar2_size_qdma {128} \
    CONFIG.pf1_bar2_type_qdma {AXI_Bridge_Master} \
    CONFIG.pf1_class_code_base_qdma {12} \
    CONFIG.pf1_class_code_sub_qdma {00} \
    CONFIG.pf1_device_id {5701} \
    CONFIG.pf1_pciebar2axibar_0 {0x0000000000000000} \
    CONFIG.pf1_pciebar2axibar_2 {0x0000020200000000} \
    CONFIG.pf1_subsystem_id {000e} \
    CONFIG.pl_link_cap_max_link_speed {8.0_GT/s} \
    CONFIG.testname {mm} \
    CONFIG.tl_pf_enable_reg {2} \
  ] $qdma_0


  # Create instance: qdma_0_smc, and set properties
  set qdma_0_smc [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect qdma_0_smc ]
  set_property -dict [list \
    CONFIG.ADVANCED_PROPERTIES {__view__ { functional { S00_Entry { SUPPORTS_WRAP 0 } } timing { M01_Exit { REGSLICE 0 } S00_Entry { MMU_REGSLICE 0 TR_REGSLICE 0 } M00_Exit { REGSLICE 0 } } }   } \
    CONFIG.NUM_CLKS {1} \
    CONFIG.NUM_MI {1} \
    CONFIG.NUM_SI {1} \
  ] $qdma_0_smc


  # Create instance: qdma_0_support
  create_hier_cell_qdma_0_support [current_bd_instance .] qdma_0_support

  # Create instance: blp_logic
  create_hier_cell_blp_logic $hier_obj blp_logic

  save_bd_design

  # Create instance: dfx_decoupling
  create_hier_cell_dfx_decoupling $hier_obj dfx_decoupling

  # Create instance: const_vcc, and set properties
  set const_vcc [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant const_vcc ]

  save_bd_design

  # Create interface connections
  connect_bd_intf_net -intf_net BLP_S_AXI_CTRL_USER_00 [get_bd_intf_pins blp_logic/m_axi_user_ctrl] [get_bd_intf_pins dfx_decoupling/BLP_S_AXI_CTRL_USER_00]
  connect_bd_intf_net -intf_net ULP_M_INI_DGB_00 [get_bd_intf_pins axi_noc_ic/M06_INI] [get_bd_intf_pins ULP_M_INI_DBG_00]
  connect_bd_intf_net -intf_net axi_noc_ic_M00_AXI [get_bd_intf_pins axi_noc_ic/M00_AXI] [get_bd_intf_pins qdma_0_smc/S00_AXI]
  connect_bd_intf_net -intf_net axi_noc_ic_M00_INI [get_bd_intf_pins axi_noc_ic/M00_INI] [get_bd_intf_pins axi_noc_mc_1x/S00_INI]
  connect_bd_intf_net -intf_net axi_noc_ic_M01_INI [get_bd_intf_pins axi_noc_ic/M01_INI] [get_bd_intf_pins axi_noc_mc_1x/S01_INI]
  connect_bd_intf_net -intf_net axi_noc_ic_M02_INI [get_bd_intf_pins axi_noc_ic/M02_INI] [get_bd_intf_pins axi_noc_mc_1x/S02_INI]
  connect_bd_intf_net -intf_net axi_noc_ic_M03_AXI [get_bd_intf_pins axi_noc_ic/M03_AXI] [get_bd_intf_pins blp_logic/s_axi_mgmt_data]
  connect_bd_intf_net -intf_net axi_noc_ic_M03_INI [get_bd_intf_pins axi_noc_ic/M03_INI] [get_bd_intf_pins axi_noc_mc_1x/S03_INI]
  connect_bd_intf_net -intf_net axi_noc_ic_M04_INI [get_bd_intf_pins axi_noc_ic/M04_INI] [get_bd_intf_pins ULP_M_INI_AIE_00]
  connect_bd_intf_net -intf_net axi_noc_ic_M05_INI [get_bd_intf_pins axi_noc_mc_1x/S06_INI] [get_bd_intf_pins axi_noc_ic/M05_INI]
  connect_bd_intf_net -intf_net cips_M_AXI_FPD [get_bd_intf_pins blp_logic/s_axi_apu] [get_bd_intf_pins cips/M_AXI_FPD]
  connect_bd_intf_net -intf_net cips_M_AXI_LPD [get_bd_intf_pins blp_logic/s_axi_rpu] [get_bd_intf_pins cips/M_AXI_LPD]
  connect_bd_intf_net -intf_net dfx_decoupling_ULP_M_AXI_CTRL_USER_00 [get_bd_intf_pins ULP_M_AXI_CTRL_USER_00] [get_bd_intf_pins dfx_decoupling/ULP_M_AXI_CTRL_USER_00]
  connect_bd_intf_net -intf_net pcie_refclk [get_bd_intf_pins pcie_refclk] [get_bd_intf_pins qdma_0_support/pcie_refclk]
  connect_bd_intf_net -intf_net pcie_cfg_ext [get_bd_intf_pins qdma_0_support/pcie_cfg_ext] [get_bd_intf_pins blp_logic/s_pcie4_cfg_ext]
  connect_bd_intf_net -intf_net qdma_0_M_AXI [get_bd_intf_pins qdma_0/M_AXI] [get_bd_intf_pins axi_noc_ic/S06_AXI]
  connect_bd_intf_net -intf_net qdma_0_M_AXI_BRIDGE [get_bd_intf_pins qdma_0/M_AXI_BRIDGE] [get_bd_intf_pins axi_noc_ic/S07_AXI]
  connect_bd_intf_net -intf_net qdma_0_pcie_cfg_control_if [get_bd_intf_pins qdma_0/pcie_cfg_control_if] [get_bd_intf_pins qdma_0_support/pcie_cfg_control]
  connect_bd_intf_net -intf_net qdma_0_pcie_cfg_external_msix_without_msi_if [get_bd_intf_pins qdma_0/pcie_cfg_external_msix_without_msi_if] [get_bd_intf_pins qdma_0_support/pcie_cfg_external_msix_without_msi]
  connect_bd_intf_net -intf_net qdma_0_pcie_cfg_interrupt [get_bd_intf_pins qdma_0/pcie_cfg_interrupt] [get_bd_intf_pins qdma_0_support/pcie_cfg_interrupt]
  connect_bd_intf_net -intf_net qdma_0_pcie_cfg_mgmt_if [get_bd_intf_pins qdma_0/pcie_cfg_mgmt_if] [get_bd_intf_pins qdma_0_support/pcie_cfg_mgmt]
  connect_bd_intf_net -intf_net qdma_0_s_axis_cc [get_bd_intf_pins qdma_0/s_axis_cc] [get_bd_intf_pins qdma_0_support/s_axis_cc]
  connect_bd_intf_net -intf_net qdma_0_s_axis_rq [get_bd_intf_pins qdma_0/s_axis_rq] [get_bd_intf_pins qdma_0_support/s_axis_rq]
  connect_bd_intf_net -intf_net qdma_0_smc_M00_AXI [get_bd_intf_pins qdma_0_smc/M00_AXI] [get_bd_intf_pins qdma_0/S_AXI_LITE_CSR]
  connect_bd_intf_net -intf_net qdma_0_support_m_axis_cq [get_bd_intf_pins qdma_0/m_axis_cq] [get_bd_intf_pins qdma_0_support/m_axis_cq]
  connect_bd_intf_net -intf_net qdma_0_support_m_axis_rc [get_bd_intf_pins qdma_0/m_axis_rc] [get_bd_intf_pins qdma_0_support/m_axis_rc]
  connect_bd_intf_net -intf_net qdma_0_support_pcie_cfg_fc [get_bd_intf_pins qdma_0/pcie_cfg_fc] [get_bd_intf_pins qdma_0_support/pcie_cfg_fc]
  connect_bd_intf_net -intf_net qdma_0_support_pcie_cfg_mesg_rcvd [get_bd_intf_pins qdma_0/pcie_cfg_mesg_rcvd] [get_bd_intf_pins qdma_0_support/pcie_cfg_mesg_rcvd]
  connect_bd_intf_net -intf_net qdma_0_support_pcie_cfg_mesg_tx [get_bd_intf_pins qdma_0/pcie_cfg_mesg_tx] [get_bd_intf_pins qdma_0_support/pcie_cfg_mesg_tx]
  connect_bd_intf_net -intf_net qdma_0_support_pcie_cfg_status [get_bd_intf_pins qdma_0/pcie_cfg_status_if] [get_bd_intf_pins qdma_0_support/pcie_cfg_status]
  connect_bd_intf_net -intf_net qdma_0_support_pcie_mgt_gt_pciea0 [get_bd_intf_pins gt_pciea0] [get_bd_intf_pins qdma_0_support/pcie_mgt]
  connect_bd_intf_net -intf_net qdma_0_support_pcie_transmit_fc [get_bd_intf_pins qdma_0/pcie_transmit_fc_if] [get_bd_intf_pins qdma_0_support/pcie_transmit_fc]
  connect_bd_intf_net -intf_net s_axi_mgmt_ctrl_1 [get_bd_intf_pins blp_logic/s_axi_mgmt_ctrl] [get_bd_intf_pins axi_noc_ic/M02_AXI]
  connect_bd_intf_net -intf_net s_axi_user_ctrl_1 [get_bd_intf_pins blp_logic/s_axi_user_ctrl] [get_bd_intf_pins axi_noc_ic/M01_AXI]
  connect_bd_intf_net -intf_net ulp_MC_M00_INI [get_bd_intf_pins ULP_S_INI_MC_00] [get_bd_intf_pins axi_noc_mc_1x/S04_INI]
  connect_bd_intf_net -intf_net ulp_MC_M01_INI [get_bd_intf_pins ULP_S_INI_MC_01] [get_bd_intf_pins axi_noc_mc_1x/S05_INI]
  connect_bd_intf_net -intf_net ulp_MC_M02_INI [get_bd_intf_pins ULP_S_INI_MC_02] [get_bd_intf_pins axi_noc_mc_1x/S07_INI]

  # Create port connections
  connect_bd_net -net blp_logic_aclk_ext_tog_kernel_00 [get_bd_pins blp_logic/aclk_ext_tog_kernel_00] [get_bd_pins dfx_decoupling/blp_s_aclk_ext_tog_kernel_00]
  connect_bd_net -net blp_logic_aclk_ext_tog_kernel_00 [get_bd_pins blp_logic/aclk_ext_tog_kernel_00] [get_bd_pins ulp_m_aclk_ext_tog_kernel_00]
  connect_bd_net -net blp_logic_aclk_ext_tog_kernel_01 [get_bd_pins blp_logic/aclk_ext_tog_kernel_01] [get_bd_pins dfx_decoupling/blp_s_aclk_ext_tog_kernel_01]
  connect_bd_net -net blp_logic_aclk_ext_tog_kernel_01 [get_bd_pins blp_logic/aclk_ext_tog_kernel_01] [get_bd_pins ulp_m_aclk_ext_tog_kernel_01]
  connect_bd_net -net blp_logic_aresetn_ext_tog_kernel_00 [get_bd_pins blp_logic/aresetn_ext_tog_kernel_00] [get_bd_pins dfx_decoupling/blp_s_aresetn_ext_tog_kernel_00]
  connect_bd_net -net blp_logic_aresetn_ext_tog_kernel_01 [get_bd_pins blp_logic/aresetn_ext_tog_kernel_01] [get_bd_pins dfx_decoupling/blp_s_aresetn_ext_tog_kernel_01]
  connect_bd_net -net blp_logic_clk_kernel0 [get_bd_pins blp_logic/clk_kernel0] [get_bd_pins ulp_m_aclk_kernel_00]
  connect_bd_net -net blp_logic_clk_kernel1 [get_bd_pins blp_logic/clk_kernel1] [get_bd_pins ulp_m_aclk_kernel_01]
  connect_bd_net -net blp_logic_ext_tog_ctrl_kernel_00_out [get_bd_pins blp_logic/ext_tog_ctrl_kernel_00_out] [get_bd_pins dfx_decoupling/blp_s_ext_tog_ctrl_kernel_00_out]
  connect_bd_net -net blp_logic_ext_tog_ctrl_kernel_01_out [get_bd_pins blp_logic/ext_tog_ctrl_kernel_01_out] [get_bd_pins dfx_decoupling/blp_s_ext_tog_ctrl_kernel_01_out]
  connect_bd_net -net blp_logic_force_reset_enable [get_bd_pins blp_logic/force_reset_enable] [get_bd_pins force_reset_concat_0/In0]
  connect_bd_net -net blp_logic_irq_cu_completion [get_bd_pins blp_logic/irq_cu_completion] [get_bd_pins cips/pl_ps_irq9]
  connect_bd_net -net blp_logic_irq_debug_uart_apu [get_bd_pins blp_logic/irq_debug_uart_apu] [get_bd_pins cips/pl_ps_irq10]
  connect_bd_net -net blp_logic_irq_debug_uart_rpu [get_bd_pins blp_logic/irq_debug_uart_rpu] [get_bd_pins cips/pl_ps_irq3]
  connect_bd_net -net blp_logic_irq_firewall_user [get_bd_pins blp_logic/irq_firewall_user] [get_bd_pins cips/pl_ps_irq2]
  connect_bd_net -net blp_logic_irq_fnc [get_bd_pins blp_logic/irq_fnc] [get_bd_pins qdma_0/usr_irq_in_fnc]
  connect_bd_net -net blp_logic_irq_gcq_a2r [get_bd_pins blp_logic/irq_gcq_a2r] [get_bd_pins cips/pl_ps_irq1]
  connect_bd_net -net blp_logic_irq_gcq_apu [get_bd_pins blp_logic/irq_gcq_apu] [get_bd_pins cips/pl_ps_irq11]
  connect_bd_net -net blp_logic_irq_gcq_m2r [get_bd_pins blp_logic/irq_gcq_m2r] [get_bd_pins cips/pl_ps_irq0]
  connect_bd_net -net blp_logic_irq_gcq_r2a [get_bd_pins blp_logic/irq_gcq_r2a] [get_bd_pins cips/pl_ps_irq8]
  connect_bd_net -net blp_logic_irq_vec [get_bd_pins blp_logic/irq_vec] [get_bd_pins qdma_0/usr_irq_in_vec]
  connect_bd_net -net blp_logic_irq_vld [get_bd_pins blp_logic/irq_vld] [get_bd_pins qdma_0/usr_irq_in_vld]
  connect_bd_net -net blp_m_dbg_hub_fw_00_1 [get_bd_pins dfx_decoupling/blp_m_dbg_hub_fw_00] [get_bd_pins cips/pl_ps_irq4]
  connect_bd_net -net cips_pl0_ref_clk [get_bd_pins cips/pl0_ref_clk] [get_bd_pins axi_noc_ic/aclk7]
  connect_bd_net -net cips_pl0_ref_clk [get_bd_pins cips/pl0_ref_clk] [get_bd_pins ulp_m_aclk_ctrl_00]
  connect_bd_net -net cips_pl0_ref_clk [get_bd_pins cips/pl0_ref_clk] [get_bd_pins blp_logic/clk_pl_axi]
  connect_bd_net -net cips_pl0_ref_clk [get_bd_pins cips/pl0_ref_clk] [get_bd_pins cips/m_axi_fpd_aclk]
  connect_bd_net -net cips_pl0_ref_clk [get_bd_pins cips/pl0_ref_clk] [get_bd_pins cips/m_axi_lpd_aclk]
  connect_bd_net -net cips_pl0_ref_clk [get_bd_pins cips/pl0_ref_clk] [get_bd_pins dfx_decoupling/blp_s_aclk_ctrl_00]
  connect_bd_net -net cips_pl0_resetn [get_bd_pins cips/pl0_resetn] [get_bd_pins blp_logic/resetn_pl_axi]
  connect_bd_net -net cips_pl1_ref_clk [get_bd_pins cips/pl1_ref_clk] [get_bd_pins blp_logic/clk_pl_ref]
  connect_bd_net -net cips_pl_pcie_resetn [get_bd_pins cips/pl_pcie0_resetn] [get_bd_pins qdma_0_support/sys_reset]
  connect_bd_net -net const_vcc_dout [get_bd_pins const_vcc/dout] [get_bd_pins qdma_0/tm_dsc_sts_rdy]
  connect_bd_net -net const_vcc_dout [get_bd_pins const_vcc/dout] [get_bd_pins qdma_0/qsts_out_rdy]
  connect_bd_net -net dfx_decoupling_blp_m_ext_tog_ctrl_kernel_00_enable [get_bd_pins dfx_decoupling/blp_m_ext_tog_ctrl_kernel_00_enable] [get_bd_pins blp_logic/ext_tog_ctrl_kernel_00_enable]
  connect_bd_net -net dfx_decoupling_blp_m_ext_tog_ctrl_kernel_00_in [get_bd_pins dfx_decoupling/blp_m_ext_tog_ctrl_kernel_00_in] [get_bd_pins blp_logic/ext_tog_ctrl_kernel_00_in]
  connect_bd_net -net dfx_decoupling_blp_m_ext_tog_ctrl_kernel_01_enable [get_bd_pins dfx_decoupling/blp_m_ext_tog_ctrl_kernel_01_enable] [get_bd_pins blp_logic/ext_tog_ctrl_kernel_01_enable]
  connect_bd_net -net dfx_decoupling_blp_m_ext_tog_ctrl_kernel_01_in [get_bd_pins dfx_decoupling/blp_m_ext_tog_ctrl_kernel_01_in] [get_bd_pins blp_logic/ext_tog_ctrl_kernel_01_in]
  connect_bd_net -net dfx_decoupling_blp_m_irq_kernel_00 [get_bd_pins dfx_decoupling/blp_m_irq_kernel_00] [get_bd_pins blp_logic/Din]
  connect_bd_net -net dfx_decoupling_ulp_m_aresetn_pcie_reset_00 [get_bd_pins dfx_decoupling/ulp_m_aresetn_pcie_reset_00] [get_bd_pins ulp_m_aresetn_pcie_reset_00]
  connect_bd_net -net dfx_decoupling_ulp_m_aresetn_pr_reset_00 [get_bd_pins dfx_decoupling/ulp_m_aresetn_pr_reset_00] [get_bd_pins ulp_m_aresetn_pr_reset_00]
  connect_bd_net -net dfx_decoupling_ulp_m_ext_tog_ctrl_kernel_00_out [get_bd_pins dfx_decoupling/ulp_m_ext_tog_ctrl_kernel_00_out] [get_bd_pins ulp_m_ext_tog_ctrl_kernel_00_out]
  connect_bd_net -net dfx_decoupling_ulp_m_ext_tog_ctrl_kernel_01_out [get_bd_pins dfx_decoupling/ulp_m_ext_tog_ctrl_kernel_01_out] [get_bd_pins ulp_m_ext_tog_ctrl_kernel_01_out]
  connect_bd_net -net force_reset_and_0_Res [get_bd_pins force_reset_and_0/Res] [get_bd_pins blp_logic/force_reset_result]
  connect_bd_net -net force_reset_concat_0_dout [get_bd_pins force_reset_concat_0/dout] [get_bd_pins force_reset_and_0/Op1]
  connect_bd_net -net force_reset_not_0_Res [get_bd_pins force_reset_not_0/Res] [get_bd_pins force_reset_concat_0/In1]
  connect_bd_net -net qdma_0_pcie_noc_axi_clk [get_bd_pins qdma_0/axi_aclk] [get_bd_pins qdma_0_smc/aclk]
  connect_bd_net -net qdma_0_pcie_noc_axi_clk [get_bd_pins qdma_0/axi_aclk] [get_bd_pins axi_noc_ic/aclk8]
  connect_bd_net -net qdma_0_support_phy_rdy_out [get_bd_pins qdma_0_support/phy_rdy_out] [get_bd_pins qdma_0/phy_rdy_out_sd]
  connect_bd_net -net qdma_0_support_user_lnk_up [get_bd_pins qdma_0_support/user_lnk_up] [get_bd_pins qdma_0/user_lnk_up_sd]
  connect_bd_net -net qdma_0_support_user_reset [get_bd_pins qdma_0_support/user_reset] [get_bd_pins qdma_0/user_reset_sd]
  connect_bd_net -net qdma_0_usr_irq_out_ack [get_bd_pins qdma_0/usr_irq_out_ack] [get_bd_pins blp_logic/irq_ack]
  connect_bd_net -net qdma_0_usr_irq_out_fail [get_bd_pins qdma_0/usr_irq_out_fail] [get_bd_pins blp_logic/irq_fail]
  connect_bd_net -net qdma_axi_aresetn [get_bd_pins qdma_0/axi_aresetn] [get_bd_pins blp_logic/resetn_pcie]
  connect_bd_net -net qdma_axi_aresetn [get_bd_pins qdma_0/axi_aresetn] [get_bd_pins force_reset_not_0/Op1]
  connect_bd_net -net qdma_axi_aresetn [get_bd_pins qdma_0/axi_aresetn] [get_bd_pins qdma_0_smc/aresetn]
  connect_bd_net -net qdma_pcie_user_clk [get_bd_pins qdma_0_support/user_clk] [get_bd_pins blp_logic/clk_pcie]
  connect_bd_net -net qdma_pcie_user_clk [get_bd_pins qdma_0_support/user_clk] [get_bd_pins ulp_m_aclk_pcie_00]
  connect_bd_net -net qdma_pcie_user_clk [get_bd_pins qdma_0_support/user_clk] [get_bd_pins blp_logic/clk_pl_pcie]
  connect_bd_net -net qdma_pcie_user_clk [get_bd_pins qdma_0_support/user_clk] [get_bd_pins dfx_decoupling/clk_pl_pcie]
  connect_bd_net -net qdma_pcie_user_clk [get_bd_pins qdma_0_support/user_clk] [get_bd_pins axi_noc_ic/aclk6]
  connect_bd_net -net qdma_pcie_user_clk [get_bd_pins qdma_0_support/user_clk] [get_bd_pins qdma_0/user_clk_sd]
  connect_bd_net -net resetn_pl_pcie_pr_net [get_bd_pins blp_logic/resetn_pl_pcie_pr] [get_bd_pins dfx_decoupling/blp_s_aresetn_pcie_reset_00]
  connect_bd_net -net resetn_pr_net [get_bd_pins blp_logic/resetn_pr] [get_bd_pins dfx_decoupling/blp_s_aresetn_pr_reset_00]
  connect_bd_net -net ulp_s_dbg_hub_fw_00_1 [get_bd_pins ulp_s_dbg_hub_fw_00] [get_bd_pins dfx_decoupling/ulp_s_dbg_hub_fw_00]
  connect_bd_net -net ulp_s_ext_tog_ctrl_kernel_00_enable [get_bd_pins ulp_s_ext_tog_ctrl_kernel_00_enable] [get_bd_pins dfx_decoupling/ulp_s_ext_tog_ctrl_kernel_00_enable]
  connect_bd_net -net ulp_s_ext_tog_ctrl_kernel_00_in [get_bd_pins ulp_s_ext_tog_ctrl_kernel_00_in] [get_bd_pins dfx_decoupling/ulp_s_ext_tog_ctrl_kernel_00_in]
  connect_bd_net -net ulp_s_ext_tog_ctrl_kernel_01_enable [get_bd_pins ulp_s_ext_tog_ctrl_kernel_01_enable] [get_bd_pins dfx_decoupling/ulp_s_ext_tog_ctrl_kernel_01_enable]
  connect_bd_net -net ulp_s_ext_tog_ctrl_kernel_01_in [get_bd_pins ulp_s_ext_tog_ctrl_kernel_01_in] [get_bd_pins dfx_decoupling/ulp_s_ext_tog_ctrl_kernel_01_in]
  connect_bd_net -net ulp_s_irq_kernel_00_1 [get_bd_pins ulp_s_irq_kernel_00] [get_bd_pins dfx_decoupling/ulp_s_irq_kernel_00]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell} {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
 }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
 }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
 }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  set_property -dict [list \
  SRC_RM_MAP./ulp.ulp {ulp_inst_0} \
  SRC_RM_MAP./ulp.ulp_training {ulp_training_inst_0} \
] [get_bd_designs $design_name]


  # Create interface ports

  set pcie_refclk [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 -portmaps { \
   CLK_N { physical_name pcie_refclk_clk_n direction I } \
   CLK_P { physical_name pcie_refclk_clk_p direction I } \
 } \
  pcie_refclk ]
  set_property -dict [ list \
   CONFIG.CAN_DEBUG {false} \
   CONFIG.FREQ_HZ {100000000} \
   ] $pcie_refclk

  set gt_pciea0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 -portmaps { \
   GRX_N { physical_name gt_pciea0_grx_n direction I left 7 right 0 } \
   GRX_P { physical_name gt_pciea0_grx_p direction I left 7 right 0 } \
   GTX_N { physical_name gt_pciea0_gtx_n direction O left 7 right 0 } \
   GTX_P { physical_name gt_pciea0_gtx_p direction O left 7 right 0 } \
 } \
  gt_pciea0 ]
  set_property -dict [ list \
   CONFIG.CAN_DEBUG {false} \
   ] $gt_pciea0

  # Create ports

  # Create instance: blp
  create_hier_cell_blp [current_bd_instance .] blp

  # Create instance: ulp, and set properties
  set ulp [ create_bd_cell -type container -reference ulp_training ulp ]
  set_property -dict [list \
    CONFIG.ACTIVE_SIM_BD {ulp_training.bd} \
    CONFIG.ACTIVE_SYNTH_BD {ulp_training.bd} \
    CONFIG.ENABLE_DFX {true} \
    CONFIG.LIST_SIM_BD {ulp.bd:ulp_training.bd} \
    CONFIG.LIST_SYNTH_BD {ulp.bd:ulp_training.bd} \
    CONFIG.LOCK_PROPAGATE {true} \
  ] $ulp


  set_property SELECTED_SIM_MODEL rtl  $ulp
  set_property APERTURES {{0x500_0000_0000 6G}} [get_bd_intf_pins /ulp/BLP_M_M00_INI_0]
  set_property APERTURES {{0x500_0000_0000 6G}} [get_bd_intf_pins /ulp/BLP_M_M01_INI_0]
  set_property APERTURES {{0x500_0000_0000 6G}} [get_bd_intf_pins /ulp/BLP_M_M02_INI_0]
  set_property APERTURES {{0x202_0000_0000 32M}} [get_bd_intf_pins /ulp/BLP_S_AXI_CTRL_USER_00]
  set_property APERTURES {{0x200_0000_0000 4G}} [get_bd_intf_pins /ulp/BLP_S_INI_AIE_00]
  set_property APERTURES {{0x202_0580_0000 2M}} [get_bd_intf_pins /ulp/BLP_S_INI_DBG_00]

  # Create interface connections
  connect_bd_intf_net -intf_net blp_ULP_M_AXI_CTRL_USER_00 [get_bd_intf_pins blp/ULP_M_AXI_CTRL_USER_00] [get_bd_intf_pins ulp/BLP_S_AXI_CTRL_USER_00]
  connect_bd_intf_net -intf_net blp_ULP_M_INI_AIE_00 [get_bd_intf_pins blp/ULP_M_INI_AIE_00] [get_bd_intf_pins ulp/BLP_S_INI_AIE_00]
  connect_bd_intf_net -intf_net blp_ULP_M_INI_DBG_00 [get_bd_intf_pins blp/ULP_M_INI_DBG_00] [get_bd_intf_pins ulp/BLP_S_INI_DBG_00]
  connect_bd_intf_net -intf_net blp_ULP_S_INI_MC_00 [get_bd_intf_pins ulp/BLP_M_M00_INI_0] [get_bd_intf_pins blp/ULP_S_INI_MC_00]
  connect_bd_intf_net -intf_net blp_ULP_S_INI_MC_01 [get_bd_intf_pins ulp/BLP_M_M01_INI_0] [get_bd_intf_pins blp/ULP_S_INI_MC_01]
  connect_bd_intf_net -intf_net blp_ULP_S_INI_MC_02 [get_bd_intf_pins ulp/BLP_M_M02_INI_0] [get_bd_intf_pins blp/ULP_S_INI_MC_02]

  connect_bd_intf_net -intf_net blp_gt_pciea0 [get_bd_intf_ports gt_pciea0] [get_bd_intf_pins blp/gt_pciea0]
  connect_bd_intf_net -intf_net pcie_refclk_1 [get_bd_intf_ports pcie_refclk] [get_bd_intf_pins blp/pcie_refclk]

  # Create port connections
  connect_bd_net -net blp_ulp_aclk_ext_tog_kernel_00 [get_bd_pins blp/ulp_m_aclk_ext_tog_kernel_00] [get_bd_pins ulp/blp_s_aclk_ext_tog_kernel_00]
  connect_bd_net -net blp_ulp_aclk_ext_tog_kernel_01 [get_bd_pins blp/ulp_m_aclk_ext_tog_kernel_01] [get_bd_pins ulp/blp_s_aclk_ext_tog_kernel_01]
  connect_bd_net -net blp_ulp_ext_tog_ctrl_kernel_00_out [get_bd_pins blp/ulp_m_ext_tog_ctrl_kernel_00_out] [get_bd_pins ulp/blp_s_ext_tog_ctrl_kernel_00_out]
  connect_bd_net -net blp_ulp_ext_tog_ctrl_kernel_01_out [get_bd_pins blp/ulp_m_ext_tog_ctrl_kernel_01_out] [get_bd_pins ulp/blp_s_ext_tog_ctrl_kernel_01_out]
  connect_bd_net -net blp_ulp_m_aclk_ctrl_00 [get_bd_pins blp/ulp_m_aclk_ctrl_00] [get_bd_pins ulp/blp_s_aclk_ctrl_00]
  connect_bd_net -net blp_ulp_m_aclk_kernel_00 [get_bd_pins blp/ulp_m_aclk_kernel_00] [get_bd_pins ulp/blp_s_aclk_kernel_00]
  connect_bd_net -net blp_ulp_m_aclk_kernel_01 [get_bd_pins blp/ulp_m_aclk_kernel_01] [get_bd_pins ulp/blp_s_aclk_kernel_01]
  connect_bd_net -net blp_ulp_m_aclk_pcie_00 [get_bd_pins blp/ulp_m_aclk_pcie_00] [get_bd_pins ulp/blp_s_aclk_pcie_00]
  connect_bd_net -net blp_ulp_m_aresetn_pcie_reset_00 [get_bd_pins blp/ulp_m_aresetn_pcie_reset_00] [get_bd_pins ulp/blp_s_aresetn_pcie_reset_00]
  connect_bd_net -net blp_ulp_m_aresetn_pr_reset_00 [get_bd_pins blp/ulp_m_aresetn_pr_reset_00] [get_bd_pins ulp/blp_s_aresetn_pr_reset_00]
  connect_bd_net -net ulp_blp_dbg_hub_fw_00 [get_bd_pins ulp/blp_m_dbg_hub_fw_00] [get_bd_pins blp/ulp_s_dbg_hub_fw_00]
  connect_bd_net -net ulp_blp_ext_tog_ctrl_kernel_00_enable [get_bd_pins ulp/blp_m_ext_tog_ctrl_kernel_00_enable] [get_bd_pins blp/ulp_s_ext_tog_ctrl_kernel_00_enable]
  connect_bd_net -net ulp_blp_ext_tog_ctrl_kernel_00_in [get_bd_pins ulp/blp_m_ext_tog_ctrl_kernel_00_in] [get_bd_pins blp/ulp_s_ext_tog_ctrl_kernel_00_in]
  connect_bd_net -net ulp_blp_ext_tog_ctrl_kernel_01_enable [get_bd_pins ulp/blp_m_ext_tog_ctrl_kernel_01_enable] [get_bd_pins blp/ulp_s_ext_tog_ctrl_kernel_01_enable]
  connect_bd_net -net ulp_blp_ext_tog_ctrl_kernel_01_in [get_bd_pins ulp/blp_m_ext_tog_ctrl_kernel_01_in] [get_bd_pins blp/ulp_s_ext_tog_ctrl_kernel_01_in]
  connect_bd_net -net ulp_blp_m_irq_kernel_00 [get_bd_pins ulp/blp_m_irq_kernel_00] [get_bd_pins blp/ulp_s_irq_kernel_00]

  save_bd_design;

  # Create address segments
  assign_bd_address -offset 0x050000000000 -range 0x000180000000 -target_address_space [get_bd_addr_spaces ulp/axi_vip_0/Master_AXI] [get_bd_addr_segs blp/axi_noc_mc_1x/S04_INI/C1_DDR_CH1] -force
  assign_bd_address -offset 0x050000000000 -range 0x000180000000 -target_address_space [get_bd_addr_spaces ulp/axi_vip_1/Master_AXI] [get_bd_addr_segs blp/axi_noc_mc_1x/S05_INI/C2_DDR_CH1] -force
  assign_bd_address -offset 0x050000000000 -range 0x000180000000 -target_address_space [get_bd_addr_spaces ulp/axi_vip_2/Master_AXI] [get_bd_addr_segs blp/axi_noc_mc_1x/S07_INI/C0_DDR_CH1] -force
  assign_bd_address -offset 0x020000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_0] [get_bd_addr_segs ulp/ai_engine_0/S00_AXI/AIE_ARRAY_0] -force
  assign_bd_address -offset 0x020200000000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_0] [get_bd_addr_segs ulp/axi_gpio_null_user/S_AXI/Reg] -force
  assign_bd_address -offset 0x020202020000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_0] [get_bd_addr_segs blp/blp_logic/ert_support/axi_intc_0_31/S_AXI/Reg] -force
  assign_bd_address -offset 0x050000000000 -range 0x000180000000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_0] [get_bd_addr_segs blp/axi_noc_mc_1x/S00_INI/C0_DDR_CH1] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_0] [get_bd_addr_segs blp/axi_noc_mc_1x/S00_INI/C0_DDR_LOW0] -force
  assign_bd_address -offset 0x020000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_1] [get_bd_addr_segs ulp/ai_engine_0/S00_AXI/AIE_ARRAY_0] -force
  assign_bd_address -offset 0x020200000000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_1] [get_bd_addr_segs ulp/axi_gpio_null_user/S_AXI/Reg] -force
  assign_bd_address -offset 0x020202020000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_1] [get_bd_addr_segs blp/blp_logic/ert_support/axi_intc_0_31/S_AXI/Reg] -force
  assign_bd_address -offset 0x050000000000 -range 0x000180000000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_1] [get_bd_addr_segs blp/axi_noc_mc_1x/S01_INI/C1_DDR_CH1] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_1] [get_bd_addr_segs blp/axi_noc_mc_1x/S01_INI/C1_DDR_LOW0] -force
  assign_bd_address -offset 0x020000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_2] [get_bd_addr_segs ulp/ai_engine_0/S00_AXI/AIE_ARRAY_0] -force
  assign_bd_address -offset 0x020200000000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_2] [get_bd_addr_segs ulp/axi_gpio_null_user/S_AXI/Reg] -force
  assign_bd_address -offset 0x020202020000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_2] [get_bd_addr_segs blp/blp_logic/ert_support/axi_intc_0_31/S_AXI/Reg] -force
  assign_bd_address -offset 0x050000000000 -range 0x000180000000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_2] [get_bd_addr_segs blp/axi_noc_mc_1x/S02_INI/C2_DDR_CH1] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_2] [get_bd_addr_segs blp/axi_noc_mc_1x/S02_INI/C2_DDR_LOW0] -force
  assign_bd_address -offset 0x020000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_3] [get_bd_addr_segs ulp/ai_engine_0/S00_AXI/AIE_ARRAY_0] -force
  assign_bd_address -offset 0x020200000000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_3] [get_bd_addr_segs ulp/axi_gpio_null_user/S_AXI/Reg] -force
  assign_bd_address -offset 0x020202020000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_3] [get_bd_addr_segs blp/blp_logic/ert_support/axi_intc_0_31/S_AXI/Reg] -force
  assign_bd_address -offset 0x050000000000 -range 0x000180000000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_3] [get_bd_addr_segs blp/axi_noc_mc_1x/S03_INI/C3_DDR_CH1] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_3] [get_bd_addr_segs blp/axi_noc_mc_1x/S03_INI/C3_DDR_LOW0] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces blp/cips/LPD_AXI_NOC_0] [get_bd_addr_segs blp/axi_noc_mc_1x/S00_INI/C0_DDR_LOW0] -force
  assign_bd_address -offset 0x000402031000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/M_AXI_FPD] [get_bd_addr_segs blp/blp_logic/axi_intc_gcq_apu/S_AXI/Reg] -force
  assign_bd_address -offset 0x000402030000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/M_AXI_FPD] [get_bd_addr_segs blp/blp_logic/axi_intc_uart_apu/S_AXI/Reg] -force
  assign_bd_address -offset 0x000402020000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/M_AXI_FPD] [get_bd_addr_segs blp/blp_logic/axi_uart_apu0/S_AXI/Reg] -force
  assign_bd_address -offset 0x000402000000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/M_AXI_FPD] [get_bd_addr_segs blp/blp_logic/gcq_r2a/S01_AXI/S01_AXI_Reg] -force
  assign_bd_address -offset 0x000402010000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/M_AXI_FPD] [get_bd_addr_segs blp/blp_logic/gcq_u2a_0/S01_AXI/S01_AXI_Reg] -force
  assign_bd_address -offset 0x80001000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/M_AXI_LPD] [get_bd_addr_segs blp/blp_logic/axi_firewall_user/S_AXI_CTL/Control] -force
  assign_bd_address -offset 0x80021000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/M_AXI_LPD] [get_bd_addr_segs blp/blp_logic/axi_uart_rpu/S_AXI/Reg] -force
  assign_bd_address -offset 0x80042000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/M_AXI_LPD] [get_bd_addr_segs blp/blp_logic/ulp_clocking/clkwiz_aclk_kernel_00/s_axi_lite/Reg] -force
  assign_bd_address -offset 0x80043000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/M_AXI_LPD] [get_bd_addr_segs blp/blp_logic/ulp_clocking/clkwiz_aclk_kernel_01/s_axi_lite/Reg] -force
  assign_bd_address -offset 0x80010000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/M_AXI_LPD] [get_bd_addr_segs blp/blp_logic/gcq_m2r/S01_AXI/S01_AXI_Reg] -force
  assign_bd_address -offset 0x80011000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/M_AXI_LPD] [get_bd_addr_segs blp/blp_logic/gcq_r2a/S00_AXI/S00_AXI_Reg] -force
  assign_bd_address -offset 0x80044000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/M_AXI_LPD] [get_bd_addr_segs blp/blp_logic/pfm_irq_ctlr/S_AXI/Reg] -force
  assign_bd_address -offset 0x80020000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/M_AXI_LPD] [get_bd_addr_segs blp/blp_logic/base_clocking/pr_reset_gpio/S_AXI/Reg] -force
  assign_bd_address -offset 0x80030000 -range 0x00010000 -target_address_space [get_bd_addr_spaces blp/cips/M_AXI_LPD] [get_bd_addr_segs blp/blp_logic/ulp_clocking/shell_utils_ucc/S_AXI_CTRL_MGMT/reg0] -force
  assign_bd_address -offset 0x80045000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/M_AXI_LPD] [get_bd_addr_segs blp/blp_logic/uuid_register/S0_AXI/reg0] -force
  assign_bd_address -offset 0x020000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces blp/cips/PMC_NOC_AXI_0] [get_bd_addr_segs ulp/ai_engine_0/S00_AXI/AIE_ARRAY_0] -force
  assign_bd_address -offset 0x020105000000 -range 0x00200000 -target_address_space [get_bd_addr_spaces blp/cips/PMC_NOC_AXI_0] [get_bd_addr_segs blp/blp_logic/axi_blp_dbg_hub/S_AXI_DBG_HUB/Mem0] -force
  assign_bd_address -offset 0x020205800000 -range 0x00200000 -target_address_space [get_bd_addr_spaces blp/cips/PMC_NOC_AXI_0] [get_bd_addr_segs ulp/axi_dbg_hub/S_AXI_DBG_HUB/Mem0] -force
  assign_bd_address -offset 0x050000000000 -range 0x000180000000 -target_address_space [get_bd_addr_spaces blp/cips/PMC_NOC_AXI_0] [get_bd_addr_segs blp/axi_noc_mc_1x/S00_INI/C0_DDR_CH1] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces blp/cips/PMC_NOC_AXI_0] [get_bd_addr_segs blp/axi_noc_mc_1x/S00_INI/C0_DDR_LOW0] -force
  assign_bd_address -offset 0x020105000000 -range 0x00200000 -target_address_space [get_bd_addr_spaces blp/qdma_0/M_AXI] [get_bd_addr_segs blp/blp_logic/axi_blp_dbg_hub/S_AXI_DBG_HUB/Mem0] -force
  assign_bd_address -offset 0x020205800000 -range 0x00200000 -target_address_space [get_bd_addr_spaces blp/qdma_0/M_AXI] [get_bd_addr_segs ulp/axi_dbg_hub/S_AXI_DBG_HUB/Mem0] -force
  assign_bd_address -offset 0x050000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces blp/qdma_0/M_AXI] [get_bd_addr_segs blp/axi_noc_mc_1x/S00_INI/C0_DDR_CH1] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces blp/qdma_0/M_AXI] [get_bd_addr_segs blp/axi_noc_mc_1x/S00_INI/C0_DDR_LOW0] -force
  assign_bd_address -offset 0x020105000000 -range 0x00200000 -target_address_space [get_bd_addr_spaces blp/qdma_0/M_AXI_BRIDGE] [get_bd_addr_segs blp/blp_logic/axi_blp_dbg_hub/S_AXI_DBG_HUB/Mem0] -force
  assign_bd_address -offset 0x020205800000 -range 0x00200000 -target_address_space [get_bd_addr_spaces blp/qdma_0/M_AXI_BRIDGE] [get_bd_addr_segs ulp/axi_dbg_hub/S_AXI_DBG_HUB/Mem0] -force
  assign_bd_address -offset 0x020200000000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/qdma_0/M_AXI_BRIDGE] [get_bd_addr_segs ulp/axi_gpio_null_user/S_AXI/Reg] -force
  assign_bd_address -offset 0x020202020000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/qdma_0/M_AXI_BRIDGE] [get_bd_addr_segs blp/blp_logic/ert_support/axi_intc_0_31/S_AXI/Reg] -force
  assign_bd_address -offset 0x020108000000 -range 0x08000000 -target_address_space [get_bd_addr_spaces blp/qdma_0/M_AXI_BRIDGE] [get_bd_addr_segs blp/axi_noc_mc_1x/S06_INI/C3_DDR_LOW0] -force
  assign_bd_address -offset 0x020102021000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/qdma_0/M_AXI_BRIDGE] [get_bd_addr_segs blp/blp_logic/axi_uart_mgmt_apu0/S_AXI/Reg] -force
  assign_bd_address -offset 0x020102020000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/qdma_0/M_AXI_BRIDGE] [get_bd_addr_segs blp/blp_logic/axi_uart_mgmt_rpu/S_AXI/Reg] -force
  assign_bd_address -offset 0x020102040000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/qdma_0/M_AXI_BRIDGE] [get_bd_addr_segs blp/blp_logic/base_clocking/force_reset_gpio/S_AXI/Reg] -force
  assign_bd_address -offset 0x020102010000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/qdma_0/M_AXI_BRIDGE] [get_bd_addr_segs blp/blp_logic/gcq_m2r/S00_AXI/S00_AXI_Reg] -force
  assign_bd_address -offset 0x020202010000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/qdma_0/M_AXI_BRIDGE] [get_bd_addr_segs blp/blp_logic/gcq_u2a_0/S00_AXI/S00_AXI_Reg] -force
  assign_bd_address -offset 0x020102001000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/qdma_0/M_AXI_BRIDGE] [get_bd_addr_segs blp/blp_logic/hw_discovery/s_axi_ctrl_pf0/reg0] -force
  assign_bd_address -offset 0x020202001000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/qdma_0/M_AXI_BRIDGE] [get_bd_addr_segs blp/blp_logic/hw_discovery/s_axi_ctrl_pf1/reg0] -force
  assign_bd_address -offset 0x020102000000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/qdma_0/M_AXI_BRIDGE] [get_bd_addr_segs blp/blp_logic/pf_mailbox/S0_AXI/S0_AXI_Reg] -force
  assign_bd_address -offset 0x020202000000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/qdma_0/M_AXI_BRIDGE] [get_bd_addr_segs blp/blp_logic/pf_mailbox/S1_AXI/S1_AXI_Reg] -force
  assign_bd_address -offset 0x020107000000 -range 0x00004000 -target_address_space [get_bd_addr_spaces blp/qdma_0/M_AXI_BRIDGE] [get_bd_addr_segs blp/qdma_0/S_AXI_LITE_CSR/CTL0] -force
  assign_bd_address -offset 0x020102002000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/qdma_0/M_AXI_BRIDGE] [get_bd_addr_segs blp/blp_logic/uuid_register/S1_AXI/reg0] -force

  # Exclude Address Segments
  exclude_bd_addr_seg -offset 0x020102021000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_0] [get_bd_addr_segs blp/blp_logic/axi_uart_mgmt_apu0/S_AXI/Reg]
  exclude_bd_addr_seg -offset 0x020102020000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_0] [get_bd_addr_segs blp/blp_logic/axi_uart_mgmt_rpu/S_AXI/Reg]
  exclude_bd_addr_seg -offset 0x020102040000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_0] [get_bd_addr_segs blp/blp_logic/base_clocking/force_reset_gpio/S_AXI/Reg]
  exclude_bd_addr_seg -offset 0x020102010000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_0] [get_bd_addr_segs blp/blp_logic/gcq_m2r/S00_AXI/S00_AXI_Reg]
  exclude_bd_addr_seg -offset 0x020202010000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_0] [get_bd_addr_segs blp/blp_logic/gcq_u2a_0/S00_AXI/S00_AXI_Reg]
  exclude_bd_addr_seg -offset 0x020202001000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_0] [get_bd_addr_segs blp/blp_logic/hw_discovery/s_axi_ctrl_pf1/reg0]
  exclude_bd_addr_seg -offset 0x020102001000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_0] [get_bd_addr_segs blp/blp_logic/hw_discovery/s_axi_ctrl_pf0/reg0]
  exclude_bd_addr_seg -offset 0x020202000000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_0] [get_bd_addr_segs blp/blp_logic/pf_mailbox/S1_AXI/S1_AXI_Reg]
  exclude_bd_addr_seg -offset 0x020102000000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_0] [get_bd_addr_segs blp/blp_logic/pf_mailbox/S0_AXI/S0_AXI_Reg]
  exclude_bd_addr_seg -offset 0x020102002000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_0] [get_bd_addr_segs blp/blp_logic/uuid_register/S1_AXI/reg0]
  exclude_bd_addr_seg -offset 0x020102021000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_1] [get_bd_addr_segs blp/blp_logic/axi_uart_mgmt_apu0/S_AXI/Reg]
  exclude_bd_addr_seg -offset 0x020102020000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_1] [get_bd_addr_segs blp/blp_logic/axi_uart_mgmt_rpu/S_AXI/Reg]
  exclude_bd_addr_seg -offset 0x020102040000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_1] [get_bd_addr_segs blp/blp_logic/base_clocking/force_reset_gpio/S_AXI/Reg]
  exclude_bd_addr_seg -offset 0x020102010000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_1] [get_bd_addr_segs blp/blp_logic/gcq_m2r/S00_AXI/S00_AXI_Reg]
  exclude_bd_addr_seg -offset 0x020202010000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_1] [get_bd_addr_segs blp/blp_logic/gcq_u2a_0/S00_AXI/S00_AXI_Reg]
  exclude_bd_addr_seg -offset 0x020202001000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_1] [get_bd_addr_segs blp/blp_logic/hw_discovery/s_axi_ctrl_pf1/reg0]
  exclude_bd_addr_seg -offset 0x020102001000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_1] [get_bd_addr_segs blp/blp_logic/hw_discovery/s_axi_ctrl_pf0/reg0]
  exclude_bd_addr_seg -offset 0x020202000000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_1] [get_bd_addr_segs blp/blp_logic/pf_mailbox/S1_AXI/S1_AXI_Reg]
  exclude_bd_addr_seg -offset 0x020102000000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_1] [get_bd_addr_segs blp/blp_logic/pf_mailbox/S0_AXI/S0_AXI_Reg]
  exclude_bd_addr_seg -offset 0x020102002000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_1] [get_bd_addr_segs blp/blp_logic/uuid_register/S1_AXI/reg0]
  exclude_bd_addr_seg -offset 0x020102021000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_2] [get_bd_addr_segs blp/blp_logic/axi_uart_mgmt_apu0/S_AXI/Reg]
  exclude_bd_addr_seg -offset 0x020102020000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_2] [get_bd_addr_segs blp/blp_logic/axi_uart_mgmt_rpu/S_AXI/Reg]
  exclude_bd_addr_seg -offset 0x020102040000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_2] [get_bd_addr_segs blp/blp_logic/base_clocking/force_reset_gpio/S_AXI/Reg]
  exclude_bd_addr_seg -offset 0x020102010000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_2] [get_bd_addr_segs blp/blp_logic/gcq_m2r/S00_AXI/S00_AXI_Reg]
  exclude_bd_addr_seg -offset 0x020202010000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_2] [get_bd_addr_segs blp/blp_logic/gcq_u2a_0/S00_AXI/S00_AXI_Reg]
  exclude_bd_addr_seg -offset 0x020202001000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_2] [get_bd_addr_segs blp/blp_logic/hw_discovery/s_axi_ctrl_pf1/reg0]
  exclude_bd_addr_seg -offset 0x020102001000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_2] [get_bd_addr_segs blp/blp_logic/hw_discovery/s_axi_ctrl_pf0/reg0]
  exclude_bd_addr_seg -offset 0x020202000000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_2] [get_bd_addr_segs blp/blp_logic/pf_mailbox/S1_AXI/S1_AXI_Reg]
  exclude_bd_addr_seg -offset 0x020102000000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_2] [get_bd_addr_segs blp/blp_logic/pf_mailbox/S0_AXI/S0_AXI_Reg]
  exclude_bd_addr_seg -offset 0x020102002000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_2] [get_bd_addr_segs blp/blp_logic/uuid_register/S1_AXI/reg0]
  exclude_bd_addr_seg -offset 0x020102021000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_3] [get_bd_addr_segs blp/blp_logic/axi_uart_mgmt_apu0/S_AXI/Reg]
  exclude_bd_addr_seg -offset 0x020102020000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_3] [get_bd_addr_segs blp/blp_logic/axi_uart_mgmt_rpu/S_AXI/Reg]
  exclude_bd_addr_seg -offset 0x020102040000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_3] [get_bd_addr_segs blp/blp_logic/base_clocking/force_reset_gpio/S_AXI/Reg]
  exclude_bd_addr_seg -offset 0x020102010000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_3] [get_bd_addr_segs blp/blp_logic/gcq_m2r/S00_AXI/S00_AXI_Reg]
  exclude_bd_addr_seg -offset 0x020202010000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_3] [get_bd_addr_segs blp/blp_logic/gcq_u2a_0/S00_AXI/S00_AXI_Reg]
  exclude_bd_addr_seg -offset 0x020202001000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_3] [get_bd_addr_segs blp/blp_logic/hw_discovery/s_axi_ctrl_pf1/reg0]
  exclude_bd_addr_seg -offset 0x020102001000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_3] [get_bd_addr_segs blp/blp_logic/hw_discovery/s_axi_ctrl_pf0/reg0]
  exclude_bd_addr_seg -offset 0x020202000000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_3] [get_bd_addr_segs blp/blp_logic/pf_mailbox/S1_AXI/S1_AXI_Reg]
  exclude_bd_addr_seg -offset 0x020102000000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_3] [get_bd_addr_segs blp/blp_logic/pf_mailbox/S0_AXI/S0_AXI_Reg]
  exclude_bd_addr_seg -offset 0x020102002000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_3] [get_bd_addr_segs blp/blp_logic/uuid_register/S1_AXI/reg0]
  exclude_bd_addr_seg -offset 0x050000000000 -range 0x000180000000 -target_address_space [get_bd_addr_spaces blp/cips/LPD_AXI_NOC_0] [get_bd_addr_segs blp/axi_noc_mc_1x/S00_INI/C0_DDR_CH1]
  exclude_bd_addr_seg -offset 0x020102021000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/PMC_NOC_AXI_0] [get_bd_addr_segs blp/blp_logic/axi_uart_mgmt_apu0/S_AXI/Reg]
  exclude_bd_addr_seg -offset 0x020102020000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/PMC_NOC_AXI_0] [get_bd_addr_segs blp/blp_logic/axi_uart_mgmt_rpu/S_AXI/Reg]
  exclude_bd_addr_seg -offset 0x020102040000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/PMC_NOC_AXI_0] [get_bd_addr_segs blp/blp_logic/base_clocking/force_reset_gpio/S_AXI/Reg]
  exclude_bd_addr_seg -offset 0x020102010000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/PMC_NOC_AXI_0] [get_bd_addr_segs blp/blp_logic/gcq_m2r/S00_AXI/S00_AXI_Reg]
  exclude_bd_addr_seg -offset 0x020102001000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/PMC_NOC_AXI_0] [get_bd_addr_segs blp/blp_logic/hw_discovery/s_axi_ctrl_pf0/reg0]
  exclude_bd_addr_seg -offset 0x020102000000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/PMC_NOC_AXI_0] [get_bd_addr_segs blp/blp_logic/pf_mailbox/S0_AXI/S0_AXI_Reg]
  exclude_bd_addr_seg -offset 0x020107000000 -range 0x00004000 -target_address_space [get_bd_addr_spaces blp/cips/PMC_NOC_AXI_0] [get_bd_addr_segs blp/qdma_0/S_AXI_LITE_CSR/CTL0]
  exclude_bd_addr_seg -offset 0x020102002000 -range 0x00001000 -target_address_space [get_bd_addr_spaces blp/cips/PMC_NOC_AXI_0] [get_bd_addr_segs blp/blp_logic/uuid_register/S1_AXI/reg0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces blp/qdma_0/M_AXI_BRIDGE] [get_bd_addr_segs blp/axi_noc_mc_1x/S06_INI/C3_DDR_CH1]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces ulp/axi_vip_0/Master_AXI] [get_bd_addr_segs blp/axi_noc_mc_1x/S04_INI/C1_DDR_LOW0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces ulp/axi_vip_1/Master_AXI] [get_bd_addr_segs blp/axi_noc_mc_1x/S05_INI/C2_DDR_LOW0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces ulp/axi_vip_2/Master_AXI] [get_bd_addr_segs blp/axi_noc_mc_1x/S07_INI/C0_DDR_LOW0]


  # Restore current instance
  current_bd_instance $oldCurInst


  # Add XRT_ENDPOINT properties for metadata automation

  set_property PFM.XRT_ENDPOINT \
    [dict create \
      S0_AXI ep_mailbox_mgmt_00 \
      S1_AXI ep_mailbox_user_00 \
    ] [get_bd_cells /blp/blp_logic/pf_mailbox]

  set_property PFM.XRT_ENDPOINT \
    [dict create \
      S00_AXI [dict create ep_xgq_user_to_apu_sq_pi_00 [dict create reg_abs "xilinx.com:reg_abs:xgq:1.2" interrupt irq_cq]] \
    ] [get_bd_cells /blp/blp_logic/gcq_u2a_0]

  set_property PFM.XRT_ENDPOINT \
    [dict create \
      S00_AXI [dict create ep_xgq_mgmt_to_rpu_sq_pi_00 [dict create reg_abs "xilinx.com:reg_abs:xgq:1.2"]] \
    ] [get_bd_cells /blp/blp_logic/gcq_m2r]

  set_property PFM.XRT_ENDPOINT \
    [dict create \
      s_axi_ctrl_pf0 ep_bar_layout_mgmt_00 \
      s_axi_ctrl_pf1 ep_bar_layout_user_00 \
    ] [get_bd_cells /blp/blp_logic/hw_discovery]

  set_property PFM.XRT_ENDPOINT \
    [dict create \
      S1_AXI ep_blp_rom_00 \
    ] [get_bd_cells /blp/blp_logic/uuid_register]

  set_property PFM.XRT_ENDPOINT \
    [dict create \
      S_AXI ep_pmc_mux_00 \
    ] [get_bd_cells /blp/blp_logic/base_clocking/force_reset_gpio]

  set_property PFM.XRT_ENDPOINT \
    [dict create \
      S_AXI ep_ert_debug_uart_00 \
    ] [get_bd_cells /blp/blp_logic/axi_uart_mgmt_rpu]

  set_property PFM.XRT_ENDPOINT \
    [dict create \
      S_AXI ep_ert_debug_uart_01 \
    ] [get_bd_cells /blp/blp_logic/axi_uart_mgmt_apu0]

  set_property PFM.XRT_ENDPOINT \
    [dict create \
      S_AXI [dict create ep_debug_hub_mgmt_00 [dict create reg_abs "xilinx.com:reg_abs:debug_hub:1.0"]] \
    ] [get_bd_cells /blp/blp_logic/axi_blp_dbg_hub]

  validate_bd_design
  save_bd_design

}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""
