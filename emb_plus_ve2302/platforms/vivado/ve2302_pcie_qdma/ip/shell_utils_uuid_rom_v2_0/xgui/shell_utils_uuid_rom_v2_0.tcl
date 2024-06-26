## Copyright (C) 2023 Advanced Micro Devices, Inc.
## SPDX-License-Identifier: MIT

# Definitional proc to organize widgets for parameters.

proc init_gui { IPINST } {

  ipgui::add_param $IPINST -name "Component_Name"

  #---> Adding Page -----------------------------------------------------------------------------------------------------------------------#

  set General_Config [ipgui::add_page $IPINST -name "General Configuration"]

    set C_INITIAL_UUID [ipgui::add_param $IPINST -name C_INITIAL_UUID -parent $General_Config]
    set_property tooltip  "Set a default 128-bit UUID to be initialized in the ROM during synthesis" $C_INITIAL_UUID

}

#==========================================================================================================================================#
# Parameter Validation Procedures
#==========================================================================================================================================#

# Validate the entered UUID

proc validate_PARAM_VALUE.C_INITIAL_UUID {PARAM_VALUE.C_INITIAL_UUID IPINST} {

    # Verify the UUID string is 32 characters in length
    set uuid_length [string length [get_property value ${PARAM_VALUE.C_INITIAL_UUID}]]

    if {[expr $uuid_length != 32]} {
      set_property errmsg "UUID string length of $uuid_length is not equal to 32" [ipgui::get_paramspec -name C_INITIAL_UUID -of $IPINST ]
      return false
    }

    # Verify the UUID string is valid hexadecimal
    return [RangeCheck4HexDec C_INITIAL_UUID [get_property value ${PARAM_VALUE.C_INITIAL_UUID}] 00000000000000000000000000000000 FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF $IPINST]

}

#==========================================================================================================================================#
# Parameter Update Procedures
#==========================================================================================================================================#

proc update_MODELPARAM_VALUE.C_MEMORY_INIT { MODELPARAM_VALUE.C_MEMORY_INIT PARAM_VALUE.C_INITIAL_UUID } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

  set uuid ""
  set uuid_chars [split [get_property value ${PARAM_VALUE.C_INITIAL_UUID}] {}]

  # Split the UUID into dword's and rotate to match the XPM_MEM string init format
  for {set dw 3} {$dw >= 0} {incr dw -1} {
    set dword ""
    for {set n 0} {$n < 8} {incr n} {
      append dword [lindex $uuid_chars [expr $dw * 8 + $n]]
    }
    if {[expr $dw == 3]} {
      append uuid $dword
    } else {
      append uuid "," $dword
    }
  }
	set_property value $uuid ${MODELPARAM_VALUE.C_MEMORY_INIT}

}

#==========================================================================================================================================#
# Helper Procedures
#==========================================================================================================================================#

# Proc to validate that the entered Hex string value is within the correct range
proc RangeCheck4HexDec {param paramValue MinValue MaxValue IPINST} {

    if { [regexp -all {[a-fA-F0-9]} $paramValue] != [ string length $paramValue ]} {

        set_property errmsg "Entered invalid Hexadecimal value $paramValue" [ipgui::get_paramspec -name $param -of $IPINST ]
        return false

    }

    if {$paramValue  == ""} {

        set_property errmsg "Entered invalid Hexadecimal value $paramValue" [ipgui::get_paramspec -name $param -of $IPINST ]
        return false

    }

    if {[expr 0x$MaxValue ] < [expr 0x$paramValue ] ||  [expr 0x$paramValue ] < [expr 0x$MinValue]} {

        set_property errmsg "Entered Hexadecimal value $paramValue is out of range." [ipgui::get_paramspec -name $param -of $IPINST ]
        return false

    }

    return true

}
