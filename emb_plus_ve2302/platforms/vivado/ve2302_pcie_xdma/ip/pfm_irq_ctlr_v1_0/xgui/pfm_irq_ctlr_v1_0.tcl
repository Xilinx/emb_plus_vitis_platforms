## Copyright (C) 2023 Advanced Micro Devices, Inc.
## SPDX-License-Identifier: MIT

# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"

  #---> Adding Page ---------------------------------------------------------------------------------------------------------------------#

  set General_Config [ipgui::add_page $IPINST -name "General Configuration"]

      #---> Adding Group ----------------------------------------------------------------------------------------------------------------#

      set PF_Count_Group [ipgui::add_group $IPINST -parent $General_Config -name "Number of Physical Functions Configuration" ]

          #---> Adding Params -----------------------------------------------------------------------------------------------------------#

          set NUM_OF_PFS [ipgui::add_param $IPINST -name NUM_OF_PFS -widget comboBox -parent $PF_Count_Group]
          set_property tooltip "Specify the number of Physical Functions that will be connected to IP." $NUM_OF_PFS

          #---> End Params --------------------------------------------------------------------------------------------------------------#

      #---> End Group -------------------------------------------------------------------------------------------------------------------#

      #---> Adding Group ----------------------------------------------------------------------------------------------------------------#

      set PF_Interrupt_Group [ipgui::add_group $IPINST -parent $General_Config -name "Physical Function Interrupt Configuration" ]

          #---> Adding Params -----------------------------------------------------------------------------------------------------------#

          set NUM_OF_IRQ_PF0 [ipgui::add_param $IPINST -name NUM_OF_IRQ_PF0 -parent $PF_Interrupt_Group]
          set_property tooltip "Specify the number of interrupts on Physical Function 0." $NUM_OF_IRQ_PF0

          set NUM_OF_IRQ_PF1 [ipgui::add_param $IPINST -name NUM_OF_IRQ_PF1 -parent $PF_Interrupt_Group]
          set_property tooltip "Specify the number of interrupts on Physical Function 1." $NUM_OF_IRQ_PF1

          set NUM_OF_IRQ_PF2 [ipgui::add_param $IPINST -name NUM_OF_IRQ_PF2 -parent $PF_Interrupt_Group]
          set_property tooltip "Specify the number of interrupts on Physical Function 2." $NUM_OF_IRQ_PF2

          set NUM_OF_IRQ_PF3 [ipgui::add_param $IPINST -name NUM_OF_IRQ_PF3 -parent $PF_Interrupt_Group]
          set_property tooltip "Specify the number of interrupts on Physical Function 3." $NUM_OF_IRQ_PF3

          #---> End Params --------------------------------------------------------------------------------------------------------------#

      #---> End Group -------------------------------------------------------------------------------------------------------------------#

      #---> Adding Group ----------------------------------------------------------------------------------------------------------------#

      set Edge_Select_Group [ipgui::add_group $IPINST -parent $General_Config -name "Interrupt Edge Selection Configuration - Rising 0 / Falling 1" ]

          #---> Adding Params -----------------------------------------------------------------------------------------------------------#

          set EDGE_SELECT_PF0 [ipgui::add_param $IPINST -name EDGE_SELECT_PF0 -parent $Edge_Select_Group]
          set_property tooltip "Specify the array of interrupt edge selection for Physical Function 0." $EDGE_SELECT_PF0

          set EDGE_SELECT_PF1 [ipgui::add_param $IPINST -name EDGE_SELECT_PF1 -parent $Edge_Select_Group]
          set_property tooltip "Specify the array of interrupt edge selection for Physical Function 1." $EDGE_SELECT_PF1

          set EDGE_SELECT_PF2 [ipgui::add_param $IPINST -name EDGE_SELECT_PF2 -parent $Edge_Select_Group]
          set_property tooltip "Specify the array of interrupt edge selection for Physical Function 2." $EDGE_SELECT_PF2

          set EDGE_SELECT_PF3 [ipgui::add_param $IPINST -name EDGE_SELECT_PF3 -parent $Edge_Select_Group]
          set_property tooltip "Specify the array of interrupt edge selection for Physical Function 3." $EDGE_SELECT_PF3

          #---> End Params --------------------------------------------------------------------------------------------------------------#

      #---> End Group -------------------------------------------------------------------------------------------------------------------#

      #---> Adding Group ----------------------------------------------------------------------------------------------------------------#

      set CPM_Type_Group [ipgui::add_group $IPINST -parent $General_Config -name "CPM Type Definition Configuration" ]

          #---> Adding Params -----------------------------------------------------------------------------------------------------------#

          set CPM_TYPE [ipgui::add_param $IPINST -name CPM_TYPE -parent $CPM_Type_Group]
          set_property tooltip "Specify the CPM Type that the Platform Controller IP will connect to." $CPM_TYPE

          #---> End Params --------------------------------------------------------------------------------------------------------------#

      #---> End Group -------------------------------------------------------------------------------------------------------------------#

      #---> Adding Group ----------------------------------------------------------------------------------------------------------------#

      set AXI_Enablement_Group [ipgui::add_group $IPINST -parent $General_Config -name "AXI Bus and Register Space Enablement Configuration" ]

          #---> Adding Params -----------------------------------------------------------------------------------------------------------#

          set AXI_CTRL_EN [ipgui::add_param $IPINST -name AXI_CTRL_EN -parent $AXI_Enablement_Group]
          set_property tooltip "Specify whether AXI bus to be implemented to access register space within the IP." $AXI_CTRL_EN

          #---> End Params --------------------------------------------------------------------------------------------------------------#

      #---> End Group -------------------------------------------------------------------------------------------------------------------#

  #---> End Page ------------------------------------------------------------------------------------------------------------------------#
}

