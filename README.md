
# Embedded+ HW/PL platform repository.

## Introduction
This repo is used to capture Vivado XSA generation of the Embedded+ HW/PL platform & Reconfigurable Modules (RMs).
The emb_plus_ve2302 hw_platform targets the ve2302 FPGA.

## Instructions

This repo contains submodules. To clone this repo, run:
```
git clone --recursive https://github.com/Xilinx/emb_plus_vitis_platforms.git
```

## Contents

This repo contains a DFX platform and multiple overlays.

Platforms list:
- ve2302_pcie_qdma

Overlays list:
- bandwidth_test
- filter2d_aie\*
- filter2d_pl
- validate_aie2_pl
- verify_test

\* These overlays are untested in hardware.  Testing will happen in the next release.

## Tools Version

This branch is targeting the Vivado and Vitis 2024.2 tools version. Note that
not all platforms and overlays may be validated with this tools version. Consult
the application specific documentation for the latest validated version.

## Tool Flow

At a high-level, the builds steps are as follows:

1. AMD Vivado™ platform design: The Vivado design is augmented with platform parameters that describe the meta data and physical interfaces available to the AMD Vitis™ compiler for stitching in programmable logic (PL) or artificial intelligence engine (AIE) kernels.

2. Platform creation: The software command-line tool (XSCT) utility is used to create an extensible platform whose main component is the XSA created by Vivado in step 1.

3. PL kernels: The Vitis compiler is used to compile PL accelerator kernels from C/C++ using high-level synthesis (HLS) or to package register transfer level (RTL) kernels. The kernels are compiled into xo files and consumed by the Vitis linker in the next step.

4. AIE kernels: The Vitis compiler is used to compile AIE accelerator kernels from C/C++ into a libadf.a file and consumed by Vitis.

5. Vitis linker and packager: The Vitis linker integrates the PL kernels into the platform and implements the design. The packager combines the PL and the AIE portions.  It generates a new device image (bitfile) as well as xclbin file containing meta data information about the PL and/or AIE kernels.

    NOTE: Adding PL and/or AIE kernels to a platform is optional. If the system design needs certain acceleration or processing functions, then this build step is needed.

## Directory Structure

The directory structure of the repository is shown as follows:
```
emb_plus_vitis_platforms
+-- common
¦ +-- Vitis_Libraries
+-- emb_plus_ve2302
¦ +-- Makefile
¦ +-- overlays
¦ ¦  +-- examples
¦ ¦  ¦   +-- bandwidth_test
¦ ¦  ¦   +-- filter2d_aie
¦ ¦  ¦   +-- filter2d_pl
¦ ¦  ¦   +-- validate_aie2_pl
¦ ¦  ¦   +-- verify_test
¦ ¦  +-- README
¦ +-- platforms
¦ ¦  +-- Makefile
¦ ¦  +-- README
¦ ¦  +-- scripts
¦ ¦  +-- vivado
¦ ¦  ¦   +-- ve2302_pcie_qdma
¦ +-- Makefile
+-- README
```
## Build Instructions

### UUID information

A platform and its corresponding overlay have a parent-child
relationship. To load an overlay, the AMD ACAP must first be loaded
with its platform (via the PDI file in OSPI). The overlay must be
generated using the exact same platform with which it will be loaded.
If not, the UUID (Universally Unique Identifier) between the platform
and overlay will not match. Currently, there is an issue where
different builds of a platform from the same source  may have differing
NOC configuration, even though the UUID is the same. This can lead to
incompatibility if the overlay is built against a different instance of
the platform, despite matching UUIDs. Therefore, the platform loaded
must be the exact version against which the overlay was generated to
ensure compatibility.

### Generating Platform and Overlay from Source

To create the Vitis platform, run the following command from the ```emb_plus_ve2302/``` folder

```
make platform PFM=<platform_name> [SILICON=<es1,prod>]
```

The default silicon version is Production.  Valid platforms are listed under Contents above.

The Makefile uses the XSA from the vivado project to generate a platform.
The generated platform will be located at:

```
./platforms/xilinx_<platform_name>_<version_num>
```

The xpfm file in the above directory  will be used as input
when building the Vitis accelerator projects. It exposes all
the essential Platform Interfaces like Clock, Interrupts, Master
AXI interfaces and Slave AXI interfaces for the accelerator to
connect to.

To create the platform and overlay, run the following command:

```
make platform PFM=<platform_name> [SILICON=<es1,prod>] overlay OVERLAY=<overlay_name>
```

The default for SILICON is Production (prod).  Valid platforms and overlays are listed under Contents above.

### Generating Overlay from Released Platform

If users are working with released artifacts and do not wish to update
the OSPI PDI file containing the released platform, they can generate
overlays against pre-built platforms. The pre-built platforms for each
release are available in the [released section](https://github.com/Xilinx/emb_plus_vitis_platforms/releases).
Look for the "xilinx_ve2302_pcie_qdma_*.tar.gz" tarballs.

**_NOTE:_** : the current V0.5 and V0.6 releases has identical
platforms. Therefore for both V0.6 and V0.5 prebuilt platform, look for
xilinx_ve2302_pcie_qdma_*.tar.gz tar ball under V0.5 release.

To use these platforms:

1. Download the appropriate tarball.
2. Uncompress the tarball.
3. Copy the contents to the emb_plus_ve2302/platforms folder.
4. Run the makefile to generate the overlay.

The makefile output will indicate that there is no further action required for
the platform if everything is in order.

The following are the commands:

```
tar -xf xilinx_ve2302_pcie_qdma_<*>.tar.gz
cp xilinx_ve2302_pcie_qdma_202320_1/ emb_plus_vitis_platforms/emb_plus_ve2302/platforms/ -rf
cd emb_plus_vitis_platforms/emb_plus_ve2302/
make overlay OVERLAY=<overlay_name>
```


## License

(C) Copyright 2023 - 2024, Advanced Micro Devices Inc.\
SPDX-License-Identifier: MIT

