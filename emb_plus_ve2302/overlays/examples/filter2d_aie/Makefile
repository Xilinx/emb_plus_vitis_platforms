# Copyright (C) 2023-2025 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

SHELL = bash
YEAR = $(shell date '+%Y')
MONTH = $(shell date '+%m')
VERSION = 1.3
CURDIR = $(shell pwd)
REPO_PATH = $(shell dirname $(shell dirname $(shell dirname $(shell dirname $(CURDIR)))))
COMMON_PATH = $(REPO_PATH)/common
RMDIR = rm -rf
MV = mv
PYTHON = python3
META_GEN = $(COMMON_PATH)/gen_metadata.py
VIV_DIR = $(REPO_PATH)/emb_plus_ve2302/platforms/vivado/ve2302_pcie_qdma
XUTIL = xclbinutil
META_JSON =  $(CURDIR)/filter2d_aie_partition_metadata.json
PLATFORM ?=
PLATFORM_NAME = $(strip $(patsubst %.xpfm, % , $(shell basename $(PLATFORM))))

# v++ flags
VPP = v++
SRC_DIR_1_RELATIVE = ../../../../common/Vitis_Libraries/vision/L1/include
SRC_DIR_1 = $(realpath $(SRC_DIR_1_RELATIVE))
XO_SRC_RELATIVE = ../../../../common/Vitis_Libraries/vision/L1/lib/hw/
XO_SRC = $(realpath $(XO_SRC_RELATIVE))

# setting default value
TARGET ?= hw
TEMP_DIR := _x
TEMP_REPORT_DIR := $(CURDIR)/reports/_x.$(TARGET).$(PLATFORM_NAME)
BUILD_DIR := build_dir.$(TARGET).$(PLATFORM_NAME)
BUILD_REPORT_DIR := $(CURDIR)/reports/_build.$(TARGET).$(PLATFORM_NAME)
XCLBIN_DIR := $(CURDIR)/$(BUILD_DIR)
export XCL_BINDIR = $(XCLBIN_DIR)

# aie template
XILINX_VITIS_AIETOOLS ?=

ifneq ($(wildcard $(XILINX_VITIS)/aietools/.*),)
XILINX_VITIS_AIETOOLS := $(XILINX_VITIS)/aietools
else
XILINX_VITIS_AIETOOLS := $(XILINX_VITIS)/cardano
endif

############################ setting AIE Compiler ###########################

AIETARGET := hw
AIE_CXXFLAGS += -c --mode aie
AIE_CXXFLAGS += --target=$(AIETARGET) --platform=$(PLATFORM)
AIE_CXXFLAGS += -I $(XILINX_VITIS_AIETOOLS)/include
AIE_CONTAINER = $(TEMP_DIR)/libadf.a
AIE_CXXFLAGS += -I $(SRC_DIR_1)/aie-ml
AIE_CXXFLAGS += -I $(SRC_DIR_1)/aie
AIE_CXXFLAGS += -I $(CURDIR)

########################## Kernel compiler global settings ##########################

VPP_FLAGS += --save-temps
VPP_FLAGS +=  -I $(SRC_DIR_1)
VPP_FLAGS +=  -I $(XILINX_VITIS_AIETOOLS)/include
VPP_FLAGS +=  -I $(CURDIR)
VPP_LDFLAGS += --clock.freqHz 400000000:Tiler_top_1  --clock.freqHz 400000000:stitcher_top_1  $(XO_SRC_RELATIVE)/tiler.xo  $(XO_SRC_RELATIVE)/stitcher.xo
VPP_LDFLAGS +=  --config system.cfg
VPP_FLAGS_MM2S += --verbose
VPP_FLAGS_MM2S += -I$(XILINX_VITIS)/aietools/include
MM2S_XO_FILE = $(TEMP_DIR)/mm2s.xo

################### deb package generation variables and binary container global settings ###############
MAINTAINER = AMD
BOARD = ve2302
EXAMPLE = filter2d-aie
XSA_FILE = $(BUILD_DIR)/filter2d_aie.xsa
BINARY_CONTAINERS = $(TEMP_DIR)/link/int/filter2d_aie.xclbin
XCLBIN_FILE = $(CURDIR)/filter2d_aie.xclbin
DEB_BUILD_DIR = filter2d-aie-$(BOARD)
DEB_DIR = $(DEB_BUILD_DIR)/opt/xilinx/firmware/emb_plus/ve2302_pcie_qdma/base/test/
VIV_CONFIG = $(VIV_DIR)/scripts/config_bd.tcl
ULP_CONFIG = $(VIV_DIR)/scripts/ulp.tcl
VIV_PDI = $(CURDIR)/_x/link/int/partial.pdi

