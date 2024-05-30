# Copyright (C) 2023 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

CP = cp -rf
MKDIR = mkdir -p
RM = rm -rf
MV = mv
XSCT = $(XILINX_VITIS)/bin/xsct
JOBS ?= 8
SILICON ?= prod
PLATFORM ?= ve2302_pcie_qdma
VERSION ?= 202410_1

ifeq ($(SILICON), es1)
  VIV_DESIGN = ve2302_es1_pcie_qdma
else
  VIV_DESIGN = ve2302_pcie_qdma
endif

PFM_DIR = xilinx_$(VIV_DESIGN)_$(VERSION)
PFM_PRJ_DIR = xsct/$(VIV_XSA_NAME)/$(VIV_XSA_NAME)/export/xilinx_$(VIV_DESIGN)_$(VIV_DESIGN)_1_0
PFM_SCRIPTS_DIR = scripts

PFM_TCL = $(PFM_SCRIPTS_DIR)/pfm.tcl
PFM_XPFM = $(PFM_DIR)/$(VIV_DESIGN).xpfm

VIV_DIR = vivado/$(PLATFORM)
VIV_XSA_NAME = $(VIV_DESIGN)
VIV_XSA = $(VIV_DIR)/project/$(VIV_XSA_NAME).xsa

.PHONY: help
help:
	@echo 'Usage:'
	@echo ''
	@echo '  make platform [PLATFORM=<p>] [SILICON=<es1,prod>] [VERSION=<v>]'
	@echo '    Generate Vitis platform'
	@echo ''
	@echo '  make clean [PLATFORM=<p>] [SILICON=<es1,prod>] [VERSION=<v>]'
	@echo '    Clean files and directories for specified platform'
	@echo ''
	@echo '  Defaults:'
	@echo '    PLATFORM: $(PLATFORM) '
	@echo '    SILICON: $(SILICON) '
	@echo '    VERSION: $(VERSION) '
	@echo ''


.PHONY: all
all: platform

.PHONY: platform
platform: $(PFM_XPFM)
$(PFM_XPFM): $(VIV_XSA)
	$(XSCT) $(PFM_TCL) -xsa $(VIV_XSA)
	@$(CP) $(PFM_PRJ_DIR) $(PFM_DIR)
# Added MV command because the name of the xpfm is not what we're looking for (not sure why)
	@$(MV) $(PFM_DIR)/*.xpfm $(PFM_DIR)/$(VIV_DESIGN).xpfm
	@echo 'Vitis platform available at $(PFM_DIR)'

$(VIV_XSA):
	make -C $(VIV_DIR) xsa JOBS=$(JOBS) SILICON=$(SILICON)

.PHONY: clean
clean:
	-@$(RM) .Xil boot image linux.bif ws $(PFM_DIR) xsct
	make -C $(VIV_DIR) clean

