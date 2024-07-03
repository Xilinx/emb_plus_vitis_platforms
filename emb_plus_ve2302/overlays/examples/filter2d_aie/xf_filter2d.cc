/**
* Copyright (C) 2024 Advanced Micro Devices, Inc.
* SPDX-License-Identifier: MIT
*/

//#include "imgproc/xf_yuy2_filter2d_aieml.hpp"
#include "xf_yuy2_filter2d_aieml.hpp"
#include "kernels.h"

void filter2D(adf::input_buffer<int16>& input, adf::output_buffer<int16>& output) {
    xf::cv::aie::yuy2_filter2D(input, output);
};
