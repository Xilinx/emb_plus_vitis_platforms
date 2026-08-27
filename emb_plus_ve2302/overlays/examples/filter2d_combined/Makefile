# Copyright (C) 2023-2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT
#
# Combined AIE + PL filter2d overlay. Produces one xclbin carrying both the
# AI Engine graph (with its tiler/stitcher/mm2s data movers) and the PL
# accelerator, so the host can select a path at runtime with -m aie|pl without
# reprogramming the device.
#
# This directory holds NO kernel sources of its own. Everything is built from
# filter2d_aie/ and filter2d_pl/, so a fix to either lands here automatically
# and the three overlays cannot drift apart.
#
# Build with:  make -C ../../.. overlay OVERLAY=filter2d_combined
# or directly: make all PLATFORM=<abs path to .xpfm>

SHELL = bash
VERSION = 1.3
CURDIR = $(shell pwd)
REPO_PATH = $(shell dirname $(shell dirname $(shell dirname $(shell dirname $(CURDIR)))))
COMMON_PATH = $(REPO_PATH)/common
RMDIR = rm -rf
PYTHON = python3
META_GEN = $(COMMON_PATH)/gen_metadata.py
VIV_DIR = $(REPO_PATH)/emb_plus_ve2302/platforms/vivado/ve2302_pcie_xdma
XUTIL = xclbinutil
META_JSON = $(CURDIR)/filter2d_partition_metadata.json
PLATFORM ?=
PLATFORM_NAME = $(strip $(patsubst %.xpfm, % , $(shell basename $(PLATFORM))))

# Sibling overlays that own the sources.
AIE_DIR = ../filter2d_aie
PL_KERNEL_DIR = ../filter2d_pl/kernel

VPP = v++
SRC_DIR_1_RELATIVE = ../../../../common/Vitis_Libraries/vision/L1/include
SRC_DIR_1 = $(realpath $(SRC_DIR_1_RELATIVE))
XO_SRC_RELATIVE = ../../../../common/Vitis_Libraries/vision/L1/lib/hw/

TARGET ?= hw
TEMP_DIR := _x
BUILD_DIR := build_dir.$(TARGET).$(PLATFORM_NAME)
BUILD_REPORT_DIR := $(CURDIR)/reports/_build.$(TARGET).$(PLATFORM_NAME)
XCLBIN_DIR := $(CURDIR)/$(BUILD_DIR)
export XCL_BINDIR = $(XCLBIN_DIR)

XILINX_VITIS_AIETOOLS ?=
ifneq ($(wildcard $(XILINX_VITIS)/aietools/.*),)
XILINX_VITIS_AIETOOLS := $(XILINX_VITIS)/aietools
else
XILINX_VITIS_AIETOOLS := $(XILINX_VITIS)/cardano
endif

############################ AIE compiler ###########################

AIETARGET := hw
AIE_CXXFLAGS += -c --mode aie
AIE_CXXFLAGS += --target=$(AIETARGET) --platform=$(PLATFORM)
AIE_CXXFLAGS += -I $(XILINX_VITIS_AIETOOLS)/include
AIE_CONTAINER = $(TEMP_DIR)/libadf.a
AIE_CXXFLAGS += -I $(SRC_DIR_1)/aie-ml
AIE_CXXFLAGS += -I $(SRC_DIR_1)/aie
# The graph and its kernels live in filter2d_aie.
AIE_CXXFLAGS += -I $(realpath $(AIE_DIR))

########################## PL kernels ##########################

MM2S_XO_FILE = $(TEMP_DIR)/mm2s.xo
PL_XO_FILE = $(TEMP_DIR)/filter2d_pl_accel.xo
PL_KERNEL = filter2d_pl_accel
PL_CLK_FREQ = 299996999
PL_PPC ?= XF_NPPC8

VPP_FLAGS += --save-temps
VPP_FLAGS += -I $(SRC_DIR_1)
VPP_FLAGS += -I $(XILINX_VITIS_AIETOOLS)/include
VPP_FLAGS += -I $(realpath $(AIE_DIR))
# Tiler/stitcher are asked for a faster clock than the PL accelerator. Note the
# platform only offers 300 and 250 MHz kernel clocks, so this request is capped
# in practice -- see the xclbin's CLOCK_FREQ_TOPOLOGY.
VPP_LDFLAGS += --clock.freqHz 400000000:Tiler_top_1 --clock.freqHz 400000000:stitcher_top_1
VPP_LDFLAGS += $(XO_SRC_RELATIVE)/tiler.xo $(XO_SRC_RELATIVE)/stitcher.xo
VPP_LDFLAGS += --config system.cfg
VPP_FLAGS_MM2S += --verbose
VPP_FLAGS_MM2S += -I$(XILINX_VITIS)/aietools/include

################### packaging ###############

MAINTAINER = AMD
BOARD = ve2302
EXAMPLE = filter2d
XSA_FILE = $(BUILD_DIR)/filter2d.xsa
BINARY_CONTAINERS = $(TEMP_DIR)/link/int/filter2d.xclbin
XCLBIN_FILE = $(CURDIR)/filter2d.xclbin
DEB_BUILD_DIR = $(EXAMPLE)-$(BOARD)
DEB_DIR = $(DEB_BUILD_DIR)/opt/xilinx/firmware/emb_plus/ve2302_pcie_xdma/base/test/
VIV_CONFIG = $(VIV_DIR)/scripts/config_bd.tcl
ULP_CONFIG = $(VIV_DIR)/scripts/ulp.tcl
VIV_PDI = $(CURDIR)/_x/link/int/partial.pdi

