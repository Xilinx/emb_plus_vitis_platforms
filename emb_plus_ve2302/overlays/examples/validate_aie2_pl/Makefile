# Copyright (C) 2023 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

YEAR = $(shell date '+%Y')
MONTH = $(shell date '+%m')
VERSION = 1.0
CURDIR = $(shell pwd)
REPO_PATH = $(shell dirname $(shell dirname $(shell dirname $(shell dirname $(CURDIR)))))
COMMON_PATH = $(REPO_PATH)/common
SRC = $(CURDIR)/src
RM = rm -rf
MV = mv
PYTHON = python3
META_GEN = $(COMMON_PATH)/gen_metadata.py
VIV_DIR = $(REPO_PATH)/emb_plus_ve2302/platforms/vivado/ve2302_pcie_qdma
XUTIL = xclbinutil
PLATFORM ?=
PLATFORM_NAME = $(strip $(patsubst %.xpfm, % , $(shell basename $(PLATFORM))))

include utils.mk

# v++ flags
VPP = v++
MK_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
CUR_DIR := $(patsubst %/,%,$(dir $(MK_PATH)))
SRC_DIR = .
META_JSON =  $(CURDIR)/validate_aie2pl_partition_metadata.json

# setting devault value
TARGET ?= hw
TEMP_DIR := _x
TEMP_REPORT_DIR := $(CUR_DIR)/reports/_x
BUILD_REPORT_DIR := $(CUR_DIR)/reports
XCLBIN_DIR := $(CUR_DIR)/$(BUILD_DIR)
export XCL_BINDIR = $(XCLBIN_DIR)
BINARY_CONTAINER_DEPS :=

VPP_FLAGS += --save-temps
VPP_LDFLAGS += --optimize 2 -R 2
VPP_FLAGS += $(EXTRA_VPP_FLAGS)

## deb package script location
SILICON ?= prod
MAINTAINER = AMD
BOARD = ve2302
EXAMPLE = validate-aie2pl
ifeq ($(SILICON),es1)
	BUILD_DIR = xrt-aie-test-$(BOARD)-$(SILICON)
	DEB_DIR = $(BUILD_DIR)/opt/xilinx/firmware/emb_plus/ve2302_pcie_qdma-$(SILICON)/base/test/
else
	BUILD_DIR = xrt-aie-test-$(BOARD)
	DEB_DIR = $(BUILD_DIR)/opt/xilinx/firmware/emb_plus/ve2302_pcie_qdma/base/test/
endif 

VIV_CONFIG = $(VIV_DIR)/scripts/config_bd.tcl
VIV_PDI = $(CURDIR)/_x/link/int/partial.pdi

PKGNAME = $(BUILD_DIR)_$(VERSION)
CONTROL_FILE = $(BUILD_DIR)/DEBIAN/control
CONTROL_CONTENT = "Package: $(BUILD_DIR)\nArchitecture: all\nVersion: $(VERSION)\nPriority: optional\nDescription: $(EXAMPLE) firmware\nMaintainer: $(MAINTAINER)\n"
DEB_FILE = $(PKGNAME).deb

# aie template
XILINX_VITIS_AIETOOLS ?=

ifneq ($(wildcard $(XILINX_VITIS)/aietools/.*),)
XILINX_VITIS_AIETOOLS := $(XILINX_VITIS)/aietools
else
XILINX_VITIS_AIETOOLS := $(XILINX_VITIS)/cardano
endif

# Setting customized_params in aiecompiler

############################ setting AIE Compiler ###########################

AIETARGET := hw
AIE_CXXFLAGS += --target=$(AIETARGET) --platform=$(PLATFORM) --pl-freq=1000
AIE_CXXFLAGS += -I $(XILINX_VITIS_AIETOOLS)/include
AIE_CONTAINER = $(TEMP_DIR)/libadf.a
AIE_CXXFLAGS += -I $(SRC_DIR)/aie
AIE_CXXFLAGS += -I $(SRC_DIR)/aie/kernels
AIE_CXXFLAGS += -I $(SRC_DIR)/pl_kernels
AIE_CXXFLAGS += --Xpreproc=-DAIE_CORE_COL=16

########################## Kernel compiler global settings ##########################

VPP_FLAGS_pl_controller_top += --verbose
VPP_FLAGS_pl_controller_top += --hls.clock 250000000:pl_controller_top
VPP_FLAGS_sender_receiver += --verbose
VPP_FLAGS_sender_receiver += --hls.clock 250000000:sender_receiver
VPP_FLAGS +=  -I $(SRC_DIR)/pl_kernels -I $(XILINX_VITIS)/aietools/include
VPP_LDFLAGS +=  --config $(CUR_DIR)/system.cfg
VPP_LDFLAGS += --kernel_frequency 250

