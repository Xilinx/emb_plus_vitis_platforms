# Copyright (C) 2023 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

YEAR = $(shell date '+%Y')
MONTH = $(shell date '+%m')
VERSION = 1
CURDIR = $(shell pwd)
REPO_PATH = $(shell dirname $(shell dirname $(shell dirname $(shell dirname $(CURDIR)))))
COMMON_PATH = $(REPO_PATH)/common
SRC = $(CURDIR)/src
RMDIR = rm -rf
MV = mv
PYTHON = python3
META_GEN = $(COMMON_PATH)/gen_metadata.py
VIV_DIR = $(REPO_PATH)/emb_plus_ve2302/platforms/vivado/ve2302_pcie_qdma
XUTIL = xclbinutil
META_JSON =  $(CURDIR)/filter2d_aie_partition_metadata.json

PLATFORM ?=
PLATFORM_NAME = $(strip $(patsubst %.xpfm, % , $(shell basename $(PLATFORM))))
include utils.mk 

# v++ flags
VPP = v++
AIECXX := aiecompiler
MK_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
CUR_DIR := $(patsubst %/,%,$(dir $(MK_PATH)))
SRC_DIR_1_RELATIVE = ../../../../common/xf_opencv/L1/include
SRC_DIR_2_RELATIVE = ../../../../common/xf_opencv/L2/tests/aie-ml/yuy2_filter2d/16bit_aie_8bit_pl

SRC_DIR_1 = $(realpath $(SRC_DIR_1_RELATIVE))
SRC_DIR_2 = $(realpath $(SRC_DIR_2_RELATIVE))

XO_SRC_RELATIVE = ../../../../common/xf_opencv/L1/lib/hw/
XO_SRC = $(realpath $(XO_SRC_RELATIVE))

# setting devault value
TARGET ?= hw
TEMP_DIR := _x
TEMP_REPORT_DIR := $(CUR_DIR)/reports/_x.$(TARGET).$(PLATFORM_NAME)
BUILD_DIR := build_dir.$(TARGET).$(PLATFORM_NAME)
BUILD_REPORT_DIR := $(CUR_DIR)/reports/_build.$(TARGET).$(PLATFORM_NAME)
XCLBIN_DIR := $(CUR_DIR)/$(BUILD_DIR)
export XCL_BINDIR = $(XCLBIN_DIR)
BINARY_CONTAINERS_DEPS :=

VPP_FLAGS += --save-temps 
VPP_LDFLAGS += --optimize 2 -R 2 
VPP_LDFLAGS += --kernel_frequency 400

# aie template
XILINX_VITIS_AIETOOLS ?=

ifneq ($(wildcard $(XILINX_VITIS)/aietools/.*),)
XILINX_VITIS_AIETOOLS := $(XILINX_VITIS)/aietools
else
XILINX_VITIS_AIETOOLS := $(XILINX_VITIS)/cardano
endif

############################ setting AIE Compiler ###########################

AIETARGET := hw
AIE_CXXFLAGS += --target=$(AIETARGET) --platform=$(PLATFORM) --pl-freq=400 -pl-axi-lite=true 
AIE_CXXFLAGS += -I $(XILINX_VITIS_AIETOOLS)/include
AIE_CONTAINER = $(TEMP_DIR)/libadf.a
AIE_CXXFLAGS += -I $(SRC_DIR_1)/aie-ml
AIE_CXXFLAGS += -I $(SRC_DIR_1)/aie
AIE_CXXFLAGS += -I $(SRC_DIR_2)
BINARY_CONTAINERS_DEPS += $(AIE_CONTAINER)


########################## Kernel compiler global settings ##########################

VPP_FLAGS +=  -I $(SRC_DIR_1)
VPP_FLAGS +=  -I $(XILINX_VITIS_AIETOOLS)/include
VPP_FLAGS +=  -I $(SRC_DIR_2)
VPP_LDFLAGS +=  --config system.cfg
VPP_LDFLAGS += --clock.freqHz 400000000:Tiler_top_1  --clock.freqHz 400000000:stitcher_top_1  $(XO_SRC_RELATIVE)/tiler.xo  $(XO_SRC_RELATIVE)/stitcher.xo

######################### binary container global settings ##########################

