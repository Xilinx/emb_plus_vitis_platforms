# Copyright (C) 2023 - 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

CP = cp -rf
MKDIR = mkdir -p
RM = rm -rf
MV = mv
VITIS = $(XILINX_VITIS)/bin/vitis
SDTGEN = $(XILINX_VITIS)/bin/sdtgen
JOBS ?= 8
SECURE ?= 0
PLATFORM ?= ve2302_pcie_xdma
VERSION ?= 202610_1
BOARD_DTS ?= versal-emb-plus-ve2302-reva
VIV_DESIGN = ve2302_pcie_xdma

ifeq ($(SECURE),1)
  VIV_DESIGN = ve2302_pcie_xdma_secure
endif

VIV_DIR = vivado/$(PLATFORM)
VIV_XSA_NAME = $(VIV_DESIGN)
VIV_XSA = $(VIV_DIR)/project/$(VIV_XSA_NAME).xsa
VIV_SDT = project_sdt
VIV_BASE_XSA = $(VIV_DIR)/project/$(VIV_DESIGN)_base.xsa

PFM_DIR = xilinx_$(VIV_DESIGN)_$(VERSION)
PFM_SCRIPTS_DIR = scripts

PFM_PY = $(PFM_SCRIPTS_DIR)/pfm.py
PFM_XPFM = $(PFM_DIR)/$(VIV_DESIGN).xpfm

.PHONY: help
help:
	@echo 'Usage:'
	@echo ''
	@echo '  make platform [PLATFORM=<p>] [VERSION=<v>] [JOBS=<j>] [SECURE=1]'
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
	@echo '    JOBS: $(JOBS) '
	@echo '    SECURE: $(SECURE) '
	@echo ''


.PHONY: all
all: platform

.PHONY: platform
platform: $(PFM_XPFM) sdt
$(PFM_XPFM): $(VIV_XSA)
	$(VITIS) -s $(PFM_PY) -xsa $(VIV_XSA) -out $(PFM_DIR)
	@echo 'Vitis platform available at $(PFM_DIR)'

.PHONY: sdt
sdt: $(VIV_SDT)
$(VIV_SDT): $(VIV_BASE_XSA)
	$(SDTGEN) -xsa $(VIV_BASE_XSA) -dir $(VIV_SDT) -board_dts $(BOARD_DTS) -debug enable

$(VIV_BASE_XSA): $(VIV_XSA)
$(VIV_XSA):
	make -C $(VIV_DIR) xsa JOBS=$(JOBS) SECURE=$(SECURE)

.PHONY: clean
clean:
	-@$(RM) .Xil boot image linux.bif ws $(PFM_DIR) xsct $(VIV_SDT) vitis_journal.py
	make -C $(VIV_DIR) clean

