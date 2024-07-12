# Copyright (C) 2023 - 2024, Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

RM = rm -rf
VIVADO = $(XILINX_VIVADO)/bin/vivado
JOBS ?= 8
SILICON ?= prod
PYTHON = python3

VIV_PRJ_DIR = project
VIV_SCRIPTS_DIR = scripts

PLATFORM_JSON = ./platform.json
META_JSON =  $(VIV_PRJ_DIR)/partition_metadata.json
META_PY = $(VIV_SCRIPTS_DIR)/partition_metadata_gen_script.py

VIV_TIMING_ERROR = "CRITICAL WARNING: \[Timing 38-282\] The design failed to meet the timing requirements"

ifeq ($(SILICON), es1)
  UUID = $(UUID_ES1)
  VIV_DESIGN = ve2302_es1_pcie_qdma
else
  UUID = $(UUID_PROD)
  VIV_DESIGN = ve2302_pcie_qdma
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
	@echo '  make xsa [JOBS=<n>] [SILICON=<es1,prod>]'
	@echo '    Generate extensible xsa for platform generation'
	@echo ''
	@echo '  Options:'
	@echo '    JOBS: optional param to set number of synthesis jobs (default: 8)'
	@echo '    SILICON: optional param to choose es1 or production  (default: prod)'
	@echo ''


.PHONY: all
all: xsa

xsa: $(VIV_XSA)

$(VIV_XSA): $(VIV_SRC) $(VIV_CONFIG)
	$(VIVADO) -mode batch -notrace -source $(VIV_SRC) -tclargs -jobs $(JOBS) -silicon $(SILICON)
	@grep $(VIV_TIMING_ERROR) vivado.log; if [ $$? = 0 ]; then exit 1; fi
	$(PYTHON) $(META_PY) -config $(VIV_CONFIG) -pdi $(VIV_PDI) -ulp $(VIV_ULP) -o $(META_JSON)
	zip -u $(VIV_PRJ_DIR)/$(VIV_DESIGN)_base.xsa $(META_JSON) $(PLATFORM_JSON)

.PHONY: clean
clean:
	$(RM) $(VIV_PRJ_DIR) vivado* .Xil *dynamic* *.log *.xpe .crashReporter hd_visual *.swp uuid_data.txt