CONTROL_FILE = $(DEB_BUILD_DIR)/DEBIAN/control
CONTROL_CONTENT = "Package: $(DEB_BUILD_DIR)\nArchitecture: all\nVersion: $(VERSION)\nPriority: optional\nDescription: $(EXAMPLE) firmware\nMaintainer: $(MAINTAINER)\n"
PKGNAME = $(DEB_BUILD_DIR)_$(VERSION)
DEB_FILE = $(PKGNAME).deb

############################## targets ##############################

.PHONY: all
all: xclbin $(XSA_FILE) $(DEB_FILE)

.PHONY: xclbin
xclbin: $(XCLBIN_FILE)
$(XCLBIN_FILE): $(BINARY_CONTAINERS)
	$(PYTHON) $(META_GEN) -config $(VIV_CONFIG) -pdi $(VIV_PDI) -ulp $(ULP_CONFIG) -o $(META_JSON)
	$(XUTIL) --input $^ --remove-section AIE_RESOURCES --output f2d_aie_resource.xclbin
	$(XUTIL) --input f2d_aie_resource.xclbin --add-section PARTITION_METADATA:JSON:$(META_JSON) --output $@
	rm -f f2d_aie_resource.xclbin

$(BINARY_CONTAINERS): $(XSA_FILE) $(AIE_CONTAINER)
	${VPP} -p -t ${TARGET} -f ${PLATFORM} ${AIE_CONTAINER} --package.boot_mode=ospi -o $@ $^

$(XSA_FILE): $(AIE_CONTAINER) $(MM2S_XO_FILE) $(PL_XO_FILE)
	mkdir -p $(BUILD_DIR)
	$(VPP) -l $(VPP_FLAGS) -t $(TARGET) --platform $(PLATFORM) --temp_dir $(TEMP_DIR) --report_dir $(BUILD_REPORT_DIR) $(VPP_LDFLAGS) -o $@ $^
	cp $(XSA_FILE) ./

################ kernel builds, all from the sibling overlays ################

# PL accelerator, source owned by filter2d_pl.
$(PL_XO_FILE): $(PL_KERNEL_DIR)/xf_filter2d_pl_accel.cpp
	@echo "Compiling Kernel: $(PL_KERNEL) (from $(PL_KERNEL_DIR))"
	mkdir -p $(dir $@)
	$(VPP) -c -t $(TARGET) --platform $(PLATFORM) --save-temps \
		--clock.defaultFreqHz $(PL_CLK_FREQ) --report_level estimate \
		-k $(PL_KERNEL) -I$(PL_KERNEL_DIR) -I$(SRC_DIR_1) \
		-DPPC=$(PL_PPC) -D__SDSVHLS__ \
		--temp_dir $(TEMP_DIR) --report_dir $(BUILD_REPORT_DIR) -o $@ $<

# AIE-path data mover, source owned by filter2d_aie.
$(MM2S_XO_FILE): $(AIE_DIR)/mm2s.cpp
	@echo "Compiling Kernel: mm2s (from $(AIE_DIR))"
	mkdir -p $(dir $@)
	$(VPP) -c $(VPP_FLAGS_MM2S) -t $(TARGET) --platform $(PLATFORM) -k mm2s \
		-I'$(AIE_DIR)' --temp_dir $(TEMP_DIR) --report_dir $(BUILD_REPORT_DIR) -o'$@' '$<'

# AI Engine graph, source owned by filter2d_aie.
$(AIE_CONTAINER): $(AIE_DIR)/graph.cpp
	@echo "Compiling: libadf.a (from $(AIE_DIR))"
	mkdir -p $(dir $@)
	$(VPP) $(AIE_CXXFLAGS) --aie.xlopt=0 --aie.Xmapper=DisableFloorplanning --work_dir=./Work $<
	cp ./libadf.a $(AIE_CONTAINER)

.PHONY: deb
deb: $(DEB_FILE)
$(DEB_FILE): $(XCLBIN_FILE)
	mkdir -p $(DEB_DIR)
	cp $^ $(DEB_DIR)
	mkdir -p $(DEB_BUILD_DIR)/DEBIAN
	chmod 00755 $(DEB_BUILD_DIR)/DEBIAN
	@echo -e $(CONTROL_CONTENT) > $(CONTROL_FILE)
	@echo "Now generating the debian package"
	dpkg-deb --build ./$(DEB_BUILD_DIR)
	mv $(DEB_BUILD_DIR).deb $(DEB_FILE)

.PHONY: help
help:
	@echo "Makefile Usage:"
	@echo "make all PLATFORM=<xpfm_file_location>"
	@echo "Command to build xclbin application and deb package"
	@echo ""
	@echo "make clean"
	@echo "Command to remove the generated files."

.PHONY: clean
clean:
	-$(RMDIR) $(BUILD_DIR)/*.xclbin *xclbin.run_summary pl*start_simulation.sh *.xclbin
	-$(RMDIR) _x_temp.*/_x.* _x_temp.*/.Xil _x_temp.*/profile_summary.* xo_* _x*
	-$(RMDIR) _x_temp.*/dltmp* _x_temp.*/kernel_info.dat _x_temp.*/*.log
	-$(RMDIR) _x_temp.* .Xil .ipcache .crashReporter
	-$(RMDIR) $(CURDIR)/libadf.a *.csv *.log sol.db
	-$(RMDIR) _x_temp.hw.* build_dir.hw.* *.BIN *.bin *.xsa *.bif
	-$(RMDIR) $(CURDIR)/Work $(CURDIR)/reports $(BUILD_DIR)
	-$(RMDIR) $(DEB_BUILD_DIR) $(DEB_FILE)
	-$(RMDIR) $(META_JSON) *data.txt
	-$(RMDIR) analyzer_input baremetal_metadata_package.cpp
