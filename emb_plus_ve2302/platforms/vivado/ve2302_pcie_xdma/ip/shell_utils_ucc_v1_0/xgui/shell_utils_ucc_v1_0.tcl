## Copyright (C) 2023 Advanced Micro Devices, Inc.
## SPDX-License-Identifier: MIT

proc init_gui { IPINST } {

  set Component_Name [ ipgui::add_param  $IPINST  -parent $IPINST -name Component_Name ]
  set NUM_CLOCKS [ ipgui::add_param  $IPINST  -parent $IPINST -name NUM_CLOCKS ]
  set FREQ_CNT_REF_CLK_HZ [ ipgui::add_param  $IPINST  -parent $IPINST -name FREQ_CNT_REF_CLK_HZ ]
  set EXT_TOG_ENABLE [ ipgui::add_param  $IPINST  -parent $IPINST -name EXT_TOG_ENABLE ]

}

proc update_MODELPARAM_VALUE.C_NUM_CLOCKS { MODELPARAM_VALUE.C_NUM_CLOCKS PARAM_VALUE.NUM_CLOCKS } {
	set_property value [get_property value ${PARAM_VALUE.NUM_CLOCKS}] ${MODELPARAM_VALUE.C_NUM_CLOCKS}
}

proc update_MODELPARAM_VALUE.C_FREQ_CNT_REF_CLK_HZ { MODELPARAM_VALUE.C_FREQ_CNT_REF_CLK_HZ PARAM_VALUE.FREQ_CNT_REF_CLK_HZ } {
	set_property value [get_property value ${PARAM_VALUE.FREQ_CNT_REF_CLK_HZ}] ${MODELPARAM_VALUE.C_FREQ_CNT_REF_CLK_HZ}
}

proc update_MODELPARAM_VALUE.C_EXT_TOG_ENABLE { MODELPARAM_VALUE.C_EXT_TOG_ENABLE PARAM_VALUE.EXT_TOG_ENABLE } {
	set_property value [get_property value ${PARAM_VALUE.EXT_TOG_ENABLE}] ${MODELPARAM_VALUE.C_EXT_TOG_ENABLE}
}
