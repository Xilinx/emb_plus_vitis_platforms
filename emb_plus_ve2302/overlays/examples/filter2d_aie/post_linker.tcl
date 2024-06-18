# Copyright (C) 2023-2024 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

set CurrentPath [pwd]

set BasePath [regsub {\/emb_plus_ve2302\/.*$} [pwd] ""]
set script [regsub {\/emb_plus_ve2302\/.*$} [pwd] ""]/common/Vitis_Libraries/vision/ext/xf_rtl_utils.tcl

source -notrace $script

#Instances of PL kernels need to be declared as in system.cfg
set TilerInstances [list [list "Tiler_top_1" 0]]
set StitcherInstances [list [list "stitcher_top_1" 0]]

# ConfigDM <HostPixelType> <AIEPixelType> <DDRDataWidth> <AIEDataWidth> <TilerInst> <StitcherInst>
# Default     <XF_8UC1>      <XF_8UC1>        <128>          <128>          <"">         <"">
# If No TilerInst/StitcherInst is used then assign it with "" 
# Please set DDRDataWidth and AIEDataWidth depending on PixelTypes to make NPPC Transfer as same.
# Ex: DDRWidth = 64 and HostPixel = 8 => NPPC = 64/8 = 8
# So, AIEWidth = 128 and AIEPixel = 16 => NPPC = 128/16 = 8


# Tiler Instances Configuration
foreach inst_info $TilerInstances {
    configTiler \
        HostPixelType $PixelType("XF_8UC2") \
        AIEPixelType $PixelType("XF_16UC2") \
        TilerInstInfo $inst_info
    }

# Stitcher Instances Configuration
foreach inst_info $StitcherInstances {
    configStitcher \
        HostPixelType $PixelType("XF_8UC2") \
        AIEPixelType $PixelType("XF_16UC2") \
        StitcherInstInfo $inst_info
}
