## Copyright (C) 2023 Advanced Micro Devices, Inc.
## SPDX-License-Identifier: MIT

#==============================================================================#
# Post IP Configuration Procedure
#==============================================================================#

proc post_config_ip { cell args } {
  set ip [get_bd_cells $cell]
  set s_axi_intf [get_bd_intf_pins $ip/S_AXI]

  # Set interface as READ_ONLY
  set_property CONFIG.READ_WRITE_MODE READ_ONLY $s_axi_intf
  set_property CONFIG.READ_WRITE_MODE.VALUE_SRC CONSTANT $s_axi_intf

}