#==========================================================================================================================================#
# Model Parameter Update Procedures
#==========================================================================================================================================#

proc update_MODELPARAM_VALUE.C_NUM_OF_PFS { MODELPARAM_VALUE.C_NUM_OF_PFS PARAM_VALUE.NUM_OF_PFS IPINST } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

  set_property value [get_property value ${PARAM_VALUE.NUM_OF_PFS}] ${MODELPARAM_VALUE.C_NUM_OF_PFS}

}

proc update_MODELPARAM_VALUE.C_NUM_OF_IRQ_PF0 { MODELPARAM_VALUE.C_NUM_OF_IRQ_PF0 PARAM_VALUE.NUM_OF_IRQ_PF0 IPINST } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

  set_property value [get_property value ${PARAM_VALUE.NUM_OF_IRQ_PF0}] ${MODELPARAM_VALUE.C_NUM_OF_IRQ_PF0}

}

proc update_MODELPARAM_VALUE.C_NUM_OF_IRQ_PF1 { MODELPARAM_VALUE.C_NUM_OF_IRQ_PF1 PARAM_VALUE.NUM_OF_IRQ_PF1 IPINST } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

  set_property value [get_property value ${PARAM_VALUE.NUM_OF_IRQ_PF1}] ${MODELPARAM_VALUE.C_NUM_OF_IRQ_PF1}

}

proc update_MODELPARAM_VALUE.C_NUM_OF_IRQ_PF2 { MODELPARAM_VALUE.C_NUM_OF_IRQ_PF2 PARAM_VALUE.NUM_OF_IRQ_PF2 IPINST } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

  set_property value [get_property value ${PARAM_VALUE.NUM_OF_IRQ_PF2}] ${MODELPARAM_VALUE.C_NUM_OF_IRQ_PF2}

}

proc update_MODELPARAM_VALUE.C_NUM_OF_IRQ_PF3 { MODELPARAM_VALUE.C_NUM_OF_IRQ_PF3 PARAM_VALUE.NUM_OF_IRQ_PF3 IPINST } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

  set_property value [get_property value ${PARAM_VALUE.NUM_OF_IRQ_PF3}] ${MODELPARAM_VALUE.C_NUM_OF_IRQ_PF3}

}

proc update_MODELPARAM_VALUE.C_EDGE_SELECT_PF0 { MODELPARAM_VALUE.C_EDGE_SELECT_PF0 PARAM_VALUE.EDGE_SELECT_PF0 IPINST } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

  set_property value [get_property value ${PARAM_VALUE.EDGE_SELECT_PF0}] ${MODELPARAM_VALUE.C_EDGE_SELECT_PF0}

}

proc update_MODELPARAM_VALUE.C_EDGE_SELECT_PF1 { MODELPARAM_VALUE.C_EDGE_SELECT_PF1 PARAM_VALUE.EDGE_SELECT_PF1 IPINST } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

  set_property value [get_property value ${PARAM_VALUE.EDGE_SELECT_PF1}] ${MODELPARAM_VALUE.C_EDGE_SELECT_PF1}

}

proc update_MODELPARAM_VALUE.C_EDGE_SELECT_PF2 { MODELPARAM_VALUE.C_EDGE_SELECT_PF2 PARAM_VALUE.EDGE_SELECT_PF2 IPINST } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

  set_property value [get_property value ${PARAM_VALUE.EDGE_SELECT_PF2}] ${MODELPARAM_VALUE.C_EDGE_SELECT_PF2}

}

proc update_MODELPARAM_VALUE.C_EDGE_SELECT_PF3 { MODELPARAM_VALUE.C_EDGE_SELECT_PF3 PARAM_VALUE.EDGE_SELECT_PF3 IPINST } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

  set_property value [get_property value ${PARAM_VALUE.EDGE_SELECT_PF3}] ${MODELPARAM_VALUE.C_EDGE_SELECT_PF3}

}

proc update_MODELPARAM_VALUE.C_CPM_TYPE { MODELPARAM_VALUE.C_CPM_TYPE PARAM_VALUE.CPM_TYPE IPINST } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

  set_property value [get_property value ${PARAM_VALUE.CPM_TYPE}] ${MODELPARAM_VALUE.C_CPM_TYPE}

}

