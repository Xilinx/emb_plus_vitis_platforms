# Copyright (C) 2024 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

create_iso_design

# DDR Memory regions
create_iso_destination -addr 0x0 -size 864M -mem -comment {ns_strict} ddr_reg_0
create_iso_destination -addr 0x36000000 -size 16M -mem -comment {ns_shared} ddr_reg_1
create_iso_destination -addr 0x37000000 -size 16M -mem -comment {ns_shared} ddr_reg_2
create_iso_destination -addr 0x38000000 -size 128M -mem -comment {secure_shared} ddr_reg_3
create_iso_destination -addr 0x40000000 -size 512M -mem -comment {secure} ddr_reg_4
create_iso_destination -addr 0x60000000 -size 512M -mem -comment {ns_shared} ddr_reg_5
create_iso_destination -addr 0x050000000000 -size 8192M -mem -comment {secure} ddr_reg_6

# Disable default subsystem (not sure why - xapp1380 did this)
set_property ignore {true} [get_iso_domains /default]

# Create Secure Subsystem and Add Isolation Accesses for DDR Memory
# Create Secure Subsystem (RPU)
create_iso_domain subsystem_0
set_property name {Secure} [get_iso_domains /subsystem_0]
create_iso_access -type cpu_list -domain /Secure cpus_0
edit_iso_access -access /Secure/cpus_0 -add [get_iso_smids /blp/cips/RPU0 ]
set_property secure true [get_iso_accesses /Secure/cpus_0]

# Create Secure Access (RPU) for RPU Local Execution Space (ddr_reg_4)
create_iso_access -domain /Secure access_0
set_property name {secure_xmpu_rpu} [get_iso_accesses /Secure/access_0]
edit_iso_access -access /Secure/secure_xmpu_rpu -add [get_iso_smids /blp/cips/RPU0 ]
edit_iso_access -access /Secure/secure_xmpu_rpu -add [get_iso_smids /blp/cips/OSPI ]
edit_iso_access -access /Secure/secure_xmpu_rpu -add [get_iso_smids /blp/cips/PMC ]
edit_iso_access -access /Secure/secure_xmpu_rpu -add [get_iso_destinations /ddr_reg_4 ]
set_property secure true [get_iso_accesses /Secure/secure_xmpu_rpu]

# Create Secure Access (RPU) for RPU TCM (LPD_XPPU)
create_iso_access -domain /Secure access_0
set_property name {secure_xppu} [get_iso_accesses /Secure/access_0]
set_property secure true [get_iso_accesses /Secure/secure_xppu]
edit_iso_access -access /Secure/secure_xppu -add [get_iso_smids /blp/cips/RPU0 ]
edit_iso_access -access /Secure/secure_xppu -add [get_iso_destinations /blp/cips/RPU0_TCMA_mem ]
edit_iso_access -access /Secure/secure_xppu -add [get_iso_destinations /blp/cips/UART0 ]
edit_iso_access -access /Secure/secure_xppu -add [get_iso_destinations /blp/cips/PMC_I2C]
edit_iso_access -access /Secure/secure_xppu -add [get_iso_destinations /blp/cips/PMC_GPIO]
edit_iso_access -access /Secure/secure_xppu -add [get_iso_destinations /blp/cips/TTC0]
edit_iso_access -access /Secure/secure_xppu -add [get_iso_destinations /blp/cips/TTC1]

# Create non-secure access for Sysmon (non-secure so others can also read Sysmon)
create_iso_access -domain /Secure access_0
set_property name {ns_pmc_xppu_rpu} [get_iso_accesses /Secure/access_0]
edit_iso_access -access /Secure/ns_pmc_xppu_rpu -add [get_iso_smids /blp/cips/RPU0 ]
edit_iso_access -access /Secure/ns_pmc_xppu_rpu -add [get_iso_destinations /blp/cips/PMC_SYSMON_CSR ]
edit_iso_access -access /Secure/ns_pmc_xppu_rpu -add [get_iso_destinations /blp/cips/OSPI ]

