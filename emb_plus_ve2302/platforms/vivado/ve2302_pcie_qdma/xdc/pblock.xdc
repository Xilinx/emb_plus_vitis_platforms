# Copyright (C) 2023 - 2024 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

create_pblock pblock_ulp
add_cells_to_pblock [get_pblocks pblock_ulp] [get_cells -quiet [list */ulp]]
resize_pblock [get_pblocks pblock_ulp] -add {SLICE_X16Y147:SLICE_X99Y187 SLICE_X60Y75:SLICE_X75Y146}
resize_pblock [get_pblocks pblock_ulp] -add {BUFGCE_X2Y0:BUFGCE_X3Y23}
resize_pblock [get_pblocks pblock_ulp] -add {BUFGCE_DIV_X3Y0:BUFGCE_DIV_X3Y3}
resize_pblock [get_pblocks pblock_ulp] -add {BUFGCTRL_X3Y0:BUFGCTRL_X3Y7}
resize_pblock [get_pblocks pblock_ulp] -add {DPLL_X0Y0:DPLL_X1Y3}
resize_pblock [get_pblocks pblock_ulp] -add {DSP58_CPLX_X0Y66:DSP58_CPLX_X1Y93}
resize_pblock [get_pblocks pblock_ulp] -add {DSP_X0Y83:DSP_X1Y93 DSP_X0Y66:DSP_X3Y82}
resize_pblock [get_pblocks pblock_ulp] -add {GCLK_PD_X2Y96:GCLK_PD_X2Y143}
resize_pblock [get_pblocks pblock_ulp] -add {IRI_QUAD_X18Y524:IRI_QUAD_X66Y779 IRI_QUAD_X17Y556:IRI_QUAD_X17Y779 IRI_QUAD_X9Y524:IRI_QUAD_X10Y779}
resize_pblock [get_pblocks pblock_ulp] -add {MMCM_X2Y0:MMCM_X3Y0}
resize_pblock [get_pblocks pblock_ulp] -add {NOC_NMU512_X0Y2:NOC_NMU512_X0Y4}
resize_pblock [get_pblocks pblock_ulp] -add {RAMB18_X0Y84:RAMB18_X2Y95}
resize_pblock [get_pblocks pblock_ulp] -add {RAMB36_X0Y42:RAMB36_X2Y47}
resize_pblock [get_pblocks pblock_ulp] -add {URAM288_X0Y42:URAM288_X2Y47}
resize_pblock [get_pblocks pblock_ulp] -add {URAM_CAS_DLY_X0Y1:URAM_CAS_DLY_X2Y1}
resize_pblock [get_pblocks pblock_ulp] -add {CLOCKREGION_X0Y4:CLOCKREGION_X3Y4 CLOCKREGION_X0Y3:CLOCKREGION_X2Y3}

# Add more BRAMS & DSPs (increased BRAMS/URAMS to 68 total and routed)
resize_pblock [get_pblocks pblock_ulp] -add {DSP58_CPLX_X1Y46:DSP58_CPLX_X1Y73 DSP_X2Y46:DSP_X3Y73 }
resize_pblock [get_pblocks pblock_ulp] -add {RAMB18_X2Y48:RAMB18_X2Y75 RAMB36_X2Y24:RAMB36_X2Y37 }
resize_pblock [get_pblocks pblock_ulp] -add {URAM288_X2Y24:URAM288_X2Y37 }
# Add even more (increased BRAMS/URAMS to 81 total and routed)
resize_pblock [get_pblocks pblock_ulp] -add {RAMB18_X0Y48:RAMB18_X0Y73 RAMB36_X0Y24:RAMB36_X0Y36 }
resize_pblock [get_pblocks pblock_ulp] -add {URAM288_X0Y24:URAM288_X0Y36 }

set_property SNAPPING_MODE ON [get_pblocks pblock_ulp]
set_property DONT_TOUCH true [get_cells */ulp]


# Lock NMU512 for blp
set_property LOC NOC_NMU512_X0Y0 [get_cells */blp/axi_noc_ic/inst/S00_AXI_nmu/*/NOC_NMU512_INST]
set_property LOC NOC_NMU512_X0Y1 [get_cells */blp/axi_noc_ic/inst/S07_AXI_nmu/*/NOC_NMU512_INST]
