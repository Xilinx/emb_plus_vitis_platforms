# Copyright (C) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "C_DATA_WIDTH" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_ADDR_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "S_ADDR_MASK" -parent ${Page_0}
  set REMAP_ADDR [ipgui::add_param $IPINST -name "REMAP_ADDR" -parent ${Page_0}]
  set_property tooltip {Source Address} ${REMAP_ADDR}
  set TRANS_ADDR [ipgui::add_param $IPINST -name "TRANS_ADDR" -parent ${Page_0}]
  set_property tooltip {Translation Address} ${TRANS_ADDR}
  ipgui::add_param $IPINST -name "C_ARUSER_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_AWUSER_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_ID_WIDTH" -parent ${Page_0}


}

proc update_PARAM_VALUE.C_ADDR_WIDTH { PARAM_VALUE.C_ADDR_WIDTH } {
	# Procedure called to update C_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_ADDR_WIDTH { PARAM_VALUE.C_ADDR_WIDTH } {
	# Procedure called to validate C_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_ARUSER_WIDTH { PARAM_VALUE.C_ARUSER_WIDTH } {
	# Procedure called to update C_ARUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_ARUSER_WIDTH { PARAM_VALUE.C_ARUSER_WIDTH } {
	# Procedure called to validate C_ARUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_AWUSER_WIDTH { PARAM_VALUE.C_AWUSER_WIDTH } {
	# Procedure called to update C_AWUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AWUSER_WIDTH { PARAM_VALUE.C_AWUSER_WIDTH } {
	# Procedure called to validate C_AWUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_DATA_WIDTH { PARAM_VALUE.C_DATA_WIDTH } {
	# Procedure called to update C_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_DATA_WIDTH { PARAM_VALUE.C_DATA_WIDTH } {
	# Procedure called to validate C_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_ID_WIDTH { PARAM_VALUE.C_ID_WIDTH } {
	# Procedure called to update C_ID_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_ID_WIDTH { PARAM_VALUE.C_ID_WIDTH } {
	# Procedure called to validate C_ID_WIDTH
	return true
}

proc update_PARAM_VALUE.REMAP_ADDR { PARAM_VALUE.REMAP_ADDR } {
	# Procedure called to update REMAP_ADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.REMAP_ADDR { PARAM_VALUE.REMAP_ADDR } {
	# Procedure called to validate REMAP_ADDR
	return true
}

proc update_PARAM_VALUE.S_ADDR_MASK { PARAM_VALUE.S_ADDR_MASK } {
	# Procedure called to update S_ADDR_MASK when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S_ADDR_MASK { PARAM_VALUE.S_ADDR_MASK } {
	# Procedure called to validate S_ADDR_MASK
	return true
}

proc update_PARAM_VALUE.TRANS_ADDR { PARAM_VALUE.TRANS_ADDR } {
	# Procedure called to update TRANS_ADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TRANS_ADDR { PARAM_VALUE.TRANS_ADDR } {
	# Procedure called to validate TRANS_ADDR
	return true
}


proc update_MODELPARAM_VALUE.C_ID_WIDTH { MODELPARAM_VALUE.C_ID_WIDTH PARAM_VALUE.C_ID_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_ID_WIDTH}] ${MODELPARAM_VALUE.C_ID_WIDTH}
}

proc update_MODELPARAM_VALUE.C_DATA_WIDTH { MODELPARAM_VALUE.C_DATA_WIDTH PARAM_VALUE.C_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_DATA_WIDTH}] ${MODELPARAM_VALUE.C_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_ADDR_WIDTH { MODELPARAM_VALUE.C_ADDR_WIDTH PARAM_VALUE.C_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AWUSER_WIDTH { MODELPARAM_VALUE.C_AWUSER_WIDTH PARAM_VALUE.C_AWUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AWUSER_WIDTH}] ${MODELPARAM_VALUE.C_AWUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_ARUSER_WIDTH { MODELPARAM_VALUE.C_ARUSER_WIDTH PARAM_VALUE.C_ARUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_ARUSER_WIDTH}] ${MODELPARAM_VALUE.C_ARUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.S_ADDR_MASK { MODELPARAM_VALUE.S_ADDR_MASK PARAM_VALUE.S_ADDR_MASK } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S_ADDR_MASK}] ${MODELPARAM_VALUE.S_ADDR_MASK}
}

proc update_MODELPARAM_VALUE.REMAP_ADDR { MODELPARAM_VALUE.REMAP_ADDR PARAM_VALUE.REMAP_ADDR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.REMAP_ADDR}] ${MODELPARAM_VALUE.REMAP_ADDR}
}

proc update_MODELPARAM_VALUE.TRANS_ADDR { MODELPARAM_VALUE.TRANS_ADDR PARAM_VALUE.TRANS_ADDR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TRANS_ADDR}] ${MODELPARAM_VALUE.TRANS_ADDR}
}