# Allow RPU access to OSPI bootmedia (can't have secure flag set)
create_iso_access -domain /Secure access_0
set_property name {ns_boot_rpu} [get_iso_accesses /Secure/access_0]
edit_iso_access -access /Secure/ns_boot_rpu -add [get_iso_smids /blp/cips/RPU0 ]
edit_iso_access -access /Secure/ns_boot_rpu -add [get_iso_destinations /blp/cips/PMC_OSPI_mem ]

# Allow RPU to access PMC_XMPU memory
create_iso_access -domain /Secure access_0
set_property name {secure_pmc_xmpu} [get_iso_accesses /Secure/access_0]
set_property secure true [get_iso_accesses /Secure/secure_pmc_xmpu]
edit_iso_access -access /Secure/secure_pmc_xmpu -add [get_iso_smids /blp/cips/RPU0 ]
edit_iso_access -access /Secure/secure_pmc_xmpu -add [get_iso_destinations /blp/cips/PMC_XMPU_mem ]

# Create Shared Access (RPU-PF0) (ddr_reg_3)
create_iso_access -domain /Secure access_0
set_property name {secure_share_xmpu_rpu_pf0} [get_iso_accesses /Secure/access_0]
edit_iso_access -access /Secure/secure_share_xmpu_rpu_pf0 -add [get_iso_smids /blp/cips/RPU0 ]
edit_iso_access -access /Secure/secure_share_xmpu_rpu_pf0 -add [get_iso_smids /blp/axi_noc_ic/S07_AXI ]
edit_iso_access -access /Secure/secure_share_xmpu_rpu_pf0 -add [get_iso_destinations /ddr_reg_3 ]
set_property secure true [get_iso_accesses /Secure/secure_share_xmpu_rpu_pf0]

# Create Non-Secure Subsystem and Add Isolation Accesses for DDR Memory
# Create Non-Secure Subsystem (APU)
create_iso_domain subsystem_0
set_property name {Non_secure} [get_iso_domains /subsystem_0]
create_iso_access -type cpu_list -domain /Non_secure cpus_0
edit_iso_access -access /Non_secure/cpus_0 -add [get_iso_smids /blp/cips/APU0 ]
# Create Strict Access (APU) for APU Local Execution Space (ddr_reg_0)
create_iso_access -domain /Non_secure access_0
set_property name {ns_strict_xmpu_apu} [get_iso_accesses /Non_secure/access_0]
edit_iso_access -access /Non_secure/ns_strict_xmpu_apu -add [get_iso_smids /blp/cips/APU0 ]
edit_iso_access -access /Non_secure/ns_strict_xmpu_apu -add [get_iso_destinations /ddr_reg_0 ]
edit_iso_access -access /Non_secure/ns_strict_xmpu_apu -add [get_iso_destinations /blp/cips/OCM_mem ]

# Create Shared Access (APU-RPU) (ddr_reg_2)
create_iso_access -domain /Non_secure access_0
set_property name {ns_shared_xmpu_apu_rpu} [get_iso_accesses /Non_secure/access_0]
edit_iso_access -access /Non_secure/ns_shared_xmpu_apu_rpu -add [get_iso_smids /blp/cips/APU0 ]
edit_iso_access -access /Non_secure/ns_shared_xmpu_apu_rpu -add [get_iso_smids /blp/cips/RPU0 ]
edit_iso_access -access /Non_secure/ns_shared_xmpu_apu_rpu -add [get_iso_destinations /ddr_reg_2 ]
# Create Shared Access (APU-RPU-PF1) (ddr_reg_1)
create_iso_access -domain /Non_secure access_0
set_property name {ns_shared_xmpu_apu_rpu_pf1} [get_iso_accesses /Non_secure/access_0]
edit_iso_access -access /Non_secure/ns_shared_xmpu_apu_rpu_pf1 -add [get_iso_smids /blp/cips/APU0 ]
edit_iso_access -access /Non_secure/ns_shared_xmpu_apu_rpu_pf1 -add [get_iso_smids /blp/cips/RPU0 ]
edit_iso_access -access /Non_secure/ns_shared_xmpu_apu_rpu_pf1 -add [get_iso_smids /blp/axi_noc_ic/S07_AXI ]
edit_iso_access -access /Non_secure/ns_shared_xmpu_apu_rpu_pf1 -add [get_iso_destinations /ddr_reg_1]
# Create Shared Access (APU-DMA) (ddr_reg_5)
create_iso_access -domain /Non_secure access_0
set_property name {ns_shared_xmpu_apu_dma} [get_iso_accesses /Non_secure/access_0]
edit_iso_access -access /Non_secure/ns_shared_xmpu_apu_dma -add [get_iso_smids /blp/cips/APU0 ]
edit_iso_access -access /Non_secure/ns_shared_xmpu_apu_dma -add [get_iso_smids /blp/axi_noc_ic/S06_AXI ]
edit_iso_access -access /Non_secure/ns_shared_xmpu_apu_dma -add [get_iso_destinations /ddr_reg_5]

