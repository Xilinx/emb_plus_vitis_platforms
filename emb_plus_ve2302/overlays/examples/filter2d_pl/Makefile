# Copyright (C) 2023 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

RM = rm -rf
MV = mv
CURDIR = $(shell pwd)
REPO_PATH = $(shell dirname $(shell dirname $(shell dirname $(shell dirname $(CURDIR)))))
COMMON_PATH = $(REPO_PATH)/common
PYTHON = python3
META_GEN = $(COMMON_PATH)/gen_metadata.py
VIV_DIR = $(REPO_PATH)/emb_plus_ve2302/platforms/vivado/ve2302_pcie_qdma
XUTIL = xclbinutil 
META_JSON =  $(CURDIR)/filter2d_pl_partition_metadata.json

# v++ flags
VPP ?= v++
PLATFORM ?=
LINK_CFG ?= kernel.cfg
JOBS ?= 32
VPP_LINK_FLAGS = -l -t hw --platform $(PLATFORM) --save-temps \
	--report_level estimate -j $(JOBS) --config $(LINK_CFG)

# kernels and xclbin
KERNEL_OBJS += kernel/filter2d_pl_accel/filter2d_pl_accel.xo
BINARY_CONTAINER = _x/link/int/filter2d_pl.xclbin
XCLBIN_FILE = $(CURDIR)/filter2d_pl.xclbin
XSA_FILE = filter2d_pl.xsa
CLK_FREQ = 299996999

## deb package script location
VERSION = 1.0
SILICON ?= prod
MAINTAINER = AMD
BOARD = ve2302
EXAMPLE = filter2d-pl
CONTROL_FILE = $(BUILD_DIR)/DEBIAN/control
ifeq ($(SILICON),es1)
	BUILD_DIR = $(EXAMPLE)-$(BOARD)-$(SILICON)
	DEB_DIR = $(BUILD_DIR)/opt/xilinx/firmware/emb_plus/ve2302_pcie_qdma-$(SILICON)/base/test/
else
	BUILD_DIR = $(EXAMPLE)-$(BOARD)
	DEB_DIR = $(BUILD_DIR)/opt/xilinx/firmware/emb_plus/ve2302_pcie_qdma/base/test/
endif

VIV_CONFIG = $(VIV_DIR)/scripts/config_bd.tcl
VIV_PDI = $(CURDIR)/_x/link/int/partial.pdi

CONTROL_CONTENT = "Package: $(BUILD_DIR)\nArchitecture: all\nVersion: $(VERSION)\nPriority: optional\nDescription: $(EXAMPLE) firmware\nMaintainer: $(MAINTAINER)\n"
PKGNAME = $(BUILD_DIR)_$(VERSION)
DEB_FILE = $(PKGNAME).deb

# Rules
.PHONY: all
all: $(KERNEL_OBJS) $(XSA_FILE) $(DEB_FILE) $(XCLBIN_FILE)

.PHONY: xclbin
xclbin: $(XCLBIN_FILE)
$(XCLBIN_FILE): $(BINARY_CONTAINER)
	$(PYTHON) $(META_GEN) -config $(VIV_CONFIG) -pdi $(VIV_PDI) -o $(META_JSON)
	$(XUTIL) --input $(BINARY_CONTAINER) --add-section PARTITION_METADATA:JSON:$(META_JSON) --output $(XCLBIN_FILE)
	-@$(RM) $(BINARY_CONTAINER)

$(BINARY_CONTAINER): $(XSA_FILE)
$(XSA_FILE): $(KERNEL_OBJS)
	$(VPP) $(VPP_LINK_FLAGS) -o $@ $(+)
	-@$(RM) .Xil

$(KERNEL_OBJS):
	$(MAKE) -C kernel FREQ=$(CLK_FREQ)

.PHONY: deb
deb: $(DEB_FILE)
$(DEB_FILE): $(XCLBIN_FILE)
	mkdir -p $(DEB_DIR)
	cp $^ $(DEB_DIR)
	mkdir -p $(BUILD_DIR)/DEBIAN
	@echo -e $(CONTROL_CONTENT) > $(CONTROL_FILE)
	@echo "Now generating the debian package"
	dpkg-deb --build ./$(BUILD_DIR)
	mv $(BUILD_DIR).deb $(DEB_FILE)

.PHONY: clean clean-subdirs
clean: clean-subdirs
	-$(RM) _xocc* .Xil _x *.o *.xclbin *.BIN *.bif *.pdi
	-$(RM) .Xil _sds *.xml *.dat *.hpfm iprepo *.xtxt *.xsa
	-$(RM) sd_card *.log *.rpt .ipcache
	-$(RM) *.info .crashReporter kernel/.crashReporter
	-$(RM) *.link_summary* *.package_summary* *.ltx
	-$(RM) $(BUILD_DIR) $(DEB_FILE)
	-$(RM) $(META_JSON) *data.txt

clean-subdirs:
	$(MAKE) -C kernel clean
