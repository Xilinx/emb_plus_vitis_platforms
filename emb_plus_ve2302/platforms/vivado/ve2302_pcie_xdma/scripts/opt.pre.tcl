# Copyright (C) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

# CR-1125650 Disable the SLVERR output from the axi_uartlite in response to a read from an empty FIFO (or write to a full FIFO)

set Gnd_Net [get_nets -of [lindex [get_cells -hierarchical GND -filter {NAME =~ "*/blp/*"}] 0]]

set UART_Resp_Pins [get_pins -of [get_nets -of [get_pins */blp/blp_logic/axi_uart_*/s_axi_?resp]] -filter {DIRECTION ==IN}]

if {[llength ${UART_Resp_Pins}] > 0} {

    set_property DONT_TOUCH FALSE [get_nets -of ${UART_Resp_Pins}]
    disconnect_net -objects ${UART_Resp_Pins}
    connect_net -objects ${UART_Resp_Pins} -hier -net ${Gnd_Net}
}

#set ClkWiz_Resp_Pins [get_pins -of [get_nets -of [get_pins */blp/blp_logic/ulp_clocking/s_axi_clk_wiz_?_?resp]] -filter {DIRECTION ==IN}]
#
#if {[llength ${ClkWiz_Resp_Pins}] > 0} {
#
#    set_property DONT_TOUCH FALSE [get_nets -of ${ClkWiz_Resp_Pins}]
#    disconnect_net -objects ${ClkWiz_Resp_Pins}
#    connect_net -objects ${ClkWiz_Resp_Pins} -hier -net ${Gnd_Net}
#}
