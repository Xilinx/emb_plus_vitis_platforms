/*
* Copyright (C) 2025 Advanced Micro Devices, Inc.
* SPDX-License-Identifier: MIT
*/

#ifndef __GRAPH_H__
#define __GRAPH_H__

#include "config.h"
#include "kernels.h"
#include <adf.h>
extern int16_t y_buff[TILE_ELEMENTS / 2];
extern int16_t uv_buff[TILE_ELEMENTS / 2];
extern int16_t y_filtered_buff[TILE_ELEMENTS / 2];

using namespace adf;

class myGraph : public adf::graph {
   public:
    kernel k1;
    input_plio inptr;
    output_plio outptr;
    input_plio kernelCoefficients;

    myGraph() {
        k1 = kernel::create(yuy2_filter2D);

        inptr = input_plio::create("DataIn1", adf::plio_128_bits, "data/input_128x16.txt");
        kernelCoefficients = input_plio::create("DataIn2", adf::plio_128_bits, "data/input_128x16.txt");
        outptr = output_plio::create("DataOut1", adf::plio_128_bits, "data/output.txt");

        adf::connect<>(inptr.out[0], k1.in[0]);
        adf::connect<>(kernelCoefficients.out[0], k1.in[1]);
        adf::connect<>(k1.out[0], outptr.in[0]);

        adf::dimensions(k1.in[0]) = {ELEM_WITH_METADATA};
        adf::dimensions(k1.in[1]) = {COEFF_DATA};
        adf::dimensions(k1.out[0]) = {ELEM_WITH_METADATA};

        source(k1) = "xf_yuy2_filter2d.cc";

        auto y_buff1 = parameter::array(y_buff);
        auto uv_buff1 = parameter::array(uv_buff);
        auto y_filtered_buff1 = parameter::array(y_filtered_buff);
        connect<>(y_buff1, k1);
        connect<>(uv_buff1, k1);
        connect<>(y_filtered_buff1, k1);
        location<kernel>(k1) = tile(15, 0);

        // Initial mapping
        runtime<ratio>(k1) = 0.5;
    };
};

#endif