proc update_MODELPARAM_VALUE.C_AXI_CTRL_EN { MODELPARAM_VALUE.C_AXI_CTRL_EN PARAM_VALUE.AXI_CTRL_EN IPINST } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

  set_property value [get_property value ${PARAM_VALUE.AXI_CTRL_EN}] ${MODELPARAM_VALUE.C_AXI_CTRL_EN}

}

proc update_PARAM_VALUE.NUM_OF_IRQ_PF1 { PARAM_VALUE.NUM_OF_IRQ_PF1 PARAM_VALUE.NUM_OF_PFS IPINST } {

    set num_of_pfs [get_property value ${PARAM_VALUE.NUM_OF_PFS}]

    if {$num_of_pfs eq 4} {

      set_property value 32 ${PARAM_VALUE.NUM_OF_IRQ_PF1}
      set_property enabled true ${PARAM_VALUE.NUM_OF_IRQ_PF1}

    } elseif {$num_of_pfs eq 3} {

      set_property value 32 ${PARAM_VALUE.NUM_OF_IRQ_PF1}
      set_property enabled true ${PARAM_VALUE.NUM_OF_IRQ_PF1}

    } elseif {$num_of_pfs eq 2} {

      set_property value 32 ${PARAM_VALUE.NUM_OF_IRQ_PF1}
      set_property enabled true ${PARAM_VALUE.NUM_OF_IRQ_PF1}

    } elseif {$num_of_pfs eq 1} {

      set_property value 32 ${PARAM_VALUE.NUM_OF_IRQ_PF1}
      set_property enabled false ${PARAM_VALUE.NUM_OF_IRQ_PF1}

    } else {

      set_property value 32 ${PARAM_VALUE.NUM_OF_IRQ_PF1}
      set_property enabled false ${PARAM_VALUE.NUM_OF_IRQ_PF1}

    }

}

proc update_PARAM_VALUE.NUM_OF_IRQ_PF2 { PARAM_VALUE.NUM_OF_IRQ_PF2 PARAM_VALUE.NUM_OF_PFS IPINST } {

    set num_of_pfs [get_property value ${PARAM_VALUE.NUM_OF_PFS}]

    if {$num_of_pfs eq 4} {

      set_property value 32 ${PARAM_VALUE.NUM_OF_IRQ_PF2}
      set_property enabled true ${PARAM_VALUE.NUM_OF_IRQ_PF2}

    } elseif {$num_of_pfs eq 3} {

      set_property value 32 ${PARAM_VALUE.NUM_OF_IRQ_PF2}
      set_property enabled true ${PARAM_VALUE.NUM_OF_IRQ_PF2}

    } elseif {$num_of_pfs eq 2} {

      set_property value 32 ${PARAM_VALUE.NUM_OF_IRQ_PF2}
      set_property enabled false ${PARAM_VALUE.NUM_OF_IRQ_PF2}

    } elseif {$num_of_pfs eq 1} {

      set_property value 32 ${PARAM_VALUE.NUM_OF_IRQ_PF2}
      set_property enabled false ${PARAM_VALUE.NUM_OF_IRQ_PF2}

    } else {

      set_property value 32 ${PARAM_VALUE.NUM_OF_IRQ_PF2}
      set_property enabled false ${PARAM_VALUE.NUM_OF_IRQ_PF2}

    }

}

proc update_PARAM_VALUE.NUM_OF_IRQ_PF3 { PARAM_VALUE.NUM_OF_IRQ_PF3 PARAM_VALUE.NUM_OF_PFS IPINST } {

    set num_of_pfs [get_property value ${PARAM_VALUE.NUM_OF_PFS}]

    if {$num_of_pfs eq 4} {

      set_property value 32 ${PARAM_VALUE.NUM_OF_IRQ_PF3}
      set_property enabled true ${PARAM_VALUE.NUM_OF_IRQ_PF3}

    } elseif {$num_of_pfs eq 3} {

      set_property value 32 ${PARAM_VALUE.NUM_OF_IRQ_PF3}
      set_property enabled false ${PARAM_VALUE.NUM_OF_IRQ_PF3}

    } elseif {$num_of_pfs eq 2} {

      set_property value 32 ${PARAM_VALUE.NUM_OF_IRQ_PF3}
      set_property enabled false ${PARAM_VALUE.NUM_OF_IRQ_PF3}

    } elseif {$num_of_pfs eq 1} {

      set_property value 32 ${PARAM_VALUE.NUM_OF_IRQ_PF3}
      set_property enabled false ${PARAM_VALUE.NUM_OF_IRQ_PF3}

    } else {

      set_property value 32 ${PARAM_VALUE.NUM_OF_IRQ_PF3}
      set_property enabled false ${PARAM_VALUE.NUM_OF_IRQ_PF3}

    }

}