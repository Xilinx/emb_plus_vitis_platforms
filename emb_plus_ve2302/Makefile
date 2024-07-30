# Copyright (C) 2023 - 2024 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

CP = cp -f

PWD = $(shell readlink -f .)

# the platform directory has to be an absolute path when passed to v++
PFM_DIR = $(PWD)/platforms
PFM_VER = 202420_1

# valid platforms / overlays
PFM_LIST += ve2302_pcie_qdma
OVERLAY_LIST += filter2d_pl bandwidth_test validate_aie2_pl verify_test filter2d_aie

VITIS_DIR = overlays/examples
VITIS_OVERLAY_DIR = $(VITIS_DIR)/$(OVERLAY)
VITIS_OVERLAY_BIT = $(VITIS_OVERLAY_DIR)/binary_container_1/link/int/system.bit

SILICON = prod
PFM_NAME = ve2302_pcie_qdma

.PHONY: help
help:
	@echo 'Usage:'
	@echo ''
	@echo '  make overlay OVERLAY=<val>'
	@echo '    Build the Vitis application overlay.'
	@echo ''
	@echo '    Valid options for OVERLAY: ${OVERLAY_LIST}'
	@echo ''
	@echo '  make platform PFM=<val> JOBS=<n> SILICON=<es1,prod>'
	@echo '    Build the Vitis platform.'
	@echo ''
	@echo '    Valid options for PFM: ${PFM_LIST}'
	@echo '    JOBS: optional param to set number of synthesis jobs (default 8)'
	@echo '    SILICON: optional param to choose es1 (default prod)'
	@echo ''
	@echo '  make clean'
	@echo '    Clean runs'
	@echo ''

# override platform name based on overlay
ifneq ($(filter $(OVERLAY), $(OVERLAY_LIST)),)
  PFM = ve2302_pcie_qdma
endif

# Choose actual platform name based on SILICON flag
ifeq ($(PFM), ve2302_pcie_qdma)
  ifeq ($(SILICON), es1)
    PFM_NAME = ve2302_es1_pcie_qdma
  endif
endif

ifeq ($(PFM), ve2302_pcie_qdma)
  ifneq ($(SILICON), es1)
    PFM_NAME = ve2302_pcie_qdma
  endif
endif

PFM_XPFM = $(PFM_DIR)/xilinx_$(PFM_NAME)_$(PFM_VER)/$(PFM_NAME).xpfm

.PHONY: overlay
overlay: $(VITIS_OVERLAY_BIT)
$(VITIS_OVERLAY_BIT): $(PFM_XPFM)
	@valid=0; \
	for o in $(OVERLAY_LIST); do \
	  if [ "$$o" = "$(OVERLAY)" ]; then \
	    valid=1; \
	    break; \
	  fi \
	done; \
	if [ "$$valid" -ne 1 ]; then \
	  echo 'Invalid parameter OVERLAY=$(OVERLAY). Choose one of: $(OVERLAY_LIST)'; \
	  exit 1; \
	fi; \
	echo 'Build $(OVERLAY) Vitis overlay using platform $(PFM_NAME)'; \
	$(MAKE) -C $(VITIS_OVERLAY_DIR) all PLATFORM=$(PFM_XPFM) SILICON=$(SILICON)

.PHONY: platform
platform: $(PFM_XPFM)
$(PFM_XPFM):
	@valid=0; \
	for p in $(PFM_LIST); do \
	  if [ "$$p" = "$(PFM)" ]; then \
	    valid=1; \
	    break; \
	  fi \
	done; \
	if [ "$$valid" -ne 1 ]; then \
	  echo 'Invalid parameter PFM=$(PFM). Choose one of: $(PFM_LIST)'; \
	  exit 1; \
	fi; \
	echo 'Create Vitis platform $(PFM_NAME) and SDT'; \
	$(MAKE) -C $(PFM_DIR) all PLATFORM=$(PFM) VERSION=$(PFM_VER) SILICON=$(SILICON)

.PHONY: clean
clean:
	$(foreach o, $(OVERLAY_LIST), $(MAKE) -C $(VITIS_DIR)/$(o) PLATFORM=$(PFM_XPFM) clean;)
	$(foreach p, $(PFM_LIST), $(MAKE) -C $(PFM_DIR) clean PLATFORM=$(p) VERSION=$(PFM_VER); $(MAKE) -C $(PFM_DIR) clean PLATFORM=$(p) VERSION=$(PFM_VER) SILICON=es1;)
