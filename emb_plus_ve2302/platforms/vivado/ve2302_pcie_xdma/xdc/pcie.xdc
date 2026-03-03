# Copyright (C) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

# Pin placement
set_property LOC GTYP_QUAD_X0Y0      [get_cells */blp/xdma_0_support/gt_quad_0/inst/quad_inst]
set_property LOC GTYP_REFCLK_X0Y0    [get_cells */blp/xdma_0_support/refclk_ibuf/U0/USE_IBUFDS_GTE5.GEN_IBUFDS_GTE5[0].IBUFDS_GTE5_I]

create_clock -period 10.0 [get_ports pcie_refclk_clk_p]