BINARY_CONTAINERS = $(TEMP_DIR)/link/int/kernel_pkg.xclbin
XSA_FILE = $(BUILD_DIR)/kernel_pkg.xsa

################### deb package generation variables ###############

VERSION = 1.0
SILICON ?= prod
MAINTAINER = AMD
BOARD = ve2302
EXAMPLE = filter2d-aie
ifeq ($(SILICON),es1)
	DEB_BUILD_DIR = xrt-filter2d-aie-test-$(BOARD)-$(SILICON)
	DEB_DIR = $(DEB_BUILD_DIR)/opt/xilinx/firmware/emb_plus/ve2302_pcie_qdma-$(SILICON)/base/test/
else
	DEB_BUILD_DIR = xrt-filter2d-aie-test-$(BOARD)
	DEB_DIR = $(DEB_BUILD_DIR)/opt/xilinx/firmware/emb_plus/ve2302_pcie_qdma/base/test/
endif 

VIV_CONFIG = $(VIV_DIR)/scripts/config_bd.tcl
VIV_PDI = $(CURDIR)/_x/link/int/partial.pdi

CONTROL_FILE = $(DEB_BUILD_DIR)/DEBIAN/control
CONTROL_CONTENT = "Package: $(DEB_BUILD_DIR)\nArchitecture: all\nVersion: $(VERSION)\nPriority: optional\nDescription: $(EXAMPLE) firmware\nMaintainer: $(MAINTAINER)\n"
PKGNAME = $(DEB_BUILD_DIR)_$(VERSION)
DEB_FILE = $(PKGNAME).deb
XCLBIN_FILE = $(CURDIR)/kernel_pkg.xclbin

############################## Setting Targets ##############################

.PHONY: all xclbin 
all: xclbin $(XSA_FILE) $(DEB_FILE)

.PHONY: xclbin
xclbin:  $(XCLBIN_FILE)
$(XCLBIN_FILE): $(BINARY_CONTAINERS)
	$(PYTHON) $(META_GEN) -config $(VIV_CONFIG) -pdi $(VIV_PDI) -o $(META_JSON)
	$(XUTIL) --input $^ --add-section PARTITION_METADATA:JSON:$(META_JSON) --output $@
	-@$(RM) $(META_JSON) *data.txt

$(BINARY_CONTAINERS): $(XSA_FILE) $(AIE_CONTAINER)
	${VPP} -p -t ${TARGET} -f ${PLATFORM} ${AIE_CONTAINER} --package.boot_mode=ospi --package.defer_aie_run -o $@ $^ 


$(XSA_FILE): $(AIE_CONTAINER) 
	mkdir -p $(BUILD_DIR)
	$(VPP) -l $(VPP_FLAGS) -t $(TARGET) --platform $(PLATFORM) --temp_dir $(TEMP_DIR) --report_dir $(BUILD_REPORT_DIR) $(VPP_LDFLAGS)  -o $@ $^ 
	cp $(XSA_FILE) ./

################ Setting Rules for Binary Containers (Building Kernels) ################

BINARY_CONTAINERS_DEPS += $(BINARY_CONTAINER_emb_plus_pl_controller.xclbin_OBJS)
BINARY_CONTAINERS_DEPS += $(AIE_CONTAINER)

$(AIE_CONTAINER): $(SRC_DIR_2)/graph.cpp $(SRC_DIR_2)/xf_filter2d.cc
	$(ECHO) "Compiling: libadf.a"
	mkdir -p $(dir $@)
	$(AIECXX) $(AIE_CXXFLAGS) $^
	cp ./libadf.a $(AIE_CONTAINER)

.PHONY: deb
deb: $(DEB_FILE)
$(DEB_FILE): $(XCLBIN_FILE)
	mkdir -p $(DEB_DIR)
	cp $^ $(DEB_DIR)
	mkdir -p $(DEB_BUILD_DIR)/DEBIAN
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
	-$(RMDIR) $(CUR_DIR)/libadf.a  *.csv *.log sol.db 
	-$(RMDIR) _x_temp.hw.* build_dir.hw.* 
	-$(RMDIR) $(CUR_DIR)/Work  $(CUR_DIR)/reports $(BUILD_DIR)
	-$(RMDIR) $(DEB_BUILD_DIR) $(DEB_FILE)

