# Copyright (C) 2023 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

CP = cp -rf
MKDIR = mkdir -p
RM = rm -rf
MV = mv
XSCT = $(XILINX_VITIS)/bin/xsct
JOBS ?= 8
PLATFORM ?= ve2302_pcie_qdma
VERSION ?= 202410_1
VIV_DESIGN = ve2302_pcie_qdma

PFM_DIR = xilinx_$(VIV_DESIGN)_$(VERSION)
PFM_PRJ_DIR = xsct/$(VIV_XSA_NAME)/$(VIV_XSA_NAME)/export/xilinx_$(VIV_DESIGN)_$(VIV_DESIGN)_1_0
PFM_SCRIPTS_DIR = scripts

PFM_TCL = $(PFM_SCRIPTS_DIR)/pfm.tcl
PFM_XPFM = $(PFM_DIR)/$(VIV_DESIGN).xpfm

VIV_DIR = vivado/$(PLATFORM)
VIV_XSA_NAME = $(VIV_DESIGN)
VIV_XSA = $(VIV_DIR)/project/$(VIV_XSA_NAME).xsa
VIV_SDT = project_sdt
VIV_BASE_XSA = $(VIV_DIR)/project/$(VIV_DESIGN)_base.xsa
XSCT_SRC = $(PFM_SCRIPTS_DIR)/gen_sdt.tcl

.PHONY: help
help:
	@echo 'Usage:'
	@echo ''
	@echo '  make platform [PLATFORM=<p>] [VERSION=<v>]'
	@echo '    Generate Vitis platform'
	@echo ''
	@echo '  make sdt [PLATFORM=<p>] [VERSION=<v>]'
	@echo '    Generate SDT file for base xsa'
	@echo ''
	@echo '  make clean [PLATFORM=<p>] [VERSION=<v>]'
	@echo '    Clean files and directories for specified platform'
	@echo ''
	@echo '  Defaults:'
	@echo '    PLATFORM: $(PLATFORM) '
	@echo '    VERSION: $(VERSION) '
	@echo ''


.PHONY: all
all: platform sdt

.PHONY: platform
platform: $(PFM_XPFM)
$(PFM_XPFM): $(VIV_XSA)
	$(XSCT) $(PFM_TCL) -xsa $(VIV_XSA)
	@$(CP) $(PFM_PRJ_DIR) $(PFM_DIR)
# Added MV command because the name of the xpfm is not what we're looking for (not sure why)
	@$(MV) $(PFM_DIR)/*.xpfm $(PFM_DIR)/$(VIV_DESIGN).xpfm
	@echo 'Vitis platform available at $(PFM_DIR)'

.PHONY: sdt
sdt: $(VIV_SDT)
$(VIV_SDT): $(VIV_BASE_XSA)
	$(XSCT) $(XSCT_SRC) -xsa_path $(VIV_BASE_XSA)

$(VIV_BASE_XSA): $(VIV_XSA)
$(VIV_XSA):
	make -C $(VIV_DIR) xsa JOBS=$(JOBS)

.PHONY: clean
clean:
	-@$(RM) .Xil boot image linux.bif ws $(PFM_DIR) xsct $(VIV_SDT)
	make -C $(VIV_DIR) clean

