## Platform README

The Makefile in this folder creates a RAVE Vitis platform.

### Create a Vitis Extensible Platform:

To create the Vitis platform, run the following command:

```
make platform PLATFORM=<platform_name> [SILICON=<es1,prod>]
```
Options for platform_name are
   - ve2302_pcie_qdma

Default option for SILICON is Production (prod).

The Makefile uses the XSA from the vivado project to generate a platform.
The generated platform will be located at:

```
./xilinx_<platform_name>_<version_num>
```

The xpfm file in the above directory  will be used as input
when building the Vitis accelerator projects. It exposes all
the essential Platform Interfaces like Clock, Interrupts, Master
AXI interfaces and Slave AXI interfaces for the accelerator to
connect to.

Note: The software components (boot, smp_linux etc) in this platform
      are empty. The software components will be generated later.

Copyright (C) 2023, Advanced Micro Devices, Inc.\
SPDX-License-Identifier: MIT

