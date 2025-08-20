/*
* Copyright (C) 2025 Advanced Micro Devices, Inc.
* SPDX-License-Identifier: MIT
*/

#include "xf_yuy2_filter2d_aieml_strm_coeff.hpp"
#include "kernels.h"

void yuy2_filter2D(adf::input_buffer<int16>& input, adf::input_buffer<int16> &coeff, adf::output_buffer<int16>& output) {
    xf::cv::aie::yuy2_filter2D(input, coeff, output);
};