# Create Shared Access (AIE-PL-DMA) (ddr_reg_6)
create_iso_access -domain /Non_secure access_0
set_property name {ns_shared_xmpu_aie_pl_dma} [get_iso_accesses /Non_secure/access_0]
edit_iso_access -access /Non_secure/ns_shared_xmpu_aie_pl_dma -add [get_iso_smids /ulp/BLP_M_M00_INI_0]
edit_iso_access -access /Non_secure/ns_shared_xmpu_aie_pl_dma -add [get_iso_smids /ulp/BLP_M_M01_INI_0]
edit_iso_access -access /Non_secure/ns_shared_xmpu_aie_pl_dma -add [get_iso_smids /ulp/BLP_M_M02_INI_0]
edit_iso_access -access /Non_secure/ns_shared_xmpu_aie_pl_dma -add [get_iso_smids /blp/cips/AIE ]
edit_iso_access -access /Non_secure/ns_shared_xmpu_aie_pl_dma -add [get_iso_smids /blp/axi_noc_ic/S06_AXI ]
edit_iso_access -access /Non_secure/ns_shared_xmpu_aie_pl_dma -add [get_iso_smids /blp/cips/RPU0 ]
edit_iso_access -access /Non_secure/ns_shared_xmpu_aie_pl_dma -add [get_iso_destinations /ddr_reg_6]

# Base Protections
# Create access to protection unit status registers for user applications
create_iso_access access_0
set_property name {prot_status} [get_iso_accesses /access_0]
edit_iso_access -access /prot_status -add [get_iso_smids /blp/cips/APU0]
edit_iso_access -access /prot_status -add [get_iso_smids /blp/cips/RPU0 ]
edit_iso_access -access /prot_status -add [get_iso_destinations /blp/cips/LPD_XPPU]
edit_iso_access -access /prot_status -add [get_iso_destinations /blp/cips/PSM_GLOBAL]
edit_iso_access -access /prot_status -add [get_iso_destinations /blp/cips/PMC_XPPU_NPI_64KB_apertures]
edit_iso_access -access /prot_status -add [get_iso_destinations /blp/cips/OCM_XMPU ]

# Create access to Control Reset Logic registers for both CPUs
create_iso_access access_0
set_property name {cpu_rw} [get_iso_accesses /access_0]
edit_iso_access -access /cpu_rw -add [get_iso_smids /blp/cips/RPU0 ]
edit_iso_access -access /cpu_rw -add [get_iso_smids /blp/cips/APU0 ]
edit_iso_access -access /cpu_rw -add [get_iso_destinations /blp/cips/CRL_0 ]

# Create access to PMC registers for RPU
create_iso_access access_0
set_property name {rpu_rw} [get_iso_accesses /access_0]
edit_iso_access -access /rpu_rw -add [get_iso_smids /blp/cips/RPU0 ]
edit_iso_access -access /rpu_rw -add [get_iso_destinations /blp/cips/PMC_IOP_SLCR_SECURE]
edit_iso_access -access /rpu_rw -add [get_iso_destinations /blp/cips/PMC_IOP_SLCR ]
edit_iso_access -access /rpu_rw -add [get_iso_destinations /blp/cips/PMC_JTAG_CSR ]
edit_iso_access -access /rpu_rw -add [get_iso_destinations /blp/cips/PMC_GLOBAL ]