######################### binary container global settings ##########################

PL_CONT_XO_FILE = $(TEMP_DIR)/pl_controller_top.xo
SEND_REC_XO_FILE = $(TEMP_DIR)/sender_receiver.xo
BINARY_CONTAINER_OBJS += $(PL_CONT_XO_FILE)
BINARY_CONTAINER_OBJS += $(SEND_REC_XO_FILE)
BINARY_CONTAINER_DEPS += $(BINARY_CONTAINER_OBJS)
BINARY_CONTAINER_DEPS += $(AIE_CONTAINER)
BINARY_CONTAINER = $(TEMP_DIR)/link/int/pl_controller_aie.xclbin
XSA_FILE = pl_controller_aie.xsa
XCLBIN_FILE = $(CURDIR)/pl_controller_aie.xclbin

############################## Setting Targets ##############################

.PHONY: all xclbin
all: xclbin $(DEB_FILE)

xclbin: $(XCLBIN_FILE)
$(XCLBIN_FILE): $(BINARY_CONTAINER)
	$(PYTHON) $(META_GEN) -config $(VIV_CONFIG) -pdi $(VIV_PDI) -o $(META_JSON)
	$(XUTIL) --input $(BINARY_CONTAINER) --add-section PARTITION_METADATA:JSON:$(META_JSON) --output $(XCLBIN_FILE)
	-@$(RM) $(BINARY_CONTAINER)

xclbin_cont: $(BINARY_CONTAINER)
$(BINARY_CONTAINER): $(XSA_FILE)
	${VPP} -p -t ${TARGET} -f ${PLATFORM} ${AIE_CONTAINER} --package.boot_mode=ospi --package.defer_aie_run -o $@ $^ 
$(XSA_FILE): $(BINARY_CONTAINER_OBJS) $(AIE_CONTAINER)
	$(VPP) -l $(VPP_FLAGS) -t $(TARGET) --platform $(PLATFORM) --temp_dir $(TEMP_DIR) --report_dir $(BUILD_REPORT_DIR) $(VPP_LDFLAGS) -o $@ $^

################ Setting Rules for Binary Containers (Building Kernels) ################
$(PL_CONT_XO_FILE): $(SRC_DIR)/pl_kernels/pl_controller_top.cpp
	$(ECHO) "Compiling Kernel: pl_controller_top"
	mkdir -p $(TEMP_DIR)
	$(VPP) -c $(VPP_FLAGS_pl_controller_top) $(VPP_FLAGS) -t $(TARGET) --platform $(PLATFORM) -k pl_controller_top -I'$(<D)' --temp_dir $(TEMP_DIR) --report_dir $(TEMP_REPORT_DIR) -o'$@' '$<'

$(SEND_REC_XO_FILE): $(SRC_DIR)/pl_kernels/sender_receiver.cpp
	$(ECHO) "Compiling Kernel: sender_receiver"
	mkdir -p $(TEMP_DIR)
	$(VPP) -c $(VPP_FLAGS_sender_receiver) $(VPP_FLAGS) -t $(TARGET) --platform $(PLATFORM) -k sender_receiver -I'$(<D)' --temp_dir $(TEMP_DIR) --report_dir $(TEMP_REPORT_DIR) -o'$@' '$<'

$(AIE_CONTAINER): $(SRC_DIR)/aie/graph.cpp
	$(ECHO) "Compiling: libadf.a"
	mkdir -p $(dir $@)
	$(AIECXX) $(AIE_CXXFLAGS) $^
	cp ./libadf.a $(AIE_CONTAINER)

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

.PHONY: help
help:
	@echo "Makefile Usage:"
	@echo "make all PLATFORM= <xpfm_file_location>"
	@echo "Command to build xclbin application"
	@echo ""
	@echo "make clean"
	@echo "Command to remove the generated files. "
	@echo ""


.PHONY: clean
clean:
	-$(RMDIR) *xclbin.run_summary pl*start_simulation. sh *.xclbin
	-$(RMDIR)  xo_* _x*
	-$(RMDIR) .Xil .ipcache .crashReporter
	-$(RMDIR) $(CUR_DIR)/libadf.a  *.csv *.log sol.db
	-$(RMDIR) .nfs* *.xsa *.ltx *.link_summary
	-$(RMDIR) $(CUR_DIR)/Work  $(CUR_DIR)/reports $(BUILD_DIR)
	-$(RMDIR) $(BUILD_DIR) $(DEB_FILE)
	-$(RMDIR) $(META_JSON) *data.txt

