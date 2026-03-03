# Copyright (C) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

# Timing
# ------------------------------------------------------------------------------

# JUSTIFICIATION:  Kernel interrupts are level triggered but may be driven by a flop on an arbitrary clock source within the kernel.
# The set_false_path suppresses false timing failures that would otherwise be reported.
set_false_path -to [get_pins {*/blp/dfx_decoupling/ip_irq_kernel_00/inst/FDRE.FDRElp[*].FDRE_inst/D}]