# Module Protections

set_property hide_en {true} [get_iso_units -hier PMC_XPPU_NPI]
set_property hide_en {true} [get_iso_units -hier PMC_XPPU]
set_property hide_en {true} [get_iso_units -hier LPD_XPPU]
set_property hide_en {true} [get_iso_units -hier PMC_XMPU]
set_property hide_en {true} [get_iso_units -hier FPD_XMPU]
set_property enable {true} [get_iso_units -hier OCM_XMPU]
set_property hide_en {true} [get_iso_units -hier OCM_XMPU]
set_property enable {true} [get_iso_units /blp/axi_noc_mc_1x/ddrmc]
set_property interrupt_enable {true} [get_iso_units /blp/axi_noc_mc_1x/ddrmc]
set_property hide_en {true} [get_iso_units /blp/axi_noc_mc_1x/ddrmc]
set_property lock {true} [get_iso_units /blp/axi_noc_mc_1x/ddrmc]

# Add APU0 LPD_XPPU access
create_iso_access -domain /Non_secure access_0
set_property name {ns_strict_xppu_apu} [get_iso_accesses /Non_secure/access_0]
edit_iso_access -access /Non_secure/ns_strict_xppu_apu -add [get_iso_smids /blp/cips/APU0]
edit_iso_access -access /Non_secure/ns_strict_xppu_apu -add [get_iso_destinations /blp/cips/LPD_GPIO ]
edit_iso_access -access /Non_secure/ns_strict_xppu_apu -add [get_iso_destinations /blp/cips/TTC3 ]
edit_iso_access -access /Non_secure/ns_strict_xppu_apu -add [get_iso_destinations /blp/cips/UART1]
edit_iso_access -access /Non_secure/ns_strict_xppu_apu -add [get_iso_destinations /blp/cips/LPD_I2C0]
edit_iso_access -access /Non_secure/ns_strict_xppu_apu -add [get_iso_destinations /blp/cips/SPI0]
edit_iso_access -access /Non_secure/ns_strict_xppu_apu -add [get_iso_destinations /blp/cips/PMC_RTC]
edit_iso_access -access /Non_secure/ns_strict_xppu_apu -add [get_iso_destinations /blp/cips/TTC2]

# Add IPI to both APU (non-secure) and RPU (secure) subsystems
create_iso_access -domain /Non_secure access_0
set_property name {ipi_apu} [get_iso_accesses /Non_secure/access_0]
edit_iso_access -access /Non_secure/ipi_apu -add [get_iso_smids /blp/cips/APU0 ]
edit_iso_access -access /Non_secure/ipi_apu -add [get_iso_destinations /blp/cips/IPI0 ]
edit_iso_access -access /Non_secure/ipi_apu -add [get_iso_destinations /blp/cips/IPI1 ]
edit_iso_access -access /Non_secure/ipi_apu -add [get_iso_destinations /blp/cips/IPI2 ]
edit_iso_access -access /Non_secure/ipi_apu -add [get_iso_destinations /blp/cips/IPI5 ]
edit_iso_access -access /Non_secure/ipi_apu -add [get_iso_destinations /blp/cips/IPI6 ]

create_iso_access -domain /Secure access_0
set_property name {ipi_rpu} [get_iso_accesses /Secure/access_0]
edit_iso_access -access /Secure/ipi_rpu -add [get_iso_smids /blp/cips/RPU0 ]
edit_iso_access -access /Secure/ipi_rpu -add [get_iso_destinations /blp/cips/IPI3]
edit_iso_access -access /Secure/ipi_rpu -add [get_iso_destinations /blp/cips/IPI4 ]
set_property secure true [get_iso_accesses /Secure/ipi_rpu]

set_property enable {true} [get_iso_units -hier IPI]
set_property slverr_enable {true} [get_iso_units -hier IPI]
set_property hide_error {true} [get_iso_units -hier IPI]
set_property lock {true} [get_iso_units -hier IPI]

