## Copyright (C) 2023 Advanced Micro Devices, Inc.
## SPDX-License-Identifier: MIT

proc init { cell_name undefined_params } {
  set cell [get_bd_cells $cell_name]
  set_property CONFIG.ASSOCIATED_BUSIF {S_AXI_CTRL_MGMT} [get_bd_pins $cell_name/aclk_ctrl]
  set_property CONFIG.ASSOCIATED_RESET {aresetn_ctrl} [get_bd_pins $cell_name/aclk_ctrl]
}

proc propagate { cell_name args } {
  set cell [get_bd_cells $cell_name]
  set_property CONFIG.FREQ_HZ [get_property CONFIG.FREQ_HZ [get_bd_pins $cell_name/clk_in_kernel_00]] [get_bd_pins $cell_name/aclk_kernel_cont_00]
  if {[get_property CONFIG.NUM_CLOCKS $cell] > 1} {set_property CONFIG.FREQ_HZ [get_property CONFIG.FREQ_HZ [get_bd_pins $cell_name/clk_in_kernel_01]] [get_bd_pins $cell_name/aclk_kernel_cont_01]  }
  if {[get_property CONFIG.NUM_CLOCKS $cell] > 2} {set_property CONFIG.FREQ_HZ [get_property CONFIG.FREQ_HZ [get_bd_pins $cell_name/clk_in_kernel_02]] [get_bd_pins $cell_name/aclk_kernel_cont_02]  }
  if {[get_property CONFIG.NUM_CLOCKS $cell] > 3} {set_property CONFIG.FREQ_HZ [get_property CONFIG.FREQ_HZ [get_bd_pins $cell_name/clk_in_kernel_03]] [get_bd_pins $cell_name/aclk_kernel_cont_03]  }
  if {[get_property CONFIG.NUM_CLOCKS $cell] > 4} {set_property CONFIG.FREQ_HZ [get_property CONFIG.FREQ_HZ [get_bd_pins $cell_name/clk_in_kernel_04]] [get_bd_pins $cell_name/aclk_kernel_cont_04]  }
  if {[get_property CONFIG.NUM_CLOCKS $cell] > 5} {set_property CONFIG.FREQ_HZ [get_property CONFIG.FREQ_HZ [get_bd_pins $cell_name/clk_in_kernel_05]] [get_bd_pins $cell_name/aclk_kernel_cont_05]  }
  set_property CONFIG.FREQ_HZ [get_property CONFIG.FREQ_HZ [get_bd_pins $cell_name/clk_in_kernel_00]] [get_bd_pins $cell_name/aclk_kernel_00]
  if {[get_property CONFIG.NUM_CLOCKS $cell] > 1} {set_property CONFIG.FREQ_HZ [get_property CONFIG.FREQ_HZ [get_bd_pins $cell_name/clk_in_kernel_01]] [get_bd_pins $cell_name/aclk_kernel_01]  }
  if {[get_property CONFIG.NUM_CLOCKS $cell] > 2} {set_property CONFIG.FREQ_HZ [get_property CONFIG.FREQ_HZ [get_bd_pins $cell_name/clk_in_kernel_02]] [get_bd_pins $cell_name/aclk_kernel_02]  }
  if {[get_property CONFIG.NUM_CLOCKS $cell] > 3} {set_property CONFIG.FREQ_HZ [get_property CONFIG.FREQ_HZ [get_bd_pins $cell_name/clk_in_kernel_03]] [get_bd_pins $cell_name/aclk_kernel_03]  }
  if {[get_property CONFIG.NUM_CLOCKS $cell] > 4} {set_property CONFIG.FREQ_HZ [get_property CONFIG.FREQ_HZ [get_bd_pins $cell_name/clk_in_kernel_04]] [get_bd_pins $cell_name/aclk_kernel_04]  }
  if {[get_property CONFIG.NUM_CLOCKS $cell] > 5} {set_property CONFIG.FREQ_HZ [get_property CONFIG.FREQ_HZ [get_bd_pins $cell_name/clk_in_kernel_05]] [get_bd_pins $cell_name/aclk_kernel_05]  }

  if {[get_property CONFIG.EXT_TOG_ENABLE $cell] > 0} {
    set_property CONFIG.FREQ_HZ [get_property CONFIG.FREQ_HZ [get_bd_pins $cell_name/clk_in_kernel_00]] [get_bd_pins $cell_name/aclk_ext_tog_kernel_00]
    if {[get_property CONFIG.NUM_CLOCKS $cell] > 1} {set_property CONFIG.FREQ_HZ [get_property CONFIG.FREQ_HZ [get_bd_pins $cell_name/clk_in_kernel_01]] [get_bd_pins $cell_name/aclk_ext_tog_kernel_01]  }
    if {[get_property CONFIG.NUM_CLOCKS $cell] > 2} {set_property CONFIG.FREQ_HZ [get_property CONFIG.FREQ_HZ [get_bd_pins $cell_name/clk_in_kernel_02]] [get_bd_pins $cell_name/aclk_ext_tog_kernel_02]  }
    if {[get_property CONFIG.NUM_CLOCKS $cell] > 3} {set_property CONFIG.FREQ_HZ [get_property CONFIG.FREQ_HZ [get_bd_pins $cell_name/clk_in_kernel_03]] [get_bd_pins $cell_name/aclk_ext_tog_kernel_03]  }
    if {[get_property CONFIG.NUM_CLOCKS $cell] > 4} {set_property CONFIG.FREQ_HZ [get_property CONFIG.FREQ_HZ [get_bd_pins $cell_name/clk_in_kernel_04]] [get_bd_pins $cell_name/aclk_ext_tog_kernel_04]  }
    if {[get_property CONFIG.NUM_CLOCKS $cell] > 5} {set_property CONFIG.FREQ_HZ [get_property CONFIG.FREQ_HZ [get_bd_pins $cell_name/clk_in_kernel_05]] [get_bd_pins $cell_name/aclk_ext_tog_kernel_05]  }
  }
}

