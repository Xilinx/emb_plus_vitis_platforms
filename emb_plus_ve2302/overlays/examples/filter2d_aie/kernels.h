/**
* Copyright (C) 2024 Advanced Micro Devices, Inc.
* SPDX-License-Identifier: MIT
*/

#ifndef _KERNELS_H_
#define _KERNELS_H_

#include <adf/window/types.h>
#include <adf/stream/types.h>
#include "adf.h"

// SRS shift used can be increased if input data likewise adjusted) // should be same as one in xf_yuy2_filter2d.hpp
#define SRS_SHIFT 10

void filter2D(adf::input_buffer<int16>& input, adf::output_buffer<int16>& output);

#endif
