/**
* Copyright (C) 2023 Advanced Micro Devices, Inc.
* SPDX-License-Identifier: MIT
*/
#include <adf.h>
#include "aie/kernels/include.h"
#include "kernels.h"

using namespace adf;

class simpleGraph : public graph {
   private:
    kernel first;
    pktcontrol ctrl_first;

   public:
    input_port in0;
    output_port out0;
    input_port ctrl_in;

    simpleGraph() {
        first = kernel::create(simple);
        source(first) = "aie/kernels/kernels.cc";
        runtime<ratio>(first) = 0.9;

        ctrl_first = pktcontrol::create(); // true => Response port also

        // plctrl = kernel::create(pl_controller);
        // source(plctrl) = "aie/kernels/pl_controller.cpp";
        // fabric<pl>(plctrl);

        // Kernel connections
        connect<window<128> > n0(in0, first.in[0]);
        connect<window<128> > n1(first.out[0], out0);
        // Control connections
        connect<pktstream, pktstream> n3(ctrl_in, ctrl_first.in[0]);

        // Constrain AIE kernels to the same row, otherwise tiles may be flipped.
        // Constrain buffers such that addressmap is identical.
        location<kernel>(first) = tile(AIE_CORE_COL, AIE_CORE_ROW);
        location<buffer>(first.in[0]) = {address(AIE_CORE_COL, AIE_CORE_ROW, 0x100),
                                         address(AIE_CORE_COL, AIE_CORE_ROW, 0x4100)}; // {0,16} KB
        location<buffer>(first.out[0]) = {address(AIE_CORE_COL, AIE_CORE_ROW, 0x400),
                                          address(AIE_CORE_COL, AIE_CORE_ROW, 0x4400)}; // {1,17} KB
        location<stack>(first) = location<kernel>(first);

        location<interconnect>(ctrl_first) = location<kernel>(first);
    }
};
