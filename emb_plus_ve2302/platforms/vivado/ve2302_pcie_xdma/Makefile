# Copyright (C) 2023 - 2026, Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

RM = rm -rf
VIVADO = $(XILINX_VIVADO)/bin/vivado
JOBS ?= 8
SECURE ?= 0
PYTHON = python3

VIV_PRJ_DIR = project
VIV_SCRIPTS_DIR = scripts

PLATFORM_JSON = ./platform.json
META_JSON =  $(VIV_PRJ_DIR)/partition_metadata.json
META_PY = $(VIV_SCRIPTS_DIR)/partition_metadata_gen_script.py

VIV_TIMING_ERROR = "CRITICAL WARNING: \[Timing 38-282\] The design failed to meet the timing requirements"
UUID = $(UUID_PROD)

ifeq ($(SECURE),1)
  VIV_DESIGN = ve2302_pcie_xdma_secure
else
  VIV_DESIGN = ve2302_pcie_xdma
endif


VIV_XSA = $(VIV_PRJ_DIR)/$(VIV_DESIGN).xsa
VIV_SRC = $(VIV_SCRIPTS_DIR)/main.tcl
VIV_CONFIG = $(VIV_SCRIPTS_DIR)/config_bd.tcl
VIV_ULP = $(VIV_SCRIPTS_DIR)/ulp.tcl
VIV_PDI = $(VIV_PRJ_DIR)/$(VIV_DESIGN).runs/impl_1/$(VIV_DESIGN)_wrapper.pdi


.PHONY: help
help:
	@echo 'Usage:'
	@echo ''
	@echo '  make xsa [JOBS=<n>] [SECURE=1]'
	@echo '    Generate extensible xsa for platform generation'
	@echo ''
	@echo '  Options:'
	@echo '    JOBS: optional param to set number of synthesis jobs (default: 8)'
	@echo '    SECURE: optional param to enable XMPU/XPPU protections (default: 0)'
	@echo ''


.PHONY: all
all: xsa

xsa: $(VIV_XSA)

$(VIV_XSA): $(VIV_SRC) $(VIV_CONFIG)
	$(VIVADO) -mode batch -notrace -source $(VIV_SRC) -tclargs -jobs $(JOBS) -secure $(SECURE)
	@grep $(VIV_TIMING_ERROR) vivado.log; if [ $$? = 0 ]; then exit 1; fi
	$(PYTHON) $(META_PY) -config $(VIV_CONFIG) -pdi $(VIV_PDI) -ulp $(VIV_ULP) -o $(META_JSON)
	zip -u $(VIV_PRJ_DIR)/$(VIV_DESIGN)_base.xsa $(META_JSON) $(PLATFORM_JSON)

.PHONY: clean
clean:
	$(RM) $(VIV_PRJ_DIR) vivado* .Xil *dynamic* *.log *.xpe .crashReporter hd_visual *.swp uuid_data.txt *.json