CONTROL_FILE = $(DEB_BUILD_DIR)/DEBIAN/control
CONTROL_CONTENT = "Package: $(DEB_BUILD_DIR)\nArchitecture: all\nVersion: $(VERSION)\nPriority: optional\nDescription: $(EXAMPLE) firmware\nMaintainer: $(MAINTAINER)\n"
PKGNAME = $(DEB_BUILD_DIR)_$(VERSION)
DEB_FILE = $(PKGNAME).deb

############################## Setting Targets ##############################

.PHONY: all
all: xclbin $(XSA_FILE) $(DEB_FILE)

.PHONY: xclbin
xclbin:  $(XCLBIN_FILE)
$(XCLBIN_FILE): $(BINARY_CONTAINERS)
	$(PYTHON) $(META_GEN) -config $(VIV_CONFIG) -pdi $(VIV_PDI) -ulp $(ULP_CONFIG) -o $(META_JSON)
	$(XUTIL) --input $^ --remove-section AIE_RESOURCES --output f2d_aie_aie_resource.xclbin
	$(XUTIL) --input f2d_aie_aie_resource.xclbin --add-section PARTITION_METADATA:JSON:$(META_JSON) --output $@

$(BINARY_CONTAINERS): $(XSA_FILE) $(AIE_CONTAINER)
	${VPP} -p -t ${TARGET} -f ${PLATFORM} ${AIE_CONTAINER} --package.boot_mode=ospi -o $@ $^


$(XSA_FILE): $(AIE_CONTAINER) $(MM2S_XO_FILE)
	mkdir -p $(BUILD_DIR)
	$(VPP) -l $(VPP_FLAGS) -t $(TARGET) --platform $(PLATFORM) --temp_dir $(TEMP_DIR) --report_dir $(BUILD_REPORT_DIR) $(VPP_LDFLAGS)  -o $@ $^
	cp $(XSA_FILE) ./

################ Setting Rules for Binary Containers (Building Kernels) ################

$(MM2S_XO_FILE): $(CURDIR)/mm2s.cpp
	@echo "Compiling Kernel: mm2s"
	mkdir -p $(dir $@)
	$(VPP) -c  $(VPP_FLAGS_MM2S) -t $(TARGET) --platform $(PLATFORM) -k mm2s -I'$(<D)' --temp_dir $(TEMP_DIR) --report_dir $(BUILD_REPORT_DIR) -o'$@' '$<'


$(AIE_CONTAINER): $(CURDIR)/graph.cpp
	@echo "Compiling: libadf.a"
	mkdir -p $(dir $@)
	$(VPP) $(AIE_CXXFLAGS) --aie.xlopt=0 --aie.Xmapper=DisableFloorplanning --work_dir=./Work $^
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
	@echo "make all PLATFORM= <xpfm_file_location>"
	@echo "Command to build xclbin application and deb package"
	@echo ""
	@echo "make clean"
	@echo "Command to remove the generated files. "
	@echo ""


.PHONY: clean
clean:
	-$(RMDIR) $(BUILD_DIR)/*.xclbin *xclbin.run_summary pl*start_simulation. sh *.xclbin
	-$(RMDIR) _x_temp.*/_x.* _x_temp.*/.Xil _x_temp.*/profile_summary.* xo_* _x*
	-$(RMDIR) _x_temp.*/dltmp* _x_temp.*/kernel_info.dat _x_temp.*/*.log
	-$(RMDIR) _x_temp.* .Xil .ipcache .crashReporter
	-$(RMDIR) $(CURDIR)/libadf.a  *.csv *.log sol.db
	-$(RMDIR) _x_temp.hw.* build_dir.hw.* *.BIN *.bin *.xsa *.bif
	-$(RMDIR) $(CURDIR)/Work  $(CURDIR)/reports $(BUILD_DIR)
	-$(RMDIR) $(DEB_BUILD_DIR) $(DEB_FILE)
	-$(RMDIR) $(META_JSON) *data.txt

